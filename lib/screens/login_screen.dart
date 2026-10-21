import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 1. Await the asynchronous Google Sign-In request
            final result = await AuthService().signInWithGoogle();
            
            // 2. CRUCIAL SAFETY FIX: Abort instantly if this screen was unmounted during the network call
            if (!context.mounted) return;

            // 3. Safe to execute UI/Context code now
            if (result == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Authentication failed or was canceled.')),
              );
            }
          },
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
