import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'screens/auth/login_screen.dart'; // <--- Tambahan Baru

void main() {
  runApp(const SimMechApp());
}

class SimMechApp extends StatelessWidget {
  const SimMechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SimMech',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(), // <--- Kita ganti ini jadi LoginScreen
    );
  }
}
