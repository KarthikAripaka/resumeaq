import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/screens/home_screen.dart';
import '../../features/resume/presentation/screens/upload_screen.dart';
import '../../features/resume/presentation/screens/analysis_screen.dart';
import '../../features/interview/presentation/screens/interview_screen.dart';
import '../../features/interview/presentation/screens/interview_result_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
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
             builder: (context, state) => const InterviewResultScreen(),
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
});

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
          BottomNavigationBarItem(
              icon: Icon(Icons.upload_file), label: 'Upload'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Interview'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
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
              context.go('/settings');
              break;
          }
        },
      ),
    );
  }
}
