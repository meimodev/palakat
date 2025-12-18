import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/models/models.dart';

part 'article_detail_state.freezed.dart';

@freezed
abstract class ArticleDetailState with _$ArticleDetailState {
  const ArticleDetailState._();

  const factory ArticleDetailState({
    @Default(true) bool isLoading,
    @Default(false) bool isLikeLoading,
    Article? article,
    bool? liked,
    String? errorMessage,
  }) = _ArticleDetailState;

  int get likesCount => article?.likesCount ?? 0;
}
