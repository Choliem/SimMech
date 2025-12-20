import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../chat/chat_screen.dart';
import '../auth/login_screen.dart';

class ExpertDashboardScreen extends StatelessWidget {
  const ExpertDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String currentExpertId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Expert"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.cardColor,
            width: double.infinity,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo, Expert! 👨‍🔧",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Silakan jawab pertanyaan user di bawah ini.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // LIST CHAT MASUK
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Ambil chat dimana Expert terlibat
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('users', arrayContains: currentExpertId)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
                var chats = snapshot.data!.docs;

                if (chats.isEmpty)
                  return const Center(
                    child: Text(
                      "Belum ada konsultasi masuk.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );

                return ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Colors.grey),
                  itemBuilder: (context, index) {
                    var data = chats[index].data() as Map<String, dynamic>;

                    // Cari ID User (Lawan Bicara)
                    List<dynamic> users = data['users'];
                    String otherUserId = users.firstWhere(
                      (id) => id != currentExpertId,
                      orElse: () => "",
                    );
                    String senderName = data['user_name'] ?? 'User';

                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
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
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(
                        Icons.chat_bubble_outline,
                        color: AppTheme.primaryColor,
                      ),
                      onTap: () {
                        // Buka Chat Room
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
          ),
        ],
      ),
    );
  }
}
