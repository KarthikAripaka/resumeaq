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
        if (analysis == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Analysis Error')),
            body: const Center(
              child: Text(
                  'No analysis data available. Please try uploading again.'),
            ),
          );
        }

        final safeAnalysis = analysis;
        // Update the current analysis provider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(currentAnalysisProvider.notifier).state = safeAnalysis;
        });

        return Scaffold(
          appBar: AppBar(title: const Text('Resume Analysis')),
          body: SingleChildScrollView(
            child: Padding(
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
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _scoreColor(safeAnalysis.atsScore),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                  ),
                  const SizedBox(height: 32),

                  // Strengths Section
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.green.shade300, width: 2),
                    ),
                     child: Row(
                       children: [
                         Icon(Icons.check_circle,
                             color: Colors.green.shade700, size: 24),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Text('Strengths',
                               style: TextStyle(
                                 fontSize: 20,
                                 fontWeight: FontWeight.w800,
                                 color: Colors.green.shade800,
                                 letterSpacing: 0.5,
                               )),
                         ),
                       ],
                     ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: safeAnalysis.strengths
                        .where((e) => e.trim().isNotEmpty)
                        .map((s) => Chip(
                              key: ValueKey('strength_$s'),
                              label: Text(s,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.green.shade400, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ))
                        .toList(),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 32),

                  // Weaknesses Section
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.amber.shade300, width: 2),
                    ),
                     child: Row(
                       children: [
                         Icon(Icons.warning,
                             color: Colors.amber.shade700, size: 24),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Text('Areas Needing Attention',
                               style: TextStyle(
                                 fontSize: 20,
                                 fontWeight: FontWeight.w800,
                                 color: Colors.amber.shade800,
                                 letterSpacing: 0.5,
                               )),
                         ),
                       ],
                     ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: safeAnalysis.weaknesses
                        .where((e) => e.trim().isNotEmpty)
                        .map((s) => Chip(
                              key: ValueKey('weakness_$s'),
                              label: Text(s,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.amber.shade400, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ))
                        .toList(),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  // Missing Skills Section
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: Colors.orange.shade300, width: 2),
                    ),
                     child: Row(
                       children: [
                         Icon(Icons.build,
                             color: Colors.orange.shade700, size: 24),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Text('Missing Skills',
                               style: TextStyle(
                                 fontSize: 20,
                                 fontWeight: FontWeight.w800,
                                 color: Colors.orange.shade800,
                                 letterSpacing: 0.5,
                               )),
                         ),
                       ],
                     ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    runSpacing: 10,
                    spacing: 10,
                    children: safeAnalysis.missingSkills
                        .where((e) => e.trim().isNotEmpty)
                        .map((s) => Chip(
                              key: ValueKey('missing_$s'),
                              label: Text(s,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                  color: Colors.orange.shade400, width: 2),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ))
                        .toList(),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 32),

                  // Improvement Tips Section
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade300, width: 2),
                    ),
                     child: Row(
                       children: [
                         Icon(Icons.lightbulb,
                             color: Colors.blue.shade700, size: 24),
                         const SizedBox(width: 12),
                         Expanded(
                           child: Text('Actionable Recommendations',
                               style: TextStyle(
                                 fontSize: 20,
                                 fontWeight: FontWeight.w800,
                                 color: Colors.blue.shade800,
                                 letterSpacing: 0.5,
                               )),
                         ),
                       ],
                     ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 400, // Fixed height instead of Expanded
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
                          key: ValueKey('recommendation_$index'),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                             child: Container(
                             decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(16),
                               boxShadow: [
                                 BoxShadow(
                                   color: Colors.grey.shade200,
                                   blurRadius: 4,
                                   offset: const Offset(0, 2),
                                 ),
                               ],
                             ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(
                                        top: 6, right: 16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade600,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.6,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: (600 + index * 50).ms);
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
                      valueColor: AlwaysStoppedAnimation<Color>(
                          _scoreColor(safeAnalysis.atsScore)),
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
                      child: const Text('Start Mock Interview',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ).animate().fadeIn(delay: 1000.ms),

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
                      child: const Text('Save Report',
                          style: TextStyle(fontSize: 16)),
                    ),
                  ).animate().fadeIn(delay: 1100.ms),

                  const SizedBox(
                      height: 32), // Extra padding at bottom for scrolling
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
