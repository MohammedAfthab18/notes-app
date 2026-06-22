import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
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
  var _grid = false;
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
    final recentCount = recents.length > 4 ? 4 : recents.length;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = responsiveClassForWidth(screenWidth) == ResponsiveClass.desktop;
    final gridColumns = isDesktop ? 3 : 2;
    final gridAspect = isDesktop ? 1.02 : 1.08;

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
        child: ResponsiveContent(
          maxWidth: 1280,
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
                    child: SectionHeader(
                      title: 'Recent Notes',
                      trailing: Text(
                        '$recentCount',
                        style: TextStyle(color: theme.secondaryText),
                      ),
                    ),
                  ),
                if (recents.isNotEmpty)
                  SliverList.separated(
                    itemCount: recentCount,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final chapter = recents[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          index == 0 ? 0 : 0,
                          20,
                          index == recentCount - 1 ? 10 : 0,
                        ),
                        child: GlassSurface(
                          padding: const EdgeInsets.all(12),
                          radius: 18,
                          onTap: () => context.push('/reader/${chapter.id}'),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: theme.mint.withValues(alpha: .14),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  CupertinoIcons.clock,
                                  color: theme.mint,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      chapter.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: theme.text,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Recently opened',
                                      style: TextStyle(
                                        color: theme.secondaryText,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                CupertinoIcons.chevron_forward,
                                color: theme.secondaryText,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
                          SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: gridColumns,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: gridAspect,
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
                        listTile: true,
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
    ref.invalidate(subjectsProvider);
  }

  Future<void> _rename(Subject subject) async {
    final title = await _textSheet(
      'Rename Subject',
      'Subject name',
      initial: subject.title,
    );
    if (title == null || title.trim().isEmpty) return;
    await ref.read(subjectRepositoryProvider).rename(subject.id, title);
    ref.invalidate(subjectsProvider);
  }

  Future<void> _delete(Subject subject) async {
    await ref.read(subjectRepositoryProvider).delete(subject.id);
    ref.invalidate(subjectsProvider);
    ref.invalidate(chaptersProvider);
  }

  Future<String?> _textSheet(
    String title,
    String placeholder, {
    String initial = '',
  }) async {
    final controller = TextEditingController(text: initial);
    final theme = ref.read(appThemeProvider);
    final result = await showCupertinoModalPopup<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final insets = MediaQuery.viewInsetsOf(context);
        return AnimatedPadding(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(bottom: insets.bottom),
          child: SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CupertinoPopupSurface(
                isSurfacePainted: false,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
                  decoration: BoxDecoration(
                    color: theme.elevated.withValues(alpha: .94),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: theme.hairline),
                    boxShadow: [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(alpha: .18),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      CupertinoTextField(
                        controller: controller,
                        placeholder: placeholder,
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: theme.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.hairline),
                        ),
                        onSubmitted: (_) =>
                            Navigator.pop(context, controller.text),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: CupertinoButton(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: CupertinoButton.filled(
                              borderRadius: BorderRadius.circular(16),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              onPressed: () =>
                                  Navigator.pop(context, controller.text),
                              child: const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    controller.dispose();
    return result;
  }
}
