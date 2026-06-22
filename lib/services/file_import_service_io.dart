import 'dart:io';

import 'package:docx_to_text/docx_to_text.dart';
import 'package:file_picker/file_picker.dart';

import '../core/constants/app_constants.dart';

class ImportedNote {
  const ImportedNote({required this.title, required this.content});
  final String title;
  final String content;
}

class FileImportService {
  Future<ImportedNote?> pickTextOrDocx() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppConstants.supportedImportExtensions,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.single;
    final ext = file.extension?.toLowerCase();
    final bytes = file.bytes ?? await File(file.path!).readAsBytes();
    final content = switch (ext) {
      'txt' => String.fromCharCodes(bytes),
      'docx' => docxToText(bytes),
      _ => '',
    };
    final title = file.name.replaceAll(
      RegExp(r'\.(txt|docx)$', caseSensitive: false),
      '',
    );
    return ImportedNote(title: title, content: content.trim());
  }
}
