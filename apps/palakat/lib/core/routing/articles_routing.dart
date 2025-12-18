import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/articles/presentations/article_detail/article_detail_screen.dart';
import 'package:palakat/features/articles/presentations/articles_list/articles_list_screen.dart';

final articlesRouting = GoRoute(
  path: '/articles',
  name: AppRoute.articles,
  builder: (context, state) => const ArticlesListScreen(),
  routes: [
    GoRoute(
      path: ':articleId',
      name: AppRoute.articleDetail,
      builder: (context, state) {
        final idStr = state.pathParameters['articleId'];
        assert(idStr != null, 'articleId path parameter cannot be null');
        final articleId = int.parse(idStr!);
        return ArticleDetailScreen(articleId: articleId);
      },
    ),
  ],
);
