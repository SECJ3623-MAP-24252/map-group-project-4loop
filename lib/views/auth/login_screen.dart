import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    final authVM = Provider.of<AuthViewModel>(context);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            Text('Welcome Back',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4),
                            Text('Sign in to your account',
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
                      SizedBox(height: 18),
                      Text('Password',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: Icon(Icons.lock_outline),
                          suffixIcon: Icon(Icons.visibility_off),
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) =>
                                setState(() => _rememberMe = val ?? false),
                            activeColor: Colors.teal,
                          ),
                          Text('Remember me'),
                          Spacer(),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, '/reset-password'),
                            child: Text('Forgot password?',
                                style: TextStyle(
                                    color: Colors.teal[700],
                                    fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: authVM.isLoading
                              ? null
                              : () async {
                                  final success = await authVM.login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    rememberMe: _rememberMe,
                                  );
                                  if (success) {
                                    Navigator.pushReplacementNamed(
                                        context, '/dashboard');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              authVM.error ?? 'Login failed')),
                                    );
                                  }
                                },
                          child: authVM.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('Log In', style: TextStyle(fontSize: 18)),
                        ),
                      ),
                      SizedBox(height: 18),
                      Center(
                        child: GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text("Don't have an account? Sign Up",
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
      ),
    );
  }
}
