import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/file_import_service.dart';
import '../../home/providers/home_providers.dart';
import '../../home/widgets/adaptive_search_field.dart';
import '../../home/widgets/empty_state.dart';
import '../../notes/models/chapter.dart';
import '../providers/subject_providers.dart';
import '../widgets/chapter_card.dart';

class SubjectScreen extends ConsumerStatefulWidget {
  const SubjectScreen({required this.subjectId, super.key});

  final String subjectId;

  @override
  ConsumerState<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends ConsumerState<SubjectScreen> {
  final _search = TextEditingController();
  var _sort = ChapterSort.updated;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final subject = ref.watch(subjectByIdProvider(widget.subjectId));
    final chapters = _filtered(
      ref.watch(chaptersBySubjectProvider(widget.subjectId)),
    );

    return CupertinoPageScaffold(
      backgroundColor: theme.background,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Subjects',
        middle: Text(subject?.title ?? 'Subject'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _createSheet,
          child: const Icon(CupertinoIcons.add_circled),
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Column(
                  children: [
                    AdaptiveSearchField(
                      controller: _search,
                      placeholder: 'Search chapters',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    CupertinoSlidingSegmentedControl<ChapterSort>(
                      groupValue: _sort,
                      children: const {
                        ChapterSort.updated: Text('Date'),
                        ChapterSort.name: Text('Name'),
                      },
                      onValueChanged: (value) =>
                          setState(() => _sort = value ?? _sort),
                    ),
                  ],
                ),
              ),
            ),
            if (chapters.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  icon: CupertinoIcons.doc_text,
                  title: 'No chapters yet',
                  message: 'Paste notes or import a .txt/.docx file.',
                ),
              )
            else
              SliverList.separated(
                itemCount: chapters.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 14),
                itemBuilder: (_, index) {
                  final chapter = chapters[index];
                  return Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      index == 0 ? 4 : 0,
                      20,
                      index == chapters.length - 1 ? 96 : 0,
                    ),
                    child: ChapterCard(
                      chapter: chapter,
                      onTap: () => context.push('/reader/${chapter.id}'),
                      onEdit: () => context.push(
                        '/editor/${widget.subjectId}/${chapter.id}',
                      ),
                      onDelete: () => _deleteChapter(chapter),
                      onToggleFavorite: () => _updateChapter(
                        chapter.copyWith(favorite: !chapter.favorite),
                      ),
                      onTogglePin: () => _updateChapter(
                        chapter.copyWith(pinned: !chapter.pinned),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  List<Chapter> _filtered(List<Chapter> chapters) {
    final query = _search.text.trim().toLowerCase();
    final result = chapters
        .where(
          (chapter) =>
              chapter.title.toLowerCase().contains(query) ||
              chapter.content.toLowerCase().contains(query),
        )
        .toList();
    if (_sort == ChapterSort.name) {
      result.sort((a, b) => a.title.compareTo(b.title));
    } else {
      result.sort((a, b) {
        if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
        return b.updatedAt.compareTo(a.updatedAt);
      });
    }
    return result;
  }

  Future<void> _createSheet() async {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Create Chapter'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              context.push('/editor/${widget.subjectId}');
            },
            child: const Text('Paste text manually'),
          ),
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await _importFile();
            },
            child: const Text('Import .txt or .docx'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _importFile() async {
    final imported = await FileImportService().pickTextOrDocx();
    if (imported == null || imported.content.isEmpty) return;
    final chapter = await ref
        .read(chapterRepositoryProvider)
        .create(
          subjectId: widget.subjectId,
          title: imported.title,
          content: imported.content,
        );
    ref.invalidate(chaptersProvider);
    if (mounted) context.push('/editor/${widget.subjectId}/${chapter.id}');
  }

  Future<void> _updateChapter(Chapter chapter) async {
    await ref.read(chapterRepositoryProvider).update(chapter);
    ref.invalidate(chaptersProvider);
  }

  Future<void> _deleteChapter(Chapter chapter) async {
    await ref.read(chapterRepositoryProvider).delete(chapter.id);
    ref.invalidate(chaptersProvider);
  }
}
