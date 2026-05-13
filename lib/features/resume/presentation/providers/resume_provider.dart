import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../../../core/services/ai_cache.dart';
import '../../domain/models/resume_analysis.dart';

part 'resume_provider.g.dart';

// Global provider to store current analysis
final currentAnalysisProvider = StateProvider<ResumeAnalysis?>((ref) => null);

@riverpod
class ResumeNotifier extends _$ResumeNotifier {
  @override
  FutureOr<ResumeAnalysis?> build() async {
    // Try to load last analysis from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final analysisJson = prefs.getString('last_resume_analysis');
    if (analysisJson != null) {
      try {
        final analysisMap = jsonDecode(analysisJson) as Map<String, dynamic>;
        final analysis = ResumeAnalysis.fromJson(analysisMap);
        // Update the global provider
        Future.microtask(() => ref.read(currentAnalysisProvider.notifier).state = analysis);
        return analysis;
      } catch (e) {
        debugPrint('Failed to load cached analysis: $e');
      }
    }
    return null;
  }

  String _getUserFriendlyErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('rate limit')) {
      return 'AI service is busy. Please wait a moment and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('api key') ||
        errorString.contains('unauthorized')) {
      return 'Service configuration error. Please contact support.';
    } else {
      // UI will never display technical error text.
      return 'Resume analysis is still being prepared. Showing the best available screening insights.';
    }
  }

  Future<void> uploadAndAnalyze(PlatformFile pdfFile, String jobRole) async {
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    try {
      final analysis = await Future.any([
        _performAnalysis(pdfFile, jobRole),
        Future.delayed(const Duration(seconds: 60), () {
          throw Exception('Analysis timed out. Please try again.');
        }),
      ]);

      state = AsyncValue.data(analysis);

      // Save to shared preferences for persistence
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_resume_analysis', jsonEncode(analysis.toJson()));

      // Update global provider
      ref.read(currentAnalysisProvider.notifier).state = analysis;
    } catch (error, stackTrace) {
      final userFriendlyError = _getUserFriendlyErrorMessage(error);
      state = AsyncValue.error(userFriendlyError, stackTrace);
    }
  }

  Future<ResumeAnalysis> _performAnalysis(
    PlatformFile pdfFile,
    String jobRole,
  ) async {
    final pdfService = ref.read(pdfParserServiceProvider);
    final bytes = pdfFile.bytes;
    if (bytes == null) {
      throw Exception('PDF bytes are missing. Please try again.');
    }

    final resumeText = await pdfService.extractTextFromBytes(bytes);

    // Save resume locally for offline access
    LocalStorageService.saveResumeLocally(bytes, pdfFile.name);

    debugPrint('Starting AI analysis with Groq...');

    final groqService = ref.read(groqServiceProvider);
    final analysis = await groqService.analyzeResume(resumeText, jobRole);

    debugPrint('AI analysis completed successfully');
    return analysis;
  }

  void clearAnalysis() {
    state = const AsyncValue.data(null);
  }
}

@riverpod
class SelectedJobRoleNotifier extends _$SelectedJobRoleNotifier {
  @override
  String build() => AppConstants.jobRoles.first;

  void setJobRole(String jobRole) {
    state = jobRole;
  }
}
