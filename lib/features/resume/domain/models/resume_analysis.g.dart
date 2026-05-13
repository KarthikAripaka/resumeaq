// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeAnalysis _$ResumeAnalysisFromJson(Map<String, dynamic> json) =>
    ResumeAnalysis(
      atsScore: (json['ats_score'] as num).toInt(),
      strengths:
          (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      missingSkills: (json['missing_skills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keywordMatch: (json['keyword_match'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      improvementTips: (json['improvement_tips'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      summary: json['summary'] as String,
      jobRole: json['job_role'] as String,
      analyzedAt: DateTime.parse(json['analyzed_at'] as String),
    );

Map<String, dynamic> _$ResumeAnalysisToJson(ResumeAnalysis instance) =>
    <String, dynamic>{
      'ats_score': instance.atsScore,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'missing_skills': instance.missingSkills,
      'keyword_match': instance.keywordMatch,
      'improvement_tips': instance.improvementTips,
      'summary': instance.summary,
      'job_role': instance.jobRole,
      'analyzed_at': instance.analyzedAt.toIso8601String(),
    };
