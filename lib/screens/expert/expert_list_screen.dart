import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../../services/database_service.dart';
import '../premium/upgrade_screen.dart';
import '../chat/chat_screen.dart';

class ExpertListScreen extends StatelessWidget {
  const ExpertListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: DatabaseService().getUserStream(),
      builder: (context, snapshot) {
        // Handle Loading Awal
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        var userData = snapshot.data?.data() as Map<String, dynamic>?;

        // Default values agar tidak null error
        List<dynamic> roles = userData?['roles'] ?? ['user'];
        String tier = userData?['tier'] ?? 'free';
        String paymentStatus = userData?['payment_status'] ?? 'none';

        bool isExpert = roles.contains('expert');

        if (isExpert) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Ruang Konsultasi"),
                bottom: const TabBar(
                  indicatorColor: AppTheme.primaryColor,
                  labelColor: AppTheme.primaryColor,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: "Inbox Klien", icon: Icon(Icons.inbox)),
                    Tab(text: "List Expert", icon: Icon(Icons.list)),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildExpertInbox(context),
                  _buildUserView(context, tier, paymentStatus),
                ],
              ),
              // OPTIONAL: FAB untuk Expert mencari User Premium
              floatingActionButton: isExpert
                  ? FloatingActionButton(
                      backgroundColor: AppTheme.primaryColor,
                      child: const Icon(Icons.add_comment, color: Colors.black),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Fitur cari user premium (Coming Soon)",
                            ),
                          ),
                        );
                      },
                    )
                  : null,
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Konsultasi Expert")),
          body: _buildUserView(context, tier, paymentStatus),
        );
      },
    );
  }

  // --- TAB 1: INBOX EXPERT (WHATSAPP STYLE) ---
  Widget _buildExpertInbox(BuildContext context) {
    final String myUid = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      // Query ini butuh Composite Index (Klik link di error log console jika merah)
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: myUid)
          .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Tampilkan pesan error yang bisa dicopy user
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SelectableText(
                "Error Database: ${snapshot.error}\n\n(Klik link di console untuk buat Index)",
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var chats = snapshot.data?.docs ?? [];

        if (chats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.mark_chat_unread_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  "Belum ada pesan masuk.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: chats.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            var data = chats[index].data() as Map<String, dynamic>;

            // Safety: Handle jika field user_ids belum ada (data lama)
            Map<String, dynamic> userMap = data['user_ids'] ?? {};

            // Cari ID lawan bicara
            List<dynamic> users = data['users'] ?? [];
            String otherUserId = users.firstWhere(
              (id) => id != myUid,
              orElse: () => "",
            );
            String otherUserName =
                userMap[otherUserId] ?? "User"; // Default Name

            // Status Read
            bool isUnread =
                !(data['isRead'] ?? true) && (data['lastSenderId'] != myUid);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              tileColor: AppTheme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              leading: CircleAvatar(
                backgroundColor: isUnread
                    ? AppTheme.primaryColor
                    : Colors.grey[800],
                foregroundColor: isUnread ? Colors.black : Colors.white,
                child: Text(
                  otherUserName.isNotEmpty
                      ? otherUserName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                otherUserName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  data['lastMessage'] ?? '...',
                  style: TextStyle(
                    color: isUnread ? Colors.white : Colors.grey,
                    fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow
                      .ellipsis, // PENTING: Mencegah RenderFlex Overflow
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isUnread)
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const Icon(
                      Icons.done_all,
                      size: 16,
                      color: Colors.blueGrey,
                    ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      receiverId: otherUserId,
                      receiverName: otherUserName,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // --- TAB 2: LIST EXPERT (TAMPILAN USER) ---
  Widget _buildUserView(
    BuildContext context,
    String tier,
    String paymentStatus,
  ) {
    bool isPremium = tier == 'premium';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isPremium)
            _buildUpgradeBanner(context, paymentStatus)
          else
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Akun Premium Aktif.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          const Text(
            "Daftar Expert:",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('roles', arrayContains: 'expert')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              var experts = snapshot.data!.docs;
              // Filter diri sendiri
              String myUid = FirebaseAuth.instance.currentUser!.uid;
              var filtered = experts.where((e) => e.id != myUid).toList();

              if (filtered.isEmpty)
                return const Text(
                  "Belum ada expert lain.",
                  style: TextStyle(color: Colors.grey),
                );

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  var data = filtered[index].data() as Map<String, dynamic>;
                  return _buildExpertCard(
                    context,
                    data['name'] ?? 'Expert',
                    data['expertise'] ?? 'Umum',
                    tier,
                    filtered[index].id,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper Widgets (Banner & Card)
  Widget _buildExpertCard(
    BuildContext context,
    String name,
    String role,
    String userTier,
    String expertId,
  ) {
    bool isLocked = userTier == 'free';
    return Card(
      color: AppTheme.cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : 'E')),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(role, style: const TextStyle(color: Colors.grey)),
        trailing: Icon(
          isLocked ? Icons.lock : Icons.chat,
          color: isLocked ? Colors.red : Colors.green,
        ),
        onTap: () {
          if (isLocked) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UpgradeScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ChatScreen(receiverId: expertId, receiverName: name),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildUpgradeBanner(BuildContext context, String status) {
    // Versi simple untuk hemat baris
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            "Fitur Terkunci",
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UpgradeScreen()),
            ),
            child: const Text("Upgrade Sekarang"),
          ),
        ],
      ),
    );
  }
}
