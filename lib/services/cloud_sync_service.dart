import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/app_constants.dart';
import '../features/home/models/subject.dart';
import '../features/notes/models/chapter.dart';

class CloudSyncService {
  bool get _enabled => !kIsWeb;

  Future<void> bootstrapUser([User? user]) async {
    if (!_enabled) return;
    final current = user ?? FirebaseAuth.instance.currentUser;
    if (current == null) return;
    await _ensureUserDoc(current);
    await syncFromCloud();
  }

  Future<void> syncFromCloud() async {
    if (!_enabled) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;
    final subjectBox = Hive.box<Subject>(AppConstants.subjectBox);
    final chapterBox = Hive.box<Chapter>(AppConstants.chapterBox);
    final userRef = firestore.collection('users').doc(user.uid);

    final remoteSubjects = await userRef.collection('subjects').get();
    final remoteChapters = await userRef.collection('chapters').get();

    final remoteSubjectMap = {
      for (final doc in remoteSubjects.docs) doc.id: doc.data(),
    };
    final remoteChapterMap = {
      for (final doc in remoteChapters.docs) doc.id: doc.data(),
    };

    for (final local in subjectBox.values) {
      final remote = remoteSubjectMap[local.id];
      if (remote == null ||
          local.updatedAt.isAfter(_readDate(remote['updatedAt']))) {
        await userRef
            .collection('subjects')
            .doc(local.id)
            .set(_subjectMap(local));
      }
    }
    for (final entry in remoteSubjectMap.entries) {
      final remote = _subjectFromMap(entry.key, entry.value);
      final local = subjectBox.get(remote.id);
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await subjectBox.put(remote.id, remote);
      }
    }

    for (final local in chapterBox.values) {
      final remote = remoteChapterMap[local.id];
      if (remote == null ||
          local.updatedAt.isAfter(_readDate(remote['updatedAt']))) {
        await userRef
            .collection('chapters')
            .doc(local.id)
            .set(_chapterMap(local));
      }
    }
    for (final entry in remoteChapterMap.entries) {
      final remote = _chapterFromMap(entry.key, entry.value);
      final local = chapterBox.get(remote.id);
      if (local == null || remote.updatedAt.isAfter(local.updatedAt)) {
        await chapterBox.put(remote.id, remote);
      }
    }
  }

  Future<void> upsertSubject(Subject subject) async {
    if (!_enabled) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _userRef(user.uid)
        .collection('subjects')
        .doc(subject.id)
        .set(_subjectMap(subject), SetOptions(merge: true));
  }

  Future<void> deleteSubject(String subjectId) async {
    if (!_enabled) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userRef = _userRef(user.uid);
    final batch = FirebaseFirestore.instance.batch();
    final chapters = await userRef
        .collection('chapters')
        .where('subjectId', isEqualTo: subjectId)
        .get();
    for (final doc in chapters.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(userRef.collection('subjects').doc(subjectId));
    await batch.commit();
  }

  Future<void> upsertChapter(Chapter chapter) async {
    if (!_enabled) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _userRef(user.uid)
        .collection('chapters')
        .doc(chapter.id)
        .set(_chapterMap(chapter), SetOptions(merge: true));
  }

  Future<void> deleteChapter(String chapterId) async {
    if (!_enabled) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _userRef(user.uid).collection('chapters').doc(chapterId).delete();
  }

  Future<void> reorderSubjects(List<Subject> subjects) async {
    if (!_enabled) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final batch = FirebaseFirestore.instance.batch();
    final ref = _userRef(user.uid).collection('subjects');
    for (final subject in subjects) {
      batch.set(
        ref.doc(subject.id),
        _subjectMap(subject),
        SetOptions(merge: true),
      );
    }
    await batch.commit();
  }

  Future<void> _ensureUserDoc(User user) async {
    await _userRef(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }
}

Map<String, dynamic> _subjectMap(Subject subject) {
  return {
    'id': subject.id,
    'title': subject.title,
    'createdAt': Timestamp.fromDate(subject.createdAt),
    'updatedAt': Timestamp.fromDate(subject.updatedAt),
    'position': subject.position,
    'iconIndex': subject.iconIndex,
  };
}

Map<String, dynamic> _chapterMap(Chapter chapter) {
  return {
    'id': chapter.id,
    'subjectId': chapter.subjectId,
    'title': chapter.title,
    'content': chapter.content,
    'favorite': chapter.favorite,
    'pinned': chapter.pinned,
    'createdAt': Timestamp.fromDate(chapter.createdAt),
    'updatedAt': Timestamp.fromDate(chapter.updatedAt),
    'lastOpenedAt': chapter.lastOpenedAt == null
        ? null
        : Timestamp.fromDate(chapter.lastOpenedAt!),
    'bookmarkOffset': chapter.bookmarkOffset,
  };
}

Subject _subjectFromMap(String id, Map<String, dynamic> data) {
  return Subject(
    id: data['id'] as String? ?? id,
    title: data['title'] as String? ?? 'Untitled Subject',
    createdAt: _readDate(data['createdAt']),
    updatedAt: _readDate(data['updatedAt']),
    position: (data['position'] as num?)?.toInt() ?? 0,
    iconIndex: (data['iconIndex'] as num?)?.toInt() ?? 0,
  );
}

Chapter _chapterFromMap(String id, Map<String, dynamic> data) {
  return Chapter(
    id: data['id'] as String? ?? id,
    subjectId: data['subjectId'] as String? ?? '',
    title: data['title'] as String? ?? 'Untitled Note',
    content: data['content'] as String? ?? '',
    favorite: data['favorite'] as bool? ?? false,
    pinned: data['pinned'] as bool? ?? false,
    createdAt: _readDate(data['createdAt']),
    updatedAt: _readDate(data['updatedAt']),
    lastOpenedAt: _readDateNullable(data['lastOpenedAt']),
    bookmarkOffset: (data['bookmarkOffset'] as num?)?.toDouble() ?? 0,
  );
}

DateTime _readDate(dynamic value) {
  return _readDateNullable(value) ?? DateTime.now();
}

DateTime? _readDateNullable(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

final cloudSyncService = CloudSyncService();
