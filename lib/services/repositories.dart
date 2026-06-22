import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../features/home/models/subject.dart';
import '../features/notes/models/chapter.dart';

class SubjectRepository {
  SubjectRepository(this._box, this._chapters);

  final Box<Subject> _box;
  final Box<Chapter> _chapters;
  final _uuid = const Uuid();

  List<Subject> all() =>
      _box.values.toList()..sort((a, b) => a.position.compareTo(b.position));

  Future<Subject> create(String title) async {
    final now = DateTime.now();
    final subject = Subject(
      id: _uuid.v4(),
      title: title.trim(),
      createdAt: now,
      updatedAt: now,
      position: _box.length,
      iconIndex: _box.length,
    );
    await _box.put(subject.id, subject);
    return subject;
  }

  Future<void> rename(String id, String title) async {
    final subject = _box.get(id);
    if (subject == null) return;
    await _box.put(
      id,
      subject.copyWith(title: title.trim(), updatedAt: DateTime.now()),
    );
  }

  Future<void> delete(String id) async {
    final related = _chapters.values
        .where((chapter) => chapter.subjectId == id)
        .map((e) => e.id)
        .toList();
    await _chapters.deleteAll(related);
    await _box.delete(id);
    await reorder(all());
  }

  Future<void> reorder(List<Subject> subjects) async {
    for (final entry in subjects.indexed) {
      await _box.put(
        entry.$2.id,
        entry.$2.copyWith(position: entry.$1, updatedAt: DateTime.now()),
      );
    }
  }
}

class ChapterRepository {
  ChapterRepository(this._box);

  final Box<Chapter> _box;
  final _uuid = const Uuid();

  List<Chapter> all() => _box.values.toList();

  List<Chapter> bySubject(String subjectId) {
    final chapters = _box.values
        .where((chapter) => chapter.subjectId == subjectId)
        .toList();
    chapters.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return chapters;
  }

  Chapter? get(String id) => _box.get(id);

  Future<Chapter> create({
    required String subjectId,
    required String title,
    required String content,
  }) async {
    final now = DateTime.now();
    final chapter = Chapter(
      id: _uuid.v4(),
      subjectId: subjectId,
      title: title.trim().isEmpty ? 'Untitled Note' : title.trim(),
      content: content,
      createdAt: now,
      updatedAt: now,
    );
    await _box.put(chapter.id, chapter);
    return chapter;
  }

  Future<void> update(Chapter chapter) async {
    await _box.put(chapter.id, chapter.copyWith(updatedAt: DateTime.now()));
  }

  Future<void> delete(String id) => _box.delete(id);

  Future<void> markOpened(String id) async {
    final chapter = get(id);
    if (chapter == null) return;
    await _box.put(id, chapter.copyWith(lastOpenedAt: DateTime.now()));
  }

  Future<void> saveBookmark(String id, double offset) async {
    final chapter = get(id);
    if (chapter == null) return;
    await _box.put(id, chapter.copyWith(bookmarkOffset: offset));
  }

  Future<String> exportJson() async {
    final data = _box.values.map((chapter) {
      return {
        'id': chapter.id,
        'subjectId': chapter.subjectId,
        'title': chapter.title,
        'content': chapter.content,
        'favorite': chapter.favorite,
        'pinned': chapter.pinned,
        'createdAt': chapter.createdAt.toIso8601String(),
        'updatedAt': chapter.updatedAt.toIso8601String(),
      };
    }).toList();
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<String> exportTxt() async {
    return _box.values
        .map((e) => '# ${e.title}\n\n${e.content}')
        .join('\n\n---\n\n');
  }
}

final subjectRepository = SubjectRepository(
  Hive.box<Subject>(AppConstants.subjectBox),
  Hive.box<Chapter>(AppConstants.chapterBox),
);

final chapterRepository = ChapterRepository(
  Hive.box<Chapter>(AppConstants.chapterBox),
);
