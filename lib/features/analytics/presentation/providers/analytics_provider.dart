import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interview_iq_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:interview_iq_ai/core/providers/service_providers.dart';
import 'package:interview_iq_ai/features/interview/domain/models/interview_models.dart';

final sessionHistoryProvider = FutureProvider<List<InterviewSession>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  final userId = ref.read(authNotifierProvider).value?.id ?? '';
  return supabaseService.getHistory(userId);
});

final userStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  final userId = ref.read(authNotifierProvider).value?.id ?? '';
  return supabaseService.getUserStats(userId);
});
