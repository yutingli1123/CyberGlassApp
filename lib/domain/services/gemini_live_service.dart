import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:sound_stream/sound_stream.dart';
import 'package:record/record.dart';
import 'package:image/image.dart' as img;

/// GeminiLiveService - Dart port of Python Gemini Live API client
///
/// Handles real-time bidirectional audio/video streaming with Gemini 2.0 Flash Live
class GeminiLiveService {
  // Audio settings matching Python script
  static const int sendSampleRate = 16000;
  static const int receiveSampleRate = 24000;
  static const int channels = 1;
  static const String model =
      'models/gemini-2.5-flash-native-audio-preview-12-2025';

  // WebSocket
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  // Audio streams
  final AudioRecorder _recorder = AudioRecorder();
  final PlayerStream _player = PlayerStream();
  StreamSubscription<List<int>>? _recorderSubscription;

  // State
  bool _isConnected = false;
  bool _isPlaying = false;
  bool _isListening = false; // User is currently speaking
  bool _turnComplete =
      false; // Track if turn is complete but audio still playing
  bool _shouldQuit = false;
  bool _isPaused =
      false; // Pause flag - when true, don't send audio to WebSocket

  // Audio output queue (mimics Python's audio_in_queue)
  final List<Uint8List> _audioOutQueue = [];
  Timer? _playbackTimer;

  // Callbacks
  Function(String)? onTextReceived;
  Function(String)? onStatusChanged;
  Function()? onTurnComplete;
  Function()? onInterrupted;
  Function()? onMicActivityStopped; // For "latency mask" haptic feedback
  Function(bool)? onListeningStateChanged; // User is speaking
  Function(bool)? onSpeakingStateChanged; // Gemini is speaking
  Function()?
  onUserStoppedSpeaking; // User finished speaking, entering processing state

  // Silence detection for "latency mask"
  Timer? _silenceTimer;
  bool _wasUserSpeaking = false;
  static const Duration silenceThreshold = Duration(milliseconds: 300);

  // Latency tracking
  DateTime? _userStoppedSpeakingTime;
  DateTime? _lastAudioSentTime;

  /// API Key - should be passed during initialization
  late final String _apiKey;
  final String _systemPrompt;

  GeminiLiveService(this._apiKey, {required String systemPrompt})
    : _systemPrompt = systemPrompt.trim();

  /// Connect to Gemini Live API via WebSocket
  Future<bool> connect() async {
    if (_isConnected) {
      onStatusChanged?.call('Already connected');
      return true;
    }

    _shouldQuit = false;

    try {
      // Build WebSocket URL
      final uri = Uri.parse(
        'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1alpha.GenerativeService.BidiGenerateContent?key=$_apiKey',
      );

      _channel = WebSocketChannel.connect(uri);

      // Wait for connection
      await _channel!.ready;
      onStatusChanged?.call('WebSocket connected');

      // Send setup message exactly like Python script
      final setup = {
        'model': model,
        'systemInstruction': {
          'parts': [
            {'text': _systemPrompt},
          ],
        },
        'generationConfig': {
          'responseModalities': ['AUDIO'],
        },
        'proactivity': {'proactive_audio': true},
      };

      _channel!.sink.add(jsonEncode({'setup': setup}));
      onStatusChanged?.call('Setup message sent');

      // Start listening for responses
      _wsSubscription = _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: (error) {
          onStatusChanged?.call('WebSocket error: $error');
          disconnect();
        },
        onDone: () {
          onStatusChanged?.call('WebSocket closed');
          _isConnected = false;
        },
      );

      _isConnected = true;
      return true;
    } catch (e) {
      onStatusChanged?.call('Connection failed: $e');
      return false;
    }
  }

  /// Start audio recording and streaming
  Future<void> startAudioStream() async {
    if (!_isConnected) {
      onStatusChanged?.call('Not connected - cannot start audio');
      return;
    }

    try {
      // Check microphone permission
      if (!await _recorder.hasPermission()) {
        onStatusChanged?.call('Microphone permission denied');
        return;
      }

      // Initialize player with 24kHz sample rate for Gemini output
      await _player.initialize(sampleRate: receiveSampleRate, showLogs: false);

      // Start recording with echo cancellation
      final audioStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          echoCancel: true,
          noiseSuppress: true,
          autoGain: true,
        ),
      );

      // Listen to microphone data
      int micChunks = 0;
      _recorderSubscription = audioStream.listen((data) {
        micChunks++;
        if (micChunks % 100 == 0) {
          print('[GeminiLive] Mic chunks: $micChunks, size: ${data.length}');
        }

        if (_shouldQuit || !_isConnected) return;

        // If paused, don't send audio to WebSocket but keep recording (for AEC)
        if (_isPaused) return;

        // Detect user speaking activity for "latency mask"
        final audioData = Uint8List.fromList(data);
        _detectMicActivity(audioData);

        // Convert to base64 and send
        final base64Audio = base64Encode(data);

        final message = {
          'realtimeInput': {
            'mediaChunks': [
              {'mimeType': 'audio/pcm', 'data': base64Audio},
            ],
          },
        };

        _channel?.sink.add(jsonEncode(message));
        _lastAudioSentTime = DateTime.now(); // Track when audio was sent
      });

      // Start player for audio output
      await _player.start();

      // Start playback processing
      _startPlaybackTimer();

      // Reset states when audio stream starts
      _isListening = true;
      _turnComplete = false;
      _wasUserSpeaking = false;
      onListeningStateChanged?.call(true);

      onStatusChanged?.call('Audio streaming started (with AEC)');
    } catch (e) {
      onStatusChanged?.call('Audio stream error: $e');
    }
  }

  /// Detect microphone activity for "latency mask" feature
  void _detectMicActivity(Uint8List audioData) {
    // Calculate RMS amplitude to detect speech
    final samples = Int16List.view(audioData.buffer);
    double sum = 0;
    for (final sample in samples) {
      sum += sample * sample;
    }
    final rms = sum / samples.length;

    // Threshold for detecting speech (adjust as needed)
    const double speechThreshold =
        5000000; // High threshold to prevent echo-triggered interruptions

    if (rms > speechThreshold) {
      _wasUserSpeaking = true;
      _silenceTimer?.cancel();
      _silenceTimer = null;
    } else if (_wasUserSpeaking && _silenceTimer == null) {
      // User stopped speaking - start silence timer
      _silenceTimer = Timer(silenceThreshold, () {
        _wasUserSpeaking = false;

        // Record time for latency measurement
        _userStoppedSpeakingTime = DateTime.now();

        // Calculate latency from last audio sent to user stopped speaking
        if (_lastAudioSentTime != null) {
          final sendLatency = _userStoppedSpeakingTime!.difference(
            _lastAudioSentTime!,
          );
          print(
            '[GeminiLive] 📤 Send latency (last audio sent → user stopped): ${sendLatency.inMilliseconds}ms',
          );
        }

        print(
          '[GeminiLive] User stopped speaking at ${_userStoppedSpeakingTime!.toIso8601String()}',
        );

        // Notify that user stopped speaking (entering processing state)
        onUserStoppedSpeaking?.call();

        // Trigger "latency mask" - haptic feedback
        onMicActivityStopped?.call();
        HapticFeedback.heavyImpact();
      });
    }
  }

  /// Start playback timer to process audio queue
  void _startPlaybackTimer() {
    _playbackTimer?.cancel();
    int chunkCount = 0;
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      // Don't play audio if paused
      if (_isPaused) return;

      // Play audio whenever there's data in the queue
      if (_audioOutQueue.isNotEmpty) {
        final chunk = _audioOutQueue.removeAt(0);
        _player.writeChunk(chunk);
        chunkCount++;
        if (chunkCount % 10 == 0) {
          print(
            '[GeminiLive] Played $chunkCount chunks, queue: ${_audioOutQueue.length}',
          );
        }
      } else if (_turnComplete && _isPlaying) {
        // Queue is empty and turn is complete - stop speaking
        print(
          '[GeminiLive] Audio queue empty and turn complete - stopping speaking state',
        );
        print('[GeminiLive] Total chunks played: $chunkCount');
        _isPlaying = false;
        _turnComplete = false;
        onSpeakingStateChanged?.call(false);
      }
    });
  }

  /// Handle incoming WebSocket messages
  void _handleWebSocketMessage(dynamic message) {
    try {
      Map<String, dynamic> data;

      if (message is String) {
        data = jsonDecode(message) as Map<String, dynamic>;
      } else if (message is List<int>) {
        // Binary message - decode as UTF-8
        data = jsonDecode(utf8.decode(message)) as Map<String, dynamic>;
      } else {
        return;
      }

      // Debug: log the message structure
      print('[GeminiLive] Message keys: ${data.keys.toList()}');

      // Check for setup complete
      if (data.containsKey('setupComplete')) {
        onStatusChanged?.call('Setup complete - ready to speak');
        return;
      }

      // Handle server content
      if (data.containsKey('serverContent')) {
        final serverContent = data['serverContent'] as Map<String, dynamic>;
        print(
          '[GeminiLive] serverContent keys: ${serverContent.keys.toList()}',
        );

        // Check for interruption (critical for UX)
        if (serverContent['interrupted'] == true) {
          onStatusChanged?.call('User speaking - interrupting Gemini');
          _handleInterruption();
          onInterrupted?.call();
          return;
        }

        // Check for turn complete
        if (serverContent['turnComplete'] == true) {
          // Mark turn as complete, but don't stop speaking yet
          // Speaking will be stopped when audio queue is empty
          print(
            '[GeminiLive] Turn complete received, queue size: ${_audioOutQueue.length}, isPlaying: $_isPlaying',
          );
          _turnComplete = true;
          onTurnComplete?.call();
          onStatusChanged?.call('Turn complete - continue speaking');
          return;
        }

        // Handle model turn with content
        if (serverContent.containsKey('modelTurn')) {
          final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>;
          print('[GeminiLive] modelTurn keys: ${modelTurn.keys.toList()}');
          if (modelTurn.containsKey('parts')) {
            final parts = modelTurn['parts'] as List<dynamic>;
            print('[GeminiLive] parts count: ${parts.length}');
            for (final part in parts) {
              final partMap = part as Map<String, dynamic>;
              print('[GeminiLive] part keys: ${partMap.keys.toList()}');

              // Handle audio data
              if (partMap.containsKey('inlineData')) {
                final inlineData =
                    partMap['inlineData'] as Map<String, dynamic>;
                final mimeType = inlineData['mimeType'] as String?;
                final dataStr = inlineData['data'] as String?;
                print(
                  '[GeminiLive] inlineData mimeType: $mimeType, hasData: ${dataStr != null}',
                );

                if (mimeType != null &&
                    mimeType.contains('audio') &&
                    dataStr != null) {
                  // Don't queue audio if paused
                  if (_isPaused) {
                    print('[GeminiLive] Audio chunk dropped (paused)');
                    continue;
                  }

                  final audioBytes = base64Decode(dataStr);
                  _audioOutQueue.add(Uint8List.fromList(audioBytes));

                  // Update speaking state and calculate latency on first response
                  if (!_isPlaying) {
                    _isPlaying = true;
                    onSpeakingStateChanged?.call(true);

                    // Calculate and print latency
                    if (_userStoppedSpeakingTime != null) {
                      final latency = DateTime.now().difference(
                        _userStoppedSpeakingTime!,
                      );
                      print(
                        '[GeminiLive] ⏱️  Latency (user stopped → first response): ${latency.inMilliseconds}ms',
                      );
                      _userStoppedSpeakingTime = null; // Reset for next turn
                    }
                  }

                  print(
                    '[GeminiLive] Audio chunk received: ${audioBytes.length} bytes, queue size: ${_audioOutQueue.length}',
                  );
                }
              }

              // Handle text
              if (partMap.containsKey('text')) {
                final text = partMap['text'] as String;
                onTextReceived?.call(text);
              }
            }
          }
        }
      }
    } catch (e) {
      onStatusChanged?.call('Message parse error: $e');
    }
  }

  /// Handle interruption - clear audio queue immediately
  Future<void> _handleInterruption() async {
    print(
      '[GeminiLive] Handling interruption - clearing queue and restarting player',
    );

    if (_isPlaying) {
      _isPlaying = false;
      onSpeakingStateChanged?.call(false);
    }

    // Reset turn complete flag
    _turnComplete = false;

    // Clear the audio queue
    _audioOutQueue.clear();

    // Stop and restart player to clear its internal buffer
    try {
      await _player.stop();
      await _player.start();
      print('[GeminiLive] Player restarted to clear buffer');
    } catch (e) {
      print('[GeminiLive] Error restarting player: $e');
      // If restart fails, try to reinitialize
      try {
        await _player.initialize(
          sampleRate: receiveSampleRate,
          showLogs: false,
        );
        await _player.start();
        print('[GeminiLive] Player reinitialized');
      } catch (e2) {
        print('[GeminiLive] Error reinitializing player: $e2');
      }
    }

    onStatusChanged?.call('Audio playback stopped and queue cleared');
  }

  /// Send image to Gemini
  /// Resizes to max 1024x1024, converts to JPEG quality 90
  Future<void> sendImage(Uint8List imageBytes) async {
    if (!_isConnected) {
      onStatusChanged?.call('Not connected - cannot send image');
      return;
    }

    // Don't send images when paused
    if (_isPaused) {
      print('[GeminiLive] Image send skipped (paused)');
      return;
    }

    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        onStatusChanged?.call('Failed to decode image');
        return;
      }

      // Resize to max 1024x1024 maintaining aspect ratio
      img.Image resized;
      if (image.width > 1024 || image.height > 1024) {
        if (image.width > image.height) {
          resized = img.copyResize(image, width: 1024);
        } else {
          resized = img.copyResize(image, height: 1024);
        }
      } else {
        resized = image;
      }

      // Compress to JPEG quality 90
      final jpegBytes = img.encodeJpg(resized, quality: 90);

      // Send via WebSocket
      final base64Image = base64Encode(jpegBytes);
      final message = {
        'realtimeInput': {
          'mediaChunks': [
            {'mimeType': 'image/jpeg', 'data': base64Image},
          ],
        },
      };

      _channel?.sink.add(jsonEncode(message));
      onStatusChanged?.call('Image sent (${jpegBytes.length} bytes)');
    } catch (e) {
      onStatusChanged?.call('Image send error: $e');
    }
  }

  /// Send text message to Gemini
  Future<void> sendText(String text) async {
    if (!_isConnected || text.isEmpty) return;

    final message = {
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {'text': text},
            ],
          },
        ],
        'turnComplete': true,
      },
    };

    _channel?.sink.add(jsonEncode(message));
  }

  /// Pause audio streaming (keeps audio devices running, just stops sending data)
  Future<void> pauseAudioStream() async {
    if (!_isPaused) {
      _isPaused = true;

      // Clear any pending audio output queue
      _audioOutQueue.clear();

      // Clear player's internal buffer by stopping and restarting
      try {
        await _player.stop();
        await _player.start();
        print('[GeminiLive] Player buffer cleared');
      } catch (e) {
        print('[GeminiLive] Error clearing player buffer: $e');
        // If restart fails, try to reinitialize
        try {
          await _player.initialize(
            sampleRate: receiveSampleRate,
            showLogs: false,
          );
          await _player.start();
          print('[GeminiLive] Player reinitialized after pause');
        } catch (e2) {
          print('[GeminiLive] Error reinitializing player on pause: $e2');
        }
      }

      // Update states
      if (_isPlaying) {
        _isPlaying = false;
        onSpeakingStateChanged?.call(false);
      }
      if (_isListening) {
        _isListening = false;
        onListeningStateChanged?.call(false);
      }

      onStatusChanged?.call('Audio paused (devices still active)');
      print('[GeminiLive] Audio paused - mic and speaker still active for AEC');
    }
  }

  /// Resume audio streaming
  void resumeAudioStream() {
    if (_isPaused) {
      _isPaused = false;

      // Restore listening state
      if (!_isListening) {
        _isListening = true;
        onListeningStateChanged?.call(true);
      }

      onStatusChanged?.call('Audio resumed');
      print('[GeminiLive] Audio resumed - now sending to WebSocket');
    }
  }

  /// Stop audio streaming (completely stops audio devices)
  Future<void> stopAudioStream() async {
    _isPaused = false;

    await _recorderSubscription?.cancel();
    _recorderSubscription = null;

    if (await _recorder.isRecording()) {
      await _recorder.stop();
    }
    await _player.stop();

    _playbackTimer?.cancel();
    _playbackTimer = null;

    _silenceTimer?.cancel();
    _silenceTimer = null;

    _audioOutQueue.clear();

    // Reset listening and speaking states
    if (_isListening) {
      _isListening = false;
      onListeningStateChanged?.call(false);
    }
    if (_isPlaying) {
      _isPlaying = false;
      onSpeakingStateChanged?.call(false);
    }

    onStatusChanged?.call('Audio streaming stopped');
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _shouldQuit = true;
    _isConnected = false;

    await stopAudioStream();

    await _wsSubscription?.cancel();
    _wsSubscription = null;

    await _channel?.sink.close();
    _channel = null;

    onStatusChanged?.call('Disconnected');
  }

  /// Check if connected
  bool get isConnected => _isConnected;

  /// Check if currently playing audio
  bool get isPlaying => _isPlaying;

  /// Dispose all resources
  Future<void> dispose() async {
    await disconnect();
    _recorder.dispose();
  }
}
