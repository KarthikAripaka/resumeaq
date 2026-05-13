import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../services/pdf_parser_service.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) => GeminiService());

final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());

final pdfParserServiceProvider = Provider<PdfParserService>((ref) => PdfParserService());