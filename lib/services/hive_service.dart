import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants/app_constants.dart';
import '../features/home/models/subject.dart';
import '../features/notes/models/chapter.dart';

abstract final class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SubjectAdapter());
    if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(ChapterAdapter());
    await Hive.openBox<Subject>(AppConstants.subjectBox);
    await Hive.openBox<Chapter>(AppConstants.chapterBox);
    await Hive.openBox<dynamic>(AppConstants.settingsBox);
  }
}
