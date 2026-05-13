import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/interview_provider.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(interviewNotifierProvider).value;
    final progress = ref.watch(interviewProgressNotifierProvider);

    if (session == null) return const CircularProgressIndicator();

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
          ],
        ),
      ).animate().fadeIn().slideY(),
    );
  }

  void _submitAnswer(String questionId) {
    ref.read(interviewNotifierProvider.notifier).submitAnswer(questionId, _answerController.text);
    ref.read(interviewProgressNotifierProvider.notifier).nextQuestion();
    _answerController.clear();
  }
}