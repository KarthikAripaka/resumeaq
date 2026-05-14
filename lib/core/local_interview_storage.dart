import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../features/interview/domain/models/interview_models.dart';

class LocalInterviewStorage {
  static const String _boxName = 'interview_sessions';
  static const String _keyPrefix = 'session_';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static String _sessionKey(String sessionId) => '$_keyPrefix$sessionId';

  static Future<void> saveSession(InterviewSession session) async {
    final box = Hive.box<String>(_boxName);
    await box.put(_sessionKey(session.id), jsonEncode(session.toJson()));
  }

  static Future<List<InterviewSession>> getAllSessions() async {
    final box = Hive.box<String>(_boxName);
    final values = box.values.toList(growable: false);

    final sessions = <InterviewSession>[];
    for (final raw in values) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          sessions.add(InterviewSession.fromJson(decoded));
        } else if (decoded is Map) {
          sessions.add(
            InterviewSession.fromJson(
              decoded.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      } catch (e) {
        debugPrint('LocalInterviewStorage: failed to decode session: $e');
      }
    }

    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  static Future<void> clearAll() async {
    final box = Hive.box<String>(_boxName);
    await box.clear();
  }
}
