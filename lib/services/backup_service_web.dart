// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';

import '../features/home/models/subject.dart';
import '../features/notes/models/chapter.dart';
import 'repositories.dart';

class BackupService {
  Future<String> exportJson(
    List<Subject> subjects,
    List<Chapter> chapters,
  ) async {
    final filename =
        'noteshub-backup-${DateTime.now().millisecondsSinceEpoch}.json';
    _download(
      filename,
      const JsonEncoder.withIndent('  ').convert(_payload(subjects, chapters)),
      'application/json',
    );
    return filename;
  }

  Future<String> exportTxt(List<Chapter> chapters) async {
    final filename =
        'noteshub-notes-${DateTime.now().millisecondsSinceEpoch}.txt';
    _download(
      filename,
      chapters.map((c) => '# ${c.title}\n\n${c.content}').join('\n\n---\n\n'),
      'text/plain',
    );
    return filename;
  }

  Future<void> restoreJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;
    final raw = utf8.decode(result.files.single.bytes!);
    await _restorePayload(jsonDecode(raw) as Map<String, dynamic>);
  }
}

void _download(String filename, String content, String mimeType) {
  final bytes = utf8.encode(content);
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

Map<String, dynamic> _payload(List<Subject> subjects, List<Chapter> chapters) {
  return {
    'version': 1,
    'exportedAt': DateTime.now().toIso8601String(),
    'subjects': subjects
        .map(
          (s) => {
            'id': s.id,
            'title': s.title,
            'createdAt': s.createdAt.toIso8601String(),
            'updatedAt': s.updatedAt.toIso8601String(),
            'position': s.position,
            'iconIndex': s.iconIndex,
          },
        )
        .toList(),
    'chapters': chapters
        .map(
          (c) => {
            'id': c.id,
            'subjectId': c.subjectId,
            'title': c.title,
            'content': c.content,
            'favorite': c.favorite,
            'pinned': c.pinned,
            'createdAt': c.createdAt.toIso8601String(),
            'updatedAt': c.updatedAt.toIso8601String(),
          },
        )
        .toList(),
  };
}

Future<void> _restorePayload(Map<String, dynamic> data) async {
  for (final item in (data['subjects'] as List<dynamic>? ?? const [])) {
    final title =
        (item as Map<String, dynamic>)['title'] as String? ??
        'Imported Subject';
    await subjectRepository.create(title);
  }
}
