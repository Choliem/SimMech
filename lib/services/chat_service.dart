import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. BUAT / DAPATKAN ID CHAT ROOM
  // Format ID: "userUID_expertUID" (Agar unik untuk pasangan ini)
  String getChatRoomId(String userId, String expertId) {
    // Kita urutkan stringnya agar ID-nya konsisten siapapun yang mulai duluan
    List<String> ids = [userId, expertId];
    ids.sort();
    return ids.join("_");
  }

  // 2. KIRIM PESAN
  Future<void> sendMessage(
    String expertId,
    String message,
    String expertName,
  ) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserName =
        _auth.currentUser!.displayName ?? "User"; // Pastikan user punya nama
    final Timestamp timestamp = Timestamp.now();

    String chatRoomId = getChatRoomId(currentUserId, expertId);

    // Data Pesan
    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'senderName': currentUserName,
      'receiverId': expertId,
      'message': message,
      'timestamp': timestamp,
    };

    // A. Simpan Pesan ke Sub-collection
    await _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage);

    // B. Update Data Chat Room (Biar muncul di list inbox Admin)
    await _db.collection('chats').doc(chatRoomId).set({
      'chatRoomId': chatRoomId,
      'users': [currentUserId, expertId], // Array ID peserta
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'user_name': currentUserName, // Nama User (Biar Admin tau siapa yg chat)
      'expert_name': expertName,
    }, SetOptions(merge: true));
  }

  // 3. AMBIL STREAM PESAN (Realtime)
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false) // Urut dari lama ke baru
        .snapshots();
  }

  // 4. AMBIL LIST CHAT (Untuk Inbox Admin)
  Stream<QuerySnapshot> getAdminChats() {
    String currentAdminId = _auth.currentUser!.uid;
    return _db
        .collection('chats')
        .where(
          'users',
          arrayContains: currentAdminId,
        ) // Ambil chat dimana Admin terlibat
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
