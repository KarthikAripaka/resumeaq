import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static Future<String?> saveResumeLocally(List<int> bytes, String fileName) async {
    try {
      if (kIsWeb) {
        // On web, we can't save files locally, so just return null
        return null;
      }

      final directory = await getApplicationDocumentsDirectory();
      final resumesDir = Directory('${directory.path}/resumes');

      // Create resumes directory if it doesn't exist
      if (!await resumesDir.exists()) {
        await resumesDir.create(recursive: true);
      }

      final filePath = '${resumesDir.path}/${DateTime.now().millisecondsSinceEpoch}_${fileName}';
      final file = File(filePath);

      await file.writeAsBytes(bytes);
      debugPrint('Resume saved locally: $filePath');

      return filePath;
    } catch (e) {
      debugPrint('Failed to save resume locally: $e');
      return null;
    }
  }

  static Future<List<String>> getSavedResumes() async {
    try {
      if (kIsWeb) return [];

      final directory = await getApplicationDocumentsDirectory();
      final resumesDir = Directory('${directory.path}/resumes');

      if (!await resumesDir.exists()) return [];

      final files = await resumesDir.list().toList();
      return files
          .where((file) => file is File && file.path.endsWith('.pdf'))
          .map((file) => file.path)
          .toList();
    } catch (e) {
      debugPrint('Failed to get saved resumes: $e');
      return [];
    }
  }
}