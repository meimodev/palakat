import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/articles/presentations/articles_list/articles_list_controller.dart';
import 'package:palakat/features/articles/presentations/articles_motion_widget.dart';
import 'package:palakat_shared/palakat_shared.dart'
    hide BaseColor, BaseSize, BaseTypography, Gap, Column, LoadingWrapper;

class ArticlesListScreen extends ConsumerStatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  ConsumerState<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends ConsumerState<ArticlesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll * 0.9)) {
      ref.read(articlesListControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articlesListControllerProvider);
    final controller = ref.read(articlesListControllerProvider.notifier);

    return ScaffoldWidget(
      disableSingleChildScrollView: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ArticlesReveal(
            child: ScreenTitleWidget.titleSecondary(
              title: context.l10n.articles_title,
              onBack: () => context.pop(),
            ),
          ),
          Gap.h8,
          ArticlesReveal(
            delay: const Duration(milliseconds: 50),
            child: _SearchAndFilterBar(
              filterType: state.filterType,
              onSearchChanged: (value) {
                FocusScope.of(context).unfocus();
                controller.setSearch(value);
              },
              onClearSearch: () => controller.setSearch(''),
              onTypeChanged: controller.setTypeFilter,
              onClearFilters: controller.clearFilters,
              hasActiveFilters: state.hasActiveFilters,
              isLoading: state.isLoading,
            ),
          ),
          Gap.h8,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
              child: LoadingWrapper(
                loading: state.isLoading,
                hasError: state.errorMessage != null && !state.isLoading,
                errorMessage: state.errorMessage,
                onRetry: () => controller.fetchArticles(refresh: true),
                shimmerPlaceholder: _buildShimmerPlaceholder(),
                child: state.articles.isEmpty
                    ? ArticlesAnimatedPresence(
                        visible: state.articles.isEmpty,
                        child: _EmptyState(
                          hasActiveFilters: state.hasActiveFilters,
                          onClearFilters: controller.clearFilters,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            controller.fetchArticles(refresh: true),
                        color: BaseColor.teal.shade500,
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: BaseSize.h16),
                          itemCount:
                              state.articles.length +
                              (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, _) => Gap.h8,
                          itemBuilder: (context, index) {
                            if (index == state.articles.length) {
                              return ArticlesAnimatedPresence(
                                visible: state.isLoadingMore,
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(BaseSize.w16),
                                    child: SizedBox(
                                      width: BaseSize.w24,
                                      height: BaseSize.w24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: BaseColor.primary[700],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }

                            final article = state.articles[index];
                            return ArticlesReveal(
                              key: ValueKey(
                                'article-list-${article.id ?? index}',
                              ),
                              delay: Duration(milliseconds: 70 + (index * 35)),
                              child: _ArticleListItem(
                                article: article,
                                onTap: () {
                                  if (article.id == null) return;
                                  context.pushNamed(
                                    AppRoute.articleDetail,
                                    pathParameters: {
                                      'articleId': article.id.toString(),
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
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
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h8,
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h8,
          PalakatShimmerPlaceholders.listItemCard(),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.filterType,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTypeChanged,
    required this.onClearFilters,
    required this.hasActiveFilters,
    required this.isLoading,
  });

  final ArticleType? filterType;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(ArticleType?) onTypeChanged;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String articleTypeLabel(ArticleType? type) {
      switch (type) {
        case null:
          return l10n.filter_activityType_allTitle;
        case ArticleType.preachingMaterial:
          return l10n.articleType_preachingMaterial;
        case ArticleType.gameInstruction:
          return l10n.articleType_gameInstruction;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SearchField(
            hint: l10n.lbl_search,
            onSearch: onSearchChanged,
            debounceMilliseconds: 500,
            isLoading: isLoading,
            prefixIcon: FaIcon(
              AppIcons.search,
              size: 18,
              color: BaseColor.secondaryText,
            ),
            borderRadius: BaseSize.radiusMd,
          ),
          Gap.h8,
          InputWidget<ArticleType?>.dropdown(
            label: l10n.lbl_type,
            hint: l10n.filter_activityType_allTitle,
            currentInputValue: filterType,
            options: <ArticleType?>[null, ...ArticleType.values],
            optionLabel: (type) => articleTypeLabel(type),
            onChanged: onTypeChanged,
            onPressedWithResult: () async {
              return await showModalBottomSheet<ArticleType?>(
                context: context,
                isScrollControlled: true,
                showDragHandle: true,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          title: Text(l10n.filter_activityType_allTitle),
                          trailing: filterType == null
                              ? const Icon(Icons.check)
                              : null,
                          onTap: () => Navigator.of(context).pop(null),
                        ),
                        ...ArticleType.values.map(
                          (t) => ListTile(
                            title: Text(articleTypeLabel(t)),
                            trailing: filterType == t
                                ? const Icon(Icons.check)
                                : null,
                            onTap: () => Navigator.of(context).pop(t),
                          ),
                        ),
                        SizedBox(height: BaseSize.h12),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          ArticlesAnimatedPresence(
            visible: hasActiveFilters,
            child: Padding(
              padding: EdgeInsets.only(top: BaseSize.h8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ButtonWidget.text(
                  text: l10n.btn_clear,
                  onTap: onClearFilters,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleListItem extends StatelessWidget {
  const _ArticleListItem({required this.article, required this.onTap});

  final Article article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final title = (article.title?.trim().isNotEmpty == true)
        ? article.title!
        : l10n.article_titleFallback;
    final publishedText =
        (article.publishedAt ?? article.createdAt)?.toFromNow ??
        l10n.lbl_notSpecified;

    IconData iconForArticleType(ArticleType? type) {
      switch (type) {
        case ArticleType.preachingMaterial:
          return AppIcons.preachingMaterial;
        case ArticleType.gameInstruction:
          return AppIcons.gameInstruction;
        case null:
          return AppIcons.article;
      }
    }

    return Material(
      color: BaseColor.cardBackground1,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      surfaceTintColor: BaseColor.primary[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BaseSize.radiusMd),
        side: BorderSide(color: BaseColor.neutral20, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w8),
          child: Row(
            children: [
              if (article.coverImageUrl != null &&
                  article.coverImageUrl!.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  child: ImageNetworkWidget(
                    imageUrl: article.coverImageUrl!,
                    width: BaseSize.w48,
                    height: BaseSize.w48,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: BaseSize.w48,
                  height: BaseSize.w48,
                  decoration: BoxDecoration(
                    color: BaseColor.primary[50],
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    iconForArticleType(article.type),
                    size: BaseSize.w18,
                    color: BaseColor.primary,
                  ),
                ),
              Gap.w10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: BaseTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: BaseColor.textPrimary,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.excerpt != null &&
                        article.excerpt!.trim().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: BaseSize.h4),
                        child: Text(
                          article.excerpt!,
                          style: BaseTypography.bodyMedium.copyWith(
                            color: BaseColor.secondaryText,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: BaseSize.h6),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final shouldStackMeta =
                              constraints.maxWidth < 220 ||
                              MediaQuery.textScalerOf(context).scale(1) > 1.1;

                          final publishedMeta = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                AppIcons.time,
                                size: 12,
                                color: BaseColor.secondaryText,
                              ),
                              Gap.w4,
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: shouldStackMeta
                                      ? constraints.maxWidth > BaseSize.w16
                                            ? constraints.maxWidth -
                                                  BaseSize.w16
                                            : constraints.maxWidth
                                      : constraints.maxWidth * 0.6,
                                ),
                                child: Text(
                                  publishedText,
                                  style: BaseTypography.bodyMedium.copyWith(
                                    color: BaseColor.secondaryText,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );

                          final likesMeta = Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.heart,
                                size: 12,
                                color: BaseColor.secondaryText,
                              ),
                              Gap.w4,
                              Text(
                                (article.likesCount ?? 0).toString(),
                                style: BaseTypography.bodyMedium.copyWith(
                                  color: BaseColor.secondaryText,
                                ),
                              ),
                            ],
                          );

                          if (shouldStackMeta) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [publishedMeta, Gap.h6, likesMeta],
                            );
                          }

                          return Wrap(
                            spacing: BaseSize.w8,
                            runSpacing: BaseSize.h6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [publishedMeta, likesMeta],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Material(
        color: BaseColor.surfaceMedium,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
          side: BorderSide(color: BaseColor.neutral[200]!, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(BaseSize.w24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: BaseSize.w56,
                height: BaseSize.w56,
                decoration: BoxDecoration(
                  color: BaseColor.primary[50],
                  borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  hasActiveFilters ? AppIcons.searchOff : AppIcons.article,
                  size: BaseSize.w24,
                  color: BaseColor.primary,
                ),
              ),
              Gap.h12,
              Text(
                hasActiveFilters
                    ? l10n.noData_matchingCriteria
                    : l10n.noData_available,
                textAlign: TextAlign.center,
                style: BaseTypography.titleMedium.copyWith(
                  color: BaseColor.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (hasActiveFilters) ...[
                Gap.h12,
                ButtonWidget.outlined(
                  text: l10n.btn_clear,
                  onTap: onClearFilters,
                  isShrink: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
