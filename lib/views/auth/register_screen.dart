import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../models/user.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 16),
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
                          Text('PharmaTrack',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800])),
                          SizedBox(height: 8),
                          Text('Create Account',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Join PharmaTrack to manage your pharmacy',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    Text('Name', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    SizedBox(height: 18),
                    Text('Email Address',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    SizedBox(height: 18),
                    Text('Password',
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 6),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Create a password',
                        prefixIcon: Icon(Icons.lock_outline),
                        suffixIcon: Icon(Icons.visibility_off),
                      ),
                    ),
                    SizedBox(height: 18),
                    Text('Role', style: TextStyle(fontWeight: FontWeight.w500)),
                    SizedBox(height: 6),
                    DropdownButtonFormField<UserRole>(
                      value: _selectedRole,
                      items: [
                        DropdownMenuItem(
                          value: UserRole.pharmacist,
                          child: Text('Pharmacist'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.staff,
                          child: Text('Staff'),
                        ),
                        DropdownMenuItem(
                          value: UserRole.stockManager,
                          child: Text('Stock Manager'),
                        ),
                      ],
                      onChanged: (role) => setState(() => _selectedRole = role),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authVM.isLoading
                            ? null
                            : () async {
                                if (_selectedRole == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Please select a role')),
                                  );
                                  return;
                                }
                                if (_passwordController.text.trim().length <
                                    6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Password must be at least 6 characters')),
                                  );
                                  return;
                                }
                                final success = await authVM.register(
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                  _selectedRole!,
                                );
                                if (!mounted) return;
                                if (success) {
                                  Navigator.pushReplacementNamed(
                                      context, '/dashboard');
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(authVM.error ??
                                            'Registration failed')),
                                  );
                                }
                              },
                        child: authVM.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Sign Up', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text('Already have an account? Log In',
                            style: TextStyle(
                                color: Colors.teal[700],
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
