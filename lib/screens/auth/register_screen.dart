import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart'; // Agar bisa langsung masuk setelah daftar

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Gabung SimMech 🛠️",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Mulai perawatan mandiri kendaraanmu hari ini.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              // INPUT NAMA
              _buildInput(_nameController, "Nama Lengkap", Icons.person),
              const SizedBox(height: 16),

              // INPUT EMAIL
              _buildInput(
                _emailController,
                "Email",
                Icons.email,
                isEmail: true,
              ),
              const SizedBox(height: 16),

              // INPUT PASSWORD
              _buildInput(
                _passwordController,
                "Password (Min 6 Karakter)",
                Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 16),

              // INPUT CONFIRM PASSWORD
              _buildInput(
                _confirmPassController,
                "Ulangi Password",
                Icons.lock_clock,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // TOMBOL DAFTAR
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : _handleRegister, // Matikan tombol kalau loading
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isEmail = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleRegister() async {
    // 1. Validasi Input Kosong
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showError("Semua kolom wajib diisi!");
      return;
    }

    // 2. Validasi Password Match
    if (_passwordController.text != _confirmPassController.text) {
      _showError("Password tidak sama!");
      return;
    }

    setState(() => _isLoading = true); // Mulai Loading

    // 3. Panggil Service
    String? result = await AuthService().register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false); // Stop Loading

    // 4. Cek Hasil
    if (result == null) {
      // BERHASIL
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pendaftaran Berhasil!"),
          backgroundColor: Colors.green,
        ),
      );

      // Langsung masuk ke Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      // GAGAL
      _showError(result);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
