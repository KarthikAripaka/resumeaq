import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/local_interview_storage.dart';
import '../../../interview/domain/models/interview_models.dart';

class InterviewResultScreen extends ConsumerStatefulWidget {
  const InterviewResultScreen({super.key});

  @override
  ConsumerState<InterviewResultScreen> createState() =>
      _InterviewResultScreenState();
}

class _InterviewResultScreenState extends ConsumerState<InterviewResultScreen> {
  @override
  Widget build(BuildContext context) {
    final latestSessionAsync = ref.watch(_latestSessionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Evaluation'),
      ),
      body: latestSessionAsync.when(
        loading: () => const _LoadingState(),
        error: (e, _) => _ErrorState(
          e: e.toString(),
          onRetry: () => ref.invalidate(_latestSessionProvider),
        ),
        data: (session) {
          final report = session?.finalReport;
          if (report == null) {
            return const Center(
              child: Text('Final evaluation not available yet.'),
            );
          }

          return _InterviewResultBody(report: report);
        },
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 56,
              height: 56,
              child: CircularProgressIndicator(strokeWidth: 6),
            ),
            const SizedBox(height: 16),
            Text(
              'Preparing your results...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'This takes a moment. Please wait.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _InterviewResultBody extends StatelessWidget {
  final InterviewFinalReport report;

  const _InterviewResultBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ScoreHero(report: report),
          const SizedBox(height: 14),
          _SectionTitle(title: 'Scores breakdown'),
          const SizedBox(height: 10),
          _ScoreBreakdown(report: report),
          const SizedBox(height: 16),
          _AtsScoreCard(atsScore: report.atsScore),
          const SizedBox(height: 16),
          _RecommendationsCard(report: report),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 700;
              if (!isWide) {
                return Column(
                  children: [
                    _ListSection(
                      title: 'Strengths',
                      items: report.strengths,
                    ),
                    const SizedBox(height: 16),
                    _ListSection(
                      title: 'Weaknesses',
                      items: report.weaknesses,
                    ),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ListSection(
                      title: 'Strengths',
                      items: report.strengths,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ListSection(
                      title: 'Weaknesses',
                      items: report.weaknesses,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _ListSection(
            title: 'Missing Skills',
            items: report.missingSkills,
          ),
          const SizedBox(height: 16),
          _ListSection(
            title: 'Areas To Improve',
            items: report.areasToImprove,
          ),
          const SizedBox(height: 16),
          _VerdictCard(text: report.aiFinalVerdict),
          const SizedBox(height: 12),
          _VerdictCard(text: report.hiringRecommendation),
          const SizedBox(height: 16),
          _ListSection(
            title: 'Recommended Learning Topics',
            items: report.recommendedLearningTopics,
          ),
          const SizedBox(height: 16),
          _ListSection(
            title: 'Technical Questions',
            items: report.technicalQuestions,
          ),
          const SizedBox(height: 16),
          _ListSection(
            title: 'HR Questions',
            items: report.hrQuestions,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => context.go('/interview'),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Practice Another Interview'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: You can revisit this screen anytime after finishing an interview.',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    ).animate().fadeIn().slideY();
  }
}

final _latestSessionProvider = FutureProvider<InterviewSession?>((ref) async {
  final sessions = await LocalInterviewStorage.getAllSessions();
  if (sessions.isEmpty) return null;
  return sessions.first;
});

class _ErrorState extends StatelessWidget {
  final String e;
  final VoidCallback onRetry;

  const _ErrorState({required this.e, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 72, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              e,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            )
          ],
        ),
      ),
    );
  }
}

class _ScoreHero extends StatelessWidget {
  final InterviewFinalReport report;

  const _ScoreHero({required this.report});

  @override
  Widget build(BuildContext context) {
    final overall = report.overallInterviewScore.clamp(0, 10);
    final toneColor = overall >= 8
        ? Colors.green
        : overall >= 6
            ? Colors.blue
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            toneColor.shade400,
            toneColor.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star, color: Colors.white, size: 42),
              const Spacer(),
              _ConfidencePill(confidence: report.confidenceLevel),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${overall.toStringAsFixed(1)}/10',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            overall >= 8
                ? 'Excellent performance'
                : overall >= 6
                    ? 'Good performance'
                    : 'Keep practicing',
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'Confidence: ${report.confidenceLevel}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ConfidencePill extends StatelessWidget {
  final String confidence;

  const _ConfidencePill({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final color = confidence == 'high'
        ? Colors.green
        : confidence == 'medium'
            ? Colors.blue
            : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        confidence.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  final InterviewFinalReport report;

  const _ScoreBreakdown({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CircularScore(
            label: 'Overall', value: report.overallInterviewScore, size: 80),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CircularScore(
                label: 'Technical', value: report.technicalScore, size: 60),
            _CircularScore(
                label: 'Communication',
                value: report.communicationScore,
                size: 60),
            _CircularScore(label: 'HR', value: report.hrScore, size: 60),
            _CircularScore(label: 'DSA', value: report.dsaScore, size: 60),
          ],
        ),
      ],
    );
  }
}

class _CircularScore extends StatelessWidget {
  final String label;
  final double value;
  final double size;

  const _CircularScore({
    required this.label,
    required this.value,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, 10);
    final percent = (v / 10.0).clamp(0.0, 1.0);
    final color = percent >= 0.8
        ? Colors.green
        : percent >= 0.6
            ? Colors.blue
            : Colors.orange;

    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              CircularProgressIndicator(
                value: percent,
                strokeWidth: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Center(
                child: Text(
                  '${v.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: size / 4,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final List<String> items;

  const _ListSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final safe = items.where((e) => e.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: title),
        const SizedBox(height: 8),
        if (safe.isEmpty) const Text('—', style: TextStyle(color: Colors.grey)),
        if (safe.isNotEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: safe
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(e,
                                    style: const TextStyle(
                                        fontSize: 14, height: 1.4)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class _VerdictCard extends StatelessWidget {
  final String text;

  const _VerdictCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final safe = text.trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          safe.isEmpty ? '—' : safe,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: 15, height: 1.45),
        ),
      ),
    );
  }
}

class _AtsScoreCard extends StatelessWidget {
  final double atsScore;

  const _AtsScoreCard({required this.atsScore});

  @override
  Widget build(BuildContext context) {
    final score = atsScore.clamp(0, 100);
    final color = score >= 80
        ? Colors.green
        : score >= 60
            ? Colors.blue
            : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: color),
                const SizedBox(width: 8),
                Text(
                  'ATS Score',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: score / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${score.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              score >= 80
                  ? 'Excellent ATS compatibility'
                  : score >= 60
                      ? 'Good ATS compatibility'
                      : 'Needs improvement for ATS',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationsCard extends StatelessWidget {
  final InterviewFinalReport report;

  const _RecommendationsCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final recommendations = <String>[];

    // Use recommended_improvements as actionable recommendations.
    recommendations.addAll(report.recommendedImprovements);

    // Fallback: if empty, use areas_to_improve.
    if (recommendations.isEmpty) {
      recommendations.addAll(report.areasToImprove);
    }

    // Fallback: if empty, use weaknesses.
    if (recommendations.isEmpty) {
      recommendations.addAll(report.weaknesses);
    }

    final safe = recommendations.where((e) => e.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Actionable Recommendations'),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: safe.isEmpty
                ? const Text('—', style: TextStyle(color: Colors.grey))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: safe
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 18, color: Colors.green),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(e,
                                        style: const TextStyle(
                                            fontSize: 14, height: 1.4)),
                                  )
                                ],
                              ),
                            ))
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}
