import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/articles/presentations/article_detail/article_detail_controller.dart';
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
          if (next.errorMessage != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(next.errorMessage!),
                behavior: SnackBarBehavior.floating,
              ),
            );
            controller.clearError();
          }
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.h32,
          ScreenTitleWidget.titleSecondary(
            title: article?.title ?? 'Article',
            onBack: () => context.pop(),
          ),
          Gap.h16,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
              child: LoadingWrapper(
                loading: state.isLoading,
                hasError: state.errorMessage != null && !state.isLoading,
                errorMessage: state.errorMessage,
                onRetry: () => controller.fetchArticle(),
                shimmerPlaceholder: _buildShimmerPlaceholder(),
                child: article == null
                    ? Center(child: Text(l10n.noData_available))
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
      child: Column(
        children: [
          PalakatShimmerPlaceholders.infoCard(),
          Gap.h12,
          PalakatShimmerPlaceholders.infoCard(),
          Gap.h12,
          PalakatShimmerPlaceholders.infoCard(),
        ],
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final title = article.title ?? '-';
    final excerpt = article.excerpt;
    final coverUrl = article.coverImageUrl;
    final publishedAt = article.publishedAt;
    final createdAt = article.createdAt;
    final content = article.content;

    final effectiveDate = publishedAt ?? createdAt;

    return ListView(
      padding: EdgeInsets.only(bottom: BaseSize.h16),
      children: [
        if (coverUrl != null && coverUrl.trim().isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: ImageNetworkWidget(
              imageUrl: coverUrl,
              height: BaseSize.customHeight(200),
              fit: BoxFit.cover,
            ),
          ),
        Gap.h16,
        Text(
          title,
          style: BaseTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
            color: BaseColor.black,
          ),
        ),
        if (effectiveDate != null) ...[
          Gap.h8,
          Row(
            children: [
              FaIcon(
                AppIcons.time,
                size: BaseSize.w14,
                color: BaseColor.secondaryText,
              ),
              Gap.w8,
              Expanded(
                child: Text(
                  effectiveDate.EEEEddMMMyyyyShort,
                  style: BaseTypography.bodySmall.copyWith(
                    color: BaseColor.secondaryText,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (excerpt != null && excerpt.trim().isNotEmpty) ...[
          Gap.h12,
          Text(
            excerpt,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.secondaryText,
            ),
          ),
        ],
        Gap.h16,
        if (content != null && content.trim().isNotEmpty)
          MarkdownBody(data: content, selectable: true)
        else
          Text(
            context.l10n.noData_available,
            style: BaseTypography.bodyMedium.copyWith(
              color: BaseColor.secondaryText,
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

    final isLiked = liked ?? false;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: BaseSize.w12,
        vertical: BaseSize.h12,
      ),
      decoration: BoxDecoration(
        color: BaseColor.white,
        border: Border(top: BorderSide(color: BaseColor.neutral20, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$likesCount likes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: BaseColor.secondaryText,
              ),
            ),
          ),
          IconButton(
            onPressed: isLoading ? null : onTap,
            icon: FaIcon(
              isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              color: isLiked ? BaseColor.red[600] : BaseColor.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
