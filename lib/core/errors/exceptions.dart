class GeminiParseException implements Exception {
  final String message;
  GeminiParseException(this.message);
}

class PdfParseException implements Exception {
  final String message;
  PdfParseException(this.message);
}