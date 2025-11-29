import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_log.freezed.dart';
part 'conversation_log.g.dart';

/// Represents a single message in a conversation
@freezed
class ConversationMessage with _$ConversationMessage {
  const factory ConversationMessage({
    required String id,
    required MessageType type,
    required MessageContentType contentType,
    String? content, // Text content (optional for voice-only messages)
    String? imagePath, // Path to the image associated with this message
    String? audioPath, // Path to the audio file
    required DateTime timestamp,
  }) = _ConversationMessage;

  factory ConversationMessage.fromJson(Map<String, dynamic> json) =>
      _$ConversationMessageFromJson(json);
}

/// Message type enum
enum MessageType {
  user,
  gemini,
}

/// Content type enum
enum MessageContentType {
  text, // Text only
  voice, // Voice only (no transcription)
  textWithImage, // Text + image
  voiceWithImage, // Voice + image
}

/// Represents a conversation session
@freezed
class ConversationSession with _$ConversationSession {
  const factory ConversationSession({
    required String id,
    required List<ConversationMessage> messages,
    required DateTime startTime,
    DateTime? endTime,
  }) = _ConversationSession;

  factory ConversationSession.fromJson(Map<String, dynamic> json) =>
      _$ConversationSessionFromJson(json);
}
