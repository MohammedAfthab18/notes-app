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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _showChapterActions(context),
      child: GlassSurface(
        padding: const EdgeInsets.all(14),
        radius: 18,
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
                      fontSize: 17,
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
            const SizedBox(height: 8),
            Text(
              previewText(stripMarkdown(chapter.content), max: 104),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.secondaryText,
                height: 1.3,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
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

  void _showChapterActions(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(chapter.title),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.pencil, size: 20),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onToggleFavorite();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  chapter.favorite
                      ? CupertinoIcons.star_fill
                      : CupertinoIcons.star,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(chapter.favorite ? 'Unfavorite' : 'Favorite'),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              onTogglePin();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  chapter.pinned
                      ? CupertinoIcons.pin_slash
                      : CupertinoIcons.pin,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(chapter.pinned ? 'Unpin' : 'Pin'),
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
