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
  var _saving = false;
  var _dirty = false;
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
    _save(silent: true);
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
          padding: const EdgeInsets.only(left: 8),
          minSize: 32,
          onPressed: _saveNow,
          child: Text(
            _saving ? 'Saving...' : (_dirty ? 'Save' : 'Saved'),
            style: TextStyle(
              inherit: false,
              color: _dirty ? theme.tint : theme.secondaryText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  CupertinoSlidingSegmentedControl<bool>(
                    groupValue: _preview,
                    children: const {
                      false: Text('Edit'),
                      true: Text('Preview'),
                    },
                    onValueChanged: (value) =>
                        setState(() => _preview = value ?? _preview),
                  ),
                  const Spacer(),
                  Text(
                    _saving
                        ? 'Saving changes'
                        : (_dirty ? 'Unsaved changes' : 'All changes saved'),
                    style: TextStyle(
                      color: theme.secondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
              child: CupertinoTextField(
                controller: _title,
                placeholder: 'Chapter title',
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
                keyboardType: TextInputType.text,
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
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: SmartFormatterView(
                            content: _content.text,
                            fontSize: 17,
                            textColor: theme.text,
                          ),
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
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                          keyboardType: TextInputType.multiline,
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
    if (!_dirty) setState(() => _dirty = true);
    _autosave?.cancel();
    _autosave = Timer(const Duration(milliseconds: 650), _save);
    if (_preview) setState(() {});
  }

  Future<void> _saveNow() async {
    _autosave?.cancel();
    await _save();
  }

  Future<void> _save({bool silent = false}) async {
    if (_saving) return;
    final title = _title.text.trim().isEmpty
        ? 'Untitled Note'
        : _title.text.trim();
    if (_chapter == null) {
      if (_content.text.trim().isEmpty && _title.text.trim().isEmpty) return;
      if (!silent && mounted) setState(() => _saving = true);
      _chapter = await ref
          .read(chapterRepositoryProvider)
          .create(
            subjectId: widget.subjectId,
            title: title,
            content: _content.text,
          );
      ref.invalidate(chaptersProvider);
      ref.invalidate(chapterByIdProvider(_chapter!.id));
      if (!silent && mounted) {
        setState(() {
          _saving = false;
          _dirty = false;
        });
      }
      return;
    }
    if (!silent && mounted) setState(() => _saving = true);
    await ref
        .read(chapterRepositoryProvider)
        .update(_chapter!.copyWith(title: title, content: _content.text));
    ref.invalidate(chaptersProvider);
    ref.invalidate(chapterByIdProvider(_chapter!.id));
    if (!silent && mounted) {
      setState(() {
        _saving = false;
        _dirty = false;
      });
    }
  }
}
