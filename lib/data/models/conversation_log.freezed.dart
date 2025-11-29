// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ConversationMessage _$ConversationMessageFromJson(Map<String, dynamic> json) {
  return _ConversationMessage.fromJson(json);
}

/// @nodoc
mixin _$ConversationMessage {
  String get id => throw _privateConstructorUsedError;
  MessageType get type => throw _privateConstructorUsedError;
  MessageContentType get contentType => throw _privateConstructorUsedError;
  String? get content =>
      throw _privateConstructorUsedError; // Text content (optional for voice-only messages)
  String? get imagePath =>
      throw _privateConstructorUsedError; // Path to the image associated with this message
  String? get audioPath =>
      throw _privateConstructorUsedError; // Path to the audio file
  DateTime get timestamp => throw _privateConstructorUsedError;

  /// Serializes this ConversationMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationMessageCopyWith<ConversationMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationMessageCopyWith<$Res> {
  factory $ConversationMessageCopyWith(
    ConversationMessage value,
    $Res Function(ConversationMessage) then,
  ) = _$ConversationMessageCopyWithImpl<$Res, ConversationMessage>;
  @useResult
  $Res call({
    String id,
    MessageType type,
    MessageContentType contentType,
    String? content,
    String? imagePath,
    String? audioPath,
    DateTime timestamp,
  });
}

/// @nodoc
class _$ConversationMessageCopyWithImpl<$Res, $Val extends ConversationMessage>
    implements $ConversationMessageCopyWith<$Res> {
  _$ConversationMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? contentType = null,
    Object? content = freezed,
    Object? imagePath = freezed,
    Object? audioPath = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            contentType: null == contentType
                ? _value.contentType
                : contentType // ignore: cast_nullable_to_non_nullable
                      as MessageContentType,
            content: freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            audioPath: freezed == audioPath
                ? _value.audioPath
                : audioPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationMessageImplCopyWith<$Res>
    implements $ConversationMessageCopyWith<$Res> {
  factory _$$ConversationMessageImplCopyWith(
    _$ConversationMessageImpl value,
    $Res Function(_$ConversationMessageImpl) then,
  ) = __$$ConversationMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    MessageType type,
    MessageContentType contentType,
    String? content,
    String? imagePath,
    String? audioPath,
    DateTime timestamp,
  });
}

/// @nodoc
class __$$ConversationMessageImplCopyWithImpl<$Res>
    extends _$ConversationMessageCopyWithImpl<$Res, _$ConversationMessageImpl>
    implements _$$ConversationMessageImplCopyWith<$Res> {
  __$$ConversationMessageImplCopyWithImpl(
    _$ConversationMessageImpl _value,
    $Res Function(_$ConversationMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? contentType = null,
    Object? content = freezed,
    Object? imagePath = freezed,
    Object? audioPath = freezed,
    Object? timestamp = null,
  }) {
    return _then(
      _$ConversationMessageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        contentType: null == contentType
            ? _value.contentType
            : contentType // ignore: cast_nullable_to_non_nullable
                  as MessageContentType,
        content: freezed == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        audioPath: freezed == audioPath
            ? _value.audioPath
            : audioPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationMessageImpl implements _ConversationMessage {
  const _$ConversationMessageImpl({
    required this.id,
    required this.type,
    required this.contentType,
    this.content,
    this.imagePath,
    this.audioPath,
    required this.timestamp,
  });

  factory _$ConversationMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationMessageImplFromJson(json);

  @override
  final String id;
  @override
  final MessageType type;
  @override
  final MessageContentType contentType;
  @override
  final String? content;
  // Text content (optional for voice-only messages)
  @override
  final String? imagePath;
  // Path to the image associated with this message
  @override
  final String? audioPath;
  // Path to the audio file
  @override
  final DateTime timestamp;

  @override
  String toString() {
    return 'ConversationMessage(id: $id, type: $type, contentType: $contentType, content: $content, imagePath: $imagePath, audioPath: $audioPath, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationMessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.audioPath, audioPath) ||
                other.audioPath == audioPath) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    contentType,
    content,
    imagePath,
    audioPath,
    timestamp,
  );

  /// Create a copy of ConversationMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationMessageImplCopyWith<_$ConversationMessageImpl> get copyWith =>
      __$$ConversationMessageImplCopyWithImpl<_$ConversationMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationMessageImplToJson(this);
  }
}

abstract class _ConversationMessage implements ConversationMessage {
  const factory _ConversationMessage({
    required final String id,
    required final MessageType type,
    required final MessageContentType contentType,
    final String? content,
    final String? imagePath,
    final String? audioPath,
    required final DateTime timestamp,
  }) = _$ConversationMessageImpl;

  factory _ConversationMessage.fromJson(Map<String, dynamic> json) =
      _$ConversationMessageImpl.fromJson;

  @override
  String get id;
  @override
  MessageType get type;
  @override
  MessageContentType get contentType;
  @override
  String? get content; // Text content (optional for voice-only messages)
  @override
  String? get imagePath; // Path to the image associated with this message
  @override
  String? get audioPath; // Path to the audio file
  @override
  DateTime get timestamp;

  /// Create a copy of ConversationMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationMessageImplCopyWith<_$ConversationMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConversationSession _$ConversationSessionFromJson(Map<String, dynamic> json) {
  return _ConversationSession.fromJson(json);
}

/// @nodoc
mixin _$ConversationSession {
  String get id => throw _privateConstructorUsedError;
  List<ConversationMessage> get messages => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime? get endTime => throw _privateConstructorUsedError;

  /// Serializes this ConversationSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConversationSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConversationSessionCopyWith<ConversationSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConversationSessionCopyWith<$Res> {
  factory $ConversationSessionCopyWith(
    ConversationSession value,
    $Res Function(ConversationSession) then,
  ) = _$ConversationSessionCopyWithImpl<$Res, ConversationSession>;
  @useResult
  $Res call({
    String id,
    List<ConversationMessage> messages,
    DateTime startTime,
    DateTime? endTime,
  });
}

/// @nodoc
class _$ConversationSessionCopyWithImpl<$Res, $Val extends ConversationSession>
    implements $ConversationSessionCopyWith<$Res> {
  _$ConversationSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConversationSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = null,
    Object? startTime = null,
    Object? endTime = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            messages: null == messages
                ? _value.messages
                : messages // ignore: cast_nullable_to_non_nullable
                      as List<ConversationMessage>,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConversationSessionImplCopyWith<$Res>
    implements $ConversationSessionCopyWith<$Res> {
  factory _$$ConversationSessionImplCopyWith(
    _$ConversationSessionImpl value,
    $Res Function(_$ConversationSessionImpl) then,
  ) = __$$ConversationSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<ConversationMessage> messages,
    DateTime startTime,
    DateTime? endTime,
  });
}

/// @nodoc
class __$$ConversationSessionImplCopyWithImpl<$Res>
    extends _$ConversationSessionCopyWithImpl<$Res, _$ConversationSessionImpl>
    implements _$$ConversationSessionImplCopyWith<$Res> {
  __$$ConversationSessionImplCopyWithImpl(
    _$ConversationSessionImpl _value,
    $Res Function(_$ConversationSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConversationSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? messages = null,
    Object? startTime = null,
    Object? endTime = freezed,
  }) {
    return _then(
      _$ConversationSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        messages: null == messages
            ? _value._messages
            : messages // ignore: cast_nullable_to_non_nullable
                  as List<ConversationMessage>,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConversationSessionImpl implements _ConversationSession {
  const _$ConversationSessionImpl({
    required this.id,
    required final List<ConversationMessage> messages,
    required this.startTime,
    this.endTime,
  }) : _messages = messages;

  factory _$ConversationSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConversationSessionImplFromJson(json);

  @override
  final String id;
  final List<ConversationMessage> _messages;
  @override
  List<ConversationMessage> get messages {
    if (_messages is EqualUnmodifiableListView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_messages);
  }

  @override
  final DateTime startTime;
  @override
  final DateTime? endTime;

  @override
  String toString() {
    return 'ConversationSession(id: $id, messages: $messages, startTime: $startTime, endTime: $endTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConversationSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_messages),
    startTime,
    endTime,
  );

  /// Create a copy of ConversationSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConversationSessionImplCopyWith<_$ConversationSessionImpl> get copyWith =>
      __$$ConversationSessionImplCopyWithImpl<_$ConversationSessionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConversationSessionImplToJson(this);
  }
}

abstract class _ConversationSession implements ConversationSession {
  const factory _ConversationSession({
    required final String id,
    required final List<ConversationMessage> messages,
    required final DateTime startTime,
    final DateTime? endTime,
  }) = _$ConversationSessionImpl;

  factory _ConversationSession.fromJson(Map<String, dynamic> json) =
      _$ConversationSessionImpl.fromJson;

  @override
  String get id;
  @override
  List<ConversationMessage> get messages;
  @override
  DateTime get startTime;
  @override
  DateTime? get endTime;

  /// Create a copy of ConversationSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConversationSessionImplCopyWith<_$ConversationSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
