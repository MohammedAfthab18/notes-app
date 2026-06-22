import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HeadingAnchor {
  const HeadingAnchor({required this.title, required this.level});
  final String title;
  final int level;
}

List<HeadingAnchor> extractToc(String content) {
  final anchors = <HeadingAnchor>[];
  for (final line in content.split('\n')) {
    final markdown = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(line.trim());
    if (markdown != null) {
      anchors.add(
        HeadingAnchor(
          title: markdown.group(2)!.trim(),
          level: markdown.group(1)!.length,
        ),
      );
      continue;
    }
    if (line.trim().isNotEmpty &&
        line == line.toUpperCase() &&
        line.trim().length < 56) {
      anchors.add(HeadingAnchor(title: line.trim(), level: 1));
    }
  }
  return anchors;
}

String normalizeSmartContent(String raw) {
  final lines = raw.replaceAll('\r\n', '\n').split('\n');
  final out = <String>[];
  var inFence = false;
  var fenceLanguage = '';
  final codeBuffer = <String>[];

  bool looksLikeCode(String line) {
    final trimmed = line.trim();
    return RegExp(
      r'^(import |class |void |int |final |const |function |SELECT |CREATE |INSERT |UPDATE |DELETE |<\w+|[\}\{]|printf|console\.|System\.out|def |from )',
    ).hasMatch(trimmed);
  }

  String detectLanguage(String block) {
    if (block.contains('System.out') || block.contains('public class')) {
      return 'java';
    }
    if (block.contains('#include') || block.contains('printf(')) return 'c';
    if (block.contains('SELECT ') || block.contains('CREATE TABLE')) {
      return 'sql';
    }
    if (block.contains('console.') || block.contains('require(')) {
      return 'javascript';
    }
    if (block.contains('def ') || block.contains('print(')) return 'python';
    if (block.contains('<html') || block.contains('</')) return 'xml';
    if (block.contains('Widget build') || block.contains('StatelessWidget')) {
      return 'dart';
    }
    if (block.trim().startsWith('{') || block.trim().startsWith('[')) {
      return 'json';
    }
    return 'plaintext';
  }

  void flushCode() {
    if (codeBuffer.isEmpty) return;
    final block = codeBuffer.join('\n');
    out
      ..add(
        '```${fenceLanguage.isEmpty ? detectLanguage(block) : fenceLanguage}',
      )
      ..add(block)
      ..add('```');
    codeBuffer.clear();
    fenceLanguage = '';
  }

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('```')) {
      if (inFence) {
        flushCode();
        inFence = false;
      } else {
        inFence = true;
        fenceLanguage = trimmed.replaceFirst('```', '').trim();
      }
      continue;
    }
    if (inFence || looksLikeCode(line)) {
      codeBuffer.add(line);
      continue;
    }
    flushCode();
    if (trimmed.isEmpty) {
      out.add('');
    } else if (RegExp(r'^[A-Z][A-Za-z0-9 /&+-]{2,48}$').hasMatch(trimmed) &&
        !trimmed.endsWith('.')) {
      out.add('# $trimmed');
    } else {
      out.add(line);
    }
  }
  flushCode();
  return out.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n');
}

class SmartFormatterView extends StatelessWidget {
  const SmartFormatterView({
    required this.content,
    required this.fontSize,
    required this.textColor,
    super.key,
  });

  final String content;
  final double fontSize;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final normalized = normalizeSmartContent(content);
    return MarkdownBody(
      data: normalized,
      selectable: true,
      onTapLink: (text, href, title) {
        if (href == null) return;
        launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
      },
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(fontSize: fontSize, height: 1.8, color: textColor),
        h1: TextStyle(
          fontSize: fontSize + 14,
          fontWeight: FontWeight.w900,
          height: 1.18,
          color: textColor,
        ),
        h2: TextStyle(
          fontSize: fontSize + 8,
          fontWeight: FontWeight.w800,
          height: 1.25,
          color: textColor,
        ),
        h3: TextStyle(
          fontSize: fontSize + 4,
          fontWeight: FontWeight.w800,
          height: 1.35,
          color: textColor,
        ),
        blockquote: TextStyle(
          fontSize: fontSize,
          height: 1.7,
          color: textColor.withValues(alpha: .82),
          fontStyle: FontStyle.italic,
        ),
        code: GoogleFonts.jetBrainsMono(
          fontSize: fontSize - 1,
          color: const Color(0xFFD6336C),
        ),
        codeblockDecoration: BoxDecoration(
          color: const Color(0xFF101216),
          borderRadius: BorderRadius.circular(18),
        ),
        tableBorder: TableBorder.all(
          color: textColor.withValues(alpha: .18),
          borderRadius: BorderRadius.circular(12),
        ),
        listBullet: TextStyle(fontSize: fontSize, color: textColor),
      ),
      builders: {'code': CodeElementBuilder(fontSize: fontSize)},
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  CodeElementBuilder({required this.fontSize});

  final double fontSize;

  @override
  Widget? visitElementAfter(element, TextStyle? preferredStyle) {
    final language =
        element.attributes['class']?.replaceFirst('language-', '') ?? 'text';
    final code = element.textContent;
    if (!code.contains('\n')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECF2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          code,
          style: GoogleFonts.jetBrainsMono(
            fontSize: fontSize - 1,
            color: const Color(0xFFB4235A),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: ColoredBox(
          color: const Color(0xFF101216),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        language.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF9AA4B2),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(30, 30),
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: code)),
                      child: const Icon(
                        CupertinoIcons.doc_on_doc,
                        size: 17,
                        color: Color(0xFF9AA4B2),
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
                child: HighlightView(
                  code,
                  language: language == 'xml' ? 'html' : language,
                  theme: atomOneDarkTheme,
                  textStyle: GoogleFonts.jetBrainsMono(
                    fontSize: fontSize - 2,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
