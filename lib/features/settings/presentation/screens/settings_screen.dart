import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text('User: ${user?.email ?? 'Guest'}'),
            ),
            ElevatedButton(
              onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
              child: const Text('Sign Out'),
            ),
            const ListTile(
              title: Text('App Version: 1.0.0'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Hive.box().clear();
              },
              child: const Text('Clear Cache'),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(),
    );
  }
}