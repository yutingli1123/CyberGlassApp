import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/connection_viewmodel.dart';

/// Connection screen with animated orb
class ConnectionView extends ConsumerStatefulWidget {
  const ConnectionView({super.key});

  @override
  ConsumerState<ConnectionView> createState() => _ConnectionViewState();
}

class _ConnectionViewState extends ConsumerState<ConnectionView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rippleAnimation;

  @override
  void initState() {
    super.initState();

    // Setup pulsing and ripple animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    // Create smooth breathing animation (ease in and out)
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_animationController);

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Initialize: request permissions and start scanning
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(connectionViewModelProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(connectionViewModelProvider);

    // Determine status text
    String statusText;
    if (state.isSpeaking) {
      statusText = 'Speaking';
    } else if (state.isProcessing) {
      statusText = 'Processing';
    } else if (state.isListening) {
      statusText = 'Listening';
    } else if (state.isPaused) {
      statusText = 'Paused';
    } else if (state.isConnected) {
      statusText = 'Connected';
    } else if (state.isConnecting) {
      statusText = state.error != null ? 'Still Connecting' : 'Connecting';
    } else {
      // isScanning or requesting permissions - always show "Scanning"
      statusText = state.error != null ? 'Still Scanning' : 'Scanning';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated orb with ripples
            GestureDetector(
              onTap: () {
                // Only allow toggle if connected to Gemini
                if (state.isGeminiConnected) {
                  HapticFeedback.mediumImpact();
                  ref.read(connectionViewModelProvider.notifier).toggleAudioStream();
                }
              },
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return SizedBox(
                    width: 300,
                    height: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Ripple effects (only when scanning or connecting)
                        if (state.isScanning || state.isConnecting) ...[
                          _buildRipple(0, state),
                          _buildRipple(0.33, state),
                          _buildRipple(0.66, state),
                        ],

                        // Main orb
                        Transform.scale(
                          scale: state.isScanning || state.isConnecting
                              ? _pulseAnimation.value
                              : 1.0,
                          child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  _getOrbColor(state).withValues(alpha: 0.8),
                                  _getOrbColor(state).withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                                stops: const [0.3, 0.7, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _getOrbColor(state).withValues(alpha: 0.3),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getOrbColor(state),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 60),

            // Status text (always shown)
            Text(
              statusText,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),

            const SizedBox(height: 24),

            // Video frame preview (shown when streaming)
            if (state.currentFrame != null)
              Container(
                width: 240,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _getOrbColor(state).withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.memory(
                  state.currentFrame!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),

            if (state.currentFrame != null) const SizedBox(height: 16),

            // Error message box (shown when there's an error)
            if (state.error != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Button to connect new device
              ElevatedButton(
                onPressed: () {
                  ref.read(connectionViewModelProvider.notifier).scanForNewDevice();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Connect New Device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a ripple effect with delay
  Widget _buildRipple(double delay, ConnectionViewState state) {
    final adjustedValue = (_rippleAnimation.value + delay) % 1.0;
    final scale = 1.0 + (adjustedValue * 1.5);
    final opacity = 1.0 - adjustedValue;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _getOrbColor(state).withValues(alpha: opacity * 0.6),
            width: 2,
          ),
        ),
      ),
    );
  }

  /// Get orb color based on connection state
  Color _getOrbColor(ConnectionViewState state) {
    if (state.isSpeaking) {
      return Colors.deepPurpleAccent; // Speaking
    } else if (state.isProcessing) {
      return Colors.purpleAccent; // Processing
    } else if (state.isListening) {
      return Colors.lightBlueAccent; // Listening
    } else if (state.isPaused) {
      return Colors.grey; // Paused
    } else if (state.isConnected) {
      return Colors.green; // Connected (Idle)
    } else if (state.isConnecting) {
      return Colors.orange;
    } else {
      // Scanning or requesting permissions
      return Colors.blue;
    }
  }
}
