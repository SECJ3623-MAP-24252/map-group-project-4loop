import '../models/chat_message.dart';

abstract class ChatService {
  Future<List<ChatMessage>> getMessages(String chatId, String currentUserId);
  Future<void> sendMessage(String chatId, ChatMessage message);
  Stream<List<ChatMessage>> getMessagesStream(
      String chatId, String currentUserId);
}
