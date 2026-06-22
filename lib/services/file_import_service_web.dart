import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
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
    final bytes = file.bytes;
    if (bytes == null) return null;

    final content = switch (ext) {
      'txt' => String.fromCharCodes(bytes),
      'docx' => _extractDocx(bytes),
      _ => '',
    };
    final title = file.name.replaceAll(
      RegExp(r'\.(txt|docx)$', caseSensitive: false),
      '',
    );
    return ImportedNote(title: title, content: content.trim());
  }

  String _extractDocx(Uint8List bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    ArchiveFile? document;
    for (final file in archive.files) {
      if (file.name == 'word/document.xml') {
        document = file;
        break;
      }
    }
    if (document == null) return '';
    final raw = utf8.decode(
      document.content is List<int>
          ? document.content as List<int>
          : List<int>.from(document.content as List<dynamic>),
    );
    return raw
        .replaceAll(RegExp(r'</w:p>|</p>'), '\n')
        .replaceAll(RegExp(r'<w:tab/>'), '\t')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }
}
