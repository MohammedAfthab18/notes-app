import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../services/repositories.dart';
import '../../notes/models/chapter.dart';
import '../models/subject.dart';

enum SubjectSort { custom, az, updated }

final subjectRepositoryProvider = Provider<SubjectRepository>(
  (ref) => subjectRepository,
);
final chapterRepositoryProvider = Provider<ChapterRepository>(
  (ref) => chapterRepository,
);

final subjectBoxChangesProvider = StreamProvider<BoxEvent>((ref) {
  return Hive.box<Subject>(AppConstants.subjectBox).watch();
});

final chapterBoxChangesProvider = StreamProvider<BoxEvent>((ref) {
  return Hive.box<Chapter>(AppConstants.chapterBox).watch();
});

final subjectsProvider = Provider<List<Subject>>((ref) {
  ref.watch(subjectBoxChangesProvider);
  return ref.watch(subjectRepositoryProvider).all();
});

final chaptersProvider = Provider<List<Chapter>>((ref) {
  ref.watch(chapterBoxChangesProvider);
  return ref.watch(chapterRepositoryProvider).all();
});

final subjectChapterCountProvider = Provider.family<int, String>((
  ref,
  subjectId,
) {
  return ref
      .watch(chaptersProvider)
      .where((chapter) => chapter.subjectId == subjectId)
      .length;
});

final subjectLastUpdatedProvider = Provider.family<DateTime?, String>((
  ref,
  subjectId,
) {
  final chapters = ref
      .watch(chaptersProvider)
      .where((chapter) => chapter.subjectId == subjectId);
  if (chapters.isEmpty) return null;
  return chapters
      .map((e) => e.updatedAt)
      .reduce((a, b) => a.isAfter(b) ? a : b);
});
