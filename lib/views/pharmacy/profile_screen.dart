import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacy_viewmodel.dart';
import '../../models/pharmacy.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';
import 'pharmacy_profile_screen.dart';
import 'invite_staff_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pharmacyVM = Provider.of<PharmacyViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;
    final pharmacy = pharmacyVM.pharmacy;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    void _showEditProfileDialog() {
      final nameController = TextEditingController(text: user.name);
      final emailController = TextEditingController(text: user.email);
      final phoneController = TextEditingController(text: user.phone);

      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: Text('Edit Personal Info'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name')),
                TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email')),
                TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone')),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  await authVM.updateUserProfile(nameController.text,
                      emailController.text, phoneController.text);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile updated successfully!')),
                  );
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }

    final hasPendingInvitation =
        user.pendingPharmacyId != null && user.pendingPharmacyId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile',
            style: TextStyle(
                color: Colors.teal[800], fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.teal[50],
                      child:
                          Icon(Icons.person, size: 40, color: Colors.teal[700]),
                    ),
                    SizedBox(height: 12),
                    Text(user.name,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal[800])),
                    SizedBox(height: 4),
                    Text(user.email,
                        style:
                            TextStyle(fontSize: 15, color: Colors.grey[700])),
                    SizedBox(height: 4),
                    Text(user.role.toString().split('.').last,
                        style:
                            TextStyle(fontSize: 15, color: Colors.teal[700])),
                  ],
                ),
              ),
              SizedBox(height: 32),
              Text('Pharmacy',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: pharmacy == null
                      ? Text(user.pharmacyId == null
                          ? 'No pharmacy info available'
                          : 'Loading pharmacy details...')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pharmacy.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 6),
                            Text(pharmacy.address),
                            SizedBox(height: 6),
                            Text('Phone: ${pharmacy.phone}'),
                            SizedBox(height: 6),
                            Text('Email: ${pharmacy.contactEmail}'),
                          ],
                        ),
                ),
              ),
              if (user.isPharmacist) ...[
                SizedBox(height: 18),
                ElevatedButton.icon(
                  icon: Icon(Icons.edit),
                  label: Text('Edit Pharmacy Details'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PharmacyProfileScreen()),
                    );
                  },
                ),
                SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: Icon(Icons.group_add),
                  label: Text('Invite Staff/Manager'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => InviteStaffScreen()),
                    );
                  },
                ),
              ],
              SizedBox(height: 32),
              Text('Personal Info',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 8),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: ${user.name}'),
                      SizedBox(height: 6),
                      Text('Email: ${user.email}'),
                      SizedBox(height: 6),
                      Text('Phone: ${user.phone}'),
                      SizedBox(height: 6),
                      Text('Role: ${user.role.toString().split('.').last}'),
                      SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.edit, size: 18),
                          label: Text('Edit'),
                          onPressed: _showEditProfileDialog,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
              ElevatedButton.icon(
                icon: Icon(Icons.logout),
                label: Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await authVM.logout();
                  if (!context.mounted) return;
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
