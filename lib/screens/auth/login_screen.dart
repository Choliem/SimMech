import 'package:flutter/material.dart';
import '../../core/app_theme.dart'; // Panggil warna tema kita

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil teks inputan user
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Variable untuk menyembunyikan/melihatkan password
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background diambil dari tema (Hitam/Dark Gray)
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. LOGO / ICON (Sementara pakai Icon Obeng)
              const Icon(
                Icons.build_circle_outlined,
                size: 100,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),

              // 2. JUDUL APLIKASI
              Text(
                "SimMech",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Solusi Otomotif Mandiri",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // 3. INPUT EMAIL
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. INPUT PASSWORD
              TextField(
                controller: _passwordController,
                obscureText: _isObscure, // Biar titik-titik
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure; // Tombol mata ditekan
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 5. TOMBOL LOGIN
              ElevatedButton(
                onPressed: () {
                  // Nanti kita isi logika login Firebase disini
                  print("Login ditekan: ${_emailController.text}");
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  "MASUK",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 16),

              // 6. TOMBOL DAFTAR
              TextButton(
                onPressed: () {
                  // Nanti arahkan ke Register Screen
                },
                child: const Text("Belum punya akun? Daftar Sekarang"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
