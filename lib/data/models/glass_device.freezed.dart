// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'glass_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GlassDevice _$GlassDeviceFromJson(Map<String, dynamic> json) {
  return _GlassDevice.fromJson(json);
}

/// @nodoc
mixin _$GlassDevice {
  String get name => throw _privateConstructorUsedError;
  String get macAddress => throw _privateConstructorUsedError;
  DateTime? get lastConnected => throw _privateConstructorUsedError;

  /// Serializes this GlassDevice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GlassDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlassDeviceCopyWith<GlassDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlassDeviceCopyWith<$Res> {
  factory $GlassDeviceCopyWith(
    GlassDevice value,
    $Res Function(GlassDevice) then,
  ) = _$GlassDeviceCopyWithImpl<$Res, GlassDevice>;
  @useResult
  $Res call({String name, String macAddress, DateTime? lastConnected});
}

/// @nodoc
class _$GlassDeviceCopyWithImpl<$Res, $Val extends GlassDevice>
    implements $GlassDeviceCopyWith<$Res> {
  _$GlassDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlassDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? macAddress = null,
    Object? lastConnected = freezed,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            macAddress: null == macAddress
                ? _value.macAddress
                : macAddress // ignore: cast_nullable_to_non_nullable
                      as String,
            lastConnected: freezed == lastConnected
                ? _value.lastConnected
                : lastConnected // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GlassDeviceImplCopyWith<$Res>
    implements $GlassDeviceCopyWith<$Res> {
  factory _$$GlassDeviceImplCopyWith(
    _$GlassDeviceImpl value,
    $Res Function(_$GlassDeviceImpl) then,
  ) = __$$GlassDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String macAddress, DateTime? lastConnected});
}

/// @nodoc
class __$$GlassDeviceImplCopyWithImpl<$Res>
    extends _$GlassDeviceCopyWithImpl<$Res, _$GlassDeviceImpl>
    implements _$$GlassDeviceImplCopyWith<$Res> {
  __$$GlassDeviceImplCopyWithImpl(
    _$GlassDeviceImpl _value,
    $Res Function(_$GlassDeviceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GlassDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? macAddress = null,
    Object? lastConnected = freezed,
  }) {
    return _then(
      _$GlassDeviceImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        macAddress: null == macAddress
            ? _value.macAddress
            : macAddress // ignore: cast_nullable_to_non_nullable
                  as String,
        lastConnected: freezed == lastConnected
            ? _value.lastConnected
            : lastConnected // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GlassDeviceImpl implements _GlassDevice {
  const _$GlassDeviceImpl({
    required this.name,
    required this.macAddress,
    this.lastConnected,
  });

  factory _$GlassDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$GlassDeviceImplFromJson(json);

  @override
  final String name;
  @override
  final String macAddress;
  @override
  final DateTime? lastConnected;

  @override
  String toString() {
    return 'GlassDevice(name: $name, macAddress: $macAddress, lastConnected: $lastConnected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlassDeviceImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.lastConnected, lastConnected) ||
                other.lastConnected == lastConnected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, macAddress, lastConnected);

  /// Create a copy of GlassDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlassDeviceImplCopyWith<_$GlassDeviceImpl> get copyWith =>
      __$$GlassDeviceImplCopyWithImpl<_$GlassDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GlassDeviceImplToJson(this);
  }
}

abstract class _GlassDevice implements GlassDevice {
  const factory _GlassDevice({
    required final String name,
    required final String macAddress,
    final DateTime? lastConnected,
  }) = _$GlassDeviceImpl;

  factory _GlassDevice.fromJson(Map<String, dynamic> json) =
      _$GlassDeviceImpl.fromJson;

  @override
  String get name;
  @override
  String get macAddress;
  @override
  DateTime? get lastConnected;

  /// Create a copy of GlassDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlassDeviceImplCopyWith<_$GlassDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
