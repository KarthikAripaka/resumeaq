// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interview_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InterviewQuestion _$InterviewQuestionFromJson(Map<String, dynamic> json) =>
    InterviewQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$InterviewQuestionToJson(InterviewQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'category': instance.category,
    };

AnswerFeedback _$AnswerFeedbackFromJson(Map<String, dynamic> json) =>
    AnswerFeedback(
      score: (json['score'] as num).toInt(),
      correctness: json['correctness'] as String,
      communication: json['communication'] as String,
      confidenceTip: json['confidenceTip'] as String,
      idealAnswerHints: json['idealAnswerHints'] as String,
      followUpQuestion: json['followUpQuestion'] as String,
    );

Map<String, dynamic> _$AnswerFeedbackToJson(AnswerFeedback instance) =>
    <String, dynamic>{
      'score': instance.score,
      'correctness': instance.correctness,
      'communication': instance.communication,
      'confidenceTip': instance.confidenceTip,
      'idealAnswerHints': instance.idealAnswerHints,
      'followUpQuestion': instance.followUpQuestion,
    };

InterviewSession _$InterviewSessionFromJson(Map<String, dynamic> json) =>
    InterviewSession(
      id: json['id'] as String,
      resumeId: json['resumeId'] as String,
      jobRole: json['jobRole'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => InterviewQuestion.fromJson(e as Map<String, dynamic>))
          .toList(),
      feedbacks: (json['feedbacks'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, AnswerFeedback.fromJson(e as Map<String, dynamic>)),
      ),
      startedAt: DateTime.parse(json['startedAt'] as String),
    );

Map<String, dynamic> _$InterviewSessionToJson(InterviewSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'jobRole': instance.jobRole,
      'questions': instance.questions,
      'feedbacks': instance.feedbacks,
      'startedAt': instance.startedAt.toIso8601String(),
    };
