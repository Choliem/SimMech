import 'package:flutter/material.dart';
import 'core/app_theme.dart'; // Import file tema yang baru kita buat

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

      // GUNAKAN TEMA DI SINI
      theme: AppTheme.darkTheme,

      home: Scaffold(
        appBar: AppBar(title: const Text("SimMech Prototype")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to SimMech",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {},
                child: const Text("Tes Tombol Kuning"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
