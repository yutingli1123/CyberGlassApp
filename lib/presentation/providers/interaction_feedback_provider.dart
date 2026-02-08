import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/connection_viewmodel.dart';

/// High-level interaction phases that should map to haptic cues.
enum InteractionPhase {
  scanning,
  connected,
  listening,
  processing,
  paused,
  deviceNotFound,
}

/// Derives the primary interaction phase from [ConnectionViewState].
final interactionFeedbackProvider = Provider<InteractionPhase?>((ref) {
  final state = ref.watch(connectionViewModelProvider);

  if (_isDeviceNotFound(state)) return InteractionPhase.deviceNotFound;
  if (state.isPaused) return InteractionPhase.paused;
  if (state.isProcessing) return InteractionPhase.processing;
  if (state.isListening) return InteractionPhase.listening;
  if (state.isConnected) return InteractionPhase.connected;
  if (state.isScanning) return InteractionPhase.scanning;

  return null;
});

bool _isDeviceNotFound(ConnectionViewState state) {
  final message = state.error ?? state.statusMessage;
  if (message == null) return false;
  final lower = message.toLowerCase();
  return lower.contains('cannot find cyberglass') ||
      lower.contains('cannot find') ||
      lower.contains('failed to reconnect') ||
      lower.contains('device not found');
}
