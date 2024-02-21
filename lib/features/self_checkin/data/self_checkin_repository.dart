import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class SelfCheckinRepository {
  final AppointmentApi _appointmentApi;

  SelfCheckinRepository(
    this._appointmentApi,
  );

  Future<Result<SelfCheckinSuccessResponse>> selfCheckin(
      SelfCheckinRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(SelfCheckinSuccessResponse.fromJson({
    //     "queueNumber": 16,
    //     "bookingID": "string",
    //     "patient": {
    //       "serial": "string",
    //       "name": "Pricilla Pamela",
    //       "mrn": "0002404969449"
    //     },
    //     "doctor": {"serial": "string", "name": "dr. Leon Gerald, SpPD"}
    //   })),
    // );

    return _appointmentApi.selfCheckin(request);
  }
}

final selfCheckinRepositoryProvider =
    Provider.autoDispose<SelfCheckinRepository>((ref) {
  return SelfCheckinRepository(
    ref.read(appointmentApiProvider),
  );
});
