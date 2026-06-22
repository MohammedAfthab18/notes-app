import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../features/home/models/subject.dart';
import '../features/notes/models/chapter.dart';
import 'repositories.dart';

class BackupService {
  Future<File> exportJson(
    List<Subject> subjects,
    List<Chapter> chapters,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/noteshub-backup-${DateTime.now().millisecondsSinceEpoch}.json',
    );
    final payload = {
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
    return file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
  }

  Future<File> exportTxt(List<Chapter> chapters) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/noteshub-notes-${DateTime.now().millisecondsSinceEpoch}.txt',
    );
    return file.writeAsString(
      chapters.map((c) => '# ${c.title}\n\n${c.content}').join('\n\n---\n\n'),
    );
  }

  Future<void> restoreJson() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null) return;
    final raw = utf8.decode(
      result.files.single.bytes ??
          await File(result.files.single.path!).readAsBytes(),
    );
    final data = jsonDecode(raw) as Map<String, dynamic>;
    for (final item in (data['subjects'] as List<dynamic>? ?? const [])) {
      final title =
          (item as Map<String, dynamic>)['title'] as String? ??
          'Imported Subject';
      await subjectRepository.create(title);
    }
  }
}
