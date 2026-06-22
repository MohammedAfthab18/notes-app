import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../models/subject.dart';
import '../providers/home_providers.dart';

class SubjectCard extends ConsumerWidget {
  const SubjectCard({
    required this.subject,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    this.listTile = false,
    super.key,
  });

  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final bool listTile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final count = ref.watch(subjectChapterCountProvider(subject.id));
    final updated =
        ref.watch(subjectLastUpdatedProvider(subject.id)) ?? subject.updatedAt;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _showSubjectActions(context),
      child: Hero(
        tag: 'subject-${subject.id}',
        child: GlassSurface(
          padding: EdgeInsets.all(listTile ? 12 : 14),
          radius: listTile ? 18 : 20,
          onTap: onTap,
          child: listTile
              ? _SubjectListContent(
                  subject: subject,
                  count: count,
                  updated: updated,
                )
              : _SubjectGridContent(
                  subject: subject,
                  count: count,
                  updated: updated,
                ),
        ),
      ),
    );
  }

  void _showSubjectActions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(subject.title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onRename();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.pencil, size: 20),
                SizedBox(width: 8),
                Text('Rename'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.delete, size: 20),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
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

class _SubjectListContent extends ConsumerWidget {
  const _SubjectListContent({
    required this.subject,
    required this.count,
    required this.updated,
  });

  final Subject subject;
  final int count;
  final DateTime updated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '$count chapters - Updated ${humanDate(updated)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Icon(CupertinoIcons.chevron_forward, color: theme.secondaryText, size: 16),
      ],
    );
  }
}

class _SubjectGridContent extends ConsumerWidget {
  const _SubjectGridContent({
    required this.subject,
    required this.count,
    required this.updated,
  });

  final Subject subject;
  final int count;
  final DateTime updated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$count chapters',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.secondaryText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              color: theme.secondaryText,
              size: 15,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          subject.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.text,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1.12,
          ),
        ),
        const Spacer(),
        Text(
          'Updated ${humanDate(updated)}',
          style: TextStyle(color: theme.secondaryText, fontSize: 11),
        ),
      ],
    );
  }
}
