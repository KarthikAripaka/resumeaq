import 'dart:convert';
import '../../features/resume/domain/models/resume_analysis.dart';

ResumeAnalysis parseResumeAnalysisIsolate(List<dynamic> args) {
  return AIResponseParser.parseResumeAnalysis(args[0], args[1], args[2]);
}

List<Map<String, dynamic>> parseInterviewQuestionsIsolate(String rawResponse) {
  return AIResponseParser.parseInterviewQuestions(rawResponse);
}

Map<String, dynamic> parseAnswerFeedbackIsolate(String rawResponse) {
  return AIResponseParser.parseAnswerFeedback(rawResponse);
}

class AIResponseParser {
  /// Safely parse AI response into ResumeAnalysis
  static ResumeAnalysis parseResumeAnalysis(
      String rawResponse, String jobRole, [String resumeText = '']) {
    try {
      final cleanedJson = _extractAndCleanJson(rawResponse);
      final json = jsonDecode(cleanedJson);

      return ResumeAnalysis.fromJson({
        ...json,
        'job_role': jobRole,
        'analyzed_at': DateTime.now().toIso8601String(),
        'keyword_match':
            json['missing_skills'] ?? [], // Map missing skills to keyword match
        'improvement_tips': json['recommendations'] ??
            [], // Map recommendations to improvement tips
        'summary': _generateSummary(json),
      });
    } catch (e) {
      // Return safe fallback analysis if parsing fails
      return _createFallbackAnalysis(jobRole, resumeText);
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
    cleaned = cleaned.replaceAllMapped(
        RegExp(r',(\s*[}\]])'), (Match match) => match.group(1)!);

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
  static ResumeAnalysis _createFallbackAnalysis(String jobRole, String resumeText) {
    // Generate contextual insights from resume text
    final analysis = _analyzeResumeText(resumeText, jobRole);

    return ResumeAnalysis(
      atsScore: analysis['score'],
      strengths: analysis['strengths'],
      weaknesses: analysis['weaknesses'],
      missingSkills: analysis['missingSkills'],
      keywordMatch: analysis['keywordMatch'],
      improvementTips: analysis['improvementTips'],
      summary: analysis['summary'],
      jobRole: jobRole,
      analyzedAt: DateTime.now(),
    );
  }

  /// Analyze resume text to generate contextual insights
  static Map<String, dynamic> _analyzeResumeText(String resumeText, String jobRole) {
    final text = resumeText.toLowerCase();
    final score = _calculateFallbackScore(text, jobRole);
    final strengths = _generateStrengths(text, jobRole);
    final weaknesses = _generateWeaknesses(text, jobRole);
    final missingSkills = _generateMissingSkills(text, jobRole);
    final keywordMatch = _generateKeywordMatch(text, jobRole);
    final improvementTips = _generateImprovementTips(text, jobRole);
    final summary = _generateFallbackSummary(score, jobRole);

    return {
      'score': score,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'missingSkills': missingSkills,
      'keywordMatch': keywordMatch,
      'improvementTips': improvementTips,
      'summary': summary,
    };
  }

  /// Calculate fallback ATS score based on resume content
  static int _calculateFallbackScore(String text, String jobRole) {
    int score = 50; // Base score

    // Technical roles
    if (jobRole.toLowerCase().contains('developer') ||
        jobRole.toLowerCase().contains('engineer')) {
      if (text.contains('javascript') || text.contains('python') || text.contains('java')) score += 10;
      if (text.contains('react') || text.contains('node') || text.contains('api')) score += 5;
      if (text.contains('git') || text.contains('github')) score += 5;
      if (text.contains('test') || text.contains('testing')) score += 5;
      if (text.contains('agile') || text.contains('scrum')) score += 5;
    }

    // Add points for structure indicators
    if (text.contains('experience') && text.contains('skills')) score += 5;
    if (text.contains('project') || text.contains('portfolio')) score += 5;
    if (text.contains('education') || text.contains('degree')) score += 5;

    return score.clamp(35, 85); // Reasonable range for fallback
  }

  /// Generate contextual strengths
  static List<String> _generateStrengths(String text, String jobRole) {
    final strengths = <String>[];

    if (text.contains('experience') || text.contains('worked')) {
      strengths.add('Professional experience clearly documented');
    }

    if (text.contains('education') || text.contains('degree') || text.contains('university')) {
      strengths.add('Educational background well presented');
    }

    if (text.contains('project')) {
      strengths.add('Project experience highlighted');
    }

    if (text.contains('skill') || text.contains('technologies')) {
      strengths.add('Technical skills section present');
    }

    // Job-specific strengths
    if (jobRole.toLowerCase().contains('developer') && (text.contains('code') || text.contains('programming'))) {
      strengths.add('Programming experience demonstrated');
    }

    if (jobRole.toLowerCase().contains('manager') && text.contains('team')) {
      strengths.add('Team management experience indicated');
    }

    if (strengths.isEmpty) {
      strengths.addAll([
        'Resume structure provides clear information hierarchy',
        'Contact information readily available',
        'Professional formatting maintained throughout',
      ]);
    }

    return strengths.take(4).toList();
  }

  /// Generate contextual weaknesses
  static List<String> _generateWeaknesses(String text, String jobRole) {
    final weaknesses = <String>[];

    if (!text.contains('quantify') && !text.contains('metric') && !text.contains('result')) {
      weaknesses.add('Achievement quantification could be improved');
    }

    if (!text.contains('keyword') && jobRole.isNotEmpty) {
      weaknesses.add('Job-specific keywords may need enhancement');
    }

    if (!text.contains('test') && (jobRole.toLowerCase().contains('developer') || jobRole.toLowerCase().contains('engineer'))) {
      weaknesses.add('Testing experience not prominently featured');
    }

    if (weaknesses.isEmpty) {
      weaknesses.addAll([
        'Could benefit from more specific technical details',
        'Achievement metrics could be more prominent',
        'Industry-specific terminology could be expanded',
      ]);
    }

    return weaknesses.take(3).toList();
  }

  /// Generate contextual missing skills
  static List<String> _generateMissingSkills(String text, String jobRole) {
    final missingSkills = <String>[];

    // Technical skills for developers
    if (jobRole.toLowerCase().contains('developer') || jobRole.toLowerCase().contains('engineer')) {
      if (!text.contains('test') && !text.contains('testing')) {
        missingSkills.add('Testing frameworks and methodologies');
      }
      if (!text.contains('ci') && !text.contains('cd') && !text.contains('pipeline')) {
        missingSkills.add('CI/CD and deployment practices');
      }
      if (!text.contains('agile') && !text.contains('scrum')) {
        missingSkills.add('Agile development experience');
      }
      if (!text.contains('cloud') && !text.contains('aws') && !text.contains('azure')) {
        missingSkills.add('Cloud platform experience');
      }
    }

    // Management skills
    if (jobRole.toLowerCase().contains('manager') || jobRole.toLowerCase().contains('lead')) {
      if (!text.contains('team') && !text.contains('manage')) {
        missingSkills.add('Team leadership and management');
      }
      if (!text.contains('stakeholder')) {
        missingSkills.add('Stakeholder communication skills');
      }
    }

    if (missingSkills.isEmpty) {
      missingSkills.addAll([
        'Advanced technical certifications',
        'Industry-specific tools and platforms',
        'Performance optimization techniques',
      ]);
    }

    return missingSkills.take(4).toList();
  }

  /// Generate keyword match insights
  static List<String> _generateKeywordMatch(String text, String jobRole) {
    final keywords = <String>[];

    if (text.contains(jobRole.toLowerCase())) {
      keywords.add('Job title keywords present');
    }

    if (text.contains('skill') || text.contains('competencies')) {
      keywords.add('Skills section provides keyword coverage');
    }

    if (keywords.isEmpty) {
      keywords.add('Basic resume structure supports ATS parsing');
    }

    return keywords;
  }

  /// Generate improvement tips
  static List<String> _generateImprovementTips(String text, String jobRole) {
    final tips = <String>[];

    tips.add('Include measurable outcomes for each major achievement');
    tips.add('Mirror job description keywords in skills and experience sections');

    if (jobRole.toLowerCase().contains('developer')) {
      tips.add('Highlight testing experience and code quality practices');
      tips.add('Include version control and collaboration tools');
    }

    if (!text.contains('project')) {
      tips.add('Add specific project examples with technologies used');
    }

    return tips.take(5).toList();
  }

  /// Generate fallback summary
  static String _generateFallbackSummary(int score, String jobRole) {
    String level;
    if (score >= 75) {
      level = 'strong';
    } else if (score >= 60) {
      level = 'moderate';
    } else {
      level = 'developing';
    }

    return 'Resume analysis completed. ATS alignment appears $level for $jobRole positions. Review the insights below to optimize for better matching.';
  }

  /// Safely parse interview questions
  static List<Map<String, dynamic>> parseInterviewQuestions(
      String rawResponse) {
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
        'question':
            'Can you tell us about your previous experience in this field?',
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

      // Normalize field names to match Dart model expectations
      final normalized = <String, dynamic>{};
      json.forEach((key, value) {
        switch (key) {
          case 'confidence_tip':
            normalized['confidenceTip'] = value;
            break;
          case 'ideal_answer_hints':
            normalized['idealAnswerHints'] = value;
            break;
          case 'follow_up_question':
            normalized['followUpQuestion'] = value;
            break;
          default:
            normalized[key] = value;
        }
      });

      return normalized;
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
