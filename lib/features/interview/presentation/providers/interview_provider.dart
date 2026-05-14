import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/local_interview_storage.dart';
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
      answersByQuestionId: const {},
      finalReport: null,
    );
  }

  Future<void> submitAnswer(String questionId, String? answer) async {
    final currentSession = state.value;
    if (currentSession == null) return;

    // Store raw answers in-memory only for now.
    // Final evaluation will happen once user finishes the interview.
    final safeAnswer = answer ?? '';

    final updatedAnswers =
        Map<String, String>.from(currentSession.answersByQuestionId);
    updatedAnswers[questionId] = safeAnswer;

    state = AsyncValue.data(
      InterviewSession(
        id: currentSession.id,
        resumeId: currentSession.resumeId,
        jobRole: currentSession.jobRole,
        questions: currentSession.questions,
        feedbacks: currentSession.feedbacks,
        startedAt: currentSession.startedAt,
        answersByQuestionId: updatedAnswers,
        finalReport: currentSession.finalReport,
      ),
    );
  }

  Future<InterviewFinalReport> finishInterview() async {
    final currentSession = state.value;
    if (currentSession == null) {
      throw Exception('No active interview session');
    }

    final groqService = ref.read(groqServiceProvider);

    // Evaluate once with all Qs + answers.
    final report = await groqService.evaluateInterviewFinal(
      jobRole: currentSession.jobRole,
      questions: currentSession.questions,
      answersByQuestionId: currentSession.answersByQuestionId,
    );

    final updated = InterviewSession(
      id: currentSession.id,
      resumeId: currentSession.resumeId,
      jobRole: currentSession.jobRole,
      questions: currentSession.questions,
      feedbacks: currentSession.feedbacks,
      startedAt: currentSession.startedAt,
      answersByQuestionId: currentSession.answersByQuestionId,
      finalReport: report,
    );

    state = AsyncValue.data(updated);

    try {
      await LocalInterviewStorage.saveSession(updated);
    } catch (e) {
      debugPrint('Local save failed: $e');
    }

    return report;
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
