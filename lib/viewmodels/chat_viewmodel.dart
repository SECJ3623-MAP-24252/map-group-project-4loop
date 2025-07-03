import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/user.dart';
import '../services/chat_service.dart';
import '../services/firebase/firebase_chat_service.dart';
import '../main.dart';
import '../viewmodels/notification_viewmodel.dart';
import 'package:provider/provider.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _chatService = FirebaseChatService();
  final User? currentUser;

  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;
  String? _error;
  String? get error => _error;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Stream<List<ChatMessage>>? _chatStream;

  ChatViewModel(this.currentUser);

  void loadMessages(String chatId) {
    if (currentUser == null) return;
    _isLoading = true;
    notifyListeners();
    _chatStream = _chatService.getMessagesStream(chatId, currentUser!.id);
    _chatStream!.listen((data) {
      if (_messages.isNotEmpty && data.length > _messages.length) {
        final newMsg = data.first;
        if (!newMsg.isMine) {
          final context = navigatorKey.currentContext;
          if (context != null) {
            final notificationVM =
                Provider.of<NotificationViewModel>(context, listen: false);
            if (ModalRoute.of(context)?.settings.name != '/chat') {
              notificationVM.addChatNotification();
            }
          }
        }
      }
      _messages = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String chatId, String messageText) async {
    if (currentUser == null) return;

    final newMessage = ChatMessage(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Firestore will assign an ID
      senderId: currentUser!.id,
      senderName: currentUser!.name,
      message: messageText,
      timestamp: DateTime.now(),
      isMine: true,
    );
    await _chatService.sendMessage(chatId, newMessage);
    // No need to reload, stream will update
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
