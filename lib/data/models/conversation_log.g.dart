// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationMessageImpl _$$ConversationMessageImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationMessageImpl(
  id: json['id'] as String,
  type: $enumDecode(_$MessageTypeEnumMap, json['type']),
  contentType: $enumDecode(_$MessageContentTypeEnumMap, json['contentType']),
  content: json['content'] as String?,
  imagePath: json['imagePath'] as String?,
  audioPath: json['audioPath'] as String?,
  timestamp: DateTime.parse(json['timestamp'] as String),
);

Map<String, dynamic> _$$ConversationMessageImplToJson(
  _$ConversationMessageImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'type': _$MessageTypeEnumMap[instance.type]!,
  'contentType': _$MessageContentTypeEnumMap[instance.contentType]!,
  'content': instance.content,
  'imagePath': instance.imagePath,
  'audioPath': instance.audioPath,
  'timestamp': instance.timestamp.toIso8601String(),
};

const _$MessageTypeEnumMap = {
  MessageType.user: 'user',
  MessageType.gemini: 'gemini',
};

const _$MessageContentTypeEnumMap = {
  MessageContentType.text: 'text',
  MessageContentType.voice: 'voice',
  MessageContentType.textWithImage: 'textWithImage',
  MessageContentType.voiceWithImage: 'voiceWithImage',
};

_$ConversationSessionImpl _$$ConversationSessionImplFromJson(
  Map<String, dynamic> json,
) => _$ConversationSessionImpl(
  id: json['id'] as String,
  messages: (json['messages'] as List<dynamic>)
      .map((e) => ConversationMessage.fromJson(e as Map<String, dynamic>))
      .toList(),
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: json['endTime'] == null
      ? null
      : DateTime.parse(json['endTime'] as String),
);

Map<String, dynamic> _$$ConversationSessionImplToJson(
  _$ConversationSessionImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'messages': instance.messages,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime?.toIso8601String(),
};
