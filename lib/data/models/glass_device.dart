import 'package:freezed_annotation/freezed_annotation.dart';

part 'glass_device.freezed.dart';
part 'glass_device.g.dart';

/// Represents a CyberGlass smart glasses device
@freezed
class GlassDevice with _$GlassDevice {
  const factory GlassDevice({
    required String name,
    required String macAddress,
    DateTime? lastConnected,
  }) = _GlassDevice;

  factory GlassDevice.fromJson(Map<String, dynamic> json) =>
      _$GlassDeviceFromJson(json);
}