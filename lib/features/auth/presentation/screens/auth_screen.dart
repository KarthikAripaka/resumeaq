import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            Row(
              children: [
                Text(_isSignUp ? 'Already have an account?' : 'Need an account?'),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp ? 'Sign In' : 'Sign Up'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () => _authenticate(),
              child: Text(_isSignUp ? 'Sign Up' : 'Sign In'),
            ),
            ElevatedButton.icon(
              onPressed: () => ref.read(authNotifierProvider.notifier).signInWithGoogle(),
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
            ),
            // TextButton(
            //   onPressed: () => ref.read(authNotifierProvider.notifier).signInAnonymously(),
            //   child: const Text('Continue as Guest'),
            // ),
            if (authState.isLoading) const CircularProgressIndicator(),
            if (authState.hasError) Text('Error: ${authState.error}'),
          ],
        ),
      ).animate().fadeIn().slideY(),
    );
  }

  void _authenticate() {
    if (_isSignUp) {
      ref.read(authNotifierProvider.notifier).signUpWithEmail(
        _emailController.text,
        _passwordController.text,
      );
    } else {
      ref.read(authNotifierProvider.notifier).signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
    }
  }
}