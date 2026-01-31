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
enum VideoStreamState { idle, starting, streaming, stopping, error }

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

  // ACK/NACK tracking
  DateTime? _lastChunkTime;
  bool _frameAckSent = false;
  Timer? _timeoutCheckTimer;

  // Mode: if true, drop incomplete frames instead of requesting retransmission
  bool _dropIncompleteFrames = true;

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
        (s) =>
            s.uuid.toString().toLowerCase() ==
            BleConstants.imageServiceUuid.toLowerCase(),
        orElse: () => throw Exception('Control service not found'),
      );

      // Get control characteristics
      _imageInfoChar = controlService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() ==
            BleConstants.charImageInfoUuid.toLowerCase(),
        orElse: () => throw Exception('Image Info characteristic not found'),
      );

      _imageControlChar = controlService.characteristics.firstWhere(
        (c) =>
            c.uuid.toString().toLowerCase() ==
            BleConstants.charImageControlUuid.toLowerCase(),
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
        print(
          'Warning: Expected 8 data channels, found ${_dataChannels.length}',
        );
      }

      print(
        'VideoStreamService initialized with ${_dataChannels.length} data channels',
      );
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
          _currentFrameNumber =
              data[1] | (data[2] << 8) | (data[3] << 16) | (data[4] << 24);
          _expectedChunks = data[5] | (data[6] << 8);

          // Start new frame tracking
          _currentChunks.clear();
          _frameAckSent = false;
          _lastChunkTime = DateTime.now();
          _startTimeoutTimer();

          print(
            'Frame $_currentFrameNumber ready, expecting $_expectedChunks chunks',
          );
        }
        break;

      case BleConstants.statusIdle:
        // Stream stopped
        if (_state == VideoStreamState.streaming ||
            _state == VideoStreamState.stopping) {
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
    if (_expectedChunks == 0) return;

    _lastChunkTime = DateTime.now();

    // Parse chunk index (first 2 bytes, little endian)
    final chunkIndex = data[0] | (data[1] << 8);

    // Store chunk data (skip first 2 bytes which are the index)
    _currentChunks[chunkIndex] = Uint8List.fromList(data.sublist(2));

    // Check if frame is complete
    if (!_frameAckSent && _currentChunks.length == _expectedChunks) {
      _frameAckSent = true;
      _sendFrameAck();
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
        final elapsed = _lastFrameTime!
            .difference(_streamStartTime!)
            .inMilliseconds;
        if (elapsed > 0) {
          final fps = (_frameCount * 1000) / elapsed;
          _fpsController.add(fps);
        }
      }

      print('Frame $_currentFrameNumber assembled: ${frameData.length} bytes');

      // Send ACK to firmware to confirm frame received
      _sendFrameAck();

      // // Print average FPS every 10 frames
      // if (_frameCount % 10 == 0 && _streamStartTime != null) {
      //   final elapsed = DateTime.now().difference(_streamStartTime!).inSeconds;
      //   if (elapsed > 0) {
      //     final avgFps = _frameCount / elapsed;
      //     print(
      //       'Average FPS: ${avgFps.toStringAsFixed(2)} ($_frameCount frames in ${elapsed}s)',
      //     );
      //   }
      // }

      // Clear chunks for next frame
      _currentChunks.clear();
      _expectedChunks = 0;
    } catch (e) {
      print('Error assembling frame: $e');
    }
  }

  /// Send Frame ACK (Command 0x02) to firmware
  Future<void> _sendFrameAck() async {
    if (_imageControlChar == null) return;

    try {
      final command = Uint8List.fromList([BleConstants.cmdFrameAck]);
      await _imageControlChar!.write(command, withoutResponse: true);
    } catch (e) {
      print('Failed to send frame ACK: $e');
    }
  }

  /// Start periodic timeout check timer
  void _startTimeoutTimer() {
    _timeoutCheckTimer?.cancel();
    _timeoutCheckTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      _checkTimeout();
    });
  }

  /// Check for missing chunks and request retransmission
  void _checkTimeout() {
    if (!_isSubscribed || _frameAckSent || _expectedChunks == 0) {
      return;
    }

    final now = DateTime.now();
    if (_lastChunkTime != null &&
        now.difference(_lastChunkTime!).inMilliseconds > 150) {
      // Find missing chunks
      final missing = <int>[];
      for (int i = 0; i < _expectedChunks; i++) {
        if (!_currentChunks.containsKey(i)) {
          missing.add(i);
        }
      }

      if (missing.isNotEmpty) {
        if (_dropIncompleteFrames) {
          // Drop mode: Send ACK to tell firmware to move on, discard this frame
          print(
            'Frame $_currentFrameNumber incomplete (${_currentChunks.length}/$_expectedChunks), dropping and sending ACK',
          );
          _frameAckSent = true;
          _sendFrameAck();
          _currentChunks.clear();
          _expectedChunks = 0;
        } else {
          // Retransmit mode: Request missing chunks via NACK
          _lastChunkTime = now;
          _sendNack(missing);
        }
      }
    }
  }

  /// Send NACK for missing chunks
  Future<void> _sendNack(List<int> missingChunks) async {
    if (_imageControlChar == null) return;

    const maxChunksPerReq = 8;

    for (int i = 0; i < missingChunks.length; i += maxChunksPerReq) {
      final batch = missingChunks.skip(i).take(maxChunksPerReq).toList();

      final command = BytesBuilder();
      command.addByte(BleConstants.cmdRetransmitChunks); // 1
      command.addByte(batch.length & 0xFF);
      command.addByte((batch.length >> 8) & 0xFF);

      for (final idx in batch) {
        command.addByte(idx & 0xFF);
        command.addByte((idx >> 8) & 0xFF);
      }

      try {
        await _imageControlChar!.write(
          command.toBytes(),
          withoutResponse: true,
        );
        print('Sent NACK for ${batch.length} chunks');
      } catch (e) {
        print('Failed to send NACK: $e');
      }

      // Small delay between batches
      if (i + maxChunksPerReq < missingChunks.length) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
    }
  }

  /// Start video stream with specified resolution, quality, fps, and chunk delay
  ///
  /// [resolution] - Resolution index (0-7), see BleConstants.resolution*
  /// [quality] - JPEG quality (10-63), lower = better quality but larger file
  /// [fps] - Target frame rate (1-10), actual may be lower due to BLE bandwidth
  /// [chunkDelay] - Optional delay between chunk batches (0-255ms), null to use device default
  Future<void> startStream({
    int resolution = BleConstants.defaultResolution,
    int quality = BleConstants.defaultQuality,
    int fps = BleConstants.defaultFps,
    int? chunkDelay = BleConstants.defaultChunkDelay,
  }) async {
    if (_imageControlChar == null) {
      throw Exception('Service not initialized. Call initialize() first.');
    }

    if (_state == VideoStreamState.streaming) {
      print('Already streaming');
      return;
    }

    // Validate parameters
    final clampedFps = fps.clamp(1, BleConstants.maxFps);
    final clampedQuality = quality.clamp(10, 63);
    final clampedResolution = resolution.clamp(0, 7);

    try {
      _updateState(VideoStreamState.starting);

      // Subscribe to notifications first
      await _subscribeToNotifications();

      // Send start command: [3, resolution, quality, fps] or [3, resolution, quality, fps, chunk_delay]
      final List<int> commandList = [
        BleConstants.cmdStartVideoStream,
        clampedResolution,
        clampedQuality,
        clampedFps,
      ];

      // Add optional chunk delay (5th byte)
      if (chunkDelay != null) {
        commandList.add(chunkDelay.clamp(0, 255));
      }

      final command = Uint8List.fromList(commandList);

      await _imageControlChar!.write(command, withoutResponse: false);
      print(
        'Start stream command sent: resolution=$clampedResolution, quality=$clampedQuality, fps=$clampedFps${chunkDelay != null ? ', chunkDelay=$chunkDelay' : ''}',
      );
    } catch (e) {
      _updateState(VideoStreamState.error);
      print('Failed to start stream: $e');
      rethrow;
    }
  }

  /// Stop video stream
  Future<void> stopStream() async {
    if (_imageControlChar == null) return;

    if (_state != VideoStreamState.streaming &&
        _state != VideoStreamState.starting) {
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

      _timeoutCheckTimer?.cancel();

      _updateState(VideoStreamState.idle);

      // Print stats
      if (_streamStartTime != null && _frameCount > 0) {
        final elapsed = DateTime.now().difference(_streamStartTime!).inSeconds;
        print(
          'Stream stats: $_frameCount frames in ${elapsed}s (${(_frameCount / elapsed).toStringAsFixed(1)} FPS)',
        );
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

  /// Set frame drop mode
  /// If true: drop incomplete frames and send ACK
  /// If false: request retransmission via NACK
  void setDropIncompleteFrames(bool drop) {
    _dropIncompleteFrames = drop;
    print(
      'Frame handling mode: ${drop ? "DROP incomplete frames" : "RETRANSMIT via NACK"}',
    );
  }

  /// Clean up resources
  Future<void> dispose() async {
    await stopStream();
    await _unsubscribeFromNotifications();

    _timeoutCheckTimer?.cancel();

    await _frameController.close();
    await _stateController.close();
    await _fpsController.close();
  }
}
