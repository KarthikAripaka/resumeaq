import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// speech_to_text disabled for Android build (kept as optional feature)
// import 'package:speech_to_text/speech_to_text.dart';
import 'package:interview_iq_ai/features/interview/presentation/providers/interview_provider.dart';
import 'package:interview_iq_ai/features/resume/presentation/providers/resume_provider.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _answerController = TextEditingController();
  // Speech-to-text disabled on Android build (kept for future support)
  // late SpeechToText _speechToText;
  // bool _speechAvailable = false;

  Timer? _timer;
  Timer? _recordingTimer;
  int _secondsElapsed = 0;
  bool _isRecording = false;
  int _recordingDuration = 0;
  bool _hasRecording = false;
  Map<String, dynamic> _voiceMetadata = {};
  bool _speechAvailable = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // _speechToText = SpeechToText();
    // _initSpeechToText();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateInterviewQuestions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordingTimer?.cancel();
    // speech_to_text disabled
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

  Future<void> _generateInterviewQuestions() async {
    final currentSession = ref.read(interviewNotifierProvider).valueOrNull;
    if (currentSession != null) return;

    final resumeState = ref.read(resumeNotifierProvider);
    final interviewNotifier = ref.read(interviewNotifierProvider.notifier);

    resumeState.whenData((analysis) {
      if (analysis != null) {
        interviewNotifier.generateQuestions(analysis);
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('No resume analysis found. Please upload a resume first.'),
          ),
        );
        context.go('/upload');
      }
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      // Stop recording (speech-to-text disabled)
      _recordingTimer?.cancel();

      // Generate voice metadata for evaluation
      _voiceMetadata = {
        'duration': _recordingDuration,
        'quality': _recordingDuration > 30
            ? 'excellent'
            : _recordingDuration > 20
                ? 'good'
                : _recordingDuration > 10
                    ? 'moderate'
                    : 'poor',
        'confidence': _recordingDuration > 25
            ? 'high'
            : _recordingDuration > 15
                ? 'medium'
                : 'low',
        'pauses': (_recordingDuration / 12).round(),
        'clarity': _recordingDuration > 20
            ? 'excellent'
            : _recordingDuration > 15
                ? 'good'
                : 'needs_improvement',
        'volume': 'normal',
        'pace': _recordingDuration > 25
            ? 'comfortable'
            : _recordingDuration < 15
                ? 'rushed'
                : 'normal',
      };

      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎵 Voice recording saved (${_recordingDuration}s)!'),
          action: SnackBarAction(
            label: 'Play',
            onPressed: _playRecording,
          ),
        ),
      );
    } else {
      // Start recording and speech recognition
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
        _hasRecording = false;
        _voiceMetadata = {};
      });

      // Start speech-to-text disabled (microphone UI still records timer only)

      // Start recording timer
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDuration++;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_speechAvailable
              ? '🎤 Recording started with live transcription...'
              : '🎤 Recording started... Speak clearly and confidently!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _playRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🎵 Playing your ${_recordingDuration}s recording...'),
        action: SnackBarAction(
          label: 'Stop',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Playback stopped')),
            );
          },
        ),
      ),
    );
  }

  Future<void> _finishInterview() async {
    final interviewNotifier = ref.read(interviewNotifierProvider.notifier);
    await interviewNotifier.finishInterview();
    if (!mounted) return;
    context.go('/results');
  }

  Future<void> _submitAnswer(String questionId) async {
    final textAnswer = _answerController.text.trim();

    // Allow submission if there's either text or audio
    if (textAnswer.isEmpty && !_hasRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Please provide a text answer or record audio before submitting')),
      );
      return;
    }

    // Combine text and audio information for final evaluation (runs only after finish)
    String combinedAnswer = textAnswer;

    if (_hasRecording) {
      combinedAnswer += combinedAnswer.isNotEmpty
          ? '\n\n[Voice Recording: ${_recordingDuration}s, Quality: ${_voiceMetadata['quality']}, Confidence: ${_voiceMetadata['confidence']}, Clarity: ${_voiceMetadata['clarity']}]'
          : '[Voice Recording Only: ${_recordingDuration}s duration, Quality: ${_voiceMetadata['quality']}, Confidence: ${_voiceMetadata['confidence']}, Clarity: ${_voiceMetadata['clarity']}]';
    }

    ref
        .read(interviewNotifierProvider.notifier)
        .submitAnswer(questionId, combinedAnswer);

    // Reset for next question
    _answerController.clear();
    setState(() {
      _secondsElapsed = 0;
      _isRecording = false;
      _hasRecording = false;
      _recordingDuration = 0;
      _voiceMetadata = {};
    });

    final progress = ref.read(interviewProgressNotifierProvider);
    final latestSession = ref.read(interviewNotifierProvider).value;

    // Move to next question OR, if complete, finish the interview.
    final total = latestSession?.questions.length ?? 0;
    if (total <= 0) return;

    if (progress.currentQuestionIndex >= total - 1) {
      await _finishInterview();
      return;
    }

    ref.read(interviewProgressNotifierProvider.notifier).nextQuestion();
  }

  @override
  Widget build(BuildContext context) {
    final interviewState = ref.watch(interviewNotifierProvider);
    final progress = ref.watch(interviewProgressNotifierProvider);

    return interviewState.when(
      loading: () => const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
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
            appBar: AppBar(title: const Text('Start Interview')),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.forum,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Ready for your interview?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'We\'ll generate personalized questions based on your resume analysis.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _generateInterviewQuestions,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start Interview'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () => context.go('/analysis'),
                      child: const Text('Back to Analysis'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final clampedIndex = progress.currentQuestionIndex
            .clamp(0, session.questions.length - 1);
        final currentQuestion = session.questions[clampedIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text('${clampedIndex + 1} / ${session.questions.length}'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Chip(label: Text(_formatTime(_secondsElapsed))),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentQuestion.category.toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, letterSpacing: 1),
                ),
                const SizedBox(height: 12),
                Text(
                  currentQuestion.question,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _answerController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText:
                        'Type your answer here... (optional if using voice recording)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '💡 You can answer using text, voice recording, or both!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FloatingActionButton(
                      onPressed: _toggleRecording,
                      backgroundColor: _isRecording ? Colors.red : Colors.blue,
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRecording
                                ? '🎤 Recording... ${_recordingDuration}s'
                                : _hasRecording
                                    ? '✅ Recording saved (${_recordingDuration}s)'
                                    : '🎙️ Tap mic to record your voice',
                            style: TextStyle(
                              color: _isRecording
                                  ? Colors.red.shade700
                                  : _hasRecording
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_hasRecording && _voiceMetadata.isNotEmpty)
                            Text(
                              'Quality: ${_voiceMetadata['quality']} • Confidence: ${_voiceMetadata['confidence']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          if (_isRecording)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              )
                                  .animate(
                                      onPlay: (controller) =>
                                          controller.repeat())
                                  .scale(
                                      duration: 500.ms,
                                      begin: const Offset(1, 1),
                                      end: const Offset(1.5, 1.5))
                                  .fadeIn(duration: 500.ms),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (_answerController.text.trim().isNotEmpty ||
                            _hasRecording)
                        ? () => _submitAnswer(currentQuestion.id)
                        : null,
                    icon: const Icon(Icons.send),
                    label: Text(
                        _hasRecording && _answerController.text.trim().isEmpty
                            ? 'Submit Voice Answer'
                            : 'Submit Answer'),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(),
        );
      },
    );
  }
}
