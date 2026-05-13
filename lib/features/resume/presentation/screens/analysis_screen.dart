import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_iq_ai/features/resume/presentation/providers/resume_provider.dart';
import 'package:shimmer/shimmer.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  String _scoreLabel(int score) {
    if (score >= 90) return 'Excellent — strong ATS alignment';
    if (score >= 75) return 'Strong — close match to the role';
    if (score >= 60) return 'Moderate — improve keyword + evidence';
    return 'Needs improvement — add role keywords & outcomes';
  }

  Color _scoreColor(int score) {
    if (score >= 90) return Colors.green.shade600;
    if (score >= 75) return Colors.blue.shade600;
    if (score >= 60) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  Color _scoreBgColor(int score) {
    if (score >= 90) return Colors.green.shade100;
    if (score >= 75) return Colors.blue.shade100;
    if (score >= 60) return Colors.orange.shade100;
    return Colors.red.shade100;
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          const SizedBox(
            height: 140,
            width: 140,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 20,
            width: 200,
            color: Colors.white,
          ),
          const SizedBox(height: 24),
          Container(
            height: 16,
            width: double.infinity,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              4,
              (index) => Container(
                height: 32,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(resumeNotifierProvider);

    return resumeState.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Resume Analysis')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildShimmerLoading(),
              const Spacer(),
              const SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: null,
                  child: Text('Analyzing...'),
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Resume Analysis')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Icon(Icons.analytics_outlined,
                  size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'Analysis temporarily unavailable. Please try again in a few moments.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/upload'),
                  child: const Text('Upload another resume'),
                ),
              ),
            ],
          ),
        ),
      ),
      data: (analysis) {
        final safeAnalysis = analysis!;

        return Scaffold(
          appBar: AppBar(title: const Text('Resume Analysis')),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ATS Score Section
                Align(
                  alignment: Alignment.center,
                  child: Hero(
                    tag: 'ats_score',
                    child: Container(
                      height: 140,
                      width: 140,
                      decoration: BoxDecoration(
                        color: _scoreBgColor(safeAnalysis.atsScore),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _scoreColor(safeAnalysis.atsScore),
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${safeAnalysis.atsScore}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: _scoreColor(safeAnalysis.atsScore),
                          ),
                        ),
                      ),
                    ).animate().scale(duration: 600.ms).fadeIn(),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _scoreLabel(safeAnalysis.atsScore),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _scoreColor(safeAnalysis.atsScore),
                    ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 200.ms),
                ),
                const SizedBox(height: 32),

                // Strengths Section
                Text('Strengths',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 12),
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: safeAnalysis.strengths
                      .where((e) => e.trim().isNotEmpty)
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 13)),
                            backgroundColor: Colors.green.shade50,
                            side: BorderSide(color: Colors.green.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ))
                      .toList(),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 28),

                // Missing Skills Section
                Text('Areas for Improvement',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 12),
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: safeAnalysis.missingSkills
                      .where((e) => e.trim().isNotEmpty)
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 13)),
                            backgroundColor: Colors.orange.shade50,
                            side: BorderSide(color: Colors.orange.shade200),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ))
                      .toList(),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 28),

                // Improvement Tips Section
                Text('Actionable Recommendations',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: safeAnalysis.improvementTips
                        .where((e) => e.trim().isNotEmpty)
                        .length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final tips = safeAnalysis.improvementTips
                          .where((e) => e.trim().isNotEmpty)
                          .toList();
                      final tip = tips[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                margin: const EdgeInsets.only(top: 8, right: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: (800 + index * 100).ms);
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: safeAnalysis.atsScore.clamp(0, 100) / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_scoreColor(safeAnalysis.atsScore)),
                    minHeight: 8,
                  ),
                ).animate().fadeIn(delay: 1000.ms),

                const SizedBox(height: 24),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/interview'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start Mock Interview', style: TextStyle(fontSize: 16)),
                  ),
                ).animate().fadeIn(delay: 1200.ms),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Report', style: TextStyle(fontSize: 16)),
                  ),
                ).animate().fadeIn(delay: 1400.ms),
              ],
            ),
          ),
        );
      },
    );
  }
}
