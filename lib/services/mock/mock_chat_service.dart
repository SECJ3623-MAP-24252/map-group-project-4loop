import '../chat_service.dart';
import '../../models/chat_message.dart';
import 'dart:async';

class MockChatService implements ChatService {
  final Map<String, List<ChatMessage>> _chats = {
    'pharmacy1': [
      ChatMessage(
        id: '1',
        senderId: '2',
        senderName: 'Michael Chen',
        message: 'Hi Michael, can you check the Aspirin stock?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isMine: false,
      ),
      ChatMessage(
        id: '2',
        senderId: '3',
        senderName: 'Sarah Johnson',
        message: 'Sure! We have 45 units left. Should I reorder?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isMine: true,
      ),
      ChatMessage(
        id: '3',
        senderId: '2',
        senderName: 'Michael Chen',
        message: 'Yes, please order 100 more units',
        timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
        isMine: false,
      ),
    ],
  };

  final Map<String, StreamController<List<ChatMessage>>> _controllers = {};

  @override
  Future<List<ChatMessage>> getMessages(
      String chatId, String currentUserId) async {
    // The mock service doesn't need currentUserId, but we accept it to match the interface.
    return List<ChatMessage>.from(_chats[chatId] ?? []);
  }

  @override
  Future<void> sendMessage(String chatId, ChatMessage message) async {
    _chats.putIfAbsent(chatId, () => []);
    _chats[chatId]!.add(message);
    _controllers[chatId]?.add(List<ChatMessage>.from(_chats[chatId]!));
  }

  @override
  Stream<List<ChatMessage>> getMessagesStream(
      String chatId, String currentUserId) {
    // The mock service doesn't need currentUserId, but we accept it to match the interface.
    _controllers.putIfAbsent(
        chatId, () => StreamController<List<ChatMessage>>.broadcast());
    _controllers[chatId]!.add(List<ChatMessage>.from(_chats[chatId] ?? []));
    return _controllers[chatId]!.stream;
  }
}
