import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/articles/presentations/articles_list/articles_list_controller.dart';
import 'package:palakat_shared/core/extension/extension.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;

class ArticlesListScreen extends ConsumerStatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  ConsumerState<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends ConsumerState<ArticlesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
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

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      FocusScope.of(context).unfocus();
      ref.read(articlesListControllerProvider.notifier).setSearch(value);
    });
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
          Gap.h32,
          ScreenTitleWidget.titleSecondary(
            title: 'Articles',
            onBack: () => context.pop(),
          ),
          Gap.h16,
          _SearchAndFilterBar(
            searchController: _searchController,
            filterType: state.filterType,
            onSearchChanged: _onSearchChanged,
            onClearSearch: () {
              _searchController.clear();
              controller.setSearch('');
            },
            onTypeChanged: controller.setTypeFilter,
            onClearFilters: () {
              _searchController.clear();
              controller.clearFilters();
            },
            hasActiveFilters: state.hasActiveFilters,
          ),
          Gap.h16,
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
                    ? _EmptyState(
                        hasActiveFilters: state.hasActiveFilters,
                        onClearFilters: controller.clearFilters,
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
                          separatorBuilder: (_, _) => Gap.h12,
                          itemBuilder: (context, index) {
                            if (index == state.articles.length) {
                              return Center(
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
                              );
                            }

                            final article = state.articles[index];
                            return _ArticleListItem(
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
          Gap.h12,
          PalakatShimmerPlaceholders.listItemCard(),
          Gap.h12,
          PalakatShimmerPlaceholders.listItemCard(),
        ],
      ),
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.searchController,
    required this.filterType,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onTypeChanged,
    required this.onClearFilters,
    required this.hasActiveFilters,
  });

  final TextEditingController searchController;
  final ArticleType? filterType;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final void Function(ArticleType?) onTypeChanged;
  final VoidCallback onClearFilters;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    String articleTypeLabel(ArticleType? type) {
      switch (type) {
        case null:
          return l10n.filter_activityType_allTitle;
        case ArticleType.preachingMaterial:
          return 'Preaching Material';
        case ArticleType.gameInstruction:
          return 'Game Instruction';
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (context, value, _) {
              return TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.lbl_search,
                  prefixIcon: const FaIcon(AppIcons.search),
                  suffixIcon: value.text.isNotEmpty
                      ? IconButton(
                          icon: const FaIcon(AppIcons.clear),
                          onPressed: onClearSearch,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: BaseSize.w16,
                    vertical: BaseSize.h12,
                  ),
                ),
              );
            },
          ),
          Gap.h12,
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
          if (hasActiveFilters) ...[
            Gap.h12,
            Align(
              alignment: Alignment.centerLeft,
              child: ButtonWidget.text(
                text: l10n.btn_clear,
                onTap: onClearFilters,
              ),
            ),
          ],
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
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: BaseColor.cardBackground1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: BaseColor.neutral20, width: 1),
        ),
        padding: EdgeInsets.all(BaseSize.w12),
        child: Row(
          children: [
            if (article.coverImageUrl != null &&
                article.coverImageUrl!.trim().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageNetworkWidget(
                  imageUrl: article.coverImageUrl!,
                  width: BaseSize.w56,
                  height: BaseSize.w56,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: BaseSize.w56,
                height: BaseSize.w56,
                decoration: BoxDecoration(
                  color: BaseColor.teal[50],
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: FaIcon(
                  AppIcons.article,
                  size: BaseSize.w20,
                  color: BaseColor.teal[600],
                ),
              ),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title ?? '-',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: BaseColor.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (article.excerpt != null &&
                      article.excerpt!.trim().isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: BaseSize.h6),
                      child: Text(
                        article.excerpt!,
                        style: BaseTypography.bodySmall.copyWith(
                          color: BaseColor.secondaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: BaseSize.h8),
                    child: Row(
                      children: [
                        FaIcon(
                          AppIcons.time,
                          size: BaseSize.w12,
                          color: BaseColor.secondaryText,
                        ),
                        Gap.w6,
                        Expanded(
                          child: Text(
                            (article.publishedAt ?? article.createdAt)
                                    ?.toFromNow ??
                                '-',
                            style: BaseTypography.labelSmall.copyWith(
                              color: BaseColor.secondaryText,
                            ),
                          ),
                        ),
                        Gap.w12,
                        FaIcon(
                          FontAwesomeIcons.heart,
                          size: BaseSize.w12,
                          color: BaseColor.secondaryText,
                        ),
                        Gap.w6,
                        Text(
                          (article.likesCount ?? 0).toString(),
                          style: BaseTypography.labelSmall.copyWith(
                            color: BaseColor.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      child: Padding(
        padding: EdgeInsets.all(BaseSize.w24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(
              hasActiveFilters ? AppIcons.searchOff : AppIcons.article,
              size: BaseSize.w48,
              color: BaseColor.textSecondary,
            ),
            Gap.h12,
            Text(
              hasActiveFilters
                  ? l10n.noData_matchingCriteria
                  : l10n.noData_available,
              textAlign: TextAlign.center,
              style: BaseTypography.titleMedium.copyWith(
                color: BaseColor.textSecondary,
                fontWeight: FontWeight.w600,
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
    );
  }
}
