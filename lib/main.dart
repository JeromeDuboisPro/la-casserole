import 'package:flutter/material.dart';
import 'presentation/screens/home_screen.dart';
import 'core/constants/app_constants.dart';

void main() {
  runApp(const LaCasseroleApp());
}

class LaCasseroleApp extends StatelessWidget {
  const LaCasseroleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
