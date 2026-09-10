import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Core widget displaying the casserole pot with tap-to-spin interaction
class CasseroleWidget extends StatefulWidget {
  const CasseroleWidget({super.key});

  @override
  State<CasseroleWidget> createState() => _CasseroleWidgetState();
}

class _CasseroleWidgetState extends State<CasseroleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize spin animation controller
    _spinController = AnimationController(
      duration: const Duration(milliseconds: AppConstants.spinDurationMs),
      vsync: this,
    );

    // Create curved animation for smooth deceleration
    _spinAnimation = CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  /// Handle tap on casserole - triggers spin animation
  void _onTap() {
    // Reset animation to start and begin spinning
    _spinController.forward(from: 0.0);

    // TODO Day 3: Add audio playback
    // TODO Day 4: Add haptic feedback
    // TODO Day 5: Add spark effects
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: _spinAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _spinAnimation.value * 2 * 3.14159, // Full 360° rotation
            child: child,
          );
        },
        child: Image.asset(
          AppConstants.casseroleImagePath,
          width: AppConstants.casseroleSize,
          height: AppConstants.casseroleSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
