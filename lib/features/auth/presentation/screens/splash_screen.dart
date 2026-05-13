import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_iq_ai/core/theme/app_theme.dart';
import 'package:interview_iq_ai/features/auth/presentation/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Fallback: if auth state doesn't change within 5 seconds, redirect to auth
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        final authState = ref.read(authNotifierProvider);
        if (authState.isLoading) {
          // If still loading after 5 seconds, redirect to auth
          context.go('/auth');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // The router will automatically redirect based on auth state
    // This fallback ensures we don't get stuck forever
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