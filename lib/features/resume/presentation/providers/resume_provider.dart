import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_iq_ai/core/services/pdf_parser_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dart:convert';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/models/resume_analysis.dart';

part 'resume_provider.g.dart';

// Global provider to store current analysis
final currentAnalysisProvider = StateProvider<ResumeAnalysis?>((ref) => null);

@riverpod
class ResumeNotifier extends _$ResumeNotifier {
  @override
  FutureOr<ResumeAnalysis?> build() async {
    // Offline-friendly: do not use SharedPreferences.
    // AICache (Hive) is used for resume analysis caching.
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
    debugPrint('Starting resume analysis for $jobRole');

    try {
      final analysis = await Future.any([
        _performAnalysis(pdfFile, jobRole),
        Future.delayed(const Duration(seconds: 60), () {
          throw Exception('Analysis timed out. Please try again.');
        }),
      ]);

      state = AsyncValue.data(analysis);
      debugPrint('Analysis completed successfully');

      // Update global provider
      ref.read(currentAnalysisProvider.notifier).state = analysis;
    } catch (error, stackTrace) {
      debugPrint('Analysis failed: $error');
      final userFriendlyError = _getUserFriendlyErrorMessage(error);
      state = AsyncValue.error(userFriendlyError, stackTrace);
    }
  }

  Future<ResumeAnalysis> _performAnalysis(
    PlatformFile pdfFile,
    String jobRole,
  ) async {
    var bytes = pdfFile.bytes;

    // If bytes are null, try to read from path
    if (bytes == null && pdfFile.path != null) {
      debugPrint('PDF bytes null, reading from path: ${pdfFile.path}');
      final file = File(pdfFile.path!);
      bytes = await file.readAsBytes();
    }

    if (bytes == null || bytes.isEmpty) {
      throw Exception('Unable to read PDF file. Please try again.');
    }

    debugPrint('Extracting text from PDF...');
    final resumeText = await compute(_extractTextIsolate, [bytes]);

    debugPrint('Extracted text length: ${resumeText.length}');

    // Save resume locally for offline access
    LocalStorageService.saveResumeLocally(bytes, pdfFile.name);

    debugPrint('Starting AI analysis with Groq...');

    final groqService = ref.read(groqServiceProvider);
    final analysis = await groqService.analyzeResume(resumeText, jobRole);

    debugPrint('AI analysis completed successfully');
    return analysis;
  }

  static Future<String> _extractTextIsolate(List<dynamic> args) async {
    final bytes = args[0] as List<int>;
    return PdfParserService.extractTextFromBytes(bytes);
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
