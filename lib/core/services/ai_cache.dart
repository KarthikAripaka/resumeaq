import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/resume/domain/models/resume_analysis.dart';

class AICache {
  static const String _boxName = 'ai_cache';
  static const Duration _cacheDuration = Duration(hours: 24); // Cache for 24 hours

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static String _generateKey(String resumeText, String jobRole) {
    final combined = '$resumeText|$jobRole';
    return base64Encode(utf8.encode(combined)).replaceAll('/', '_');
  }

  static Future<ResumeAnalysis?> getCachedAnalysis(String resumeText, String jobRole) async {
    final box = Hive.box<String>(_boxName);
    final key = _generateKey(resumeText, jobRole);
    final cached = box.get(key);

    if (cached != null) {
      try {
        final data = jsonDecode(cached);
        final timestamp = DateTime.parse(data['timestamp']);
        final analysis = ResumeAnalysis.fromJson(data['analysis']);

        // Check if cache is still valid
        if (DateTime.now().difference(timestamp) < _cacheDuration) {
          return analysis;
        } else {
          // Cache expired, remove it
          await box.delete(key);
        }
      } catch (e) {
        // Invalid cache, remove it
        await box.delete(key);
      }
    }
    return null;
  }

  static Future<void> cacheAnalysis(String resumeText, String jobRole, ResumeAnalysis analysis) async {
    final box = Hive.box<String>(_boxName);
    final key = _generateKey(resumeText, jobRole);
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'analysis': analysis.toJson(),
    };
    await box.put(key, jsonEncode(data));
  }

  static Future<void> clearCache() async {
    final box = Hive.box<String>(_boxName);
    await box.clear();
  }
}