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
      confidenceTip: json['confidence_tip'] as String,
      idealAnswerHints: json['ideal_answer_hints'] as String,
      followUpQuestion: json['follow_up_question'] as String,
    );

Map<String, dynamic> _$AnswerFeedbackToJson(AnswerFeedback instance) =>
    <String, dynamic>{
      'score': instance.score,
      'correctness': instance.correctness,
      'communication': instance.communication,
      'confidence_tip': instance.confidenceTip,
      'ideal_answer_hints': instance.idealAnswerHints,
      'follow_up_question': instance.followUpQuestion,
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
      answersByQuestionId:
          (json['answersByQuestionId'] as Map<String, dynamic>?)?.map(
                (k, e) => MapEntry(k, e as String),
              ) ??
              const {},
      finalReport: json['final_report'] == null
          ? null
          : InterviewFinalReport.fromJson(
              json['final_report'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$InterviewSessionToJson(InterviewSession instance) =>
    <String, dynamic>{
      'id': instance.id,
      'resumeId': instance.resumeId,
      'jobRole': instance.jobRole,
      'questions': instance.questions,
      'feedbacks': instance.feedbacks,
      'answersByQuestionId': instance.answersByQuestionId,
      'final_report': instance.finalReport,
      'startedAt': instance.startedAt.toIso8601String(),
    };

InterviewFinalReport _$InterviewFinalReportFromJson(
        Map<String, dynamic> json) =>
    InterviewFinalReport(
      overallInterviewScore:
          (json['overall_interview_score'] as num).toDouble(),
      communicationScore: (json['communication_score'] as num).toDouble(),
      technicalScore: (json['technical_score'] as num).toDouble(),
      hrScore: (json['hr_score'] as num).toDouble(),
      dsaScore: (json['dsa_score'] as num).toDouble(),
      confidenceLevel: json['confidence_level'] as String,
      strengths:
          (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      areasToImprove: (json['areas_to_improve'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      aiFinalVerdict: json['ai_final_verdict'] as String,
      hiringRecommendation: json['hiring_recommendation'] as String,
      recommendedLearningTopics:
          (json['recommended_learning_topics'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      recommendedImprovements:
          (json['recommended_improvements'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      missingSkills: (json['missing_skills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      technicalQuestions: (json['technical_questions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      hrQuestions: (json['hr_questions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      atsScore: (json['ats_score'] as num).toDouble(),
    );

Map<String, dynamic> _$InterviewFinalReportToJson(
        InterviewFinalReport instance) =>
    <String, dynamic>{
      'overall_interview_score': instance.overallInterviewScore,
      'communication_score': instance.communicationScore,
      'technical_score': instance.technicalScore,
      'hr_score': instance.hrScore,
      'dsa_score': instance.dsaScore,
      'confidence_level': instance.confidenceLevel,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'areas_to_improve': instance.areasToImprove,
      'ai_final_verdict': instance.aiFinalVerdict,
      'hiring_recommendation': instance.hiringRecommendation,
      'recommended_learning_topics': instance.recommendedLearningTopics,
      'recommended_improvements': instance.recommendedImprovements,
      'missing_skills': instance.missingSkills,
      'technical_questions': instance.technicalQuestions,
      'hr_questions': instance.hrQuestions,
      'ats_score': instance.atsScore,
    };
