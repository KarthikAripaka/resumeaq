import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../services/gemini_service.dart';
import '../../services/supabase_service.dart';
import '../../services/pdf_parser_service.dart';

part 'service_providers.g.dart';

@riverpod
GeminiService geminiService(Ref ref) {
  return GeminiService();
}

@riverpod
SupabaseService supabaseService(Ref ref) {
  return SupabaseService();
}

@riverpod
PdfParserService pdfParserService(Ref ref) {
  return PdfParserService();
}