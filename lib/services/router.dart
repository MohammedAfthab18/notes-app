import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_providers.dart';
import '../features/auth/views/auth_screen.dart';
import '../features/home/views/home_screen.dart';
import '../features/notes/views/editor_screen.dart';
import '../features/notes/views/reader_screen.dart';
import '../features/search/views/global_search_screen.dart';
import '../features/settings/views/settings_screen.dart';
import '../features/statistics/views/statistics_screen.dart';
import '../features/subjects/views/subject_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final firebaseEnabled = ref.watch(firebaseEnabledProvider);
  final auth = firebaseEnabled ? FirebaseAuth.instance : null;

  return GoRouter(
    initialLocation: '/',
    refreshListenable:
        firebaseEnabled ? _GoRouterRefreshStream(auth!.authStateChanges()) : null,
    redirect: (context, state) {
      if (!firebaseEnabled) return null;
      final user = auth!.currentUser;
      final goingToAuth = state.matchedLocation == '/auth';
      if (user == null) return goingToAuth ? null : '/auth';
      if (goingToAuth) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        pageBuilder: _page((state) => const AuthScreen()),
      ),
      GoRoute(path: '/', pageBuilder: _page((state) => const HomeScreen())),
      GoRoute(
        path: '/subject/:id',
        pageBuilder: _page(
          (state) => SubjectScreen(subjectId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/reader/:id',
        pageBuilder: _page(
          (state) => ReaderScreen(chapterId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/editor/:subjectId',
        pageBuilder: _page(
          (state) =>
              EditorScreen(subjectId: state.pathParameters['subjectId']!),
        ),
      ),
      GoRoute(
        path: '/editor/:subjectId/:chapterId',
        pageBuilder: _page(
          (state) => EditorScreen(
            subjectId: state.pathParameters['subjectId']!,
            chapterId: state.pathParameters['chapterId'],
          ),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: _page((state) => const GlobalSearchScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: _page((state) => const SettingsScreen()),
      ),
      GoRoute(
        path: '/stats',
        pageBuilder: _page((state) => const StatisticsScreen()),
      ),
    ],
  );
});

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

Page<dynamic> Function(BuildContext, GoRouterState) _page(
  Widget Function(GoRouterState state) builder,
) {
  return (context, state) => CustomTransitionPage<void>(
    key: state.pageKey,
    child: builder(state),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(.04, .02),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
