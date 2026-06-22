import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../home/providers/home_providers.dart';
import '../models/chapter.dart';
import '../providers/note_providers.dart';
import '../widgets/smart_formatter.dart';

class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({required this.subjectId, this.chapterId, super.key});

  final String subjectId;
  final String? chapterId;

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  Timer? _autosave;
  var _preview = false;
  Chapter? _chapter;

  @override
  void initState() {
    super.initState();
    _chapter = widget.chapterId == null
        ? null
        : ref.read(chapterByIdProvider(widget.chapterId!));
    _title = TextEditingController(text: _chapter?.title ?? '');
    _content = TextEditingController(text: _chapter?.content ?? '');
    _title.addListener(_queueSave);
    _content.addListener(_queueSave);
  }

  @override
  void dispose() {
    _autosave?.cancel();
    _save();
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    return CupertinoPageScaffold(
      backgroundColor: theme.background,
      navigationBar: CupertinoNavigationBar(
        previousPageTitle: 'Chapters',
        middle: Text(_chapter == null ? 'New Chapter' : 'Edit Chapter'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => setState(() => _preview = !_preview),
          child: Icon(_preview ? CupertinoIcons.pencil : CupertinoIcons.eye),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: CupertinoTextField(
                controller: _title,
                placeholder: 'Chapter title',
                padding: const EdgeInsets.all(16),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
                decoration: BoxDecoration(
                  color: theme.glass,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.hairline),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _preview
                    ? SingleChildScrollView(
                        key: const ValueKey('preview'),
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 80),
                        child: SmartFormatterView(
                          content: _content.text,
                          fontSize: 17,
                          textColor: theme.text,
                        ),
                      )
                    : Padding(
                        key: const ValueKey('editor'),
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                        child: CupertinoTextField(
                          controller: _content,
                          placeholder:
                              'Paste notes, Markdown, code, tables, links, or formulas...',
                          expands: true,
                          maxLines: null,
                          minLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          padding: const EdgeInsets.all(18),
                          style: TextStyle(
                            fontSize: 17,
                            height: 1.65,
                            color: theme.text,
                          ),
                          decoration: BoxDecoration(
                            color: theme.glass,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: theme.hairline),
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _queueSave() {
    _autosave?.cancel();
    _autosave = Timer(const Duration(milliseconds: 650), _save);
    if (_preview) setState(() {});
  }

  Future<void> _save() async {
    final title = _title.text.trim().isEmpty
        ? 'Untitled Note'
        : _title.text.trim();
    if (_chapter == null) {
      if (_content.text.trim().isEmpty && _title.text.trim().isEmpty) return;
      _chapter = await ref
          .read(chapterRepositoryProvider)
          .create(
            subjectId: widget.subjectId,
            title: title,
            content: _content.text,
          );
      return;
    }
    await ref
        .read(chapterRepositoryProvider)
        .update(_chapter!.copyWith(title: title, content: _content.text));
  }
}
