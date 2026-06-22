import 'package:intl/intl.dart';

String humanDate(DateTime date) {
  final now = DateTime.now();
  final delta = now.difference(date);
  if (delta.inMinutes < 1) return 'Just now';
  if (delta.inHours < 1) return '${delta.inMinutes} min ago';
  if (delta.inDays < 1) return '${delta.inHours} hr ago';
  if (delta.inDays < 7) return '${delta.inDays} days ago';
  return DateFormat('MMM d, yyyy').format(date);
}

String fullDate(DateTime date) =>
    DateFormat('MMM d, yyyy - h:mm a').format(date);
