// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:palakat/core/constants/constants.dart';
// import 'package:palakat/core/datasources/datasources.dart';
//
// class UserApi {
//
//   UserApi(this._dioClient);
//
//   Future<Result<List<UserFeatureResponse>>> userFeature({
//     Map<String, dynamic>? params,
//   }) async {
//     try {
//       final response = await _dioClient.get(
//         Endpoint.userFeature,
//         queryParameters: params,
//       );
//       return Result.success(
//         List.from(
//           (response['data'] as List).map(
//             (e) => UserFeatureResponse.fromJson(e),
//           ),
//         ),
//       );
//     } catch (e, st) {
//       return Result.failure(
//         NetworkExceptions.getDioException(e, st),
//         st,
//       );
//     }
//   }
//
// }
//
// final featureApiProvider = Provider<FeatureApi>((ref) {
//   return FeatureApi(ref.read(dioClientProvider));
// });
