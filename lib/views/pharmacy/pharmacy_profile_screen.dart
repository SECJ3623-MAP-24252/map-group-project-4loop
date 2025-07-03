import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/pharmacy_viewmodel.dart';
import '../../models/pharmacy.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';

class PharmacyProfileScreen extends StatefulWidget {
  @override
  _PharmacyProfileScreenState createState() => _PharmacyProfileScreenState();
}

class _PharmacyProfileScreenState extends State<PharmacyProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final pharmacyVM = Provider.of<PharmacyViewModel>(context);
    final authVM = Provider.of<AuthViewModel>(context);
    final user = authVM.user;
    if (user == null || user.role != UserRole.pharmacist) {
      return Scaffold(
        body: Center(child: Text('Access Denied: Pharmacist Only')),
      );
    }
    final pharmacy = pharmacyVM.pharmacy;
    final nameController = TextEditingController(text: pharmacy?.name ?? '');
    final addressController =
        TextEditingController(text: pharmacy?.address ?? '');
    final phoneController = TextEditingController(text: pharmacy?.phone ?? '');
    final emailController =
        TextEditingController(text: pharmacy?.contactEmail ?? '');
    return Scaffold(
      appBar: AppBar(
        title: Text('Pharmacy Profile',
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
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.teal[50],
                          child: Icon(Icons.local_pharmacy,
                              size: 40, color: Colors.teal[700]),
                        ),
                        SizedBox(height: 12),
                        Text('Pharmacy Details',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal[800])),
                        SizedBox(height: 4),
                        Text('Manage your pharmacy information',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700])),
                      ],
                    ),
                  ),
                  SizedBox(height: 32),
                  Text('Pharmacy Name',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 6),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter pharmacy name',
                      prefixIcon: Icon(Icons.local_hospital),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text('Address',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 6),
                  TextField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: 'Enter address',
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text('Phone', style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 6),
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      hintText: 'Enter phone number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(height: 18),
                  Text('Contact Email',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  SizedBox(height: 6),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter contact email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (pharmacy == null) return;
                        final updated = Pharmacy(
                          id: pharmacy.id,
                          name: nameController.text.trim(),
                          address: addressController.text.trim(),
                          phone: phoneController.text.trim(),
                          contactEmail: emailController.text.trim(),
                        );
                        await pharmacyVM.updatePharmacy(updated);

                        if (!mounted)
                          return; // Check if the widget is still in the tree

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Pharmacy profile updated!')),
                        );
                        Navigator.of(context)
                            .pop(); // Go back to the previous screen
                      },
                      child:
                          Text('Save Changes', style: TextStyle(fontSize: 18)),
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
