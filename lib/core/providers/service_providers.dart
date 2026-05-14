import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/groq_service.dart';

import '../services/pdf_parser_service.dart';

final groqServiceProvider = Provider<GroqService>((ref) => GroqService());

final pdfParserServiceProvider =
    Provider<PdfParserService>((ref) => PdfParserService());

// Theme provider for managing app theme
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    // In a real app, load from shared preferences
    // For now, default to dark mode
    state = ThemeMode.dark;
  }

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    // In a real app, save to shared preferences
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    // In a real app, save to shared preferences
  }
}

// Notifications provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier() : super([]) {
    _loadNotifications();
  }

  void _loadNotifications() {
    // Mock notifications - in real app, load from database/API
    state = [
      NotificationItem(
        id: '1',
        title: 'Welcome to InterviewIQ AI!',
        message: 'Complete your first interview to get personalized feedback.',
        type: NotificationType.welcome,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Improve Your Scores',
        message: 'Practice more technical questions to boost your performance.',
        type: NotificationType.tips,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: false,
      ),
    ];
  }

  void markAsRead(String id) {
    state = state.map((notification) {
      if (notification.id == id) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  void addNotification(NotificationItem notification) {
    state = [notification, ...state];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

enum NotificationType {
  welcome,
  tips,
  achievement,
  reminder,
}

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    required this.isRead,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
    );
  }
}
