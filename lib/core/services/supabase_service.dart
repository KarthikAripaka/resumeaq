import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/resume/domain/models/resume_analysis.dart';
import '../../features/interview/domain/models/interview_models.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<String> uploadResumePdf(File file, String userId) async {
    final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.pdf';
    final response = await _client.storage
        .from('resumes')
        .upload(fileName, file);

    if (response.isNotEmpty) {
      return _client.storage.from('resumes').getPublicUrl(fileName);
    } else {
      throw Exception('Upload failed');
    }
  }

  Future<String> saveResumeRecord(
      String userId, String fileUrl, String fileName, String jobRole) async {
    final response = await _client
        .from('resumes')
        .insert({
          'user_id': userId,
          'file_url': fileUrl,
          'file_name': fileName,
          'job_role': jobRole,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select('id')
        .single();

    return response['id'] as String;
  }

  Future<void> saveAnalysis(String resumeId, ResumeAnalysis analysis) async {
    await _client.from('resume_analyses').insert({
      'resume_id': resumeId,
      'ats_score': analysis.atsScore,
      'strengths': analysis.strengths,
      'weaknesses': analysis.weaknesses,
      'missing_skills': analysis.missingSkills,
      'keyword_match': analysis.keywordMatch,
      'improvement_tips': analysis.improvementTips,
      'summary': analysis.summary,
      'job_role': analysis.jobRole,
      'analyzed_at': analysis.analyzedAt.toIso8601String(),
    });
  }

  Future<void> saveInterviewSession(InterviewSession session) async {
    await _client.from('interview_sessions').insert({
      'id': session.id,
      'resume_id': session.resumeId,
      'job_role': session.jobRole,
      'questions': session.questions.map((q) => q.toJson()).toList(),
      'feedbacks': session.feedbacks.map((k, v) => MapEntry(k, v.toJson())),
      'started_at': session.startedAt.toIso8601String(),
    });
  }

  Future<void> saveQuestionResponse(
      String sessionId, InterviewQuestion q, AnswerFeedback fb) async {
    await _client.from('question_responses').insert({
      'session_id': sessionId,
      'question_id': q.id,
      'question': q.question,
      'category': q.category,
      'score': fb.score,
      'correctness': fb.correctness,
      'communication': fb.communication,
      'confidence_tip': fb.confidenceTip,
      'ideal_answer_hints': fb.idealAnswerHints,
      'follow_up_question': fb.followUpQuestion,
    });
  }

  Future<List<InterviewSession>> getHistory(String userId) async {
    final response = await _client
        .from('interview_sessions')
        .select('''
          *,
          resumes!inner(user_id)
        ''')
        .eq('resumes.user_id', userId)
        .order('started_at', ascending: false)
        .limit(10);

    return response.map((json) => InterviewSession.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> getUserStats(String userId) async {
    final analyses = await _client
        .from('resume_analyses')
        .select('ats_score')
        .eq('user_id', userId); // Assuming resume_analyses has user_id or join

    final sessions = await _client
        .from('interview_sessions')
        .select('id')
        .eq('user_id', userId); // Assuming interview_sessions has user_id

    final avgAtsScore = analyses.isEmpty
        ? 0.0
        : analyses.map((a) => a['ats_score'] as int).reduce((a, b) => a + b) /
            analyses.length;

    return {
      'avgAtsScore': avgAtsScore,
      'totalSessions': sessions.length,
      'bestScore': analyses.isEmpty
          ? 0
          : analyses.map((a) => a['ats_score'] as int).reduce((a, b) => a > b ? a : b),
    };
  }
}