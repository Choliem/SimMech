import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Kotak Masuk")),
      body: StreamBuilder<QuerySnapshot>(
        // Ambil notifikasi milik user ini, urutkan dari terbaru
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('user_id', isEqualTo: uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          var notifs = snapshot.data!.docs;

          if (notifs.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada pesan baru.",
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            itemCount: notifs.length,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.grey),
            itemBuilder: (context, index) {
              var data = notifs[index].data() as Map<String, dynamic>;
              bool isRead = data['is_read'] ?? false;

              return ListTile(
                tileColor: isRead
                    ? Colors.transparent
                    : AppTheme.cardColor.withOpacity(0.5),
                leading: Icon(
                  data['type'] == 'success' ? Icons.check_circle : Icons.error,
                  color: data['type'] == 'success' ? Colors.green : Colors.red,
                ),
                title: Text(
                  data['title'] ?? 'Info',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  data['message'] ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  _formatDate(data['created_at']),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
                onTap: () {
                  // Tandai sudah dibaca
                  FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notifs[index].id)
                      .update({'is_read': true});
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month} ${date.hour}:${date.minute}";
  }
}
