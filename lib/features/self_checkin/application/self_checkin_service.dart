import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class SelfCheckinService {
  final SelfCheckinRepository _selfCheckinRepository;

  SelfCheckinService(
    this._selfCheckinRepository,
  );

  Future<Result<SelfCheckinSuccessResponse>> selfCheckin(
    String appointmentSerial,
  ) {
    return _selfCheckinRepository.selfCheckin(
      SelfCheckinRequest(appointmentSerial: appointmentSerial),
    );
  }
}

final selfCheckinServiceProvider = Provider<SelfCheckinService>((ref) {
  return SelfCheckinService(ref.read(selfCheckinRepositoryProvider));
});
