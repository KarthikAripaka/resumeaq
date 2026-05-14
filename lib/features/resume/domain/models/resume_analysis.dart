import 'package:json_annotation/json_annotation.dart';

part 'resume_analysis.g.dart';

@JsonSerializable()
class ResumeAnalysis {
  @JsonKey(name: 'ats_score')
  final int atsScore;
  final List<String> strengths;
  final List<String> weaknesses;
  @JsonKey(name: 'missing_skills')
  final List<String> missingSkills;
  @JsonKey(name: 'keyword_match')
  final List<String> keywordMatch;
  @JsonKey(name: 'improvement_tips')
  final List<String> improvementTips;
  final String summary;
  @JsonKey(name: 'job_role')
  final String jobRole;
  @JsonKey(name: 'analyzed_at')
  final DateTime analyzedAt;

  const ResumeAnalysis({
    required this.atsScore,
    required this.strengths,
    required this.weaknesses,
    required this.missingSkills,
    required this.keywordMatch,
    required this.improvementTips,
    required this.summary,
    required this.jobRole,
    required this.analyzedAt,
  });

  factory ResumeAnalysis.fromJson(Map<String, dynamic> json) {
    return ResumeAnalysis(
      atsScore: (json['ats_score'] ?? 0) as int,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      missingSkills: (json['missing_skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      keywordMatch: (json['keyword_match'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      improvementTips: (json['improvement_tips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      summary: json['summary'] ?? '',
      jobRole: json['job_role'] ?? '',
      analyzedAt: json['analyzed_at'] != null
          ? DateTime.parse(json['analyzed_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => _$ResumeAnalysisToJson(this);
}