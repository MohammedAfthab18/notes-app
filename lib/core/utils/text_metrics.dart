int wordCount(String value) {
  final matches = RegExp(r"\b[\w']+\b").allMatches(value);
  return matches.length;
}

int readingMinutes(String value) {
  final minutes = (wordCount(value) / 220).ceil();
  return minutes.clamp(1, 9999);
}

String previewText(String value, {int max = 140}) {
  final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (compact.length <= max) return compact;
  return '${compact.substring(0, max).trim()}...';
}

String stripMarkdown(String value) {
  return value
      .replaceAll(RegExp(r'```[\s\S]*?```'), ' code block ')
      .replaceAll(RegExp(r'[#>*_`~-]'), ' ')
      .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
