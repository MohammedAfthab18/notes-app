import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/text_metrics.dart';
import '../../home/providers/home_providers.dart';
import '../../home/widgets/adaptive_search_field.dart';
import '../../home/widgets/empty_state.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final q = _query.text.trim().toLowerCase();
    final subjects = ref
        .watch(subjectsProvider)
        .where((s) => s.title.toLowerCase().contains(q))
        .toList();
    final chapters = ref
        .watch(chaptersProvider)
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.content.toLowerCase().contains(q),
        )
        .toList();

    return CupertinoPageScaffold(
      backgroundColor: theme.background,
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Back',
        middle: Text('Search'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
              child: AdaptiveSearchField(
                controller: _query,
                placeholder: 'Search everything',
                onChanged: (_) => setState(() {}),
              ),
            ),
            Expanded(
              child: q.isEmpty
                  ? const EmptyState(
                      icon: CupertinoIcons.search,
                      title: 'Instant global search',
                      message: 'Find subjects, chapters, and note content.',
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 40),
                      children: [
                        if (subjects.isNotEmpty) _label('Subjects', theme),
                        for (final subject in subjects)
                          _SearchTile(
                            title: subject.title,
                            subtitle: 'Subject',
                            icon: CupertinoIcons.folder_fill,
                            onTap: () => context.push('/subject/${subject.id}'),
                          ),
                        if (chapters.isNotEmpty) _label('Chapters', theme),
                        for (final chapter in chapters)
                          _SearchTile(
                            title: chapter.title,
                            subtitle: previewText(
                              stripMarkdown(chapter.content),
                              max: 96,
                            ),
                            icon: CupertinoIcons.doc_text_fill,
                            onTap: () => context.push('/reader/${chapter.id}'),
                          ),
                        if (subjects.isEmpty && chapters.isEmpty)
                          const EmptyState(
                            icon: CupertinoIcons.xmark_circle,
                            title: 'No results',
                            message: 'Try a different keyword.',
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String value, AppTheme theme) => Padding(
    padding: const EdgeInsets.only(top: 14, bottom: 8),
    child: Text(
      value,
      style: TextStyle(color: theme.secondaryText, fontWeight: FontWeight.w800),
    ),
  );
}

class _SearchTile extends StatelessWidget {
  const _SearchTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.secondarySystemGroupedBackground,
            context,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: CupertinoColors.secondaryLabel.resolveFrom(
                        context,
                      ),
                      fontSize: 13,
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
}
