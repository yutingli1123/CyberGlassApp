import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../providers/interaction_feedback_provider.dart';

/// Provides tactile cues for major interaction phases.
class HapticFeedbackService {
  InteractionPhase? _lastPhase;
  Timer? _processingTimer;
  Timer? _scanningTimer;
  Timer? _deviceNotFoundTimer;
  Timer? _listeningTimer;

  Future<void> emit(InteractionPhase phase) async {
    if (_lastPhase == phase) {
      _log('emit (same phase) -> $phase');
      _ensurePersistentPattern(phase);
      return;
    }

    final previous = _lastPhase;
    _lastPhase = phase;

    _log('emit phase change: $previous -> $phase');
    _stopPersistentPattern(previous);

    switch (phase) {
      case InteractionPhase.scanning:
        _log('start scanning pattern');
        _startScanningPulse();
        await _kickScanningPattern();
        break;
      case InteractionPhase.connected:
        _log('connected impact');
        await HapticFeedback.mediumImpact();
        break;
      case InteractionPhase.listening:
        _log('start listening pattern');
        _startListeningPulse();
        await _kickListeningPattern();
        break;
      case InteractionPhase.processing:
        _log('start processing pattern');
        _startProcessingPulse();
        await HapticFeedback.heavyImpact();
        break;
      case InteractionPhase.paused:
        _log('paused impact');
        await HapticFeedback.vibrate();
        break;
      case InteractionPhase.deviceNotFound:
        _log('start deviceNotFound pattern');
        _startDeviceNotFoundPulse();
        await HapticFeedback.heavyImpact();
        break;
    }
  }

  void _startProcessingPulse() {
    _log('processing timer start');
    _processingTimer ??= Timer.periodic(
      const Duration(milliseconds: 700),
      (_) => HapticFeedback.heavyImpact(),
    );
  }

  void _startScanningPulse() {
    _log('scanning timer start');
    _scanningTimer ??= Timer.periodic(
      const Duration(milliseconds: 800),
      (_) {
        _log('scanning tick');
        HapticFeedback.vibrate();
      },
    );
  }

  Future<void> _kickScanningPattern() async {
    _log('scanning kick');
    await HapticFeedback.vibrate();
  }

  void _startDeviceNotFoundPulse() {
    _log('deviceNotFound timer start');
    _deviceNotFoundTimer ??= Timer.periodic(
      const Duration(milliseconds: 350),
      (_) async {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 120));
        await HapticFeedback.vibrate();
      },
    );
  }

  void _startListeningPulse() {
    _log('listening timer start');
    _listeningTimer ??= Timer.periodic(
      const Duration(milliseconds: 1200),
      (_) => HapticFeedback.heavyImpact(),
    );
  }

  Future<void> _kickListeningPattern() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    await HapticFeedback.heavyImpact();
  }

  /// Stop any running persistent vibration pattern and reset state.
  void stop() {
    _log('stop');
    _stopPersistentPattern(_lastPhase);
    _lastPhase = null;
  }

  void _ensurePersistentPattern(InteractionPhase phase) {
    switch (phase) {
      case InteractionPhase.processing:
        if (_processingTimer == null) {
          _startProcessingPulse();
        }
        break;
      case InteractionPhase.scanning:
        if (_scanningTimer == null) {
          _startScanningPulse();
        }
        break;
      case InteractionPhase.deviceNotFound:
        if (_deviceNotFoundTimer == null) {
          _startDeviceNotFoundPulse();
        }
        break;
      case InteractionPhase.listening:
        if (_listeningTimer == null) {
          _startListeningPulse();
        }
        break;
      case InteractionPhase.connected:
      case InteractionPhase.paused:
        break;
    }
  }

  void _stopPersistentPattern(InteractionPhase? phase) {
    switch (phase) {
      case InteractionPhase.processing:
        _log('processing timer stop');
        _processingTimer?.cancel();
        _processingTimer = null;
        break;
      case InteractionPhase.scanning:
        _log('scanning timer stop');
        _scanningTimer?.cancel();
        _scanningTimer = null;
        break;
      case InteractionPhase.deviceNotFound:
        _log('deviceNotFound timer stop');
        _deviceNotFoundTimer?.cancel();
        _deviceNotFoundTimer = null;
        break;
      case InteractionPhase.listening:
        _log('listening timer stop');
        _listeningTimer?.cancel();
        _listeningTimer = null;
        break;
      case InteractionPhase.connected:
      case InteractionPhase.paused:
      case null:
        break;
    }
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[Haptics] $message');
    }
  }
}
