import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/providers/home_providers.dart';
import '../models/chapter.dart';

enum ReaderFont { sfPro, inter, roboto, jetBrainsMono }

enum ReaderThemeMode { white, sepia, amoled, dark }

class ReaderPreferences {
  const ReaderPreferences({
    this.fontScale = 1,
    this.font = ReaderFont.inter,
    this.theme = ReaderThemeMode.white,
    this.width = .82,
    this.fullscreen = false,
  });

  final double fontScale;
  final ReaderFont font;
  final ReaderThemeMode theme;
  final double width;
  final bool fullscreen;

  ReaderPreferences copyWith({
    double? fontScale,
    ReaderFont? font,
    ReaderThemeMode? theme,
    double? width,
    bool? fullscreen,
  }) {
    return ReaderPreferences(
      fontScale: fontScale ?? this.fontScale,
      font: font ?? this.font,
      theme: theme ?? this.theme,
      width: width ?? this.width,
      fullscreen: fullscreen ?? this.fullscreen,
    );
  }
}

class ReaderPreferencesController extends Notifier<ReaderPreferences> {
  @override
  ReaderPreferences build() => const ReaderPreferences();

  void update(ReaderPreferences preferences) {
    state = preferences;
  }
}

final readerPreferencesProvider =
    NotifierProvider<ReaderPreferencesController, ReaderPreferences>(
      ReaderPreferencesController.new,
    );

final chapterByIdProvider = Provider.family<Chapter?, String>((ref, id) {
  return ref
      .watch(chaptersProvider)
      .where((chapter) => chapter.id == id)
      .firstOrNull;
});

final favoritesProvider = Provider<List<Chapter>>((ref) {
  final chapters = ref
      .watch(chaptersProvider)
      .where((chapter) => chapter.favorite)
      .toList();
  chapters.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  return chapters;
});

final recentChaptersProvider = Provider<List<Chapter>>((ref) {
  final chapters = ref
      .watch(chaptersProvider)
      .where((chapter) => chapter.lastOpenedAt != null)
      .toList();
  chapters.sort((a, b) => b.lastOpenedAt!.compareTo(a.lastOpenedAt!));
  return chapters.take(20).toList();
});

Color readerBackground(ReaderThemeMode mode, bool dark) {
  return switch (mode) {
    ReaderThemeMode.white => const Color(0xFFFFFEFA),
    ReaderThemeMode.sepia => const Color(0xFFF4ECD8),
    ReaderThemeMode.amoled => CupertinoColors.black,
    ReaderThemeMode.dark => const Color(0xFF111115),
  };
}
