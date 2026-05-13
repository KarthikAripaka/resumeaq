import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/groq_service.dart';
import '../services/supabase_service.dart';
import '../services/pdf_parser_service.dart';

final groqServiceProvider = Provider<GroqService>((ref) => GroqService());

final supabaseServiceProvider = Provider<SupabaseService>((ref) => SupabaseService());

final pdfParserServiceProvider = Provider<PdfParserService>((ref) => PdfParserService());