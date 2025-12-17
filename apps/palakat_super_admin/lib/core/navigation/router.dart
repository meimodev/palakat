import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/articles/presentation/articles_list_screen.dart';
import '../../features/articles/presentation/article_editor_screen.dart';
import '../../features/auth/application/super_admin_auth_controller.dart';
import '../../features/auth/presentation/signin_screen.dart';
import '../layout/app_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(superAdminAuthControllerProvider, (prev, next) {
    refresh.value++;
  });

  return GoRouter(
    initialLocation: '/articles',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(superAdminAuthControllerProvider).asData?.value;
      final isAuthed = auth != null && auth.trim().isNotEmpty;
      final goingToSignIn = state.matchedLocation == '/signin';
      String? route;
      if (!isAuthed && !goingToSignIn) route = '/signin';
      if (isAuthed && goingToSignIn) route = '/articles';
      return route;
    },
    routes: [
      GoRoute(
        path: '/signin',
        name: 'signin',
        builder: (context, state) => const SignInScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/articles',
            name: 'articles',
            builder: (context, state) => const ArticlesListScreen(),
          ),
          GoRoute(
            path: '/articles/new',
            name: 'article_new',
            builder: (context, state) => const ArticleEditorScreen(),
          ),
          GoRoute(
            path: '/articles/:id',
            name: 'article_edit',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = int.tryParse(idStr ?? '');
              return ArticleEditorScreen(articleId: id);
            },
          ),
        ],
      ),
    ],
  );
});
