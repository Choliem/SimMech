import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_theme.dart';
import '../../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId; // ID Lawan Bicara (Expert/User)
  final String receiverName; // Nama Lawan Bicara

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

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.receiverId,
        _messageController.text,
        widget.receiverName,
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ID Room unik berdasarkan pasangan user ini
    String chatRoomId = _chatService.getChatRoomId(
      _auth.currentUser!.uid,
      widget.receiverId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: AppTheme.cardColor,
      ),
      body: Column(
        children: [
          // 1. LIST PESAN
          Expanded(
            child: StreamBuilder(
              stream: _chatService.getMessages(chatRoomId),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text("Error");
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: snapshot.data!.docs
                      .map((doc) => _buildMessageItem(doc))
                      .toList(),
                );
              },
            ),
          ),

          // 2. INPUT TEXT
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Cek apakah ini pesan saya?
    bool isMe = data['senderId'] == _auth.currentUser!.uid;

    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primaryColor : Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              data['message'],
              style: TextStyle(color: isMe ? Colors.black : Colors.white),
            ),
          ),
          // Text(data['senderName'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.cardColor,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Tulis pesan...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: const Icon(Icons.send, color: AppTheme.primaryColor),
          ),
        ],
      ),
    );
  }
}
