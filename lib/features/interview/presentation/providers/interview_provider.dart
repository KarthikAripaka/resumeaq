import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/providers/service_providers.dart';
import '../../domain/models/interview_models.dart';
import '../../domain/models/resume_analysis.dart';

part 'interview_provider.g.dart';

@riverpod
class InterviewNotifier extends _$InterviewNotifier {
  @override
  FutureOr<InterviewSession?> build() {
    return null;
  }

  Future<void> generateQuestions(ResumeAnalysis analysis) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final geminiService = ref.read(geminiServiceProvider);
      final questions = await geminiService.generateInterviewQuestions(
        analysis.summary,
        analysis.jobRole,
      );

      final session = InterviewSession(
        id: const Uuid().v4(),
        resumeId: analysis.jobRole, // Assuming resumeId is from analysis, but adjust if needed
        jobRole: analysis.jobRole,
        questions: questions,
        feedbacks: {},
        startedAt: DateTime.now(),
      );

      return session;
    });
  }

  Future<void> submitAnswer(String questionId, String answer) async {
    state = await AsyncValue.guard(() async {
      final currentSession = state.value;
      if (currentSession == null) return null;

      final question = currentSession.questions.firstWhere(
        (q) => q.id == questionId,
      );

      final geminiService = ref.read(geminiServiceProvider);
      final feedback = await geminiService.evaluateAnswer(
        question.question,
        answer,
        currentSession.jobRole,
      );

      final updatedFeedbacks = Map<String, AnswerFeedback>.from(currentSession.feedbacks);
      updatedFeedbacks[questionId] = feedback;

      final updatedSession = InterviewSession(
        id: currentSession.id,
        resumeId: currentSession.resumeId,
        jobRole: currentSession.jobRole,
        questions: currentSession.questions,
        feedbacks: updatedFeedbacks,
        startedAt: currentSession.startedAt,
      );

      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.saveQuestionResponse(
        currentSession.id,
        question,
        feedback,
      );

      return updatedSession;
    });
  }

  Future<void> endSession() async {
    final currentSession = state.value;
    if (currentSession == null) return;

    final supabaseService = ref.read(supabaseServiceProvider);
    await supabaseService.saveInterviewSession(currentSession);

    // Compute overall score if needed, but for now just save
    state = const AsyncValue.data(null);
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

@riverpod
class InterviewProgressNotifier extends _$InterviewProgressNotifier {
  @override
  InterviewProgress build() {
    return InterviewProgress(
      currentQuestionIndex: 0,
      categoryScores: {},
      overallAverage: 0.0,
      completionPercentage: 0.0,
    );
  }

  void nextQuestion() {
    final current = state;
    final newIndex = current.currentQuestionIndex + 1;
    final session = ref.read(interviewNotifierProvider).value;
    final totalQuestions = session?.questions.length ?? 0;
    final completion = totalQuestions > 0 ? (newIndex / totalQuestions) * 100 : 0.0;

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
      categoryScores: {},
      overallAverage: 0.0,
      completionPercentage: 0.0,
    );
  }
}