import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../../features/resume/domain/models/resume_analysis.dart';
import '../../features/interview/domain/models/interview_models.dart';

class GeminiService {
  final Dio _dio;

  GeminiService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.geminiBaseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
          ),
        );

  Future<ResumeAnalysis> analyzeResume(String resumeText, String jobRole) async {
    final prompt = '''
You are an expert ATS resume analyzer. Analyze the resume below for a $jobRole role.
Respond ONLY with valid JSON matching this exact schema:
{
  "ats_score": ,
  "strengths": [<3-5 specific strength strings>],
  "weaknesses": [<3-5 specific weakness strings>],
  "missing_skills": [],
  "keyword_match": [],
  "improvement_tips": [<3-5 actionable improvement tips as strings>],
  "summary": "<2 sentence overall assessment>"
}
No explanation. No markdown. Only the JSON object.
Resume:
$resumeText
''';

    final response = await _sendRequest(prompt);

    try {
      final json = jsonDecode(response);
      return ResumeAnalysis.fromJson({
        ...json,
        'job_role': jobRole,
        'analyzed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw GeminiParseException('Failed to parse ResumeAnalysis: $response');
    }
  }

  Future<List<InterviewQuestion>> generateInterviewQuestions(
      String resumeText, String jobRole) async {
    final prompt = '''
Generate interview questions for a $jobRole candidate. Base HR and project questions on this resume.
Respond ONLY with valid JSON:
{
  "questions": [
    {"id": "q1", "question": "...", "category": "hr"},
    {"id": "q2", "question": "...", "category": "technical"},
    {"id": "q3", "question": "...", "category": "dsa"},
    {"id": "q4", "question": "...", "category": "project"},
    ... (generate 15 total: 4 hr, 5 technical, 3 dsa, 3 project)
  ]
}
No explanation. No markdown. Only the JSON object.
Resume:
$resumeText
''';

    final response = await _sendRequest(prompt);

    try {
      final json = jsonDecode(response);
      return (json['questions'] as List)
          .map((q) => InterviewQuestion.fromJson(q))
          .toList();
    } catch (e) {
      throw GeminiParseException('Failed to parse InterviewQuestions: $response');
    }
  }

  Future<AnswerFeedback> evaluateAnswer(
      String question, String answer, String jobRole) async {
    final prompt = '''
You are a senior $jobRole interviewer. Evaluate this interview answer.
Question: $question
Candidate answer: $answer
Respond ONLY with valid JSON:
{
  "score": ,
  "correctness": "",
  "communication": "",
  "confidence_tip": "",
  "ideal_answer_hints": "",
  "follow_up_question": ""
}
No explanation. No markdown. Only the JSON object.
''';

    final response = await _sendRequest(prompt);

    try {
      final json = jsonDecode(response);
      return AnswerFeedback.fromJson(json);
    } catch (e) {
      throw GeminiParseException('Failed to parse AnswerFeedback: $response');
    }
  }

  Future<String> generateImprovementPlan(ResumeAnalysis analysis) async {
    final prompt = '''
Based on this resume analysis, create a 30-day improvement plan for a ${analysis.jobRole} role.
Analysis: ${analysis.summary}
Strengths: ${analysis.strengths.join(', ')}
Weaknesses: ${analysis.weaknesses.join(', ')}
Improvement tips: ${analysis.improvementTips.join(', ')}

Provide a plain text 30-day plan with daily tasks.
''';

    return await _sendRequest(prompt);
  }

  Future<String> _sendRequest(String prompt) async {
    const maxRetries = 3;
    var retryCount = 0;
    var delay = const Duration(seconds: 2);

    while (retryCount < maxRetries) {
      try {
        final response = await _dio.post(
          '/v1beta/models/${AppConstants.geminiModel}:generateContent?key=${dotenv.env['GEMINI_API_KEY']}',
          data: {
            'contents': [
              {
                'parts': [
                  {'text': prompt}
                ]
              }
            ]
          },
        );

        if (kDebugMode) {
          debugPrint('Gemini Request: $prompt');
          debugPrint('Gemini Response: ${response.data}');
        }

        final text = response.data['candidates'][0]['content']['parts'][0]['text'] as String;
        return _cleanJsonResponse(text);
      } on DioException catch (e) {
        if (e.response?.statusCode == 429 || e.response?.statusCode == 503) {
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(delay);
            delay *= 2; // Exponential backoff
            continue;
          }
        }
        rethrow;
      }
    }

    throw Exception('Max retries exceeded');
  }

  String _cleanJsonResponse(String response) {
    // Strip markdown fences if present
    var cleaned = response.trim();
    if (cleaned.startsWith('```json') && cleaned.endsWith('```')) {
      cleaned = cleaned.substring(7, cleaned.length - 3).trim();
    }
    return cleaned;
  }
}