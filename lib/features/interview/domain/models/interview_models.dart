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
  final String confidenceTip;
  final String idealAnswerHints;
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
  final DateTime startedAt;

  const InterviewSession({
    required this.id,
    required this.resumeId,
    required this.jobRole,
    required this.questions,
    required this.feedbacks,
    required this.startedAt,
  });

  factory InterviewSession.fromJson(Map<String, dynamic> json) =>
      _$InterviewSessionFromJson(json);

  Map<String, dynamic> toJson() => _$InterviewSessionToJson(this);
}