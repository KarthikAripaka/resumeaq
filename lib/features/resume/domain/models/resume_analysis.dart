import 'package:json_annotation/json_annotation.dart';

part 'resume_analysis.g.dart';

@JsonSerializable()
class ResumeAnalysis {
  final int atsScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> missingSkills;
  final List<String> keywordMatch;
  final List<String> improvementTips;
  final String summary;
  final String jobRole;
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

  factory ResumeAnalysis.fromJson(Map<String, dynamic> json) =>
      _$ResumeAnalysisFromJson(json);

  Map<String, dynamic> toJson() => _$ResumeAnalysisToJson(this);
}