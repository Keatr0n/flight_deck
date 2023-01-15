import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> getLocalFile(String filename) async {
    final path = await getLocalPath();
    return File('$path/$filename');
  }

  static Future<String> readLocalFile(String filename) async {
    try {
      final file = await getLocalFile(filename);
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return "ERROR: $e";
    }
  }

  static Future<File> writeLocalFile(String filename, String content) async {
    final file = await getLocalFile(filename);
    return file.writeAsString(content);
  }

  /// returns null if file deletion was successful
  /// returns error message if file deletion failed
  static Future<String?> deleteLocalFile(String filename) async {
    final file = await getLocalFile(filename);
    try {
      await file.delete();
    } catch (e) {
      return "ERROR: $e";
    }
    return null;
  }
}
