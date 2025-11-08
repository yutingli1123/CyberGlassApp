import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/bluetooth_service.dart';
import '../../domain/services/storage_service.dart';

/// Provider for BleService singleton
final bluetoothServiceProvider = Provider<BleService>((ref) {
  final service = BleService();

  // Dispose when provider is destroyed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for StorageService singleton
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});