import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../core/utils/text_metrics.dart';
import '../../notes/models/chapter.dart';

class ChapterCard extends ConsumerWidget {
  const ChapterCard({
    required this.chapter,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onTogglePin,
    super.key,
  });

  final Chapter chapter;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTogglePin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            onEdit();
          },
          trailingIcon: CupertinoIcons.pencil,
          child: const Text('Edit'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            onToggleFavorite();
          },
          trailingIcon: chapter.favorite
              ? CupertinoIcons.star_fill
              : CupertinoIcons.star,
          child: Text(chapter.favorite ? 'Unfavorite' : 'Favorite'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            onTogglePin();
          },
          trailingIcon: chapter.pinned
              ? CupertinoIcons.pin_slash
              : CupertinoIcons.pin,
          child: Text(chapter.pinned ? 'Unpin' : 'Pin'),
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
      child: GlassSurface(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    chapter.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (chapter.pinned)
                  Icon(CupertinoIcons.pin_fill, color: theme.amber, size: 17),
                if (chapter.favorite)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      CupertinoIcons.star_fill,
                      color: theme.amber,
                      size: 17,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              previewText(stripMarkdown(chapter.content), max: 128),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.secondaryText, height: 1.35),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  CupertinoIcons.clock,
                  color: theme.secondaryText,
                  size: 15,
                ),
                const SizedBox(width: 5),
                Text(
                  '${readingMinutes(chapter.content)} min read',
                  style: TextStyle(color: theme.secondaryText, fontSize: 12),
                ),
                const Spacer(),
                Text(
                  humanDate(chapter.updatedAt),
                  style: TextStyle(color: theme.secondaryText, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
