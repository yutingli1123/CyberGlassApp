import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/glass_device.dart';
import '../../domain/services/bluetooth_service.dart';
import '../../domain/services/storage_service.dart';
import '../providers/services_provider.dart';

part 'connection_viewmodel.freezed.dart';

/// Connection screen state
@freezed
class ConnectionViewState with _$ConnectionViewState {
  const factory ConnectionViewState({
    @Default([]) List<ScanResult> scannedDevices,
    @Default(false) bool isScanning,
    @Default(false) bool isConnecting,
    @Default(false) bool isConnected,
    @Default(false) bool isRequestingPermission,
    String? error,
    String? statusMessage,
  }) = _ConnectionViewState;
}

/// ConnectionViewModel manages device scanning and auto-connection
class ConnectionViewModel extends StateNotifier<ConnectionViewState> {
  ConnectionViewModel(this._bluetoothService, this._storageService)
      : super(const ConnectionViewState());

  final BleService _bluetoothService;
  final StorageService _storageService;
  StreamSubscription? _scanSubscription;

  /// Initialize: wait for Bluetooth and start scanning
  Future<void> initialize() async {
    // Wait for Bluetooth adapter to be ready
    // Permissions will be requested automatically when scanning starts on both platforms
    await _waitForBluetoothReady();

    // Check if there's a saved device
    final savedDevice = await _storageService.getSavedDevice();

    if (savedDevice != null) {
      // Try to reconnect to saved device
      await _tryReconnectSavedDevice(savedDevice);
    } else {
      // No saved device, start scanning for new devices
      await startScanningAndAutoConnect();
    }
  }

  /// Try to reconnect to previously saved device
  Future<void> _tryReconnectSavedDevice(GlassDevice savedDevice) async {
    print('[ConnectionViewModel] Found saved device: ${savedDevice.name} (${savedDevice.macAddress})');
    print('[ConnectionViewModel] Starting scan to find saved device...');

    state = state.copyWith(
      isScanning: true,
      statusMessage: 'Looking for ${savedDevice.name}...',
    );

    try {
      // Start scanning
      _scanSubscription?.cancel();
      _scanSubscription = _bluetoothService.scanForDevices().listen(
        (devices) {
          print('[ConnectionViewModel] Found ${devices.length} CyberGlass devices');

          // Look for the saved device
          final targetDevice = devices.firstWhere(
            (result) => result.device.remoteId.str == savedDevice.macAddress,
            orElse: () => throw Exception('Saved device not found in scan results'),
          );

          print('[ConnectionViewModel] Found saved device, connecting...');
          _autoConnectToDevice(targetDevice.device);
        },
        onError: (error) {
          print('[ConnectionViewModel] Scan error: $error');
          _retrySavedDeviceScan();
        },
      );

      // Set a timeout for finding the saved device
      await Future.delayed(const Duration(seconds: 10));

      // If still scanning after 10 seconds, device not found - show error but keep scanning
      if (state.isScanning && !state.isConnecting && !state.isConnected) {
        state = state.copyWith(
          error: 'Cannot find ${savedDevice.name}. The device may be turned off or out of range.',
        );
        print('[ConnectionViewModel] Saved device not found after timeout, but continuing to scan...');
        // Keep scanning, don't stop
      }
    } catch (e) {
      print('[ConnectionViewModel] Reconnection failed: $e');
      state = state.copyWith(
        error: 'Failed to reconnect to ${savedDevice.name}',
      );
      // Don't stop scanning, retry
      _retrySavedDeviceScan();
    }
  }

  /// Clear error and start scanning for new devices
  Future<void> scanForNewDevice() async {
    print('[ConnectionViewModel] User requested to scan for new device');

    // Clear saved device
    await _storageService.clearDevice();

    // Clear error and start scanning
    state = state.copyWith(error: null);
    await startScanningAndAutoConnect();
  }

  /// Wait for Bluetooth adapter to be ready
  Future<void> _waitForBluetoothReady() async {
    print('[ConnectionViewModel] Waiting for Bluetooth to be ready...');

    // Wait up to 5 seconds for Bluetooth to be ready
    for (int i = 0; i < 10; i++) {
      try {
        final adapterState = await FlutterBluePlus.adapterState.first;
        print('[ConnectionViewModel] Bluetooth state: $adapterState');

        if (adapterState == BluetoothAdapterState.on) {
          print('[ConnectionViewModel] Bluetooth is ready!');
          return;
        }

        if (adapterState == BluetoothAdapterState.off) {
          state = state.copyWith(
            error: 'Please turn on Bluetooth',
          );
          return;
        }

        if (adapterState == BluetoothAdapterState.unauthorized) {
          state = state.copyWith(
            error: 'Bluetooth permission denied',
          );
          return;
        }
      } catch (e) {
        print('[ConnectionViewModel] Error checking Bluetooth state: $e');
      }

      // Wait 500ms before checking again
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print('[ConnectionViewModel] Bluetooth state check timed out, attempting to scan anyway...');
  }

  /// Start scanning and auto-connect to first CyberGlass device found
  Future<void> startScanningAndAutoConnect() async {
    print('[ConnectionViewModel] Starting scan...');
    state = state.copyWith(
      isScanning: true,
      error: null,
      statusMessage: 'Scanning for devices...',
    );

    try {
      _scanSubscription?.cancel();
      _scanSubscription = _bluetoothService.scanForDevices().listen(
        (devices) {
          print('[ConnectionViewModel] Found ${devices.length} CyberGlass devices');
          state = state.copyWith(scannedDevices: devices);

          // Auto-connect to first device found
          if (devices.isNotEmpty && !state.isConnecting && !state.isConnected) {
            final firstDevice = devices.first.device;
            print('[ConnectionViewModel] Auto-connecting to: ${firstDevice.platformName}');
            _autoConnectToDevice(firstDevice);
          }
        },
        onError: (error) {
          print('[ConnectionViewModel] Scan error: $error');
          // Retry after delay
          _retryNewDeviceScan();
        },
        onDone: () {
          print('[ConnectionViewModel] Scan completed');
          state = state.copyWith(isScanning: false);
        },
      );
    } catch (e) {
      print('[ConnectionViewModel] Failed to start scan: $e');
      // Retry after delay
      _retryNewDeviceScan();
    }
  }

  /// Retry scanning for saved device after a delay
  Future<void> _retrySavedDeviceScan() async {
    print('[ConnectionViewModel] Retrying saved device scan in 2 seconds...');
    await Future.delayed(const Duration(seconds: 2));

    // Only retry if not already connecting or connected
    if (!state.isConnecting && !state.isConnected && state.error != null) {
      // Get saved device and try scanning again
      final savedDevice = await _storageService.getSavedDevice();
      if (savedDevice != null) {
        await _tryReconnectSavedDevice(savedDevice);
      }
    }
  }

  /// Retry scanning for new device after a delay
  Future<void> _retryNewDeviceScan() async {
    print('[ConnectionViewModel] Retrying new device scan in 2 seconds...');
    await Future.delayed(const Duration(seconds: 2));

    // Only retry if not already connecting or connected
    if (!state.isConnecting && !state.isConnected) {
      await startScanningAndAutoConnect();
    }
  }

  /// Auto-connect to a device and save it
  Future<void> _autoConnectToDevice(BluetoothDevice device) async {
    print('[ConnectionViewModel] Setting state to connecting...');
    state = state.copyWith(
      isConnecting: true,
      isScanning: false, // Stop scanning state immediately
      error: null,
    );

    try {
      // Stop scanning first
      print('[ConnectionViewModel] Stopping scan...');
      await stopScanning();

      // Connect to device
      print('[ConnectionViewModel] Connecting to device...');
      await _bluetoothService.connect(device);

      // Save device to storage
      final glassDevice = GlassDevice(
        name: device.platformName,
        macAddress: device.remoteId.str,
        lastConnected: DateTime.now(),
      );
      print('[ConnectionViewModel] Saving device to storage...');
      await _storageService.saveDevice(glassDevice);

      print('[ConnectionViewModel] Connection successful!');
      state = state.copyWith(isConnecting: false, isConnected: true);
    } catch (e) {
      print('[ConnectionViewModel] Connection failed: $e');
      state = state.copyWith(
        isConnecting: false,
        error: 'Connection failed: $e',
      );
      // Resume scanning on failure
      print('[ConnectionViewModel] Resuming scan after failure...');
      startScanningAndAutoConnect();
    }
  }

  /// Stop scanning
  Future<void> stopScanning() async {
    await _scanSubscription?.cancel();
    await _bluetoothService.stopScan();
    state = state.copyWith(isScanning: false);
  }

  /// Connect to a specific device
  Future<void> connectToDevice(BluetoothDevice device) async {
    state = state.copyWith(isConnecting: true, error: null);

    try {
      // Stop scanning first
      await stopScanning();

      // Connect to device
      await _bluetoothService.connect(device);

      state = state.copyWith(isConnecting: false);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: 'Connection failed: $e',
      );
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}

/// Provider for ConnectionViewModel
final connectionViewModelProvider =
    StateNotifierProvider<ConnectionViewModel, ConnectionViewState>((ref) {
  final bluetoothService = ref.watch(bluetoothServiceProvider);
  final storageService = ref.watch(storageServiceProvider);
  return ConnectionViewModel(bluetoothService, storageService);
});