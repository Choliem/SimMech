import 'dart:convert'; // Wajib untuk encode Base64
import 'dart:typed_data'; // Wajib untuk menampung data gambar (Uint8List)
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_theme.dart';

class UpgradeScreen extends StatefulWidget {
  const UpgradeScreen({super.key});

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  bool _isLoading = false;
  String? _base64Image; // Variabel tunggal untuk menyimpan data gambar (Teks)

  // FUNGSI PILIH GAMBAR (VERSI UNIVERSAL: WEB & ANDROID AMAN)
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      // Kompresi ke 25% agar string tidak kepanjangan dan muat di Firestore
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 25,
      );

      if (pickedFile != null) {
        // PENTING: Gunakan readAsBytes() agar jalan di Web
        // Jangan gunakan File(pickedFile.path) karena Web tidak punya Path sistem
        final Uint8List bytes = await pickedFile.readAsBytes();
        final String base64String = base64Encode(bytes);

        setState(() {
          _base64Image = base64String;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengambil gambar: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Konfirmasi Pembayaran")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Silakan transfer Rp 50.000 ke:\n\nBCA 123-456-7890\na.n. SimMech Founder",
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // AREA UPLOAD FOTO
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _base64Image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, color: Colors.grey, size: 50),
                          SizedBox(height: 8),
                          Text(
                            "Ketuk untuk upload bukti",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        // TAMPILKAN PREVIEW DARI MEMORI (BASE64)
                        child: Image.memory(
                          base64Decode(_base64Image!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error, color: Colors.red),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // TOMBOL KIRIM (Mati jika belum ada foto atau sedang loading)
            ElevatedButton(
              onPressed: (_base64Image == null || _isLoading)
                  ? null
                  : _handleUploadAndSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
                disabledBackgroundColor: Colors.grey,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.black,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "KIRIM BUKTI",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // FUNGSI SUBMIT KE FIRESTORE
  Future<void> _handleUploadAndSubmit() async {
    if (_base64Image == null) return;

    setState(() => _isLoading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Update data user dengan status pending & string gambar
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'payment_status': 'pending',
        'payment_proof_base64': _base64Image, // Simpan teks gambar disini
        'payment_date': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Tampilkan Dialog Sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.cardColor,
          title: const Text(
            "Berhasil Terkirim",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Admin akan memverifikasi bukti Anda. Mohon tunggu notifikasi selanjutnya.",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Tutup Dialog
                Navigator.pop(context); // Tutup Halaman Upgrade
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal mengirim: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
