import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_metrics.dart';
import '../../home/providers/home_providers.dart';
import '../models/chapter.dart';
import '../providers/note_providers.dart';
import '../widgets/smart_formatter.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({required this.chapterId, super.key});

  final String chapterId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _scroll = ScrollController();
  final _search = TextEditingController();
  var _progress = 0.0;
  var _showSearch = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final chapter = ref.read(chapterByIdProvider(widget.chapterId));
      ref.read(chapterRepositoryProvider).markOpened(widget.chapterId);
      if (chapter != null && chapter.bookmarkOffset > 0) {
        _scroll.jumpTo(chapter.bookmarkOffset);
      }
    });
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    ref
        .read(chapterRepositoryProvider)
        .saveBookmark(
          widget.chapterId,
          _scroll.hasClients ? _scroll.offset : 0,
        );
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = ref.watch(appThemeProvider);
    final prefs = ref.watch(readerPreferencesProvider);
    final chapter = ref.watch(chapterByIdProvider(widget.chapterId));
    if (chapter == null) {
      return const CupertinoPageScaffold(
        child: Center(child: Text('Chapter not found')),
      );
    }
    final bg = readerBackground(prefs.theme, appTheme.isDark);
    final textColor =
        prefs.theme == ReaderThemeMode.amoled ||
            prefs.theme == ReaderThemeMode.dark
        ? CupertinoColors.white
        : const Color(0xFF191816);
    final fontSize = 17.0 * prefs.fontScale;
    final toc = extractToc(chapter.content);

    return CupertinoPageScaffold(
      backgroundColor: bg,
      navigationBar: prefs.fullscreen
          ? null
          : CupertinoNavigationBar(
              backgroundColor: bg.withValues(alpha: .85),
              previousPageTitle: 'Back',
              middle: Text(
                chapter.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => setState(() => _showSearch = !_showSearch),
                    child: const Icon(CupertinoIcons.search),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _readerSheet(chapter),
                    child: const Icon(CupertinoIcons.textformat_size),
                  ),
                ],
              ),
            ),
      child: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _progress.clamp(0, 1),
                  child: ColoredBox(
                    color: appTheme.tint,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                child: CupertinoSearchTextField(
                  controller: _search,
                  placeholder: 'Search inside note',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            Expanded(
              child: CustomScrollView(
                controller: _scroll,
                slivers: [
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 760.0 * prefs.width,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 56),
                          child: DefaultTextStyle(
                            style: _font(prefs.font, fontSize, textColor),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  chapter.title,
                                  style:
                                      _font(
                                        prefs.font,
                                        fontSize + 18.0,
                                        textColor,
                                      ).copyWith(
                                        fontWeight: FontWeight.w900,
                                        height: 1.12,
                                      ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${wordCount(chapter.content)} words - ${readingMinutes(chapter.content)} min read',
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: .58),
                                    fontSize: 13,
                                  ),
                                ),
                                if (toc.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  _TocCard(anchors: toc, textColor: textColor),
                                ],
                                const SizedBox(height: 22),
                                SmartFormatterView(
                                  content: _highlightQuery(chapter.content),
                                  fontSize: fontSize,
                                  textColor: textColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _font(ReaderFont font, double size, Color color) {
    final base = TextStyle(
      fontSize: size,
      color: color,
      height: 1.8,
      letterSpacing: 0,
    );
    return switch (font) {
      ReaderFont.sfPro => base.copyWith(fontFamily: '.SF Pro Text'),
      ReaderFont.inter => GoogleFonts.inter(textStyle: base),
      ReaderFont.roboto => GoogleFonts.roboto(textStyle: base),
      ReaderFont.jetBrainsMono => GoogleFonts.jetBrainsMono(textStyle: base),
    };
  }

  String _highlightQuery(String content) {
    final query = _search.text.trim();
    if (query.isEmpty) return content;
    return content.replaceAllMapped(
      RegExp(RegExp.escape(query), caseSensitive: false),
      (m) => '**${m.group(0)}**',
    );
  }

  void _onScroll() {
    if (!_scroll.hasClients || _scroll.position.maxScrollExtent <= 0) return;
    setState(
      () => _progress = _scroll.offset / _scroll.position.maxScrollExtent,
    );
  }

  void _readerSheet(Chapter chapter) {
    final prefs = ref.read(readerPreferencesProvider);
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Reader'),
        message: StatefulBuilder(
          builder: (context, setSheetState) {
            ReaderPreferences current() => ref.read(readerPreferencesProvider);
            void update(ReaderPreferences value) {
              ref.read(readerPreferencesProvider.notifier).update(value);
              setSheetState(() {});
            }

            return Column(
              children: [
                CupertinoSlidingSegmentedControl<ReaderThemeMode>(
                  groupValue: current().theme,
                  children: const {
                    ReaderThemeMode.white: Text('White'),
                    ReaderThemeMode.sepia: Text('Sepia'),
                    ReaderThemeMode.amoled: Text('AMOLED'),
                    ReaderThemeMode.dark: Text('Dark'),
                  },
                  onValueChanged: (value) => update(
                    current().copyWith(theme: value ?? current().theme),
                  ),
                ),
                const SizedBox(height: 16),
                CupertinoSlider(
                  value: current().fontScale,
                  min: .85,
                  max: 1.45,
                  divisions: 4,
                  onChanged: (v) => update(current().copyWith(fontScale: v)),
                ),
                CupertinoSlider(
                  value: current().width,
                  min: .55,
                  max: 1,
                  onChanged: (v) => update(current().copyWith(width: v)),
                ),
              ],
            );
          },
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(chapterRepositoryProvider)
                  .update(chapter.copyWith(favorite: !chapter.favorite));
              Navigator.pop(context);
            },
            child: Text(chapter.favorite ? 'Remove Favorite' : 'Favorite'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(chapterRepositoryProvider)
                  .update(chapter.copyWith(pinned: !chapter.pinned));
              Navigator.pop(context);
            },
            child: Text(chapter.pinned ? 'Unpin' : 'Pin'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/editor/${chapter.subjectId}/${chapter.id}');
            },
            child: const Text('Edit'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              ref
                  .read(readerPreferencesProvider.notifier)
                  .update(prefs.copyWith(fullscreen: !prefs.fullscreen));
              Navigator.pop(context);
            },
            child: Text(prefs.fullscreen ? 'Exit Fullscreen' : 'Fullscreen'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ),
    );
  }
}

class _TocCard extends StatelessWidget {
  const _TocCard({required this.anchors, required this.textColor});

  final List<HeadingAnchor> anchors;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: textColor.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contents',
            style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final anchor in anchors.take(12))
            Padding(
              padding: EdgeInsets.only(left: (anchor.level - 1) * 14.0, top: 6),
              child: Text(
                anchor.title,
                style: TextStyle(
                  color: textColor.withValues(alpha: .72),
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
