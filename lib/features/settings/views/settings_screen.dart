import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../services/backup_service.dart';
import '../../home/providers/home_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final box = Hive.box<dynamic>(AppConstants.settingsBox);
    final appearance = AppAppearance.values.byName(
      box.get('appearance', defaultValue: AppAppearance.system.name) as String,
    );

    return CupertinoPageScaffold(
      backgroundColor: theme.background,
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Home',
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: ResponsiveContent(
          maxWidth: 760,
          child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            _Group(
              title: 'Appearance',
              children: [
                CupertinoSlidingSegmentedControl<AppAppearance>(
                  groupValue: appearance,
                  children: const {
                    AppAppearance.system: Text('System'),
                    AppAppearance.light: Text('Light'),
                    AppAppearance.dark: Text('Dark'),
                  },
                  onValueChanged: (value) {
                    if (value == null) return;
                    box.put('appearance', value.name);
                    ref.invalidate(appThemeProvider);
                  },
                ),
              ],
            ),
            _Group(
              title: 'Backup',
              children: [
                _Row(
                  title: 'Export JSON',
                  icon: CupertinoIcons.square_arrow_up,
                  onTap: () async {
                    final target = await BackupService().exportJson(
                      ref.read(subjectsProvider),
                      ref.read(chaptersProvider),
                    );
                    if (context.mounted) _toast(context, 'Saved $target');
                  },
                ),
                _Row(
                  title: 'Export TXT',
                  icon: CupertinoIcons.doc_plaintext,
                  onTap: () async {
                    final target = await BackupService().exportTxt(
                      ref.read(chaptersProvider),
                    );
                    if (context.mounted) _toast(context, 'Saved $target');
                  },
                ),
                _Row(
                  title: 'Restore JSON',
                  icon: CupertinoIcons.arrow_down_doc,
                  onTap: () => BackupService().restoreJson(),
                ),
              ],
            ),
            _Group(
              title: 'About',
              children: const [
                _StaticRow(title: 'NotesHub', value: 'Offline study notes'),
                _StaticRow(title: 'Storage', value: 'Hive local database'),
                _StaticRow(title: 'Version', value: '1.0.0'),
              ],
            ),
            _Group(
              title: 'Maintenance',
              children: [
                _Row(
                  title: 'Clear cache',
                  icon: CupertinoIcons.clear,
                  onTap: () => _toast(context, 'Cache cleared'),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _toast(BuildContext context, String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('NotesHub'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: CupertinoDynamicColor.resolve(
                CupertinoColors.secondarySystemGroupedBackground,
                context,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.title, required this.icon, required this.onTap});

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      onPressed: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
          const Icon(CupertinoIcons.chevron_forward, size: 16),
        ],
      ),
    );
  }
}

class _StaticRow extends StatelessWidget {
  const _StaticRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(
            value,
            style: TextStyle(
              color: CupertinoColors.secondaryLabel.resolveFrom(context),
            ),
          ),
        ],
      ),
    );
  }
}
