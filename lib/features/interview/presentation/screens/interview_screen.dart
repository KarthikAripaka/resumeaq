import 'dart:async';
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
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // TODO: Implement actual audio recording
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isRecording ? 'Recording started...' : 'Recording stopped'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final interviewState = ref.watch(interviewNotifierProvider);
    final progress = ref.watch(interviewProgressNotifierProvider);

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
              Text('This may take 15-30 seconds',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
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

        final currentQuestion =
            session.questions[progress.currentQuestionIndex];

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text('${progress.currentQuestionIndex + 1} of ${session.questions.length}'),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatTime(_secondsElapsed),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(6),
              child: LinearProgressIndicator(
                value: progress.completionPercentage / 100,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(currentQuestion.category).withOpacity(0.1),
                      border: Border.all(
                        color: _getCategoryColor(currentQuestion.category),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      currentQuestion.category.toUpperCase(),
                      style: TextStyle(
                        color: _getCategoryColor(currentQuestion.category),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Question Text
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Answer Input Section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: TextField(
                            controller: _answerController,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Type your answer here...',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ),

                        // Voice Recording Section
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: _isRecording ? Colors.red.shade50 : Colors.grey.shade50,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            children: [
                              FloatingActionButton(
                                onPressed: _toggleRecording,
                                backgroundColor: _isRecording ? Colors.red : Colors.blue,
                                child: Icon(
                                  _isRecording ? Icons.stop : Icons.mic,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isRecording ? 'Recording...' : 'Voice Answer',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: _isRecording ? Colors.red : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isRecording
                                          ? 'Tap stop when finished'
                                          : 'Tap mic to record your answer',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isRecording)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat())
                                 .scale(duration: 500.ms, begin: const Offset(1, 1), end: const Offset(1.5, 1.5))
                                 .fadeIn(duration: 500.ms),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Navigation Controls
                  Row(
                    children: [
                      if (progress.currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref.read(interviewProgressNotifierProvider.notifier).reset();
                              setState(() {
                                _secondsElapsed = 0;
                              });
                            },
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      if (progress.currentQuestionIndex > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: progress.currentQuestionIndex == 0 ? 1 : 2,
                        child: ElevatedButton.icon(
                          onPressed: _answerController.text.trim().isNotEmpty
                              ? () => _submitAnswer(currentQuestion.id)
                              : null,
                          icon: Icon(progress.currentQuestionIndex == session.questions.length - 1
                              ? Icons.check_circle
                              : Icons.arrow_forward),
                          label: Text(progress.currentQuestionIndex == session.questions.length - 1
                              ? 'Complete Interview'
                              : 'Submit Answer'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: progress.currentQuestionIndex == session.questions.length - 1
                                ? Colors.green.shade600
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(),
        );
      },
    );
  }

  void _submitAnswer(String questionId) async {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) return;

    await ref
        .read(interviewNotifierProvider.notifier)
        .submitAnswer(questionId, answer);

    final interviewState = ref.read(interviewNotifierProvider);
    final progress = ref.read(interviewProgressNotifierProvider);

    if (progress.currentQuestionIndex >= (interviewState.value?.questions.length ?? 0) - 1) {
      // Interview completed
      await ref.read(interviewNotifierProvider.notifier).endSession();
      if (mounted) {
        context.go('/results');
      }
    } else {
      // Next question
      ref.read(interviewProgressNotifierProvider.notifier).nextQuestion();
      _answerController.clear();
      setState(() {
        _secondsElapsed = 0;
        _isRecording = false;
      });
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'hr':
        return Colors.blue.shade600;
      case 'technical':
        return Colors.green.shade600;
      case 'dsa':
        return Colors.purple.shade600;
      case 'project':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
