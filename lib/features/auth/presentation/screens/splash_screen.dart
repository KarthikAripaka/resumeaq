import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_iq_ai/core/theme/app_theme.dart';
import 'package:interview_iq_ai/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(const Duration(seconds: 2), () {
      final user = ref.read(authNotifierProvider).value;
      if (context.mounted) {
        context.go(user != null ? '/home' : '/auth');
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.colorScheme.surface,
      body: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.darkTheme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.work,
            size: 60,
            color: Color(0xFF6C63FF),
          ),
        ).animate().scale().fadeIn(),
      ),
    );
  }
}