import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interview_iq_ai/features/interview/presentation/providers/interview_provider.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final interviewState = ref.watch(interviewNotifierProvider);

    return interviewState.when(
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Generating interview questions...'),
              SizedBox(height: 8),
              Text('This may take 15-30 seconds', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Interview Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to generate questions: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/analysis'),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
      data: (session) {
        if (session == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('No Session')),
            body: const Center(
              child: Text('No interview session available'),
            ),
          );
        }

        final progress = ref.watch(interviewProgressNotifierProvider);
        final currentQuestion = session.questions[progress.currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: LinearProgressIndicator(value: progress.completionPercentage / 100),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('${progress.currentQuestionIndex + 1} / ${session.questions.length}'),
                Chip(label: Text(currentQuestion.category)),
                Text(currentQuestion.question, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                TextField(
                  controller: _answerController,
                  maxLines: 5,
                  decoration: const InputDecoration(hintText: 'Your answer...'),
                ),
                FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.mic),
                ),
                ElevatedButton(
                  onPressed: () => _submitAnswer(currentQuestion.id),
                  child: const Text('Submit Answer'),
                ),
                if (session.feedbacks.containsKey(currentQuestion.id)) ...[
                  const SizedBox(height: 20),
                  Text('Score: ${session.feedbacks[currentQuestion.id]!.score}/10'),
                  Text(session.feedbacks[currentQuestion.id]!.correctness),
                  Text(session.feedbacks[currentQuestion.id]!.communication),
                ],
              ],
            ),
          ).animate().fadeIn().slideY(),
        );
      },
    );
  }

  void _submitAnswer(String questionId) {
    ref
        .read(interviewNotifierProvider.notifier)
        .submitAnswer(questionId, _answerController.text);
    ref.read(interviewProgressNotifierProvider.notifier).nextQuestion();
    _answerController.clear();
  }
}
