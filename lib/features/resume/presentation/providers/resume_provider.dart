import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_iq_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/models/resume_analysis.dart';

part 'resume_provider.g.dart';

@riverpod
class ResumeNotifier extends _$ResumeNotifier {
  @override
  FutureOr<ResumeAnalysis?> build() {
    return null;
  }

  Future<void> uploadAndAnalyze(PlatformFile pdfFile, String jobRole) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final pdfService = ref.read(pdfParserServiceProvider);
      final resumeText = await pdfService.extractTextFromBytes(pdfFile.bytes!);

      final supabaseService = ref.read(supabaseServiceProvider);
      final userId = ref.read(authNotifierProvider).value?.id ?? '';

      String fileUrl;
      String resumeId;

      try {
        // Try to upload to storage
        fileUrl = await supabaseService.uploadResumeBytes(pdfFile.bytes!, pdfFile.name, userId);
        resumeId = await supabaseService.saveResumeRecord(
          userId,
          fileUrl,
          pdfFile.name,
          jobRole,
        );
      } catch (storageError) {
        // Fallback: Create a mock record if storage fails
        fileUrl = 'local://${pdfFile.name}'; // Mock URL for local testing
        resumeId = 'local_${DateTime.now().millisecondsSinceEpoch}';

        // Log the error but continue with analysis
        debugPrint('Storage upload failed, continuing with local analysis: $storageError');
      }

      final geminiService = ref.read(geminiServiceProvider);
      final analysis = await geminiService.analyzeResume(resumeText, jobRole);

      // Only save analysis if we have a real resume ID
      if (!resumeId.startsWith('local_')) {
        await supabaseService.saveAnalysis(resumeId, analysis);
      }

      return analysis;
    });
  }

  void clearAnalysis() {
    state = const AsyncValue.data(null);
  }
}

@riverpod
class SelectedJobRoleNotifier extends _$SelectedJobRoleNotifier {
  @override
  String build() {
    return AppConstants.jobRoles.first;
  }

  void setJobRole(String jobRole) {
    state = jobRole;
  }
}
