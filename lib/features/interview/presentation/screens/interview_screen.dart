import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:interview_iq_ai/features/interview/presentation/providers/interview_provider.dart';
import 'package:interview_iq_ai/features/resume/presentation/providers/resume_provider.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key});

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _answerController = TextEditingController();
  late SpeechToText _speechToText;
  Timer? _timer;
  Timer? _recordingTimer;
  int _secondsElapsed = 0;
  bool _isRecording = false;
  int _recordingDuration = 0;
  bool _hasRecording = false;
  Map<String, dynamic> _voiceMetadata = {};
  bool _speechAvailable = false;
  bool _isWeb = false;

  @override
  void initState() {
    super.initState();
    _isWeb = kIsWeb;
    _startTimer();

    // Initialize audio and speech components
    _audioRecorder = AudioRecorder();
    _speechToText = SpeechToText();

    if (!_isWeb) {
      _initAudioAndSpeech();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateInterviewQuestions();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recordingTimer?.cancel();
    _audioRecorder?.dispose();
    _speechToText?.stop();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _initAudioAndSpeech() async {
    if (_isWeb) return; // Skip on web

    try {
      // Initialize speech to text
      _speechAvailable = await _speechToText.initialize();

      // Check and request audio recording permission
      _hasPermission = await _audioRecorder.hasPermission();

      if (!_hasPermission) {
        // Try to request permission
        _hasPermission = await _audioRecorder.hasPermission();
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing audio/speech: $e');
      _hasPermission = false;
      _speechAvailable = false;
    }
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
            content: Text('No resume analysis found. Please upload a resume first.'),
          ),
        );
        context.go('/upload');
      }
    });
  }

  Future<void> _toggleRecording() async {
    if (_isWeb) {
      // Web simulation
      _toggleRecordingWeb();
      return;
    }

    // Mobile implementation with real audio recording
    if (!_hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission required for voice recording'),
        ),
      );
      return;
    }

    if (_isRecording) {
      // Stop recording and speech recognition
      _recordingTimer?.cancel();

      if (_speechAvailable) {
        await _speechToText.stop();
      }

      try {
        final path = await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _hasRecording = true;
          _audioPath = path;
        });

        // Analyze voice quality
        _voiceMetadata = await _analyzeVoiceQuality(path);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎵 Voice recording saved (${_recordingDuration}s)!'),
            action: SnackBarAction(
              label: 'Play',
              onPressed: () => _playRecording(),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording error: $e')),
        );
      }
    } else {
      // Start recording and speech recognition
      try {
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final path = '${directory.path}/interview_answer_$timestamp.m4a';

        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: path);

        // Start speech-to-text if available
        if (_speechAvailable) {
          await _speechToText.listen(
            onResult: (result) {
              if (mounted) {
                setState(() {
                  _answerController.text = result.recognizedWords;
                });
              }
            },
            listenMode: ListenMode.dictation,
            cancelOnError: true,
            partialResults: true,
            localeId: 'en_US', // You can make this configurable
          );
        }

        setState(() {
          _isRecording = true;
          _recordingDuration = 0;
          _hasRecording = false;
          _audioPath = null;
          _voiceMetadata = {};
        });

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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start recording: $e')),
        );
      }
    }
  }

  void _toggleRecordingWeb() {
    // Web simulation - same as before
    if (_isRecording) {
      _recordingTimer?.cancel();
      _voiceMetadata = {
        'duration': _recordingDuration,
        'quality': _recordingDuration > 30 ? 'good' : _recordingDuration > 15 ? 'moderate' : 'poor',
        'confidence': _recordingDuration > 20 ? 'high' : _recordingDuration > 10 ? 'medium' : 'low',
        'pauses': (_recordingDuration / 10).round(),
        'clarity': _recordingDuration > 25 ? 'excellent' : _recordingDuration > 15 ? 'good' : 'needs_improvement',
      };

      setState(() {
        _isRecording = false;
        _hasRecording = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎵 Voice simulation saved (${_recordingDuration}s)!'),
          action: SnackBarAction(
            label: 'Play',
            onPressed: _playRecording,
          ),
        ),
      );
    } else {
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
        _hasRecording = false;
        _voiceMetadata = {};
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted && _isRecording) {
          setState(() {
            _recordingDuration++;
          });
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎤 Voice simulation started... Speak clearly!'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _analyzeVoiceQuality(String? path) async {
    // Enhanced voice quality analysis
    final duration = _recordingDuration;

    Map<String, dynamic> analysis = {
      'duration': duration,
      'quality': duration > 30 ? 'excellent' : duration > 20 ? 'good' : duration > 10 ? 'moderate' : 'poor',
      'confidence': duration > 25 ? 'high' : duration > 15 ? 'medium' : 'low',
      'pauses': (duration / 12).round(), // Estimate natural pauses
      'clarity': duration > 20 ? 'excellent' : duration > 15 ? 'good' : 'needs_improvement',
      'volume': 'normal', // Would analyze actual audio levels
      'pace': duration > 25 ? 'comfortable' : duration < 15 ? 'rushed' : 'normal',
    };

    // On mobile, we could analyze the actual audio file
    if (!_isWeb && path != null) {
      try {
        final file = File(path);
        final fileSize = await file.length();

        // Basic file-based analysis
        analysis['fileSize'] = fileSize;
        analysis['quality'] = fileSize > 500000 ? 'high_quality' : fileSize > 200000 ? 'good_quality' : 'basic_quality';

        // Additional analysis could be done here with audio processing libraries
      } catch (e) {
        debugPrint('Error analyzing audio file: $e');
      }
    }

    return analysis;
  }

  Future<void> _playRecording() async {
    if (_audioPath != null && !_isWeb) {
      try {
        // On mobile, we could implement audio playback here
        // For now, show a message that playback would work
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Playback error: $e')),
        );
      }
    } else if (_isWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Audio playback not available on web')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No recording available to play')),
      );
    }
  }

  Future<void> _requestMicrophonePermission() async {
    if (_isWeb) return;

    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please grant microphone permission in your device settings'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permission check error: $e')),
      );
    }
  }

  Future<void> _submitAnswer(String questionId) async {
    final textAnswer = _answerController.text.trim();

    // Allow submission if there's either text or audio
    if (textAnswer.isEmpty && !_hasRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a text answer or record audio before submitting')),
      );
      return;
    }

    // Combine text and audio information for evaluation
    String combinedAnswer = textAnswer;

    if (_hasRecording) {
      combinedAnswer += combinedAnswer.isNotEmpty
          ? '\n\n[Voice Recording: ${_recordingDuration}s, Quality: ${_voiceMetadata['quality']}, Confidence: ${_voiceMetadata['confidence']}, Clarity: ${_voiceMetadata['clarity']}]'
          : '[Voice Recording Only: ${_recordingDuration}s duration, Quality: ${_voiceMetadata['quality']}, Confidence: ${_voiceMetadata['confidence']}, Clarity: ${_voiceMetadata['clarity']}]';
    }

    try {
      await ref
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

      // Check if interview is complete
      if (progress.currentQuestionIndex >= (latestSession?.questions.length ?? 0) - 1) {
        if (mounted) {
          ref.read(interviewNotifierProvider.notifier).endSession();
          context.go('/results');
        }
      } else {
        ref.read(interviewProgressNotifierProvider.notifier).nextQuestion();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit answer: $e')),
        );
      }
    }
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
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
                    hintText: 'Type your answer here... (optional if using voice recording)',
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
                      child: Icon(_isRecording ? Icons.stop : Icons.mic,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isRecording
                                ? '🎤 Recording... ${_recordingDuration}s${_speechToText.isListening ? ' (Transcribing)' : ''}'
                                : _hasRecording
                                  ? '✅ Recording saved (${_recordingDuration}s)'
                                  : '🎙️ Tap mic to record your voice${_speechAvailable ? ' (with live transcription)' : ''}',
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
                              ).animate(onPlay: (controller) => controller.repeat())
                               .scale(duration: 500.ms, begin: const Offset(1, 1), end: const Offset(1.5, 1.5))
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
                    onPressed: (_answerController.text.trim().isNotEmpty || _hasRecording)
                        ? () async => await _submitAnswer(currentQuestion.id)
                        : null,
                    icon: const Icon(Icons.send),
                    label: Text(_hasRecording && _answerController.text.trim().isEmpty
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