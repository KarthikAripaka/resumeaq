import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/resume/presentation/screens/upload_screen.dart';
import '../../features/resume/presentation/screens/analysis_screen.dart';
import '../../features/interview/presentation/screens/interview_screen.dart';
import '../../features/interview/presentation/screens/results_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplashRoute = state.matchedLocation == '/splash';

      if (session == null && !isAuthRoute && !isSplashRoute) {
        return '/auth';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) => const UploadScreen(),
          ),
          GoRoute(
            path: '/analysis',
            builder: (context, state) => const AnalysisScreen(),
          ),
          GoRoute(
            path: '/interview',
            builder: (context, state) => const InterviewScreen(),
          ),
          GoRoute(
            path: '/results',
            builder: (context, state) => const ResultsScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Interview'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Results'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/upload');
              break;
            case 2:
              context.go('/analysis');
              break;
            case 3:
              context.go('/interview');
              break;
            case 4:
              context.go('/results');
              break;
            case 5:
              context.go('/analytics');
              break;
            case 6:
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}