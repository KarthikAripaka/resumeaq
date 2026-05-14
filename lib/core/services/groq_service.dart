import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'ai_cache.dart';
import 'ai_response_parser.dart';
import '../../features/interview/domain/models/interview_models.dart';
import '../../features/resume/domain/models/resume_analysis.dart';

class GroqService {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(seconds: 2);

  final Dio _dio;

  GroqService()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://api.groq.com',
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 60),
            sendTimeout: const Duration(seconds: 30),
          ),
        );

  String _extractAndCleanJson(String response) {
    if (response.trim().isEmpty) {
      throw Exception('Empty response');
    }

    var cleaned = response.trim();

    if (cleaned.startsWith('```json') && cleaned.endsWith('```')) {
      cleaned = cleaned.substring(7, cleaned.length - 3).trim();
    } else if (cleaned.startsWith('```') && cleaned.endsWith('```')) {
      cleaned = cleaned.substring(3, cleaned.length - 3).trim();
    }

    final startIndex = cleaned.indexOf('{');
    final endIndex = cleaned.lastIndexOf('}');
    if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
      throw Exception('No valid JSON structure found');
    }

    cleaned = cleaned.substring(startIndex, endIndex + 1);
    cleaned = cleaned.replaceAllMapped(
      RegExp(r',(\s*[}\]])'),
      (Match match) => match.group(1)!,
    );

    return cleaned;
  }

  Future<String> _sendRequest(String prompt) async {
    final requestId = DateTime.now().microsecondsSinceEpoch;

    var retryCount = 0;
    var delay = baseDelay;

    while (retryCount < maxRetries) {
      try {
        if (kDebugMode) {
          debugPrint(
            'Groq Request (attempt ${retryCount + 1}): ${prompt.substring(0, 200)}...',
          );
        }

        final response = await _dio.post(
          '/openai/v1/chat/completions',
          options: Options(
            headers: {
              'Authorization': 'Bearer ${dotenv.env['GROQ_API_KEY']}',
              'Content-Type': 'application/json',
            },
          ),
          data: {
            'model': 'llama-3.3-70b-versatile',
            'response_format': {'type': 'json_object'},
            'messages': [
              {
                'role': 'user',
                'content': prompt,
              }
            ],
            'temperature': 0.2,
          },
        );

        if (kDebugMode) {
          debugPrint('Groq Response: ${response.data}');
        }

        return response.data['choices'][0]['message']['content'] as String;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        if (kDebugMode) {
          debugPrint(
            'Groq requestId=$requestId failed (attempt ${retryCount + 1}) status=$statusCode',
          );
        }

        final responseBody = e.response?.data?.toString() ?? 'No response body';
        final requestUrl = e.requestOptions.uri.toString();

        debugPrint(
          'DioException: Status $statusCode, URL: $requestUrl, Body: $responseBody',
        );

        if (statusCode == 429) {
          debugPrint('Rate limit hit, retrying in ${delay.inSeconds}s...');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(delay);
            delay = Duration(seconds: delay.inSeconds * 2);
            continue;
          }
          throw Exception(
              'Rate limit exceeded. Please wait before trying again.');
        }

        if (statusCode == 401) {
          throw Exception('Invalid API key. Please check your Groq API key.');
        }

        if (statusCode == 500 ||
            statusCode == 502 ||
            statusCode == 503 ||
            statusCode == 504) {
          if (kDebugMode) {
            debugPrint('Groq server error, retrying...');
          }
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(delay);
            delay = Duration(seconds: delay.inSeconds * 2);
            continue;
          }
        }

        throw Exception('Groq request failed (status=$statusCode)');
      }
    }

    throw Exception('Max retries exceeded');
  }

  Future<ResumeAnalysis> analyzeResume(
      String resumeText, String jobRole) async {
    await AICache.clearCache();

    final trimmedResume = resumeText.length > 6000
        ? '${resumeText.substring(0, 6000)}...'
        : resumeText;

    final prompt = '''
You are an expert ATS resume analyzer.

Analyze the resume against the provided job role.

Hard requirements:
- Return ONLY valid JSON. No markdown.
- No extra keys. No missing keys.
- Use EXACT field names and value types.

Required JSON schema (return exactly this):
{
  "ats_score": number,
  "strengths": [],
  "weaknesses": [],
  "missing_skills": [],
  "recommended_improvements": [],
  "technical_questions": [],
  "hr_questions": [],
  "final_verdict": ""
}

Job role: $jobRole

Resume:
$trimmedResume
''';

    try {
      final response = await _sendRequest(prompt);
      final analysis = await compute(
          parseResumeAnalysisIsolate, [response, jobRole, trimmedResume]);
      await AICache.cacheAnalysis(resumeText, jobRole, analysis);
      return analysis;
    } catch (e) {
      debugPrint('AI analysis failed, returning safe fallback: $e');
      return await compute(
          parseResumeAnalysisIsolate, ['', jobRole, trimmedResume]);
    }
  }

  Future<List<InterviewQuestion>> generateInterviewQuestions(
      String resumeText, String jobRole) async {
    final trimmedResume = resumeText.length > 4000
        ? '${resumeText.substring(0, 4000)}...'
        : resumeText;

    final prompt = '''
Generate 15 interview questions for a $jobRole candidate.

IMPORTANT: Respond with ONLY valid JSON. No markdown, no explanations.

JSON Schema:
{
  "questions": [
    {"id": "q1", "question": "question text", "category": "hr"},
    {"id": "q2", "question": "question text", "category": "technical"}
  ]
}

Resume:
$trimmedResume
''';

    try {
      final response = await _sendRequest(prompt);
      final questionData =
          await compute(parseInterviewQuestionsIsolate, response);
      return questionData.map((q) => InterviewQuestion.fromJson(q)).toList();
    } catch (e) {
      debugPrint('Interview questions generation failed, using fallback: $e');
      final fallbackData = await compute(parseInterviewQuestionsIsolate, '');
      return fallbackData.map((q) => InterviewQuestion.fromJson(q)).toList();
    }
  }

  Future<AnswerFeedback> evaluateAnswer(
      String question, String answer, String jobRole) async {
    final hasVoiceRecording = answer.contains('[Voice Recording');
    final voiceQuality =
        hasVoiceRecording ? answer.split('Quality: ')[1].split(',')[0] : 'none';
    final voiceConfidence = hasVoiceRecording
        ? answer.split('Confidence: ')[1].split(',')[0]
        : 'none';
    final voiceClarity =
        hasVoiceRecording ? answer.split('Clarity: ')[1].split(']')[0] : 'none';

    final prompt = '''
You are a senior $jobRole interviewer conducting a comprehensive evaluation.

Question: $question
Answer: ${hasVoiceRecording ? answer.split('\n\n[')[0] : answer}

${hasVoiceRecording ? '''
VOICE ANALYSIS:
- Recording Quality: $voiceQuality
- Speaker Confidence: $voiceConfidence
- Speech Clarity: $voiceClarity
- Voice recordings should be evaluated for communication skills, confidence, and professionalism.
''' : ''}

EVALUATION CRITERIA:
- Correctness: How accurate and relevant is the answer?
- Communication: How well is it articulated?${hasVoiceRecording ? ' (Consider voice quality, confidence, and clarity)' : ''}
- Confidence: Does the candidate seem knowledgeable and self-assured?
- Completeness: Does the answer fully address the question?

IMPORTANT: Respond with ONLY valid JSON. No markdown, no explanations.

JSON Schema:
{
  "score": 1-10,
  "correctness": "detailed assessment of answer accuracy and relevance",
  "communication": "assessment of articulation${hasVoiceRecording ? ', voice quality, and delivery' : ' and clarity'}",
  "confidence_tip": "specific advice to improve confidence and delivery",
  "ideal_answer_hints": "what a strong answer should include",
  "follow_up_question": "a relevant follow-up question to probe deeper"
}
''';

    try {
      final response = await _sendRequest(prompt);
      final feedbackData = await compute(parseAnswerFeedbackIsolate, response);
      return AnswerFeedback.fromJson(feedbackData);
    } catch (e) {
      debugPrint('Answer evaluation failed, using fallback: $e');
      final fallbackData = await compute(parseAnswerFeedbackIsolate, '');
      return AnswerFeedback.fromJson(fallbackData);
    }
  }

  Future<InterviewFinalReport> evaluateInterviewFinal({
    required String jobRole,
    required List<InterviewQuestion> questions,
    required Map<String, String> answersByQuestionId,
  }) async {
    final questionsPayload = questions
        .map((q) => {
              'id': q.id,
              'category': q.category,
              'question': q.question,
              'answer': answersByQuestionId[q.id] ?? '',
            })
        .toList();

    final prompt = '''
You are an expert interviewer and hiring manager.

Task: Evaluate the candidate's interview answers and produce a STRICT JSON final report.

IMPORTANT:
- Respond ONLY with valid JSON (no markdown, no extra text).
- Output must match the exact schema.

JSON Schema:
{
  "overall_interview_score": number,
  "communication_score": number,
  "technical_score": number,
  "hr_score": number,
  "dsa_score": number,
  "confidence_level": "low|medium|high",
  "strengths": [],
  "weaknesses": [],
  "areas_to_improve": [],
  "ai_final_verdict": "",
  "hiring_recommendation": "",
  "recommended_learning_topics": [],
  "recommended_improvements": [],
  "missing_skills": [],
  "technical_questions": [],
  "hr_questions": [],
  "ats_score": number
}

Job role: $jobRole

Interview answers:
${questionsPayload}
''';

    try {
      final response = await _sendRequest(prompt);
      final cleanedJson = _extractAndCleanJson(response);
      final decoded = jsonDecode(cleanedJson);

      if (decoded is Map<String, dynamic>) {
        return InterviewFinalReport.fromJson(decoded);
      }
      if (decoded is Map) {
        return InterviewFinalReport.fromJson(
          decoded.map((k, v) => MapEntry(k.toString(), v)),
        );
      }

      throw FormatException('Unexpected final report JSON structure');
    } catch (e) {
      debugPrint(
          'Final interview evaluation failed, returning safe fallback: $e');
      return InterviewFinalReport(
        overallInterviewScore: 0,
        communicationScore: 0,
        technicalScore: 0,
        hrScore: 0,
        dsaScore: 0,
        confidenceLevel: 'low',
        strengths: const [],
        weaknesses: const [],
        areasToImprove: const [],
        aiFinalVerdict:
            'Interview evaluation unavailable. Please try again later.',
        hiringRecommendation: 'Undetermined',
        recommendedLearningTopics: const [],
        recommendedImprovements: const [],
        missingSkills: const [],
        technicalQuestions: const [],
        hrQuestions: const [],
        atsScore: 0,
      );
    }
  }
}
