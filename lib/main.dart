import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'services/hive_service.dart';
import 'services/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: NotesHubApp()));
}

class NotesHubApp extends ConsumerWidget {
  const NotesHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = ref.watch(appThemeProvider);
    final router = ref.watch(routerProvider);

    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      title: 'NotesHub',
      theme: appTheme.cupertinoTheme,
      routerConfig: router,
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}
