import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_shared/core/constants/enums.dart';

part 'get_fetch_articles_request.freezed.dart';
part 'get_fetch_articles_request.g.dart';

@Freezed(toJson: true, fromJson: true)
abstract class GetFetchArticlesRequest with _$GetFetchArticlesRequest {
  const factory GetFetchArticlesRequest({String? search, ArticleType? type}) =
      _GetFetchArticlesRequest;

  factory GetFetchArticlesRequest.fromJson(Map<String, dynamic> json) =>
      _$GetFetchArticlesRequestFromJson(json);
}
