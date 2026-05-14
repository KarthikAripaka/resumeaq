import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/local_interview_storage.dart';
import '../../../interview/domain/models/interview_models.dart';

final sessionHistoryProvider =
    FutureProvider<List<InterviewSession>>((ref) async {
  return LocalInterviewStorage.getAllSessions();
});

final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final sessions = await LocalInterviewStorage.getAllSessions();
  if (sessions.isEmpty) {
    return {
      'avgAtsScore': 0.0,
      'totalSessions': 0,
      'bestScore': 0,
    };
  }

  // Offline stats are based on final interview report overall score if present.
  double total = 0;
  double best = 0;
  int count = 0;

  for (final s in sessions) {
    final score = s.finalReport?.overallInterviewScore;
    if (score != null) {
      total += score;
      best = score > best ? score : best;
      count++;
    }
  }

  final avg = count == 0 ? 0.0 : total / count;

  return {
    'avgAtsScore': avg,
    'totalSessions': sessions.length,
    'bestScore': best.round(),
  };
});
