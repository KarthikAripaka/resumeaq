import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/service_providers.dart';
import '../../../features/interview/domain/models/interview_models.dart';

part 'analytics_provider.g.dart';

@riverpod
Future<List<InterviewSession>> sessionHistory(Ref ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  final userId = ref.read(authNotifierProvider).value?.id ?? '';
  return supabaseService.getHistory(userId);
}

@riverpod
Future<Map<String, dynamic>> userStats(Ref ref) async {
  final supabaseService = ref.read(supabaseServiceProvider);
  final userId = ref.read(authNotifierProvider).value?.id ?? '';
  return supabaseService.getUserStats(userId);
}