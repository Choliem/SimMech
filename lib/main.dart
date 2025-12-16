import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Wajib import ini
import 'firebase_options.dart'; // File otomatis tadi
import 'core/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  // 1. Pastikan engine Flutter siap dulu
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Nyalakan Firebase sesuai platform (Android/Web)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
      home: const LoginScreen(),
    );
  }
}
