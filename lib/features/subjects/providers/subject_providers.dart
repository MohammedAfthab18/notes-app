import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/providers/home_providers.dart';
import '../../notes/models/chapter.dart';

enum ChapterSort { updated, name }

final chaptersBySubjectProvider = Provider.family<List<Chapter>, String>((
  ref,
  subjectId,
) {
  return ref.watch(chapterRepositoryProvider).bySubject(subjectId);
});

final subjectByIdProvider = Provider.family((ref, String id) {
  return ref
      .watch(subjectsProvider)
      .where((subject) => subject.id == id)
      .firstOrNull;
});
