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
      throw PdfParseException('No text extracted from PDF');
    }

    final cleanedText = _cleanText(text);
    return cleanedText.length > 8000 ? cleanedText.substring(0, 8000) : cleanedText;
  }

  String _cleanText(String text) {
    // Remove excessive whitespace and normalize newlines
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .trim();
  }
}