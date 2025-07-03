import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

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
                            child: Icon(Icons.lock_outline,
                                size: 40, color: Colors.teal[700]),
                          ),
                          SizedBox(height: 12),
                          Text('PharmaTrack',
                              style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal[800])),
                          SizedBox(height: 8),
                          Text('Reset Password',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Enter your email to receive a reset link',
                              style: TextStyle(
                                  fontSize: 15, color: Colors.grey[700])),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
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
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authVM.isLoading
                            ? null
                            : () async {
                                await authVM.resetPassword(
                                    _emailController.text.trim());
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'If the email exists, a reset link has been sent.')),
                                );
                              },
                        child: authVM.isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text('Reset Password',
                                style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () =>
                            Navigator.pushReplacementNamed(context, '/login'),
                        child: Text('Back to Login',
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
