import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/service_providers.dart';
import '../../domain/models/interview_models.dart';
import '../../../resume/domain/models/resume_analysis.dart';

part 'interview_provider.g.dart';

@riverpod
class InterviewNotifier extends _$InterviewNotifier {
  String? _jobRole;

  @override
  FutureOr<InterviewSession?> build() => null;

  String _getUserFriendlyErrorMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('rate limit')) {
      return 'AI service is busy. Please wait a moment and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('api key') ||
        errorString.contains('unauthorized')) {
      return 'Service configuration error. Please contact support.';
    } else {
      return 'Question generation temporarily unavailable. Using default questions.';
    }
  }

  Future<void> generateQuestions(ResumeAnalysis analysis) async {
    _jobRole = analysis.jobRole;
    state = const AsyncValue.loading();

    try {
      final session = await Future.any([
        _generateSession(analysis),
        Future.delayed(const Duration(seconds: 45), () {
          throw Exception('Question generation timed out. Please try again.');
        }),
      ]);

      state = AsyncValue.data(session);
    } catch (error, stackTrace) {
      final userFriendlyError = _getUserFriendlyErrorMessage(error);
      state = AsyncValue.error(userFriendlyError, stackTrace);
    }
  }

  Future<InterviewSession> _generateSession(ResumeAnalysis analysis) async {
    final groqService = ref.read(groqServiceProvider);
    final questions = await groqService.generateInterviewQuestions(
      analysis.summary,
      analysis.jobRole,
    );

    return InterviewSession(
      id: const Uuid().v4(),
      resumeId: 'local_${DateTime.now().millisecondsSinceEpoch}',
      jobRole: analysis.jobRole,
      questions: questions,
      feedbacks: {},
      startedAt: DateTime.now(),
    );
  }

  Future<void> submitAnswer(String questionId, String? answer) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Use empty string as fallback if answer is null
    final safeAnswer = answer ?? '';

    state = await AsyncValue.guard(() async {
      final groqService = ref.read(groqServiceProvider);

      final question = currentSession.questions.firstWhere(
        (q) => q.id == questionId,
      );

      final feedback = await groqService.evaluateAnswer(
        question.question,
        safeAnswer,
        _jobRole ?? 'Unknown',
      );

      final updatedFeedbacks =
          Map<String, AnswerFeedback>.from(currentSession.feedbacks);
      updatedFeedbacks[questionId] = feedback;

      final updatedSession = InterviewSession(
        id: currentSession.id,
        resumeId: currentSession.resumeId,
        jobRole: currentSession.jobRole,
        questions: currentSession.questions,
        feedbacks: updatedFeedbacks,
        startedAt: currentSession.startedAt,
      );

      // Best-effort persistence
      try {
        final supabaseService = ref.read(supabaseServiceProvider);
        await supabaseService.saveQuestionResponse(
          currentSession.id,
          question,
          feedback,
        );
      } catch (_) {
        // ignore persistence errors
      }

      return updatedSession;
    });
  }

  Future<void> endSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.saveInterviewSession(currentSession);

      // Session is saved, analytics will load it via the provider
    } catch (e) {
      debugPrint('Error ending session: $e');
      // ignore persistence errors but still update local state
    }

    state = const AsyncValue.data(null);
  }
}

@riverpod
class InterviewProgressNotifier extends _$InterviewProgressNotifier {
  @override
  InterviewProgress build() {
    return InterviewProgress(
      currentQuestionIndex: 0,
      categoryScores: const {},
      overallAverage: 0.0,
      completionPercentage: 0.0,
    );
  }

  void nextQuestion() {
    final current = state;
    final newIndex = current.currentQuestionIndex + 1;

    final session = ref.read(interviewNotifierProvider).value;
    final totalQuestions = session?.questions.length ?? 0;
    final completion =
        totalQuestions > 0 ? (newIndex / totalQuestions) * 100.0 : 0.0;

    state = InterviewProgress(
      currentQuestionIndex: newIndex,
      categoryScores: current.categoryScores,
      overallAverage: current.overallAverage,
      completionPercentage: completion,
    );
  }

  void reset() {
    state = InterviewProgress(
      currentQuestionIndex: 0,
      categoryScores: const {},
      overallAverage: 0.0,
      completionPercentage: 0.0,
    );
  }
}

class InterviewProgress {
  final int currentQuestionIndex;
  final Map<String, double> categoryScores;
  final double overallAverage;
  final double completionPercentage;

  InterviewProgress({
    required this.currentQuestionIndex,
    required this.categoryScores,
    required this.overallAverage,
    required this.completionPercentage,
  });
}
