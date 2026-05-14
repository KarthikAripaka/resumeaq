import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../errors/exceptions.dart';

class PdfParserService {
  Future<String> extractText(File pdfFile) async {
    if (!await pdfFile.exists()) {
      throw PdfParseException('PDF file does not exist');
    }

    final bytes = await pdfFile.readAsBytes();
    if (bytes.isEmpty) {
      throw PdfParseException('PDF file is empty');
    }

    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();

    document.dispose();

    if (text.trim().isEmpty) {
      throw PdfParseException('No text found in PDF. Please ensure your resume is a text-based PDF (not scanned images). If it\'s a scanned document, consider converting it to editable text format.');
    }

    final cleanedText = _cleanText(text);
    return cleanedText.length > 8000 ? cleanedText.substring(0, 8000) : cleanedText;
  }

  static Future<String> extractTextFromBytes(List<int> pdfBytes) async {
    if (pdfBytes.isEmpty) {
      throw PdfParseException('PDF bytes are empty');
    }

    final document = PdfDocument(inputBytes: pdfBytes);
    final text = PdfTextExtractor(document).extractText();

    document.dispose();

    if (text.trim().isEmpty) {
      throw PdfParseException('No text found in PDF. Please ensure your resume is a text-based PDF (not scanned images). If it\'s a scanned document, consider converting it to editable text format.');
    }

    final cleanedText = _cleanText(text);
    return cleanedText.length > 8000 ? cleanedText.substring(0, 8000) : cleanedText;
  }

  static String _cleanText(String text) {
    // Remove excessive whitespace and normalize newlines
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .trim();
  }
}