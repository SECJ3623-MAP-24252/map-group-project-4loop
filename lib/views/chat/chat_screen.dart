import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../models/chat_message.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';
import '../../viewmodels/notification_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  final User peerUser;
  const ChatScreen({Key? key, required this.peerUser}) : super(key: key);
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  String get chatId {
    final authVM = Provider.of<AuthViewModel>(context, listen: false);
    final currentUser = authVM.user;
    if (currentUser == null) return '';
    // Unique chatId for 1:1 chat (sorted to ensure same for both users)
    final ids = [currentUser.id, widget.peerUser.id]..sort();
    return ids.join('_');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatViewModel>(context, listen: false).loadMessages(chatId);
      Provider.of<NotificationViewModel>(context, listen: false).markChatRead();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      // Delay slightly to allow the list to build before scrolling
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = Provider.of<ChatViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal[100],
              child: Icon(Icons.person, color: Colors.teal[700]),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.peerUser.name, style: TextStyle(fontSize: 18)),
                Text(_roleLabel(widget.peerUser.role),
                    style: TextStyle(fontSize: 13, color: Colors.teal[700])),
              ],
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: chatVM.messages.length,
                itemBuilder: (context, i) {
                  final msg = chatVM.messages[i];
                  final isMine = msg.isMine;
                  return Align(
                    alignment:
                        isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        mainAxisAlignment: isMine
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMine)
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.teal[100],
                              child:
                                  Icon(Icons.person, color: Colors.teal[700]),
                            ),
                          if (!isMine) SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isMine ? Colors.teal[100] : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                  bottomLeft: Radius.circular(isMine ? 18 : 4),
                                  bottomRight: Radius.circular(isMine ? 4 : 18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMine
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Text(msg.message,
                                      style: TextStyle(fontSize: 16)),
                                  SizedBox(height: 4),
                                  Text(
                                    _formatTime(msg.timestamp),
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isMine) SizedBox(width: 8),
                          if (isMine)
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.teal[200],
                              child:
                                  Icon(Icons.person, color: Colors.teal[900]),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () async {
                        if (_messageController.text.trim().isEmpty ||
                            user == null) return;

                        await chatVM.sendMessage(
                            chatId, _messageController.text.trim());
                        _messageController.clear();
                        _scrollToBottom();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/dashboard');
          if (index == 1) Navigator.pushNamed(context, '/inventory');
          if (index == 3) Navigator.pushNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.pharmacist:
        return 'Pharmacist';
      case UserRole.stockManager:
        return 'Stock Manager';
      case UserRole.staff:
        return 'Staff';
      default:
        return '';
    }
  }
}
