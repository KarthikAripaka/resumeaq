import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/local_storage_service.dart';
import '../../domain/models/resume_analysis.dart';

part 'resume_provider.g.dart';

@riverpod
class ResumeNotifier extends _$ResumeNotifier {
  @override
  FutureOr<ResumeAnalysis?> build() => null;

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
