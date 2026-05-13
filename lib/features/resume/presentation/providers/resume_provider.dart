import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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

  Future<void> uploadAndAnalyze(File pdfFile, String jobRole) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final pdfService = ref.read(pdfParserServiceProvider);
      final resumeText = await pdfService.extractText(pdfFile);

      final supabaseService = ref.read(supabaseServiceProvider);
      final userId = ref.read(authNotifierProvider).value?.id ?? '';
      final fileUrl = await supabaseService.uploadResumePdf(pdfFile, userId);
      final resumeId = await supabaseService.saveResumeRecord(
        userId,
        fileUrl,
        pdfFile.path.split('/').last,
        jobRole,
      );

      final geminiService = ref.read(geminiServiceProvider);
      final analysis = await geminiService.analyzeResume(resumeText, jobRole);

      await supabaseService.saveAnalysis(resumeId, analysis);

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