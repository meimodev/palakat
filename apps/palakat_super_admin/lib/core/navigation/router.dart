import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/articles/presentation/articles_list_screen.dart';
import '../../features/articles/presentation/article_editor_screen.dart';
import '../../features/church_requests/presentation/church_request_detail_screen.dart';
import '../../features/church_requests/presentation/church_requests_list_screen.dart';
import '../../features/auth/application/super_admin_auth_controller.dart';
import '../../features/auth/presentation/signin_screen.dart';
import '../../features/churches/presentation/church_editor_screen.dart';
import '../../features/churches/presentation/churches_list_screen.dart';
import '../../features/membership_invitations/presentation/membership_invitations_list_screen.dart';
import '../../features/songs/presentation/song_editor_screen.dart';
import '../../features/songs/presentation/songs_list_screen.dart';
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
            path: '/church-requests',
            name: 'church_requests',
            builder: (context, state) => const ChurchRequestsListScreen(),
          ),
          GoRoute(
            path: '/church-requests/:id',
            name: 'church_request_detail',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = int.tryParse(idStr ?? '');
              if (id == null) {
                return const SizedBox.shrink();
              }
              return ChurchRequestDetailScreen(id: id);
            },
          ),
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
          GoRoute(
            path: '/songs',
            name: 'songs',
            builder: (context, state) => const SongsListScreen(),
          ),
          GoRoute(
            path: '/songs/new',
            name: 'song_new',
            builder: (context, state) => const SongEditorScreen(),
          ),
          GoRoute(
            path: '/songs/:id',
            name: 'song_edit',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = (idStr ?? '').trim();
              if (id.isEmpty) {
                return const SizedBox.shrink();
              }
              return SongEditorScreen(songId: id);
            },
          ),
          GoRoute(
            path: '/churches',
            name: 'churches',
            builder: (context, state) => const ChurchesListScreen(),
          ),
          GoRoute(
            path: '/membership-invitations',
            name: 'membership_invitations',
            builder: (context, state) =>
                const MembershipInvitationsListScreen(),
          ),
          GoRoute(
            path: '/churches/new',
            name: 'church_new',
            builder: (context, state) => const ChurchEditorScreen(),
          ),
          GoRoute(
            path: '/churches/:id',
            name: 'church_edit',
            builder: (context, state) {
              final idStr = state.pathParameters['id'];
              final id = int.tryParse(idStr ?? '');
              return ChurchEditorScreen(churchId: id);
            },
          ),
        ],
      ),
    ],
  );
});
