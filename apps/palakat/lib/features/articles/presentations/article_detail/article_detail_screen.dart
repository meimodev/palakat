import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/articles/presentations/article_detail/article_detail_controller.dart';
import 'package:palakat/features/articles/presentations/articles_motion_widget.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/article.dart';

class ArticleDetailScreen extends ConsumerWidget {
  const ArticleDetailScreen({super.key, required this.articleId});

  final int articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(
      articleDetailControllerProvider(articleId).notifier,
    );
    final state = ref.watch(articleDetailControllerProvider(articleId));

    final article = state.article;

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      persistBottomWidget: _LikeBar(
        likesCount: state.likesCount,
        liked: state.liked,
        isLoading: state.isLikeLoading,
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          await controller.toggleLike();
          final next = ref.read(articleDetailControllerProvider(articleId));
          final msg = next.errorMessage?.trim();
          if (msg != null && msg.isNotEmpty) {
            messenger.showSnackBar(
              SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
            );
            controller.clearError();
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArticlesReveal(
            child: ScreenTitleWidget.titleSecondary(
              title: article?.title ?? l10n.article_titleFallback,
              onBack: () => context.pop(),
            ),
          ),
          Gap.h16,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: LoadingWrapper(
                loading: state.isLoading,
                hasError: state.errorMessage != null && !state.isLoading,
                errorMessage: state.errorMessage,
                onRetry: () => controller.fetchArticle(),
                shimmerPlaceholder: _buildShimmerPlaceholder(),
                child: article == null
                    ? ArticlesAnimatedPresence(
                        visible: article == null,
                        child: Center(
                          child: Material(
                            color: AppColors.surfaceContainerLow,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              side: BorderSide(
                                color: AppColors.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                l10n.noData_available,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium!
                                    .copyWith(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : _Content(article: article),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return SingleChildScrollView(
      child: ShimmerPlaceholders.infoSection(),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = (article.title?.trim().isNotEmpty == true)
        ? article.title!
        : l10n.article_titleFallback;
    final excerpt = article.excerpt;
    final coverUrl = article.coverImageUrl;
    final publishedAt = article.publishedAt;
    final createdAt = article.createdAt;
    final content = article.content;

    final effectiveDate = publishedAt ?? createdAt;

    return ListView(
      padding: EdgeInsets.only(bottom: 16.0),
      children: [
        if (coverUrl != null && coverUrl.trim().isNotEmpty)
          ArticlesReveal(
            child: Material(
              color: AppColors.surfaceContainerLowest,
              elevation: 1,
              shadowColor: AppColors.onSurface,
              surfaceTintColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              clipBehavior: Clip.hardEdge,
              child: ImageNetworkWidget(
                imageUrl: coverUrl,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        Gap.h16,
        ArticlesReveal(
          delay: const Duration(milliseconds: 40),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),
        if (effectiveDate != null) ...[
          Gap.h8,
          ArticlesReveal(
            delay: const Duration(milliseconds: 80),
            child: Row(
              children: [
                FaIcon(
                  AppIcons.time,
                  size: 14.0,
                  color: AppColors.onSurfaceVariant,
                ),
                Gap.w8,
                Expanded(
                  child: Text(
                    effectiveDate.EEEEddMMMyyyyShort,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (excerpt != null && excerpt.trim().isNotEmpty) ...[
          Gap.h12,
          ArticlesReveal(
            delay: const Duration(milliseconds: 120),
            child: Text(
              excerpt,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
        Gap.h16,
        if (content != null && content.trim().isNotEmpty)
          ArticlesReveal(
            delay: const Duration(milliseconds: 160),
            child: MarkdownBody(data: content, selectable: true),
          )
        else
          ArticlesReveal(
            delay: const Duration(milliseconds: 160),
            child: Material(
              color: AppColors.surfaceContainerLow,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: BorderSide(color: AppColors.outlineVariant, width: 1),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  context.l10n.noData_available,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium!.copyWith(color: AppColors.onSurface),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LikeBar extends StatelessWidget {
  const _LikeBar({
    required this.likesCount,
    required this.liked,
    required this.isLoading,
    required this.onTap,
  });

  final int likesCount;
  final bool? liked;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final isLiked = liked ?? false;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(top: BorderSide(color: AppColors.tertiary, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.article_likesCount(likesCount),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onTap,
            icon: FaIcon(
              isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: isLiked ? AppColors.error : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
