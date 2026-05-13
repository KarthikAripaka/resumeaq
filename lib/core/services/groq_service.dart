import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../constants/app_constants.dart';
import 'ai_cache.dart';
import 'ai_response_parser.dart';
import '../../features/resume/domain/models/resume_analysis.dart';
import '../../features/interview/domain/models/interview_models.dart';

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

  Future<String> _sendRequest(String prompt) async {
    var retryCount = 0;
    var delay = baseDelay;

    while (retryCount < maxRetries) {
      try {
        if (kDebugMode) {
          debugPrint(
              'Groq Request (attempt ${retryCount + 1}): ${prompt.substring(0, 200)}...');
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
            'model': AppConstants.groqModel,
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

        final content =
            response.data['choices'][0]['message']['content'] as String;
        return content;
      } on DioException catch (e) {
        final statusCode = e.response?.statusCode;
        final responseBody = e.response?.data?.toString() ?? 'No response body';
        final requestUrl = e.requestOptions.uri.toString();

        debugPrint(
            'DioException: Status $statusCode, URL: $requestUrl, Body: $responseBody');

        if (statusCode == 429) {
          debugPrint('Rate limit hit, retrying in ${delay.inSeconds}s...');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(delay);
            delay = Duration(seconds: delay.inSeconds * 2);
            continue;
          } else {
            throw Exception(
                'Rate limit exceeded. Please wait before trying again.');
          }
        } else if (statusCode == 401) {
          throw Exception('Invalid API key. Please check your Groq API key.');
        } else if (statusCode == 500 ||
            statusCode == 502 ||
            statusCode == 503) {
          debugPrint('Server error, retrying...');
          retryCount++;
          if (retryCount < maxRetries) {
            await Future.delayed(delay);
            delay = Duration(seconds: delay.inSeconds * 2);
            continue;
          }
        }
        rethrow;
      }
    }

    throw Exception('Max retries exceeded');
  }

  Future<ResumeAnalysis> analyzeResume(
      String resumeText, String jobRole) async {
    // Check cache first
    final cachedAnalysis = await AICache.getCachedAnalysis(resumeText, jobRole);
    if (cachedAnalysis != null) {
      debugPrint('Using cached analysis');
      return cachedAnalysis;
    }

    // Trim resume to max 6000 characters to optimize token usage
    final trimmedResume = resumeText.length > 6000
        ? resumeText.substring(0, 6000) + '...'
        : resumeText;

    final prompt = '''
You are an expert ATS resume analyzer.

Return ONLY valid JSON.

Do not include:

* markdown
* explanations
* comments
* notes
* code fences

Return strictly:
{
"ats_score": 0-100,
"strengths": [],
"weaknesses": [],
"missing_skills": [],
"recommendations": []
}

Resume:
$trimmedResume
''';

    try {
      final response = await _sendRequest(prompt);
      final analysis = AIResponseParser.parseResumeAnalysis(response, jobRole, trimmedResume);

      // Cache the successful analysis
      await AICache.cacheAnalysis(resumeText, jobRole, analysis);

      return analysis;
    } catch (e) {
      debugPrint('AI analysis failed, using fallback: $e');

      // Produce a meaningful, role-aware analysis (NO generic error chips).
      // Use resume text for contextual fallback insights.
      final fallbackAnalysis =
          AIResponseParser.parseResumeAnalysis('', jobRole, trimmedResume);
      await AICache.cacheAnalysis(resumeText, jobRole, fallbackAnalysis);
      return fallbackAnalysis;
    }
  }

  Future<List<InterviewQuestion>> generateInterviewQuestions(
      String resumeText, String jobRole) async {
    final trimmedResume = resumeText.length > 4000
        ? resumeText.substring(0, 4000) + '...'
        : resumeText;

    final prompt = '''
Generate 15 interview questions for a $jobRole candidate.

IMPORTANT: Respond with ONLY valid JSON. No markdown, no explanations.

JSON Schema:
{
  "questions": [
    {"id": "q1", "question": "question text", "category": "hr"},
    {"id": "q2", "question": "question text", "category": "technical"},
    ... (4 hr, 5 technical, 3 dsa, 3 project)
  ]
}

Resume:
$trimmedResume
''';

    try {
      final response = await _sendRequest(prompt);
      final questionData = AIResponseParser.parseInterviewQuestions(response);
      return questionData.map((q) => InterviewQuestion.fromJson(q)).toList();
    } catch (e) {
      debugPrint('Interview questions generation failed, using fallback: $e');
      // Return fallback questions that never fail
      final fallbackData = AIResponseParser.parseInterviewQuestions('');
      return fallbackData.map((q) => InterviewQuestion.fromJson(q)).toList();
    }
  }

  Future<AnswerFeedback> evaluateAnswer(
      String question, String answer, String jobRole) async {
    final prompt = '''
You are a senior $jobRole interviewer. Evaluate this interview answer.

Question: $question
Answer: $answer

IMPORTANT: Respond with ONLY valid JSON. No markdown, no explanations.

JSON Schema:
{
  "score": 1-10,
  "correctness": "brief assessment",
  "communication": "brief assessment",
  "confidence_tip": "brief tip",
  "ideal_answer_hints": "brief hints",
  "follow_up_question": "follow-up question"
}
''';

    try {
      final response = await _sendRequest(prompt);
      final feedbackData = AIResponseParser.parseAnswerFeedback(response);
      return AnswerFeedback.fromJson(feedbackData);
    } catch (e) {
      debugPrint('Answer evaluation failed, using fallback: $e');
      // Return fallback feedback that never fails
      final fallbackData = AIResponseParser.parseAnswerFeedback('');
      return AnswerFeedback.fromJson(fallbackData);
    }
  }
}
