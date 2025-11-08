import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/glass_device.dart';

/// Service for managing local storage
class StorageService {
  static const String _deviceConfigKey = 'saved_device_config';

  /// Save device configuration
  Future<void> saveDevice(GlassDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceJson = device.toJson();
    await prefs.setString(_deviceConfigKey, jsonEncode(deviceJson));
  }

  /// Get saved device configuration
  Future<GlassDevice?> getSavedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final deviceString = prefs.getString(_deviceConfigKey);

    if (deviceString == null) return null;

    try {
      final deviceJson = jsonDecode(deviceString) as Map<String, dynamic>;
      return GlassDevice.fromJson(deviceJson);
    } catch (e) {
      return null;
    }
  }

  /// Check if device is saved
  Future<bool> hasDevice() async {
    final device = await getSavedDevice();
    return device != null;
  }

  /// Clear saved device
  Future<void> clearDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceConfigKey);
  }
}