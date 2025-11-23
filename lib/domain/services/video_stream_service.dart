import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/ble_constants.dart';

/// Represents a single video frame received from the device
class VideoFrame {
  final int frameNumber;
  final Uint8List jpegData;
  final DateTime timestamp;

  VideoFrame({
    required this.frameNumber,
    required this.jpegData,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  int get sizeInBytes => jpegData.length;
}

/// Video stream state
enum VideoStreamState {
  idle,
  starting,
  streaming,
  stopping,
  error,
}

/// Service for receiving video stream over BLE from CyberGlass device
class VideoStreamService {
  final BluetoothDevice _device;

  // Characteristics
  BluetoothCharacteristic? _imageInfoChar;
  BluetoothCharacteristic? _imageControlChar;
  final List<BluetoothCharacteristic> _dataChannels = [];

  // Stream controllers
  final _frameController = StreamController<VideoFrame>.broadcast();
  final _stateController = StreamController<VideoStreamState>.broadcast();
  final _fpsController = StreamController<double>.broadcast();

  // Current frame assembly
  final Map<int, Uint8List> _currentChunks = {};
  int _expectedChunks = 0;
  int _currentFrameNumber = 0;

  // State tracking
  VideoStreamState _state = VideoStreamState.idle;
  bool _isSubscribed = false;

  // FPS calculation
  int _frameCount = 0;
  DateTime? _streamStartTime;
  DateTime? _lastFrameTime;

  // Subscription management
  final List<StreamSubscription> _subscriptions = [];

  VideoStreamService(this._device);

  /// Stream of received video frames
  Stream<VideoFrame> get frameStream => _frameController.stream;

  /// Stream of video stream state changes
  Stream<VideoStreamState> get stateStream => _stateController.stream;

  /// Stream of current FPS
  Stream<double> get fpsStream => _fpsController.stream;

  /// Current state
  VideoStreamState get state => _state;

  /// Whether currently streaming
  bool get isStreaming => _state == VideoStreamState.streaming;

  /// Initialize the service by discovering characteristics
  Future<void> initialize() async {
    try {
      // Discover services
      final services = await _device.discoverServices();

      // Find control service
      final controlService = services.firstWhere(
        (s) => s.uuid.toString().toLowerCase() == BleConstants.imageServiceUuid.toLowerCase(),
        orElse: () => throw Exception('Control service not found'),
      );

      // Get control characteristics
      _imageInfoChar = controlService.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase() == BleConstants.charImageInfoUuid.toLowerCase(),
        orElse: () => throw Exception('Image Info characteristic not found'),
      );

      _imageControlChar = controlService.characteristics.firstWhere(
        (c) => c.uuid.toString().toLowerCase() == BleConstants.charImageControlUuid.toLowerCase(),
        orElse: () => throw Exception('Image Control characteristic not found'),
      );

      // Find data services and get all 8 data channels
      for (final service in services) {
        final serviceUuid = service.uuid.toString().toLowerCase();
        if (serviceUuid == BleConstants.imageDataService1Uuid.toLowerCase() ||
            serviceUuid == BleConstants.imageDataService2Uuid.toLowerCase()) {
          for (final char in service.characteristics) {
            final charUuid = char.uuid.toString().toLowerCase();
            if (BleConstants.dataChannelUuids.any(
              (uuid) => uuid.toLowerCase() == charUuid,
            )) {
              _dataChannels.add(char);
            }
          }
        }
      }

      if (_dataChannels.length != 8) {
        print('Warning: Expected 8 data channels, found ${_dataChannels.length}');
      }

      print('VideoStreamService initialized with ${_dataChannels.length} data channels');
    } catch (e) {
      print('Failed to initialize VideoStreamService: $e');
      rethrow;
    }
  }

  /// Subscribe to all notifications
  Future<void> _subscribeToNotifications() async {
    if (_isSubscribed) return;

    // Subscribe to image info notifications
    if (_imageInfoChar != null) {
      await _imageInfoChar!.setNotifyValue(true);
      _subscriptions.add(
        _imageInfoChar!.onValueReceived.listen(_handleImageInfoNotification),
      );
    }

    // Subscribe to all data channels
    for (final channel in _dataChannels) {
      await channel.setNotifyValue(true);
      _subscriptions.add(
        channel.onValueReceived.listen(_handleDataNotification),
      );
    }

    _isSubscribed = true;
    print('Subscribed to all BLE notifications');
  }

  /// Unsubscribe from all notifications
  Future<void> _unsubscribeFromNotifications() async {
    // Cancel all subscriptions
    for (final sub in _subscriptions) {
      await sub.cancel();
    }
    _subscriptions.clear();

    // Disable notifications
    if (_imageInfoChar != null) {
      try {
        await _imageInfoChar!.setNotifyValue(false);
      } catch (_) {}
    }

    for (final channel in _dataChannels) {
      try {
        await channel.setNotifyValue(false);
      } catch (_) {}
    }

    _isSubscribed = false;
  }

  /// Handle Image Info characteristic notifications
  void _handleImageInfoNotification(List<int> data) {
    if (data.isEmpty) return;

    final status = data[0];

    switch (status) {
      case BleConstants.statusVideoStreamActive:
        // Video stream started
        _updateState(VideoStreamState.streaming);
        _streamStartTime = DateTime.now();
        _frameCount = 0;
        print('Video stream active');
        break;

      case BleConstants.statusVideoFrameReady:
        // New frame ready - parse frame info
        if (data.length >= 7) {
          _currentFrameNumber = data[1] | (data[2] << 8) | (data[3] << 16) | (data[4] << 24);
          _expectedChunks = data[5] | (data[6] << 8);
          _currentChunks.clear();
          print('Frame $_currentFrameNumber ready, expecting $_expectedChunks chunks');
        }
        break;

      case BleConstants.statusIdle:
        // Stream stopped
        if (_state == VideoStreamState.streaming || _state == VideoStreamState.stopping) {
          _updateState(VideoStreamState.idle);
          print('Video stream stopped');
        }
        break;

      case BleConstants.statusError:
        _updateState(VideoStreamState.error);
        print('Video stream error');
        break;
    }
  }

  /// Handle data channel notifications
  void _handleDataNotification(List<int> data) {
    if (data.length < 3) return;

    // Parse chunk index (first 2 bytes, little endian)
    final chunkIndex = data[0] | (data[1] << 8);

    // Store chunk data (skip first 2 bytes which are the index)
    _currentChunks[chunkIndex] = Uint8List.fromList(data.sublist(2));

    // Check if we have all chunks
    if (_currentChunks.length == _expectedChunks && _expectedChunks > 0) {
      _assembleFrame();
    }
  }

  /// Assemble a complete frame from received chunks
  void _assembleFrame() {
    try {
      // Calculate total size
      int totalSize = 0;
      for (int i = 0; i < _expectedChunks; i++) {
        if (_currentChunks.containsKey(i)) {
          totalSize += _currentChunks[i]!.length;
        } else {
          print('Missing chunk $i, cannot assemble frame');
          return;
        }
      }

      // Combine all chunks in order
      final frameData = Uint8List(totalSize);
      int offset = 0;
      for (int i = 0; i < _expectedChunks; i++) {
        final chunk = _currentChunks[i]!;
        frameData.setRange(offset, offset + chunk.length, chunk);
        offset += chunk.length;
      }

      // Create and emit frame
      final frame = VideoFrame(
        frameNumber: _currentFrameNumber,
        jpegData: frameData,
      );

      _frameController.add(frame);
      _frameCount++;

      // Calculate and emit FPS
      _lastFrameTime = DateTime.now();
      if (_streamStartTime != null) {
        final elapsed = _lastFrameTime!.difference(_streamStartTime!).inMilliseconds;
        if (elapsed > 0) {
          final fps = (_frameCount * 1000) / elapsed;
          _fpsController.add(fps);
        }
      }

      print('Frame $_currentFrameNumber assembled: ${frameData.length} bytes');

      // Clear chunks for next frame
      _currentChunks.clear();
      _expectedChunks = 0;
    } catch (e) {
      print('Error assembling frame: $e');
    }
  }

  /// Start video stream with specified resolution and quality
  ///
  /// [resolution] - Resolution index (0-7), see BleConstants.resolution*
  /// [quality] - JPEG quality (10-63), lower = better quality but larger file
  Future<void> startStream({
    int resolution = BleConstants.defaultResolution,
    int quality = BleConstants.defaultQuality,
  }) async {
    if (_imageControlChar == null) {
      throw Exception('Service not initialized. Call initialize() first.');
    }

    if (_state == VideoStreamState.streaming) {
      print('Already streaming');
      return;
    }

    try {
      _updateState(VideoStreamState.starting);

      // Subscribe to notifications first
      await _subscribeToNotifications();

      // Send start command: [3, resolution, quality]
      final command = Uint8List.fromList([
        BleConstants.cmdStartVideoStream,
        resolution,
        quality,
      ]);

      await _imageControlChar!.write(command, withoutResponse: false);
      print('Start stream command sent: resolution=$resolution, quality=$quality');

    } catch (e) {
      _updateState(VideoStreamState.error);
      print('Failed to start stream: $e');
      rethrow;
    }
  }

  /// Stop video stream
  Future<void> stopStream() async {
    if (_imageControlChar == null) return;

    if (_state != VideoStreamState.streaming && _state != VideoStreamState.starting) {
      print('Not currently streaming');
      return;
    }

    try {
      _updateState(VideoStreamState.stopping);

      // Send stop command: [4]
      final command = Uint8List.fromList([BleConstants.cmdStopVideoStream]);
      await _imageControlChar!.write(command, withoutResponse: false);

      print('Stop stream command sent');

      // Wait a bit then unsubscribe
      await Future.delayed(const Duration(milliseconds: 500));
      await _unsubscribeFromNotifications();

      _updateState(VideoStreamState.idle);

      // Print stats
      if (_streamStartTime != null && _frameCount > 0) {
        final elapsed = DateTime.now().difference(_streamStartTime!).inSeconds;
        print('Stream stats: $_frameCount frames in ${elapsed}s (${(_frameCount / elapsed).toStringAsFixed(1)} FPS)');
      }

    } catch (e) {
      print('Failed to stop stream: $e');
      _updateState(VideoStreamState.error);
    }
  }

  /// Cancel any ongoing transfer
  Future<void> cancelTransfer() async {
    if (_imageControlChar == null) return;

    try {
      final command = Uint8List.fromList([BleConstants.cmdCancelTransfer]);
      await _imageControlChar!.write(command, withoutResponse: false);

      _currentChunks.clear();
      _expectedChunks = 0;

      print('Transfer cancelled');
    } catch (e) {
      print('Failed to cancel transfer: $e');
    }
  }

  /// Update state and notify listeners
  void _updateState(VideoStreamState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Clean up resources
  Future<void> dispose() async {
    await stopStream();
    await _unsubscribeFromNotifications();

    await _frameController.close();
    await _stateController.close();
    await _fpsController.close();
  }
}
