import 'package:flutter/cupertino.dart';

abstract final class AppConstants {
  static const appName = 'NotesHub';
  static const subjectBox = 'subjects';
  static const chapterBox = 'chapters';
  static const settingsBox = 'settings';
  static const bookmarksBox = 'bookmarks';
  static const searchDebounce = Duration(milliseconds: 220);
  static const animationDuration = Duration(milliseconds: 260);
  static const borderRadius = 24.0;
  static const supportedImportExtensions = ['txt', 'docx'];

  static const subjectIcons = [
    CupertinoIcons.globe,
    CupertinoIcons.table,
    CupertinoIcons.chevron_left_slash_chevron_right,
    CupertinoIcons.desktopcomputer,
    CupertinoIcons.device_phone_portrait,
    CupertinoIcons.cloud,
  ];
}
