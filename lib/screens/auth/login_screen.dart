import 'package:flutter/material.dart';
import '../../core/app_theme.dart'; // Panggil warna tema
import '../../services/auth_service.dart'; // Panggil logika Auth
import '../main_navigation.dart';
import 'register_screen.dart';

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

  // (Opsional) Membersihkan memori saat halaman ditutup
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background diambil otomatis dari tema (Hitam/Dark Gray)
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. LOGO / ICON
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
                keyboardType: TextInputType.emailAddress,
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

              // 5. TOMBOL LOGIN (YANG SUDAH DIUPDATE)
              ElevatedButton(
                onPressed: () async {
                  // A. Ambil teks dari inputan & Hapus spasi
                  String email = _emailController.text.trim();
                  String password = _passwordController.text.trim();

                  // B. Cek apakah kosong
                  if (email.isEmpty || password.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Email dan Password harus diisi!"),
                      ),
                    );
                    return;
                  }

                  // C. Panggil Service Login
                  // (Bisa tambahkan loading indicator disini nanti)
                  String? result = await AuthService().login(
                    email: email,
                    password: password,
                  );

                  // D. Cek Hasil Login
                  if (result == null) {
                    // SUKSES (Result null artinya tidak ada error)
                    if (!mounted) return; // Cek apakah layar masih aktif

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Login BERHASIL! Selamat Datang."),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Nanti disini kita pindah ke Home Screen:
                    // Navigator.pushReplacement(context, MaterialPageRoute(...));

                    // Pindah ke MainNavigation dan hapus Login dari sejarah (biar gak bisa di-back)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainNavigation(),
                      ),
                    );
                  } else {
                    // GAGAL (Result berisi pesan error)
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Gagal: $result"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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

              // 6. TOMBOL DAFTAR (Placeholder)
              TextButton(
                onPressed: () {
                  // PINDAH KE REGISTER SCREEN
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
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
