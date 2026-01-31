import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../data/models/glass_device.dart';
import '../../domain/services/bluetooth_service.dart';
import '../../domain/services/storage_service.dart';
import '../../domain/services/gemini_live_service.dart';
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
    // Gemini Live API state
    @Default(false) bool isGeminiConnecting,
    @Default(false) bool isGeminiConnected,
    @Default(false) bool isGeminiStreaming,
    @Default(false) bool isListening, // User is speaking (microphone active)
    @Default(false) bool isSpeaking, // Gemini is speaking (audio playback)
    @Default(false) bool isPaused, // Audio stream is paused by user
    @Default(false) bool isProcessing, // Gemini is processing user input
    @Default(false)
    bool isProactiveMode, // LLM speaks periodically without user input
    // Video stream state
    @Default(false) bool isVideoStreaming,
    @Default(0) int frameCount,
    @Default(0.0) double currentFps,
    String? geminiStatus,
    String? error,
    String? statusMessage,
  }) = _ConnectionViewState;
}

/// ConnectionViewModel manages device scanning and auto-connection
class ConnectionViewModel extends StateNotifier<ConnectionViewState> {
  ConnectionViewModel(
    this._bluetoothService,
    this._storageService,
    this._geminiLiveService,
  ) : super(const ConnectionViewState()) {
    // Set up Gemini callbacks
    _setupGeminiCallbacks();
  }

  final BleService _bluetoothService;
  final StorageService _storageService;
  final GeminiLiveService _geminiLiveService;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _videoFrameSubscription;
  StreamSubscription? _videoFpsSubscription;
  int _framesSentToGemini = 0;

  /// Set up Gemini Live Service callbacks
  void _setupGeminiCallbacks() {
    _geminiLiveService.onStatusChanged = (status) {
      print('[GeminiLive] $status');
      state = state.copyWith(geminiStatus: status);
    };

    _geminiLiveService.onTextReceived = (text) {
      print('[GeminiLive] Text: $text');
    };

    _geminiLiveService.onInterrupted = () {
      print('[GeminiLive] User interrupted');
    };

    _geminiLiveService.onTurnComplete = () {
      print('[GeminiLive] Turn complete');
    };

    _geminiLiveService.onListeningStateChanged = (isListening) {
      print('[GeminiLive] Listening state changed: $isListening');
      state = state.copyWith(isListening: isListening);
    };

    _geminiLiveService.onSpeakingStateChanged = (isSpeaking) {
      print('[ConnectionViewModel] Speaking state changed: $isSpeaking');
      print(
        '[ConnectionViewModel] Current state before update - isSpeaking: ${state.isSpeaking}, isProcessing: ${state.isProcessing}, isListening: ${state.isListening}',
      );
      state = state.copyWith(
        isSpeaking: isSpeaking,
        // When Gemini starts speaking, exit processing state
        isProcessing: isSpeaking ? false : state.isProcessing,
      );
      print(
        '[ConnectionViewModel] State updated - isSpeaking: ${state.isSpeaking}, isProcessing: ${state.isProcessing}, isListening: ${state.isListening}',
      );
    };

    _geminiLiveService.onUserStoppedSpeaking = () {
      print('[GeminiLive] User stopped speaking - entering processing state');
      // Only enter processing if not paused and not already speaking
      if (!state.isPaused && !state.isSpeaking) {
        state = state.copyWith(isProcessing: true);
      }
    };

    _geminiLiveService.onProactiveModeChanged = (isProactive) {
      print('[GeminiLive] Proactive mode changed: $isProactive');
      state = state.copyWith(isProactiveMode: isProactive);
    };
  }

  /// Start Gemini Live session after BLE connection
  Future<void> _startGeminiSession() async {
    print('[ConnectionViewModel] Starting Gemini Live session...');
    state = state.copyWith(
      isGeminiConnecting: true,
      geminiStatus: 'Connecting to Gemini...',
    );

    try {
      // Connect to Gemini Live API
      final connected = await _geminiLiveService.connect();

      if (connected) {
        // Start audio streaming
        await _geminiLiveService.startAudioStream();

        state = state.copyWith(
          isGeminiConnecting: false,
          isGeminiConnected: true,
          isGeminiStreaming: true,
          geminiStatus: 'Gemini Live ready - start speaking!',
        );
        print('[ConnectionViewModel] Gemini Live session started successfully');
      } else {
        throw Exception('Failed to connect to Gemini Live API');
      }
    } catch (e) {
      print('[ConnectionViewModel] Gemini session failed: $e');
      state = state.copyWith(
        isGeminiConnecting: false,
        isGeminiConnected: false,
        isGeminiStreaming: false,
        geminiStatus: 'Gemini error: $e',
      );
    }
  }

  /// Stop Gemini Live session
  Future<void> stopGeminiSession() async {
    print('[ConnectionViewModel] Stopping Gemini Live session...');
    await _geminiLiveService.disconnect();
    state = state.copyWith(
      isGeminiConnected: false,
      isGeminiStreaming: false,
      geminiStatus: 'Gemini disconnected',
    );
  }

  /// Toggle audio streaming on/off
  Future<void> toggleAudioStream() async {
    // Only allow toggle if Gemini is connected
    if (!state.isGeminiConnected) {
      print('[ConnectionViewModel] Cannot toggle audio - Gemini not connected');
      return;
    }

    if (!state.isPaused) {
      // Currently active (Listening/Processing/Speaking) - pause
      print(
        '[ConnectionViewModel] Pausing audio stream (from ${state.isListening
            ? "Listening"
            : state.isProcessing
            ? "Processing"
            : "Speaking"})...',
      );

      // Update UI immediately for instant feedback - clear all active states
      state = state.copyWith(
        isPaused: true,
        isProcessing: false,
        geminiStatus: 'Audio paused - tap to resume',
      );

      // Pause without stopping audio devices (async to clear buffer)
      await _geminiLiveService.pauseAudioStream();
    } else {
      // Currently paused - resume audio stream
      print('[ConnectionViewModel] Resuming audio stream...');

      // Update UI immediately for instant feedback
      state = state.copyWith(
        isPaused: false,
        geminiStatus: 'Listening - tap to pause',
      );

      // Resume sending audio to WebSocket
      _geminiLiveService.resumeAudioStream();
    }
  }

  /// Send image to Gemini
  Future<void> sendImageToGemini(List<int> imageBytes) async {
    await _geminiLiveService.sendImage(Uint8List.fromList(imageBytes));
  }

  /// Toggle proactive speaking mode
  /// When enabled, LLM will periodically analyze the scene and speak
  void toggleProactiveMode({Duration? interval}) {
    if (!state.isGeminiConnected) {
      print(
        '[ConnectionViewModel] Cannot toggle proactive mode - Gemini not connected',
      );
      return;
    }

    if (_geminiLiveService.isProactiveMode) {
      print('[ConnectionViewModel] Stopping proactive mode...');
      _geminiLiveService.stopProactiveMode();
    } else {
      print('[ConnectionViewModel] Starting proactive mode...');
      _geminiLiveService.startProactiveMode(interval: interval);
    }
  }

  /// Set proactive mode interval
  void setProactiveInterval(Duration interval) {
    _geminiLiveService.setProactiveInterval(interval);
  }

  /// Get the Gemini Live Service instance
  GeminiLiveService get geminiService => _geminiLiveService;

  /// Start video streaming and forward frames to Gemini
  Future<void> _startVideoStreamWithGemini() async {
    print(
      '[ConnectionViewModel] Starting video stream with Gemini integration...',
    );

    try {
      // Start the video stream with optimized settings
      final frameStream = await _bluetoothService.startVideoStream();

      if (frameStream == null) {
        print('[ConnectionViewModel] Failed to start video stream');
        return;
      }

      state = state.copyWith(
        isVideoStreaming: true,
        statusMessage: 'Video streaming started',
      );

      // Subscribe to video frames and forward to Gemini
      _videoFrameSubscription = frameStream.listen((frame) async {
        _framesSentToGemini++;
        state = state.copyWith(frameCount: _framesSentToGemini);

        // Send frame to Gemini if connected
        if (_geminiLiveService.isConnected) {
          await _geminiLiveService.sendImage(frame.jpegData);
          print(
            '[ConnectionViewModel] Frame ${frame.frameNumber} sent to Gemini (${frame.sizeInBytes} bytes)',
          );
        }
      });

      // Subscribe to FPS updates
      final fpsStream = _bluetoothService.videoFpsStream;
      if (fpsStream != null) {
        _videoFpsSubscription = fpsStream.listen((fps) {
          state = state.copyWith(currentFps: fps);
        });
      }

      print(
        '[ConnectionViewModel] Video stream started with Gemini integration',
      );
    } catch (e) {
      print('[ConnectionViewModel] Failed to start video stream: $e');
      state = state.copyWith(
        isVideoStreaming: false,
        statusMessage: 'Video stream error: $e',
      );
    }
  }

  /// Stop video streaming
  Future<void> stopVideoStream() async {
    print('[ConnectionViewModel] Stopping video stream...');

    await _videoFrameSubscription?.cancel();
    _videoFrameSubscription = null;

    await _videoFpsSubscription?.cancel();
    _videoFpsSubscription = null;

    await _bluetoothService.stopVideoStream();

    state = state.copyWith(
      isVideoStreaming: false,
      currentFps: 0.0,
      statusMessage: 'Video stream stopped',
    );

    print(
      '[ConnectionViewModel] Video stream stopped. Total frames sent: $_framesSentToGemini',
    );
  }

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
    print(
      '[ConnectionViewModel] Found saved device: ${savedDevice.name} (${savedDevice.macAddress})',
    );
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
          print(
            '[ConnectionViewModel] Found ${devices.length} CyberGlass devices',
          );

          // Look for the saved device
          final targetDeviceIndex = devices.indexWhere(
            (result) => result.device.remoteId.str == savedDevice.macAddress,
          );

          // If found, connect to it
          if (targetDeviceIndex != -1) {
            print('[ConnectionViewModel] Found saved device, connecting...');
            _autoConnectToDevice(devices[targetDeviceIndex].device);
          }
          // Otherwise, keep scanning (don't throw, just wait for next scan result)
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
          error:
              'Cannot find ${savedDevice.name}. The device may be turned off or out of range.',
        );
        print(
          '[ConnectionViewModel] Saved device not found after timeout, but continuing to scan...',
        );
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
          state = state.copyWith(error: 'Please turn on Bluetooth');
          return;
        }

        if (adapterState == BluetoothAdapterState.unauthorized) {
          state = state.copyWith(error: 'Bluetooth permission denied');
          return;
        }
      } catch (e) {
        print('[ConnectionViewModel] Error checking Bluetooth state: $e');
      }

      // Wait 500ms before checking again
      await Future.delayed(const Duration(milliseconds: 500));
    }

    print(
      '[ConnectionViewModel] Bluetooth state check timed out, attempting to scan anyway...',
    );
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
          print(
            '[ConnectionViewModel] Found ${devices.length} CyberGlass devices',
          );
          state = state.copyWith(scannedDevices: devices);

          // Auto-connect to first device found
          if (devices.isNotEmpty && !state.isConnecting && !state.isConnected) {
            final firstDevice = devices.first.device;
            print(
              '[ConnectionViewModel] Auto-connecting to: ${firstDevice.platformName}',
            );
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

      // Automatically start Gemini Live session after BLE connection
      await _startGeminiSession();

      // Start video streaming with Gemini integration
      await _startVideoStreamWithGemini();

      // Automatically start proactive mode for periodic scene analysis
      print('[ConnectionViewModel] Starting proactive mode...');
      _geminiLiveService.startProactiveMode(
        interval: const Duration(seconds: 5),
      );
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
    _videoFrameSubscription?.cancel();
    _videoFpsSubscription?.cancel();
    _geminiLiveService.dispose();
    super.dispose();
  }
}

/// Provider for ConnectionViewModel
final connectionViewModelProvider =
    StateNotifierProvider<ConnectionViewModel, ConnectionViewState>((ref) {
      final bluetoothService = ref.watch(bluetoothServiceProvider);
      final storageService = ref.watch(storageServiceProvider);
      final geminiService = ref.watch(geminiLiveServiceProvider);
      return ConnectionViewModel(
        bluetoothService,
        storageService,
        geminiService,
      );
    });
