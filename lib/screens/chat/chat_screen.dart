import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // WAJIB: Tambahkan package intl di pubspec.yaml jika belum ada
import '../../core/app_theme.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ScrollController _scrollController =
      ScrollController(); // Untuk Auto Scroll

  @override
  void initState() {
    super.initState();
    // Tandai sudah dibaca saat masuk screen
    _chatService.markAsRead(widget.receiverId);
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      String msg = _messageController.text;
      _messageController.clear();

      await _chatService.sendMessage(
        widget.receiverId,
        msg,
        widget.receiverName,
      );

      // Auto Scroll ke bawah setelah kirim
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent +
            60, // Tambah offset sedikit
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentUserId = _auth.currentUser!.uid;
    // PENTING: Gunakan logic ID yang sama persis dengan service
    String chatRoomId = _chatService.getChatRoomId(
      currentUserId,
      widget.receiverId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: Text(
                widget.receiverName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.receiverName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Text(
                    "Online",
                    style: TextStyle(fontSize: 12, color: Colors.greenAccent),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardColor,
      ),
      body: Column(
        children: [
          // 1. LIST PESAN
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatRoomId)
                  .collection('messages')
                  .orderBy(
                    'timestamp',
                    descending: false,
                  ) // Urutkan dari lama ke baru
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Auto Scroll ke bawah saat pesan baru masuk (First Load)
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;
                    return _buildMessageItem(data, currentUserId);
                  },
                );
              },
            ),
          ),

          // 2. INPUT FIELD
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> data, String currentUserId) {
    bool isMe = data['senderId'] == currentUserId;

    // Konversi Timestamp ke Jam (HH:mm)
    Timestamp? ts = data['timestamp'];
    String time = ts != null ? DateFormat('HH:mm').format(ts.toDate()) : "..";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.primaryColor
              : Colors.grey[800], // Kuning (Saya) vs Abu (Lawan)
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        constraints: const BoxConstraints(
          maxWidth: 280,
        ), // Biar bubble gak kepanjangan
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Bungkus konten sekompak mungkin
          children: [
            Text(
              data['message'] ?? '',
              style: TextStyle(
                color: isMe
                    ? Colors.black
                    : Colors.white, // Teks Hitam di Kuning, Putih di Abu
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isMe ? Colors.black54 : Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    (data['isRead'] ?? false) ? Icons.done_all : Icons.done,
                    size: 12,
                    color: (data['isRead'] ?? false)
                        ? Colors.blue
                        : Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: AppTheme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade800),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Ketik pesan...",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => sendMessage(), // Kirim saat tekan Enter
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            radius: 24,
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(Icons.send, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
