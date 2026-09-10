import 'package:flutter/material.dart';
import '../widgets/casserole_widget.dart';
import '../../core/constants/app_constants.dart';

/// Main home screen displaying the casserole
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Dark background for contrast
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),

              // Subtitle
              const Text(
                'Tapez pour faire du bruit! 🥘',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 60),

              // Casserole widget
              const CasseroleWidget(),

              const SizedBox(height: 60),

              // Simple instruction
              const Text(
                'Tap the casserole',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
