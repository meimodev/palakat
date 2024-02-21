import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class GoogleMapRepository {
  final GoogleMapApi _gmapApi;

  GoogleMapRepository(
    this._gmapApi,
  );

  Future<Result<List<AutocompleteResponse>>> autocomplete(
      AutocompleteRequest request) {
    return _gmapApi.autocomplete(request);
  }
}

final googleMapRepositoryProvider =
    Provider.autoDispose<GoogleMapRepository>((ref) {
  return GoogleMapRepository(
    ref.read(googleMapApiProvider),
  );
});
