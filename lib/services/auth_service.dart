import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini

class AuthService {
  // Mengambil instance FirebaseAuth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi Login
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Login ke Firebase Auth
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. CEK STATUS BAN DI FIRESTORE
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .get();

      if (userDoc.exists) {
        bool isBanned = userDoc['is_banned'] ?? false;
        if (isBanned) {
          await logout(); // Langsung logout lagi
          return 'Akun ini telah dibekukan Admin.';
        }
      }

      return null; // Sukses & Aman
    } on FirebaseAuthException catch (e) {
      // ... error handling lama ...
      if (e.code == 'user-not-found') return 'Email tidak terdaftar.';
      if (e.code == 'wrong-password') return 'Password salah.';
      return e.message;
    } catch (e) {
      return 'Terjadi kesalahan sistem.';
    }
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Cek user yang sedang login
  User? get currentUser => _auth.currentUser;

  // FUNGSI REGISTRASI BARU
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Buat Akun di Firebase Auth (Email & Pass)
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Siapkan Data User Default
      String uid = cred.user!.uid;

      // 3. Simpan Data Profil ke Firestore (Database)
      // DISINI KITA SET DEFAULT TIER = FREE
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'uid': uid,
        'name': name,
        'email': email,
        'roles': ['user'], // Default role
        'tier': 'free', // Default tier
        'payment_status': 'none',
        'is_banned': false,
        'is_verified_seller': false,
        'created_at': FieldValue.serverTimestamp(),
        'my_garage': null, // Belum pilih mobil
      });

      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email sudah terdaftar.';
      } else if (e.code == 'weak-password') {
        return 'Password terlalu lemah (min 6 karakter).';
      }
      return e.message;
    } catch (e) {
      return 'Gagal mendaftar: $e';
    }
  }
}
