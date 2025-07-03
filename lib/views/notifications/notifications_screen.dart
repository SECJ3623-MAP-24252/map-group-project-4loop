import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/notification_viewmodel.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notificationVM = Provider.of<NotificationViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;

    // Check if there's a pending invitation
    final hasPendingInvitation =
        user?.pendingPharmacyId != null && user!.pendingPharmacyId!.isNotEmpty;

    // Mark all as read when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notificationVM.markAllRead();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- PENDING INVITATION BANNER ---
            if (hasPendingInvitation) ...[
              Card(
                color: Colors.orange[50],
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You have a pending invitation to join a pharmacy.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                              fontSize: 16)),
                      SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: Icon(Icons.check_circle_outline),
                        label: Text('Accept Invitation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          final success = await authVM
                              .acceptInvitation(user.pendingPharmacyId!);
                          if (context.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Invitation accepted! Welcome to the pharmacy.'),
                                    backgroundColor: Colors.green),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Error: Could not accept invitation.'),
                                    backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],

            // --- Other Notifications ---
            Expanded(
              child: notificationVM.notifications.isEmpty
                  ? Center(
                      child: hasPendingInvitation
                          ? const SizedBox.shrink()
                          : Text('No other notifications yet.'),
                    )
                  : ListView.builder(
                      itemCount: notificationVM.notifications.length,
                      itemBuilder: (context, i) {
                        final notif = notificationVM.notifications[i];
                        return ListTile(
                          leading: Icon(Icons.notifications),
                          title: Text(notif.title),
                          subtitle: Text(notif.body),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
