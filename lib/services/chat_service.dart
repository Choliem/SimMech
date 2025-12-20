import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. GENERATE CHAT ID (Unik berdasarkan pasangan user)
  String getChatRoomId(String userA, String userB) {
    List<String> ids = [userA, userB];
    ids.sort(); // Urutkan abjad agar ID selalu sama: "A_B"
    return ids.join("_");
  }

  // 2. KIRIM PESAN (FIXED)
  Future<void> sendMessage(
    String receiverId,
    String message,
    String receiverName,
  ) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserName = _auth.currentUser!.displayName ?? "User";
    final Timestamp timestamp = Timestamp.now();

    String chatRoomId = getChatRoomId(currentUserId, receiverId);

    // Data Pesan Baru
    Map<String, dynamic> newMessage = {
      'senderId': currentUserId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
      'isRead': false, // Untuk notifikasi titik merah
    };

    // Data Room (Untuk List Inbox)
    Map<String, dynamic> roomData = {
      'chatRoomId': chatRoomId,
      'users': [
        currentUserId,
        receiverId,
      ], // PENTING: Array ini dipakai query where('users', arrayContains: myId)
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'user_ids': {
        // Map untuk ambil nama lawan bicara lebih mudah
        currentUserId: currentUserName,
        receiverId: receiverName,
      },
      'lastSenderId': currentUserId,
      'isRead': false,
    };

    // Batch Write agar atomik (sukses semua atau gagal semua)
    WriteBatch batch = _db.batch();

    // Simpan pesan ke subcollection
    DocumentReference msgRef = _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .doc();
    batch.set(msgRef, newMessage);

    // Update data room utama (merge true agar tidak menimpa data lain jika ada)
    DocumentReference roomRef = _db.collection('chats').doc(chatRoomId);
    batch.set(roomRef, roomData, SetOptions(merge: true));

    await batch.commit();
  }

  // 3. AMBIL PESAN (STREAM)
  Stream<QuerySnapshot> getMessages(String receiverId) {
    String currentUserId = _auth.currentUser!.uid;
    String chatRoomId = getChatRoomId(currentUserId, receiverId);

    return _db
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // 4. MARK AS READ (Tandai sudah dibaca)
  Future<void> markAsRead(String receiverId) async {
    String currentUserId = _auth.currentUser!.uid;
    String chatRoomId = getChatRoomId(currentUserId, receiverId);

    // Hanya update jika pesan terakhir bukan saya yang kirim
    var doc = await _db.collection('chats').doc(chatRoomId).get();
    if (doc.exists && doc['lastSenderId'] != currentUserId) {
      await _db.collection('chats').doc(chatRoomId).update({'isRead': true});
    }
  }
}
