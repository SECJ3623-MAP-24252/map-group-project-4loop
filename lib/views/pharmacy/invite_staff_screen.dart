import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';

class InviteStaffScreen extends StatefulWidget {
  @override
  _InviteStaffScreenState createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _searchController = TextEditingController();
  // This set will hold the IDs of users who have been invited in this session.
  final Set<String> _invitedUserIds = {};

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    final currentUser = authVM.user;

    // We must have a logged-in pharmacist to use this screen.
    if (currentUser == null || currentUser.role != UserRole.pharmacist) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Access Denied: Pharmacist Only')),
      );
    }

    // We need the pharmacist's pharmacyId to invite someone.
    final pharmacyId = currentUser.pharmacyId;
    if (pharmacyId == null || pharmacyId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Invite Staff')),
        body:
            Center(child: Text('Error: Your pharmacy profile is not set up.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Staff',
            style: TextStyle(
                color: Colors.teal[800], fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.teal),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.teal[50],
                          child: Icon(Icons.group_add,
                              size: 40, color: Colors.teal[700]),
                        ),
                        SizedBox(height: 12),
                        Text('Invite Staff',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800])),
                        SizedBox(height: 4),
                        Text('Add staff to your pharmacy branch',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search staff by name or email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (val) => setState(() {}),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: FutureBuilder<List<User>>(
                      // Fetch ALL users who are unassigned staff/stock managers
                      future: authVM.getUnassignedStaff(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                              child: Text('No unassigned staff found.'));
                        }

                        // Filter out the current user and apply search query
                        final searchQuery =
                            _searchController.text.toLowerCase();
                        final availableStaff =
                            snapshot.data!.where((staffUser) {
                          final nameMatches = staffUser.name
                              .toLowerCase()
                              .contains(searchQuery);
                          final emailMatches = staffUser.email
                              .toLowerCase()
                              .contains(searchQuery);
                          return staffUser.id != currentUser.id &&
                              (nameMatches || emailMatches);
                        }).toList();

                        if (availableStaff.isEmpty) {
                          return Center(
                              child: Text('No users match your search.'));
                        }

                        return ListView.builder(
                          itemCount: availableStaff.length,
                          itemBuilder: (context, i) {
                            final staffMember = availableStaff[i];
                            // Check if this user has already been invited in this session
                            final bool hasBeenInvited =
                                _invitedUserIds.contains(staffMember.id);

                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              elevation: 2,
                              margin: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                    child: Icon(Icons.person,
                                        color: Colors.teal[700])),
                                title: Text(staffMember.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(staffMember.email),
                                trailing: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasBeenInvited
                                        ? Colors.white
                                        : Colors.teal,
                                    foregroundColor: hasBeenInvited
                                        ? Colors.grey
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    side: hasBeenInvited
                                        ? BorderSide(
                                            color: Colors.grey.shade300)
                                        : BorderSide.none,
                                  ),
                                  // Disable button if invited
                                  onPressed: hasBeenInvited
                                      ? null
                                      : () async {
                                          // ---- This is now connected to the backend ----
                                          final success =
                                              await authVM.inviteUserToPharmacy(
                                                  staffMember.id, pharmacyId);

                                          if (success) {
                                            setState(() {
                                              _invitedUserIds
                                                  .add(staffMember.id);
                                            });
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Invitation sent to ${staffMember.name}')),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Error: Could not send invitation.')),
                                            );
                                          }
                                        },
                                  child:
                                      Text(hasBeenInvited ? 'Sent' : 'Invite'),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
