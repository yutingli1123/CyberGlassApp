import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/bluetooth_service.dart';
import '../../domain/services/storage_service.dart';
import '../../domain/services/gemini_live_service.dart';

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

/// Provider for Gemini API key
/// Pass via --dart-define=GEMINI_API_KEY=your_key
final geminiApiKeyProvider = Provider<String>((ref) {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: '');
  if (apiKey.isEmpty) {
    throw Exception('GEMINI_API_KEY not configured. Pass it via --dart-define=GEMINI_API_KEY=your_key');
  }
  return apiKey;
});

/// Optional system prompt for Gemini Live - pass via --dart-define=GEMINI_SYSTEM_PROMPT="Your prompt"
final geminiSystemPromptProvider = Provider<String?>((ref) {
  const prompt = String.fromEnvironment('GEMINI_SYSTEM_PROMPT', defaultValue: '');
  return prompt.isEmpty ? null : prompt;
});

/// Provider for GeminiLiveService singleton
final geminiLiveServiceProvider = Provider<GeminiLiveService>((ref) {
  final apiKey = ref.watch(geminiApiKeyProvider);
  final systemPrompt = ref.watch(geminiSystemPromptProvider);
  final service = GeminiLiveService(apiKey, systemPrompt: systemPrompt);

  // Dispose when provider is destroyed
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});
