import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';
import 'chat_screen.dart';

class ChatUserSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final currentUser = authVM.user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Start a Chat'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
        elevation: 1,
      ),
      body: FutureBuilder<List<User>>(
        future: authVM.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final users =
              snapshot.data!.where((u) => u.id != currentUser?.id).toList();
          if (users.isEmpty) {
            return Center(child: Text('No other users found.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => Divider(),
            itemBuilder: (context, i) {
              final user = users[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.teal[100],
                  child: Icon(Icons.person, color: Colors.teal[700]),
                ),
                title: Text(user.name),
                subtitle: Text(_roleLabel(user.role)),
                trailing: Icon(Icons.chat_bubble_outline, color: Colors.teal),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        peerUser: user,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
          if (index == 1) Navigator.pushReplacementNamed(context, '/inventory');
          if (index == 3) Navigator.pushReplacementNamed(context, '/profile');
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory), label: 'Inventory'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
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
