import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../notes/providers/note_providers.dart';
import '../models/subject.dart';
import '../providers/home_providers.dart';
import '../widgets/adaptive_search_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/subject_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _search = TextEditingController();
  var _grid = true;
  var _sort = SubjectSort.custom;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final subjects = _filtered(ref.watch(subjectsProvider));
    final favorites = ref.watch(favoritesProvider);
    final recents = ref.watch(recentChaptersProvider);

    return CupertinoPageScaffold(
      backgroundColor: theme.background,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('NotesHub'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/search'),
              child: const Icon(CupertinoIcons.search),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/stats'),
              child: const Icon(CupertinoIcons.chart_bar_alt_fill),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/settings'),
              child: const Icon(CupertinoIcons.settings),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your knowledge, beautifully offline.',
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AdaptiveSearchField(
                          controller: _search,
                          placeholder: 'Search subjects',
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CupertinoSlidingSegmentedControl<SubjectSort>(
                              groupValue: _sort,
                              children: const {
                                SubjectSort.custom: Text('Custom'),
                                SubjectSort.az: Text('A-Z'),
                                SubjectSort.updated: Text('Updated'),
                              },
                              onValueChanged: (value) =>
                                  setState(() => _sort = value ?? _sort),
                            ),
                            const Spacer(),
                            CupertinoButton(
                              padding: const EdgeInsets.all(8),
                              onPressed: () => setState(() => _grid = !_grid),
                              child: Icon(
                                _grid
                                    ? CupertinoIcons.list_bullet
                                    : CupertinoIcons.square_grid_2x2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (recents.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 106,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: recents.length.clamp(0, 8),
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final chapter = recents[index];
                          return SizedBox(
                            width: 210,
                            child: GlassSurface(
                              padding: const EdgeInsets.all(14),
                              onTap: () =>
                                  context.push('/reader/${chapter.id}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(CupertinoIcons.time, size: 18),
                                  const Spacer(),
                                  Text(
                                    chapter.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    'Recent note',
                                    style: TextStyle(
                                      color: theme.secondaryText,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (favorites.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SectionHeader(
                      title: 'Favorites',
                      trailing: Text(
                        '${favorites.length}',
                        style: TextStyle(color: theme.secondaryText),
                      ),
                    ),
                  ),
                if (favorites.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 56,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        scrollDirection: Axis.horizontal,
                        itemCount: favorites.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(width: 10),
                        itemBuilder: (context, index) => CupertinoButton.filled(
                          borderRadius: BorderRadius.circular(18),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          onPressed: () =>
                              context.push('/reader/${favorites[index].id}'),
                          child: Text(
                            favorites[index].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(child: SectionHeader(title: 'Subjects')),
                if (subjects.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: CupertinoIcons.folder,
                      title: 'No subjects available',
                      message: 'Tap + to create your first subject.',
                    ),
                  )
                else if (_grid)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: .88,
                          ),
                      itemCount: subjects.length,
                      itemBuilder: (_, index) => SubjectCard(
                        subject: subjects[index],
                        onTap: () =>
                            context.push('/subject/${subjects[index].id}'),
                        onRename: () => _rename(subjects[index]),
                        onDelete: () => _delete(subjects[index]),
                      ),
                    ),
                  )
                else
                  SliverReorderableList(
                    itemCount: subjects.length,
                    itemBuilder: (_, index) => Padding(
                      key: ValueKey(subjects[index].id),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                      child: SubjectCard(
                        subject: subjects[index],
                        onTap: () =>
                            context.push('/subject/${subjects[index].id}'),
                        onRename: () => _rename(subjects[index]),
                        onDelete: () => _delete(subjects[index]),
                      ),
                    ),
                    onReorder: (oldIndex, newIndex) {
                      final reordered = [...ref.read(subjectsProvider)];
                      if (newIndex > oldIndex) newIndex--;
                      final item = reordered.removeAt(oldIndex);
                      reordered.insert(newIndex, item);
                      ref.read(subjectRepositoryProvider).reorder(reordered);
                    },
                  ),
              ],
            ),
            Positioned(
              right: 22,
              bottom: 24,
              child: CupertinoButton(
                borderRadius: BorderRadius.circular(24),
                color: theme.tint,
                padding: const EdgeInsets.all(18),
                onPressed: _createSubject,
                child: const Icon(
                  CupertinoIcons.add,
                  color: CupertinoColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Subject> _filtered(List<Subject> subjects) {
    final query = _search.text.trim().toLowerCase();
    final result = subjects
        .where((s) => s.title.toLowerCase().contains(query))
        .toList();
    switch (_sort) {
      case SubjectSort.az:
        result.sort((a, b) => a.title.compareTo(b.title));
      case SubjectSort.updated:
        result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case SubjectSort.custom:
        break;
    }
    return result;
  }

  Future<void> _createSubject() async {
    final title = await _textSheet('Create Subject', 'Subject name');
    if (title == null || title.trim().isEmpty) return;
    await ref.read(subjectRepositoryProvider).create(title);
  }

  Future<void> _rename(Subject subject) async {
    final title = await _textSheet(
      'Rename Subject',
      'Subject name',
      initial: subject.title,
    );
    if (title == null || title.trim().isEmpty) return;
    await ref.read(subjectRepositoryProvider).rename(subject.id, title);
  }

  Future<void> _delete(Subject subject) async {
    await ref.read(subjectRepositoryProvider).delete(subject.id);
  }

  Future<String?> _textSheet(
    String title,
    String placeholder, {
    String initial = '',
  }) {
    final controller = TextEditingController(text: initial);
    return showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(title),
        message: CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          autofocus: true,
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}
