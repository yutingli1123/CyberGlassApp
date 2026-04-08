// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_viewmodel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ConnectionViewState {
  List<ScanResult> get scannedDevices => throw _privateConstructorUsedError;
  bool get isScanning => throw _privateConstructorUsedError;
  bool get isConnecting => throw _privateConstructorUsedError;
  bool get isConnected => throw _privateConstructorUsedError;
  bool get isRequestingPermission =>
      throw _privateConstructorUsedError; // Gemini Live API state
  bool get isGeminiConnecting => throw _privateConstructorUsedError;
  bool get isGeminiConnected => throw _privateConstructorUsedError;
  bool get isGeminiStreaming => throw _privateConstructorUsedError;
  bool get isListening =>
      throw _privateConstructorUsedError; // User is speaking (microphone active)
  bool get isSpeaking =>
      throw _privateConstructorUsedError; // Gemini is speaking (audio playback)
  bool get isPaused =>
      throw _privateConstructorUsedError; // Audio stream is paused by user
  bool get isProcessing =>
      throw _privateConstructorUsedError; // Gemini is processing user input
  // Find mode state
  bool get isFindMode =>
      throw _privateConstructorUsedError; // Gemini is in find/search mode
  String? get findTarget =>
      throw _privateConstructorUsedError; // What Gemini is looking for
  // Video stream state
  bool get isVideoStreaming => throw _privateConstructorUsedError;
  int get frameCount => throw _privateConstructorUsedError;
  double get currentFps => throw _privateConstructorUsedError;
  String? get geminiStatus => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get statusMessage => throw _privateConstructorUsedError;

  /// Create a copy of ConnectionViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConnectionViewStateCopyWith<ConnectionViewState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConnectionViewStateCopyWith<$Res> {
  factory $ConnectionViewStateCopyWith(
    ConnectionViewState value,
    $Res Function(ConnectionViewState) then,
  ) = _$ConnectionViewStateCopyWithImpl<$Res, ConnectionViewState>;
  @useResult
  $Res call({
    List<ScanResult> scannedDevices,
    bool isScanning,
    bool isConnecting,
    bool isConnected,
    bool isRequestingPermission,
    bool isGeminiConnecting,
    bool isGeminiConnected,
    bool isGeminiStreaming,
    bool isListening,
    bool isSpeaking,
    bool isPaused,
    bool isProcessing,
    bool isFindMode,
    String? findTarget,
    bool isVideoStreaming,
    int frameCount,
    double currentFps,
    String? geminiStatus,
    String? error,
    String? statusMessage,
  });
}

/// @nodoc
class _$ConnectionViewStateCopyWithImpl<$Res, $Val extends ConnectionViewState>
    implements $ConnectionViewStateCopyWith<$Res> {
  _$ConnectionViewStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConnectionViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scannedDevices = null,
    Object? isScanning = null,
    Object? isConnecting = null,
    Object? isConnected = null,
    Object? isRequestingPermission = null,
    Object? isGeminiConnecting = null,
    Object? isGeminiConnected = null,
    Object? isGeminiStreaming = null,
    Object? isListening = null,
    Object? isSpeaking = null,
    Object? isPaused = null,
    Object? isProcessing = null,
    Object? isFindMode = null,
    Object? findTarget = freezed,
    Object? isVideoStreaming = null,
    Object? frameCount = null,
    Object? currentFps = null,
    Object? geminiStatus = freezed,
    Object? error = freezed,
    Object? statusMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            scannedDevices: null == scannedDevices
                ? _value.scannedDevices
                : scannedDevices // ignore: cast_nullable_to_non_nullable
                      as List<ScanResult>,
            isScanning: null == isScanning
                ? _value.isScanning
                : isScanning // ignore: cast_nullable_to_non_nullable
                      as bool,
            isConnecting: null == isConnecting
                ? _value.isConnecting
                : isConnecting // ignore: cast_nullable_to_non_nullable
                      as bool,
            isConnected: null == isConnected
                ? _value.isConnected
                : isConnected // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRequestingPermission: null == isRequestingPermission
                ? _value.isRequestingPermission
                : isRequestingPermission // ignore: cast_nullable_to_non_nullable
                      as bool,
            isGeminiConnecting: null == isGeminiConnecting
                ? _value.isGeminiConnecting
                : isGeminiConnecting // ignore: cast_nullable_to_non_nullable
                      as bool,
            isGeminiConnected: null == isGeminiConnected
                ? _value.isGeminiConnected
                : isGeminiConnected // ignore: cast_nullable_to_non_nullable
                      as bool,
            isGeminiStreaming: null == isGeminiStreaming
                ? _value.isGeminiStreaming
                : isGeminiStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            isListening: null == isListening
                ? _value.isListening
                : isListening // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSpeaking: null == isSpeaking
                ? _value.isSpeaking
                : isSpeaking // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPaused: null == isPaused
                ? _value.isPaused
                : isPaused // ignore: cast_nullable_to_non_nullable
                      as bool,
            isProcessing: null == isProcessing
                ? _value.isProcessing
                : isProcessing // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFindMode: null == isFindMode
                ? _value.isFindMode
                : isFindMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            findTarget: freezed == findTarget
                ? _value.findTarget
                : findTarget // ignore: cast_nullable_to_non_nullable
                      as String?,
            isVideoStreaming: null == isVideoStreaming
                ? _value.isVideoStreaming
                : isVideoStreaming // ignore: cast_nullable_to_non_nullable
                      as bool,
            frameCount: null == frameCount
                ? _value.frameCount
                : frameCount // ignore: cast_nullable_to_non_nullable
                      as int,
            currentFps: null == currentFps
                ? _value.currentFps
                : currentFps // ignore: cast_nullable_to_non_nullable
                      as double,
            geminiStatus: freezed == geminiStatus
                ? _value.geminiStatus
                : geminiStatus // ignore: cast_nullable_to_non_nullable
                      as String?,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
            statusMessage: freezed == statusMessage
                ? _value.statusMessage
                : statusMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConnectionViewStateImplCopyWith<$Res>
    implements $ConnectionViewStateCopyWith<$Res> {
  factory _$$ConnectionViewStateImplCopyWith(
    _$ConnectionViewStateImpl value,
    $Res Function(_$ConnectionViewStateImpl) then,
  ) = __$$ConnectionViewStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<ScanResult> scannedDevices,
    bool isScanning,
    bool isConnecting,
    bool isConnected,
    bool isRequestingPermission,
    bool isGeminiConnecting,
    bool isGeminiConnected,
    bool isGeminiStreaming,
    bool isListening,
    bool isSpeaking,
    bool isPaused,
    bool isProcessing,
    bool isFindMode,
    String? findTarget,
    bool isVideoStreaming,
    int frameCount,
    double currentFps,
    String? geminiStatus,
    String? error,
    String? statusMessage,
  });
}

/// @nodoc
class __$$ConnectionViewStateImplCopyWithImpl<$Res>
    extends _$ConnectionViewStateCopyWithImpl<$Res, _$ConnectionViewStateImpl>
    implements _$$ConnectionViewStateImplCopyWith<$Res> {
  __$$ConnectionViewStateImplCopyWithImpl(
    _$ConnectionViewStateImpl _value,
    $Res Function(_$ConnectionViewStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConnectionViewState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scannedDevices = null,
    Object? isScanning = null,
    Object? isConnecting = null,
    Object? isConnected = null,
    Object? isRequestingPermission = null,
    Object? isGeminiConnecting = null,
    Object? isGeminiConnected = null,
    Object? isGeminiStreaming = null,
    Object? isListening = null,
    Object? isSpeaking = null,
    Object? isPaused = null,
    Object? isProcessing = null,
    Object? isFindMode = null,
    Object? findTarget = freezed,
    Object? isVideoStreaming = null,
    Object? frameCount = null,
    Object? currentFps = null,
    Object? geminiStatus = freezed,
    Object? error = freezed,
    Object? statusMessage = freezed,
  }) {
    return _then(
      _$ConnectionViewStateImpl(
        scannedDevices: null == scannedDevices
            ? _value._scannedDevices
            : scannedDevices // ignore: cast_nullable_to_non_nullable
                  as List<ScanResult>,
        isScanning: null == isScanning
            ? _value.isScanning
            : isScanning // ignore: cast_nullable_to_non_nullable
                  as bool,
        isConnecting: null == isConnecting
            ? _value.isConnecting
            : isConnecting // ignore: cast_nullable_to_non_nullable
                  as bool,
        isConnected: null == isConnected
            ? _value.isConnected
            : isConnected // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRequestingPermission: null == isRequestingPermission
            ? _value.isRequestingPermission
            : isRequestingPermission // ignore: cast_nullable_to_non_nullable
                  as bool,
        isGeminiConnecting: null == isGeminiConnecting
            ? _value.isGeminiConnecting
            : isGeminiConnecting // ignore: cast_nullable_to_non_nullable
                  as bool,
        isGeminiConnected: null == isGeminiConnected
            ? _value.isGeminiConnected
            : isGeminiConnected // ignore: cast_nullable_to_non_nullable
                  as bool,
        isGeminiStreaming: null == isGeminiStreaming
            ? _value.isGeminiStreaming
            : isGeminiStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        isListening: null == isListening
            ? _value.isListening
            : isListening // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSpeaking: null == isSpeaking
            ? _value.isSpeaking
            : isSpeaking // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPaused: null == isPaused
            ? _value.isPaused
            : isPaused // ignore: cast_nullable_to_non_nullable
                  as bool,
        isProcessing: null == isProcessing
            ? _value.isProcessing
            : isProcessing // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFindMode: null == isFindMode
            ? _value.isFindMode
            : isFindMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        findTarget: freezed == findTarget
            ? _value.findTarget
            : findTarget // ignore: cast_nullable_to_non_nullable
                  as String?,
        isVideoStreaming: null == isVideoStreaming
            ? _value.isVideoStreaming
            : isVideoStreaming // ignore: cast_nullable_to_non_nullable
                  as bool,
        frameCount: null == frameCount
            ? _value.frameCount
            : frameCount // ignore: cast_nullable_to_non_nullable
                  as int,
        currentFps: null == currentFps
            ? _value.currentFps
            : currentFps // ignore: cast_nullable_to_non_nullable
                  as double,
        geminiStatus: freezed == geminiStatus
            ? _value.geminiStatus
            : geminiStatus // ignore: cast_nullable_to_non_nullable
                  as String?,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
        statusMessage: freezed == statusMessage
            ? _value.statusMessage
            : statusMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$ConnectionViewStateImpl implements _ConnectionViewState {
  const _$ConnectionViewStateImpl({
    final List<ScanResult> scannedDevices = const [],
    this.isScanning = false,
    this.isConnecting = false,
    this.isConnected = false,
    this.isRequestingPermission = false,
    this.isGeminiConnecting = false,
    this.isGeminiConnected = false,
    this.isGeminiStreaming = false,
    this.isListening = false,
    this.isSpeaking = false,
    this.isPaused = false,
    this.isProcessing = false,
    this.isFindMode = false,
    this.findTarget,
    this.isVideoStreaming = false,
    this.frameCount = 0,
    this.currentFps = 0.0,
    this.geminiStatus,
    this.error,
    this.statusMessage,
  }) : _scannedDevices = scannedDevices;

  final List<ScanResult> _scannedDevices;
  @override
  @JsonKey()
  List<ScanResult> get scannedDevices {
    if (_scannedDevices is EqualUnmodifiableListView) return _scannedDevices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scannedDevices);
  }

  @override
  @JsonKey()
  final bool isScanning;
  @override
  @JsonKey()
  final bool isConnecting;
  @override
  @JsonKey()
  final bool isConnected;
  @override
  @JsonKey()
  final bool isRequestingPermission;
  // Gemini Live API state
  @override
  @JsonKey()
  final bool isGeminiConnecting;
  @override
  @JsonKey()
  final bool isGeminiConnected;
  @override
  @JsonKey()
  final bool isGeminiStreaming;
  @override
  @JsonKey()
  final bool isListening;
  // User is speaking (microphone active)
  @override
  @JsonKey()
  final bool isSpeaking;
  // Gemini is speaking (audio playback)
  @override
  @JsonKey()
  final bool isPaused;
  // Audio stream is paused by user
  @override
  @JsonKey()
  final bool isProcessing;
  // Gemini is processing user input
  // Find mode state
  @override
  @JsonKey()
  final bool isFindMode;
  // Gemini is in find/search mode
  @override
  final String? findTarget;
  // What Gemini is looking for
  // Video stream state
  @override
  @JsonKey()
  final bool isVideoStreaming;
  @override
  @JsonKey()
  final int frameCount;
  @override
  @JsonKey()
  final double currentFps;
  @override
  final String? geminiStatus;
  @override
  final String? error;
  @override
  final String? statusMessage;

  @override
  String toString() {
    return 'ConnectionViewState(scannedDevices: $scannedDevices, isScanning: $isScanning, isConnecting: $isConnecting, isConnected: $isConnected, isRequestingPermission: $isRequestingPermission, isGeminiConnecting: $isGeminiConnecting, isGeminiConnected: $isGeminiConnected, isGeminiStreaming: $isGeminiStreaming, isListening: $isListening, isSpeaking: $isSpeaking, isPaused: $isPaused, isProcessing: $isProcessing, isFindMode: $isFindMode, findTarget: $findTarget, isVideoStreaming: $isVideoStreaming, frameCount: $frameCount, currentFps: $currentFps, geminiStatus: $geminiStatus, error: $error, statusMessage: $statusMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConnectionViewStateImpl &&
            const DeepCollectionEquality().equals(
              other._scannedDevices,
              _scannedDevices,
            ) &&
            (identical(other.isScanning, isScanning) ||
                other.isScanning == isScanning) &&
            (identical(other.isConnecting, isConnecting) ||
                other.isConnecting == isConnecting) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected) &&
            (identical(other.isRequestingPermission, isRequestingPermission) ||
                other.isRequestingPermission == isRequestingPermission) &&
            (identical(other.isGeminiConnecting, isGeminiConnecting) ||
                other.isGeminiConnecting == isGeminiConnecting) &&
            (identical(other.isGeminiConnected, isGeminiConnected) ||
                other.isGeminiConnected == isGeminiConnected) &&
            (identical(other.isGeminiStreaming, isGeminiStreaming) ||
                other.isGeminiStreaming == isGeminiStreaming) &&
            (identical(other.isListening, isListening) ||
                other.isListening == isListening) &&
            (identical(other.isSpeaking, isSpeaking) ||
                other.isSpeaking == isSpeaking) &&
            (identical(other.isPaused, isPaused) ||
                other.isPaused == isPaused) &&
            (identical(other.isProcessing, isProcessing) ||
                other.isProcessing == isProcessing) &&
            (identical(other.isFindMode, isFindMode) ||
                other.isFindMode == isFindMode) &&
            (identical(other.findTarget, findTarget) ||
                other.findTarget == findTarget) &&
            (identical(other.isVideoStreaming, isVideoStreaming) ||
                other.isVideoStreaming == isVideoStreaming) &&
            (identical(other.frameCount, frameCount) ||
                other.frameCount == frameCount) &&
            (identical(other.currentFps, currentFps) ||
                other.currentFps == currentFps) &&
            (identical(other.geminiStatus, geminiStatus) ||
                other.geminiStatus == geminiStatus) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.statusMessage, statusMessage) ||
                other.statusMessage == statusMessage));
  }

  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    const DeepCollectionEquality().hash(_scannedDevices),
    isScanning,
    isConnecting,
    isConnected,
    isRequestingPermission,
    isGeminiConnecting,
    isGeminiConnected,
    isGeminiStreaming,
    isListening,
    isSpeaking,
    isPaused,
    isProcessing,
    isFindMode,
    findTarget,
    isVideoStreaming,
    frameCount,
    currentFps,
    geminiStatus,
    error,
    statusMessage,
  ]);

  /// Create a copy of ConnectionViewState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConnectionViewStateImplCopyWith<_$ConnectionViewStateImpl> get copyWith =>
      __$$ConnectionViewStateImplCopyWithImpl<_$ConnectionViewStateImpl>(
        this,
        _$identity,
      );
}

abstract class _ConnectionViewState implements ConnectionViewState {
  const factory _ConnectionViewState({
    final List<ScanResult> scannedDevices,
    final bool isScanning,
    final bool isConnecting,
    final bool isConnected,
    final bool isRequestingPermission,
    final bool isGeminiConnecting,
    final bool isGeminiConnected,
    final bool isGeminiStreaming,
    final bool isListening,
    final bool isSpeaking,
    final bool isPaused,
    final bool isProcessing,
    final bool isFindMode,
    final String? findTarget,
    final bool isVideoStreaming,
    final int frameCount,
    final double currentFps,
    final String? geminiStatus,
    final String? error,
    final String? statusMessage,
  }) = _$ConnectionViewStateImpl;

  @override
  List<ScanResult> get scannedDevices;
  @override
  bool get isScanning;
  @override
  bool get isConnecting;
  @override
  bool get isConnected;
  @override
  bool get isRequestingPermission; // Gemini Live API state
  @override
  bool get isGeminiConnecting;
  @override
  bool get isGeminiConnected;
  @override
  bool get isGeminiStreaming;
  @override
  bool get isListening; // User is speaking (microphone active)
  @override
  bool get isSpeaking; // Gemini is speaking (audio playback)
  @override
  bool get isPaused; // Audio stream is paused by user
  @override
  bool get isProcessing; // Gemini is processing user input
  // Find mode state
  @override
  bool get isFindMode; // Gemini is in find/search mode
  @override
  String? get findTarget; // What Gemini is looking for
  // Video stream state
  @override
  bool get isVideoStreaming;
  @override
  int get frameCount;
  @override
  double get currentFps;
  @override
  String? get geminiStatus;
  @override
  String? get error;
  @override
  String? get statusMessage;

  /// Create a copy of ConnectionViewState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConnectionViewStateImplCopyWith<_$ConnectionViewStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
