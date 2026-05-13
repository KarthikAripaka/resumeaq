import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_iq_ai/features/resume/presentation/providers/resume_provider.dart';

class AnalysisScreen extends ConsumerWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeState = ref.watch(resumeNotifierProvider);

    return resumeState.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Analyzing your resume...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Analysis Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Analysis failed: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/upload'),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
      data: (analysis) {
        if (analysis == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('No Analysis')),
            body: const Center(
              child: Text('No analysis data available'),
            ),
          );
        }

        return Scaffold(
            appBar: AppBar(title: const Text('Resume Analysis')),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Hero(
                    tag: 'ats_score',
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                          child: Text('${analysis.atsScore}',
                              style: const TextStyle(fontSize: 24))),
                    ),
                  ),
                  const Text('Strengths'),
                  Wrap(
                    children: analysis.strengths
                        .map((s) => Chip(label: Text(s)))
                        .toList(),
                  ),
                  const Text('Missing Skills'),
                  Wrap(
                    children: analysis.missingSkills
                        .map((s) =>
                            Chip(label: Text(s), backgroundColor: Colors.red))
                        .toList(),
                  ),
                  const Text('Improvement Tips'),
                  Column(
                    children: analysis.improvementTips
                        .map((tip) => Card(child: Text(tip)))
                        .toList(),
                  ),
                  LinearProgressIndicator(value: analysis.atsScore / 100 * 0.9),
                  ElevatedButton(
                    onPressed: () => context.go('/interview'),
                    child: const Text('Start Mock Interview'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Save Report'),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY());
      },
    );
  }
}
