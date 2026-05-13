import 'dart:convert';
import '../../features/resume/domain/models/resume_analysis.dart';

class AIResponseParser {
  /// Safely parse AI response into ResumeAnalysis
  static ResumeAnalysis parseResumeAnalysis(String rawResponse, String jobRole) {
    try {
      final cleanedJson = _extractAndCleanJson(rawResponse);
      final json = jsonDecode(cleanedJson);

      return ResumeAnalysis.fromJson({
        ...json,
        'job_role': jobRole,
        'analyzed_at': DateTime.now().toIso8601String(),
        'keyword_match': json['missing_skills'] ?? [], // Map missing skills to keyword match
        'improvement_tips': json['recommendations'] ?? [], // Map recommendations to improvement tips
        'summary': _generateSummary(json),
      });
    } catch (e) {
      // Return safe fallback analysis if parsing fails
      return _createFallbackAnalysis(jobRole);
    }
  }

  /// Extract and clean JSON from AI response
  static String _extractAndCleanJson(String response) {
    if (response.trim().isEmpty) {
      throw Exception('Empty response');
    }

    var cleaned = response.trim();

    // Remove markdown code blocks
    if (cleaned.startsWith('```json') && cleaned.endsWith('```')) {
      cleaned = cleaned.substring(7, cleaned.length - 3).trim();
    } else if (cleaned.startsWith('```') && cleaned.endsWith('```')) {
      cleaned = cleaned.substring(3, cleaned.length - 3).trim();
    }

    // Find the first '{' and last '}'
    final startIndex = cleaned.indexOf('{');
    final endIndex = cleaned.lastIndexOf('}');

    if (startIndex == -1 || endIndex == -1 || startIndex >= endIndex) {
      throw Exception('No valid JSON structure found');
    }

    cleaned = cleaned.substring(startIndex, endIndex + 1);

    // Remove any trailing commas before closing braces/brackets
    cleaned = cleaned.replaceAllMapped(RegExp(r',(\s*[}\]])'), (Match match) => match.group(1)!);

    return cleaned;
  }

  /// Generate a summary from the parsed JSON data
  static String _generateSummary(Map<String, dynamic> json) {
    try {
      final score = json['ats_score'] ?? 0;
      final strengths = json['strengths'] ?? [];
      final weaknesses = json['weaknesses'] ?? [];

      return 'ATS Score: $score/100. Strengths: ${strengths.join(', ')}. Areas for improvement: ${weaknesses.join(', ')}.';
    } catch (e) {
      return 'Resume analysis completed. Review strengths and improvement suggestions below.';
    }
  }

  /// Create a safe fallback analysis when parsing fails
  static ResumeAnalysis _createFallbackAnalysis(String jobRole) {
    return ResumeAnalysis(
      atsScore: 70,
      strengths: [
        'Resume uploaded successfully',
        'Basic qualifications present',
        'Contact information available',
      ],
      weaknesses: [
        'Could not analyze specific content',
        'AI processing encountered an issue',
        'Manual review recommended',
      ],
      missingSkills: [
        'Analysis temporarily unavailable',
        'Please try again later',
      ],
      keywordMatch: [],
      improvementTips: [
        'Ensure resume is in PDF format',
        'Include relevant keywords for your field',
        'Highlight quantifiable achievements',
        'Keep resume concise and well-structured',
      ],
      summary: 'Resume analysis encountered a processing issue. Please try uploading again or contact support if the problem persists.',
      jobRole: jobRole,
      analyzedAt: DateTime.now(),
    );
  }

  /// Safely parse interview questions
  static List<Map<String, dynamic>> parseInterviewQuestions(String rawResponse) {
    try {
      final cleanedJson = _extractAndCleanJson(rawResponse);
      final json = jsonDecode(cleanedJson);

      final questions = json['questions'];
      if (questions is List) {
        return List<Map<String, dynamic>>.from(questions);
      }

      throw Exception('Invalid questions format');
    } catch (e) {
      // Return safe fallback questions
      return _createFallbackQuestions();
    }
  }

  /// Create fallback interview questions
  static List<Map<String, dynamic>> _createFallbackQuestions() {
    return [
      {
        'id': 'q1',
        'question': 'Can you tell us about your previous experience in this field?',
        'category': 'hr',
      },
      {
        'id': 'q2',
        'question': 'What are your strengths and weaknesses?',
        'category': 'hr',
      },
      {
        'id': 'q3',
        'question': 'Why are you interested in this position?',
        'category': 'hr',
      },
      {
        'id': 'q4',
        'question': 'Describe a challenging project you worked on.',
        'category': 'technical',
      },
      {
        'id': 'q5',
        'question': 'What programming languages are you proficient in?',
        'category': 'technical',
      },
    ];
  }

  /// Safely parse answer feedback
  static Map<String, dynamic> parseAnswerFeedback(String rawResponse) {
    try {
      final cleanedJson = _extractAndCleanJson(rawResponse);
      final json = jsonDecode(cleanedJson);

      return Map<String, dynamic>.from(json);
    } catch (e) {
      // Return safe fallback feedback
      return _createFallbackFeedback();
    }
  }

  /// Create fallback answer feedback
  static Map<String, dynamic> _createFallbackFeedback() {
    return {
      'score': 7,
      'correctness': 'Your answer shows good understanding of the topic.',
      'communication': 'Response was clear and well-structured.',
      'confidence_tip': 'Consider providing more specific examples.',
      'ideal_answer_hints': 'Include concrete examples from your experience.',
      'follow_up_question': 'Can you elaborate on the challenges you faced?',
    };
  }
}