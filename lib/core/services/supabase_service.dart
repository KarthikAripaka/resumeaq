import 'dart:io';

import '../../features/interview/domain/models/interview_models.dart';
import '../../features/resume/domain/models/resume_analysis.dart';

// Supabase integration removed. This file is kept only to avoid breaking imports
// during the migration. It no longer performs any network/database operations.
class SupabaseService {
  Future<String> uploadResumePdf(File file, String userId) async {
    throw UnimplementedError(
        'Supabase removed: uploadResumePdf is unavailable');
  }

  Future<String> uploadResumeBytes(
      List<int> bytes, String fileName, String userId) async {
    throw UnimplementedError(
        'Supabase removed: uploadResumeBytes is unavailable');
  }

  Future<String> saveResumeRecord(
      String userId, String fileUrl, String fileName, String jobRole) async {
    throw UnimplementedError(
        'Supabase removed: saveResumeRecord is unavailable');
  }

  Future<void> saveAnalysis(String resumeId, ResumeAnalysis analysis) async {
    throw UnimplementedError('Supabase removed: saveAnalysis is unavailable');
  }

  Future<void> saveInterviewSession(InterviewSession session) async {
    throw UnimplementedError(
        'Supabase removed: saveInterviewSession is unavailable');
  }

  Future<void> saveQuestionResponse(
      String sessionId, InterviewQuestion q, AnswerFeedback fb) async {
    throw UnimplementedError(
        'Supabase removed: saveQuestionResponse is unavailable');
  }

  Future<List<InterviewSession>> getHistory(String userId) async {
    throw UnimplementedError('Supabase removed: getHistory is unavailable');
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    throw UnimplementedError('Supabase removed: getUserStats is unavailable');
  }
}
