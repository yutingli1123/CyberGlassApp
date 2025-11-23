import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/ble_constants.dart';
import 'video_stream_service.dart';

/// Bluetooth service for managing CyberGlass device connection
class BleService {
  BluetoothDevice? _connectedDevice;
  VideoStreamService? _videoStreamService;

  // Connection state stream controller
  final _connectionStateController = StreamController<bool>.broadcast();

  /// Stream of connection state (true = connected, false = disconnected)
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  /// Check if currently connected to a device
  bool get isConnected => _connectedDevice != null;

  /// Get the currently connected device
  BluetoothDevice? get connectedDevice => _connectedDevice;

  /// Get the video stream service (available after connection)
  VideoStreamService? get videoStreamService => _videoStreamService;

  /// Scan for CyberGlass devices continuously until stopped
  /// Returns a stream of scan results filtered by device name prefix
  Stream<List<ScanResult>> scanForDevices() async* {
    // Start scanning without timeout (scan until manually stopped)
    await FlutterBluePlus.startScan();

    // Listen to scan results and filter CyberGlass devices
    await for (final results in FlutterBluePlus.scanResults) {
      final cyberGlassDevices = results.where((result) {
        return result.device.platformName.startsWith(AppConstants.deviceNamePrefix);
      }).toList();

      yield cyberGlassDevices;
    }
  }

  /// Stop scanning for devices
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  /// Connect to a specific device
  Future<void> connect(BluetoothDevice device) async {
    try {
      // Connect with timeout
      await device.connect(
        timeout: Duration(seconds: BleConstants.connectionTimeoutSeconds),
      );

      _connectedDevice = device;
      _connectionStateController.add(true);

      // Initialize video stream service
      _videoStreamService = VideoStreamService(device);
      await _videoStreamService!.initialize();

      // Listen to connection state changes
      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });
    } catch (e) {
      _connectionStateController.add(false);
      rethrow;
    }
  }

  /// Connect to a saved device by MAC address
  Future<void> connectToSaved(String macAddress) async {
    // Get list of connected devices
    final connectedDevices = FlutterBluePlus.connectedDevices;

    // Check if already connected
    final alreadyConnected = connectedDevices.firstWhere(
      (device) => device.remoteId.str == macAddress,
      orElse: () => throw Exception('Device not found in connected devices'),
    );

    await connect(alreadyConnected);
  }

  /// Disconnect from the current device
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _handleDisconnection();
    }
  }

  /// Handle disconnection event
  void _handleDisconnection() {
    _videoStreamService?.dispose();
    _videoStreamService = null;
    _connectedDevice = null;
    _connectionStateController.add(false);
  }

  /// Clean up resources
  void dispose() {
    _videoStreamService?.dispose();
    _connectionStateController.close();
    disconnect();
  }

  // ============ Video Stream Methods ============

  /// Start video stream with specified resolution and quality
  ///
  /// [resolution] - Resolution index (0-7), use BleConstants.resolution*
  /// [quality] - JPEG quality (10-63), lower = better quality
  ///
  /// Returns stream of VideoFrame objects
  Future<Stream<VideoFrame>?> startVideoStream({
    int resolution = BleConstants.defaultResolution,
    int quality = BleConstants.defaultQuality,
  }) async {
    if (_videoStreamService == null) {
      throw Exception('Not connected to a device');
    }

    await _videoStreamService!.startStream(
      resolution: resolution,
      quality: quality,
    );

    return _videoStreamService!.frameStream;
  }

  /// Stop video stream
  Future<void> stopVideoStream() async {
    await _videoStreamService?.stopStream();
  }

  /// Check if video is currently streaming
  bool get isVideoStreaming => _videoStreamService?.isStreaming ?? false;

  /// Get video stream state
  VideoStreamState? get videoStreamState => _videoStreamService?.state;

  /// Get FPS stream for monitoring performance
  Stream<double>? get videoFpsStream => _videoStreamService?.fpsStream;

  /// Get video state change stream
  Stream<VideoStreamState>? get videoStateStream => _videoStreamService?.stateStream;
}