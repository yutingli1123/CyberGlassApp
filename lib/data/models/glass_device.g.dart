// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glass_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlassDeviceImpl _$$GlassDeviceImplFromJson(Map<String, dynamic> json) =>
    _$GlassDeviceImpl(
      name: json['name'] as String,
      macAddress: json['macAddress'] as String,
      lastConnected: json['lastConnected'] == null
          ? null
          : DateTime.parse(json['lastConnected'] as String),
    );

Map<String, dynamic> _$$GlassDeviceImplToJson(_$GlassDeviceImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'macAddress': instance.macAddress,
      'lastConnected': instance.lastConnected?.toIso8601String(),
    };
