import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
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
    super.key,
  });

  final Subject subject;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final count = ref.watch(subjectChapterCountProvider(subject.id));
    final updated =
        ref.watch(subjectLastUpdatedProvider(subject.id)) ?? subject.updatedAt;
    final icon = AppConstants
        .subjectIcons[subject.iconIndex % AppConstants.subjectIcons.length];

    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            onRename();
          },
          trailingIcon: CupertinoIcons.pencil,
          child: const Text('Rename'),
        ),
        CupertinoContextMenuAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          trailingIcon: CupertinoIcons.delete,
          child: const Text('Delete'),
        ),
      ],
      child: Hero(
        tag: 'subject-${subject.id}',
        child: GlassSurface(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.tint.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: theme.tint, size: 24),
                  ),
                  const Spacer(),
                  Icon(
                    CupertinoIcons.chevron_forward,
                    color: theme.secondaryText,
                    size: 18,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                subject.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$count chapters',
                style: TextStyle(
                  color: theme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Updated ${humanDate(updated)}',
                style: TextStyle(color: theme.secondaryText, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
