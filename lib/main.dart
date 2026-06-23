import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_providers.dart';
import 'firebase_options.dart';
import 'services/cloud_sync_service.dart';
import 'services/hive_service.dart';
import 'services/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const ProviderScope(child: NotesHubApp()));
}

class NotesHubApp extends ConsumerStatefulWidget {
  const NotesHubApp({super.key});

  @override
  ConsumerState<NotesHubApp> createState() => _NotesHubAppState();
}

class _NotesHubAppState extends ConsumerState<NotesHubApp> {
  @override
  void initState() {
    super.initState();
    if (ref.read(firebaseEnabledProvider)) {
      ref.listen(authStateProvider, (previous, next) {
        next.whenData((user) {
          if (user != null) {
            unawaited(cloudSyncService.bootstrapUser(user));
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
