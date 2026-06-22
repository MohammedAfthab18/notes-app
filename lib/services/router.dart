import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/home/views/home_screen.dart';
import '../features/notes/views/editor_screen.dart';
import '../features/notes/views/reader_screen.dart';
import '../features/search/views/global_search_screen.dart';
import '../features/settings/views/settings_screen.dart';
import '../features/statistics/views/statistics_screen.dart';
import '../features/subjects/views/subject_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
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
