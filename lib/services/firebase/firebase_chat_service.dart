import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:apptracker/models/chat_message.dart';
import 'package:apptracker/services/chat_service.dart';

class FirebaseChatService implements ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference _getMessagesCollection(String chatId) {
    return _firestore.collection('chats').doc(chatId).collection('messages');
  }

  @override
  Future<List<ChatMessage>> getMessages(
      String chatId, String currentUserId) async {
    final snapshot =
        await _getMessagesCollection(chatId).orderBy('timestamp').get();
    return snapshot.docs
        .map((doc) => ChatMessage.fromMap(
            doc.data() as Map<String, dynamic>, doc.id, currentUserId))
        .toList();
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(
      String chatId, String currentUserId) {
    return _getMessagesCollection(chatId)
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromMap(
              doc.data() as Map<String, dynamic>, doc.id, currentUserId))
          .toList();
    });
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    await _getMessagesCollection(chatId).add(message.toMap());
  }
}
