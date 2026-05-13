import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_iq_ai/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${user?.email ?? 'Guest'}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                title: const Text('Upload Resume'),
                onTap: () => context.go('/upload'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Continue Interview'),
                onTap: () => context.go('/interview'),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('View Analytics'),
                onTap: () => context.go('/analytics'),
              ),
            ),
            const Expanded(child: Center(child: Text('Recent Activity'))),
          ],
        ),
      ).animate().fadeIn().slideY(),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/analytics');
              break;
            case 2:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}
