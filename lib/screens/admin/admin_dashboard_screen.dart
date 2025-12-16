import 'dart:convert'; // Wajib untuk decode gambar Base64
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/app_theme.dart';
import '../chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==========================================
// 1. MENU UTAMA ADMIN (DASHBOARD)
// ==========================================
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminMenu(
            context,
            "Verifikasi Pembayaran",
            Icons.payment,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentVerificationScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminMenu(
            context,
            "Manajemen User (Ban/Unban)",
            Icons.people_alt,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserManagementScreen(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildAdminMenu(
            context,
            "Inbox Konsultasi",
            Icons.chat,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminChatInboxScreen(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMenu(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      color: AppTheme.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2), // Fix Deprecated
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN VERIFIKASI PEMBAYARAN
// ==========================================
class PaymentVerificationScreen extends StatelessWidget {
  const PaymentVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verifikasi Pembayaran")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('payment_status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var requests = snapshot.data!.docs;

          if (requests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Semua pembayaran sudah diverifikasi.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              var user = requests[index];
              var data = user.data() as Map<String, dynamic>;

              String? base64Image = data['payment_proof_base64'];

              return Card(
                color: AppTheme.cardColor,
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TAMPILAN BUKTI FOTO
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: base64Image != null
                          ? Image.memory(
                              base64Decode(base64Image),
                              height: 250,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const SizedBox(
                                    height: 200,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                            )
                          : const SizedBox(
                              height: 150,
                              child: Center(
                                child: Text(
                                  "Tidak ada bukti gambar",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                data['name'] ?? 'Tanpa Nama',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['email'] ?? '',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const Divider(color: Colors.grey, height: 24),

                          // TOMBOL AKSI
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _showRejectDialog(context, user.id),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.redAccent,
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text("TOLAK"),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _approveUser(context, user.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    "TERIMA (PREMIUM)",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- LOGIC TERIMA (APPROVE) ---
  Future<void> _approveUser(BuildContext context, String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'payment_status': 'verified',
        'tier': 'premium',
        'payment_proof_base64': FieldValue.delete(),
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'user_id': uid,
        'title': 'Upgrade Premium Berhasil! 🎉',
        'message':
            'Selamat! Pembayaranmu sudah diverifikasi. Nikmati fitur konsultasi Expert sepuasnya.',
        'type': 'success',
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });

      // Fix Async Gap: Cek mounted sebelum pakai context
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User berhasil di-upgrade!")),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- LOGIC TOLAK (REJECT) ---
  void _showRejectDialog(BuildContext context, String uid) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text(
          "Alasan Penolakan",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Misal: Bukti buram / Nominal salah",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .update({
                    'payment_status': 'rejected',
                    'rejection_reason': reasonController.text,
                    'payment_proof_base64': FieldValue.delete(),
                  });

              await FirebaseFirestore.instance.collection('notifications').add({
                'user_id': uid,
                'title': 'Upgrade Ditolak ⚠️',
                'message':
                    'Maaf, pembayaranmu ditolak. Alasan: ${reasonController.text}',
                'type': 'error',
                'is_read': false,
                'created_at': FieldValue.serverTimestamp(),
              });

              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Penolakan terkirim.")),
              );
            },
            child: const Text(
              "Kirim Penolakan",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 3. HALAMAN MANAJEMEN USER (BAN/UNBAN)
// ==========================================
class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen User")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var users = snapshot.data!.docs;

          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              var data = users[index].data() as Map<String, dynamic>;
              bool isBanned = data['is_banned'] ?? false;
              String email = data['email'] ?? '';

              List<dynamic> roles = data['roles'] ?? [];
              if (roles.contains('admin')) {
                return const SizedBox.shrink(); // Hide Admin
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isBanned ? Colors.red : Colors.green,
                  child: Icon(
                    isBanned ? Icons.block : Icons.person,
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  "${data['name'] ?? 'User'} (${data['tier'] ?? 'free'})",
                  style: TextStyle(
                    color: isBanned ? Colors.grey : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  email,
                  style: const TextStyle(color: Colors.grey),
                ),
                trailing: ElevatedButton.icon(
                  onPressed: () {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(users[index].id)
                        .update({'is_banned': !isBanned});

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBanned ? "User di-Unban" : "User berhasil di-Ban",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBanned
                        ? Colors.green
                        : Colors.red.withValues(alpha: 0.2), // Fix Deprecated
                    foregroundColor: isBanned ? Colors.white : Colors.red,
                  ),
                  icon: Icon(
                    isBanned ? Icons.lock_open : Icons.lock_outline,
                    size: 16,
                  ),
                  label: Text(isBanned ? "Unban" : "Ban User"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 4. HALAMAN INBOX CHAT ADMIN
// ==========================================
class AdminChatInboxScreen extends StatelessWidget {
  const AdminChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String currentAdminId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Inbox Konsultasi")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: currentAdminId)
            .orderBy('lastMessageTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var chats = snapshot.data!.docs;

          if (chats.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada chat masuk.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              var data = chats[index].data() as Map<String, dynamic>;

              String senderName = data['user_name'] ?? 'User';
              List<dynamic> users = data['users'];
              String otherUserId = users.firstWhere(
                (id) => id != currentAdminId,
                orElse: () => "",
              );

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(
                  senderName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  data['lastMessage'] ?? '',
                  style: const TextStyle(color: Colors.grey),
                  maxLines: 1,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        receiverId: otherUserId,
                        receiverName: senderName,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
