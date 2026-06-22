import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/text_metrics.dart';
import '../../home/providers/home_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final subjects = ref.watch(subjectsProvider);
    final chapters = ref.watch(chaptersProvider);
    final words = chapters.fold<int>(
      0,
      (sum, chapter) => sum + wordCount(chapter.content),
    );
    final hours = (words / 13200).toStringAsFixed(1);

    return CupertinoPageScaffold(
      backgroundColor: theme.background,
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Home',
        middle: Text('Statistics'),
      ),
      child: SafeArea(
        child: ResponsiveContent(
          maxWidth: 1120,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _MetricGrid(
                values: [
                  (
                    'Subjects',
                    subjects.length.toString(),
                    CupertinoIcons.folder_fill,
                    theme.tint,
                  ),
                  (
                    'Chapters',
                    chapters.length.toString(),
                    CupertinoIcons.doc_text_fill,
                    theme.purple,
                  ),
                  (
                    'Words',
                    words.toString(),
                    CupertinoIcons.textformat,
                    theme.mint,
                  ),
                  (
                    'Reading hours',
                    hours,
                    CupertinoIcons.clock_fill,
                    theme.amber,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Knowledge Balance',
                style: TextStyle(
                  color: theme.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              for (final subject in subjects)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SubjectBar(
                    name: subject.title,
                    count: chapters
                        .where((chapter) => chapter.subjectId == subject.id)
                        .length,
                    max: chapters.length.clamp(1, 9999),
                    color: theme.tint,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.values});

  final List<(String, String, IconData, Color)> values;

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width >= 900 ? 4 : 2;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: columns == 4 ? 1.15 : 1.25,
      ),
      itemCount: values.length,
      itemBuilder: (_, index) {
        final item = values[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: item.$4.withValues(alpha: .12),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(item.$3, color: item.$4),
              const Spacer(),
              Text(
                item.$2,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                item.$1,
                style: TextStyle(
                  color: CupertinoColors.secondaryLabel.resolveFrom(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SubjectBar extends StatelessWidget {
  const _SubjectBar({
    required this.name,
    required this.count,
    required this.max,
    required this.color,
  });

  final String name;
  final int count;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final factor = count / max;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text('$count'),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 12,
            child: Stack(
              children: [
                ColoredBox(
                  color: color.withValues(alpha: .12),
                  child: const SizedBox.expand(),
                ),
                FractionallySizedBox(
                  widthFactor: factor.clamp(0.0, 1.0),
                  child: ColoredBox(
                    color: color,
                    child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
