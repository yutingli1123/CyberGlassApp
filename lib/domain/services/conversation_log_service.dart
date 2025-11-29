import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/conversation_log.dart';

/// Service for managing conversation logs and associated images
class ConversationLogService {
  static const String _sessionsKey = 'conversation_sessions';
  static const String _currentSessionKey = 'current_session_id';
  static const String _imagesFolderName = 'conversation_images';

  final _uuid = const Uuid();

  /// Get the directory for storing conversation images
  Future<Directory> _getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/$_imagesFolderName');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Start a new conversation session
  Future<String> startNewSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = _uuid.v4();

    final session = ConversationSession(
      id: sessionId,
      messages: [],
      startTime: DateTime.now(),
    );

    // Save current session ID
    await prefs.setString(_currentSessionKey, sessionId);

    // Save session
    await _saveSession(session);

    return sessionId;
  }

  /// End the current session
  Future<void> endCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString(_currentSessionKey);

    if (sessionId == null) return;

    final session = await getSession(sessionId);
    if (session == null) return;

    final updatedSession = session.copyWith(endTime: DateTime.now());
    await _saveSession(updatedSession);
    await prefs.remove(_currentSessionKey);
  }

  /// Get current session ID
  Future<String?> getCurrentSessionId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentSessionKey);
  }

  /// Get or create current session
  Future<String> getOrCreateCurrentSession() async {
    final sessionId = await getCurrentSessionId();
    if (sessionId != null) {
      final session = await getSession(sessionId);
      if (session != null) return sessionId;
    }

    return await startNewSession();
  }

  /// Save an image file and return its path
  Future<String> saveImage(Uint8List imageBytes) async {
    try {
      final imagesDir = await _getImagesDirectory();
      final imageId = _uuid.v4();
      final fileName = '$imageId.jpg';
      final targetPath = '${imagesDir.path}/$fileName';

      final file = File(targetPath);
      await file.writeAsBytes(imageBytes);

      print('[ConversationLog] Image saved: $targetPath (${imageBytes.length} bytes)');

      // Verify the file was saved
      if (await file.exists()) {
        final savedSize = await file.length();
        print('[ConversationLog] Image verified: $savedSize bytes');
      } else {
        print('[ConversationLog] WARNING: Image file does not exist after save!');
      }

      return targetPath;
    } catch (e) {
      print('[ConversationLog] ERROR saving image: $e');
      rethrow;
    }
  }

  /// Add a voice-only user message (no transcription)
  Future<void> addUserVoiceMessage({
    Uint8List? imageBytes,
  }) async {
    final sessionId = await getOrCreateCurrentSession();
    String? imagePath;

    if (imageBytes != null) {
      imagePath = await saveImage(imageBytes);
    }

    final message = ConversationMessage(
      id: _uuid.v4(),
      type: MessageType.user,
      contentType: imageBytes != null
          ? MessageContentType.voiceWithImage
          : MessageContentType.voice,
      content: '[User spoke]', // Placeholder since we don't have transcription
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );

    await _addMessageToSession(sessionId, message);
  }

  /// Add a text user message
  Future<void> addUserTextMessage({
    required String content,
    Uint8List? imageBytes,
  }) async {
    final sessionId = await getOrCreateCurrentSession();
    String? imagePath;

    if (imageBytes != null) {
      imagePath = await saveImage(imageBytes);
    }

    final message = ConversationMessage(
      id: _uuid.v4(),
      type: MessageType.user,
      contentType: imageBytes != null
          ? MessageContentType.textWithImage
          : MessageContentType.text,
      content: content,
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );

    await _addMessageToSession(sessionId, message);
  }

  /// Add a Gemini response to the current session
  Future<void> addGeminiResponse({
    required String content,
    Uint8List? imageBytes,
  }) async {
    final sessionId = await getOrCreateCurrentSession();
    String? imagePath;

    if (imageBytes != null) {
      imagePath = await saveImage(imageBytes);
    }

    final message = ConversationMessage(
      id: _uuid.v4(),
      type: MessageType.gemini,
      contentType: imageBytes != null
          ? MessageContentType.textWithImage
          : MessageContentType.text,
      content: content,
      imagePath: imagePath,
      timestamp: DateTime.now(),
    );

    await _addMessageToSession(sessionId, message);
  }

  /// Add a message to a specific session
  Future<void> _addMessageToSession(String sessionId, ConversationMessage message) async {
    final session = await getSession(sessionId);
    if (session == null) return;

    final updatedMessages = [...session.messages, message];
    final updatedSession = session.copyWith(messages: updatedMessages);

    await _saveSession(updatedSession);
  }

  /// Save a session to storage
  Future<void> _saveSession(ConversationSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();

    // Update or add the session
    final index = sessions.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }

    // Save all sessions
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));
  }

  /// Get a specific session by ID
  Future<ConversationSession?> getSession(String sessionId) async {
    final sessions = await getAllSessions();
    try {
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  /// Get all conversation sessions
  Future<List<ConversationSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_sessionsKey);

    if (sessionsString == null) return [];

    try {
      final sessionsList = jsonDecode(sessionsString) as List;
      return sessionsList
          .map((json) => ConversationSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get current session
  Future<ConversationSession?> getCurrentSession() async {
    final sessionId = await getCurrentSessionId();
    if (sessionId == null) return null;
    return await getSession(sessionId);
  }

  /// Delete a session and its associated images
  Future<void> deleteSession(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return;

    // Delete associated images
    for (final message in session.messages) {
      if (message.imagePath != null) {
        final imageFile = File(message.imagePath!);
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }
    }

    // Remove session from storage
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();
    sessions.removeWhere((s) => s.id == sessionId);

    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));

    // If it's the current session, clear current session ID
    final currentSessionId = await getCurrentSessionId();
    if (currentSessionId == sessionId) {
      await prefs.remove(_currentSessionKey);
    }
  }

  /// Delete all sessions and images
  Future<void> deleteAllSessions() async {
    // Delete all images
    final imagesDir = await _getImagesDirectory();
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
    }

    // Clear storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
    await prefs.remove(_currentSessionKey);
  }

  /// Get total number of messages across all sessions
  Future<int> getTotalMessageCount() async {
    final sessions = await getAllSessions();
    return sessions.fold<int>(0, (sum, session) => sum + session.messages.length);
  }

  /// Get total size of stored images in bytes
  Future<int> getTotalImagesSize() async {
    final imagesDir = await _getImagesDirectory();
    if (!await imagesDir.exists()) return 0;

    int totalSize = 0;
    await for (final entity in imagesDir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }
}
