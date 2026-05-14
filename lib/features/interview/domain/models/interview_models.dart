import 'package:json_annotation/json_annotation.dart';

part 'interview_models.g.dart';

@JsonSerializable()
class InterviewQuestion {
  final String id;
  final String question;
  final String category;

  const InterviewQuestion({
    required this.id,
    required this.question,
    required this.category,
  });

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) =>
      _$InterviewQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewQuestionToJson(this);
}

@JsonSerializable()
class AnswerFeedback {
  final int score;
  final String correctness;
  final String communication;
  @JsonKey(name: 'confidence_tip')
  final String confidenceTip;
  @JsonKey(name: 'ideal_answer_hints')
  final String idealAnswerHints;
  @JsonKey(name: 'follow_up_question')
  final String followUpQuestion;

  const AnswerFeedback({
    required this.score,
    required this.correctness,
    required this.communication,
    required this.confidenceTip,
    required this.idealAnswerHints,
    required this.followUpQuestion,
  });

  factory AnswerFeedback.fromJson(Map<String, dynamic> json) =>
      _$AnswerFeedbackFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerFeedbackToJson(this);
}

@JsonSerializable()
class InterviewSession {
  final String id;
  final String resumeId;
  final String jobRole;
  final List<InterviewQuestion> questions;
  final Map<String, AnswerFeedback> feedbacks;

  /// Raw answers captured from the user; keyed by questionId.
  final Map<String, String> answersByQuestionId;

  /// Final evaluation report computed after the interview is finished.
  @JsonKey(name: 'final_report')
  final InterviewFinalReport? finalReport;

  final DateTime startedAt;

  const InterviewSession({
    required this.id,
    required this.resumeId,
    required this.jobRole,
    required this.questions,
    required this.feedbacks,
    required this.startedAt,
    this.answersByQuestionId = const {},
    this.finalReport,
  });

  factory InterviewSession.fromJson(Map<String, dynamic> json) =>
      _$InterviewSessionFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewSessionToJson(this);
}

@JsonSerializable()
class InterviewFinalReport {
  @JsonKey(name: 'overall_interview_score')
  final double overallInterviewScore;

  @JsonKey(name: 'communication_score')
  final double communicationScore;

  @JsonKey(name: 'technical_score')
  final double technicalScore;

  @JsonKey(name: 'hr_score')
  final double hrScore;

  @JsonKey(name: 'dsa_score')
  final double dsaScore;

  @JsonKey(name: 'confidence_level')
  final String confidenceLevel;

  @JsonKey(name: 'strengths')
  final List<String> strengths;

  @JsonKey(name: 'weaknesses')
  final List<String> weaknesses;

  @JsonKey(name: 'areas_to_improve')
  final List<String> areasToImprove;

  @JsonKey(name: 'ai_final_verdict')
  final String aiFinalVerdict;

  @JsonKey(name: 'hiring_recommendation')
  final String hiringRecommendation;

  @JsonKey(name: 'recommended_learning_topics')
  final List<String> recommendedLearningTopics;

  @JsonKey(name: 'recommended_improvements')
  final List<String> recommendedImprovements;

  @JsonKey(name: 'missing_skills')
  final List<String> missingSkills;

  @JsonKey(name: 'technical_questions')
  final List<String> technicalQuestions;

  @JsonKey(name: 'hr_questions')
  final List<String> hrQuestions;

  @JsonKey(name: 'ats_score')
  final double atsScore;

  const InterviewFinalReport({
    required this.overallInterviewScore,
    required this.communicationScore,
    required this.technicalScore,
    required this.hrScore,
    required this.dsaScore,
    required this.confidenceLevel,
    required this.strengths,
    required this.weaknesses,
    required this.areasToImprove,
    required this.aiFinalVerdict,
    required this.hiringRecommendation,
    required this.recommendedLearningTopics,
    required this.recommendedImprovements,
    required this.missingSkills,
    required this.technicalQuestions,
    required this.hrQuestions,
    required this.atsScore,
  });

  factory InterviewFinalReport.fromJson(Map<String, dynamic> json) {
    return InterviewFinalReport(
      overallInterviewScore: (json['overall_interview_score'] ?? 0).toDouble(),
      communicationScore: (json['communication_score'] ?? 0).toDouble(),
      technicalScore: (json['technical_score'] ?? 0).toDouble(),
      hrScore: (json['hr_score'] ?? 0).toDouble(),
      dsaScore: (json['dsa_score'] ?? 0).toDouble(),
      confidenceLevel: json['confidence_level'] ?? 'low',
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      areasToImprove: (json['areas_to_improve'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      aiFinalVerdict: json['ai_final_verdict'] ?? '',
      hiringRecommendation: json['hiring_recommendation'] ?? '',
      recommendedLearningTopics: (json['recommended_learning_topics'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      recommendedImprovements: (json['recommended_improvements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      missingSkills: (json['missing_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      technicalQuestions: (json['technical_questions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      hrQuestions: (json['hr_questions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      atsScore: (json['ats_score'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => _$InterviewFinalReportToJson(this);
}
