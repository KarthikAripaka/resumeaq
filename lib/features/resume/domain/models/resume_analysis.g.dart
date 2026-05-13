// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_analysis.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResumeAnalysis _$ResumeAnalysisFromJson(Map<String, dynamic> json) =>
    ResumeAnalysis(
      atsScore: (json['atsScore'] as num).toInt(),
      strengths:
          (json['strengths'] as List<dynamic>).map((e) => e as String).toList(),
      weaknesses: (json['weaknesses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      missingSkills: (json['missingSkills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      keywordMatch: (json['keywordMatch'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      improvementTips: (json['improvementTips'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      summary: json['summary'] as String,
      jobRole: json['jobRole'] as String,
      analyzedAt: DateTime.parse(json['analyzedAt'] as String),
    );

Map<String, dynamic> _$ResumeAnalysisToJson(ResumeAnalysis instance) =>
    <String, dynamic>{
      'atsScore': instance.atsScore,
      'strengths': instance.strengths,
      'weaknesses': instance.weaknesses,
      'missingSkills': instance.missingSkills,
      'keywordMatch': instance.keywordMatch,
      'improvementTips': instance.improvementTips,
      'summary': instance.summary,
      'jobRole': instance.jobRole,
      'analyzedAt': instance.analyzedAt.toIso8601String(),
    };
