import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/articles/presentations/articles_list/articles_list_controller.dart';
import 'package:palakat/features/articles/presentations/articles_motion_widget.dart';
import 'package:palakat_shared/palakat_shared.dart' hide Column, LoadingWrapper;

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
              padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                        color: AppColors.primary,
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: 16.0),
                          itemCount:
                              state.articles.length +
                              (state.isLoadingMore ? 1 : 0),
                          separatorBuilder: (_, _) => Gap.h8,
                          itemBuilder: (context, index) {
                            if (index == state.articles.length) {
                              return ArticlesAnimatedPresence(
                                visible: state.isLoadingMore,
                                child: LoadingShimmer(
                                  isLoading: true,
                                  child: PalakatShimmerPlaceholders.listItemCard(),
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
      padding: EdgeInsets.symmetric(horizontal: 12.0),
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
              color: AppColors.onSurfaceVariant,
            ),
            borderRadius: 8.0,
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
                        SizedBox(height: 12.0),
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
              padding: EdgeInsets.only(top: 8.0),
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
      color: AppColors.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.onSurface,
      surfaceTintColor: AppColors.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: AppColors.tertiary, width: 1),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (article.coverImageUrl != null &&
                  article.coverImageUrl!.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: ImageNetworkWidget(
                    imageUrl: article.coverImageUrl!,
                    width: 48.0,
                    height: 48.0,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    iconForArticleType(article.type),
                    size: 18.0,
                    color: AppColors.onPrimaryContainer,
                  ),
                ),
              Gap.w10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.excerpt != null &&
                        article.excerpt!.trim().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.0),
                        child: Text(
                          article.excerpt!,
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.2,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(top: 6.0),
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
                                color: AppColors.onSurfaceVariant,
                              ),
                              Gap.w4,
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: shouldStackMeta
                                      ? constraints.maxWidth > 16.0
                                            ? constraints.maxWidth - 16.0
                                            : constraints.maxWidth
                                      : constraints.maxWidth * 0.6,
                                ),
                                child: Text(
                                  publishedText,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(
                                        color: AppColors.onSurfaceVariant,
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
                                color: AppColors.onSurfaceVariant,
                              ),
                              Gap.w4,
                              Text(
                                (article.likesCount ?? 0).toString(),
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      color: AppColors.onSurfaceVariant,
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
                            spacing: 8.0,
                            runSpacing: 6.0,
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
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.0,
                height: 56.0,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  hasActiveFilters ? AppIcons.searchOff : AppIcons.article,
                  size: 24.0,
                  color: AppColors.onPrimaryContainer,
                ),
              ),
              Gap.h12,
              Text(
                hasActiveFilters
                    ? l10n.noData_matchingCriteria
                    : l10n.noData_available,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.onSurface,
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
