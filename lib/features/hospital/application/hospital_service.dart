import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/hospital/application/hospital_mapper.dart';

class HospitalService {
  final HospitalRepository _hospitalRepository;

  HospitalService(
    this._hospitalRepository,
  );

  Future<Result<PaginationResponse<Doctor>>> getDoctors(
      DoctorListRequest request) async {
    final result = await _hospitalRepository.doctors(request);

    return result.when(
      success: (response) => Result.success(
        PaginationResponse.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Doctor.fromJson(
            eachData as Map<String, dynamic>,
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<Doctor>> getDoctorBySerial(String serial) async {
    final result = await _hospitalRepository.doctorBySerial(
      SerialRequest(serial: serial),
    );

    return result.when(
      success: (response) => Result.success(
        Doctor.fromJson(response.toJson()),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<PaginationResponse<Doctor>>> selectDoctors(
      PaginationRequest request) async {
    final result = await _hospitalRepository.selectDoctors(request);

    return result.when(
      success: (response) => Result.success(
        PaginationResponse.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Doctor.fromJson(
            eachData as Map<String, dynamic>,
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<PaginationWithNearestResponse<Location>>> getLocations(
      LocationListRequest request) async {
    final result = await _hospitalRepository.locations(request);

    return result.when(
      success: (response) => Result.success(
        PaginationWithNearestResponse<Location>.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Location.fromJson(eachData as Map<String, dynamic>),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<PaginationResponse<SerialName>>> selectSpecialists(
      PaginationRequest request) async {
    final result = await _hospitalRepository.selectSpecialists(request);

    return result.when(
      success: (response) => Result.success(
        PaginationResponse.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => SerialName.fromJson(
            eachData as Map<String, dynamic>,
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<PaginationWithNearestResponse<Hospital>>> getHospitals(
      HospitalListRequest request) async {
    final result = await _hospitalRepository.hospitals(request);

    return result.when(
      success: (response) => Result.success(
        PaginationWithNearestResponse<Hospital>.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Hospital.fromJson(eachData as Map<String, dynamic>),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<PaginationResponse<Hospital>>> selectHospitals(
      PaginationRequest request) async {
    final result = await _hospitalRepository.selectHospitals(request);

    return result.when(
      success: (response) => Result.success(
        PaginationResponse.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Hospital.fromJson(
            eachData as Map<String, dynamic>,
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<List<DoctorScheduleResponse>>> getDoctorSchedule(
      DoctorScheduleRequest request) async {
    return _hospitalRepository.doctorSchedule(request);
  }

  Future<Result<List<DoctorHospitalSchedule>>> getDoctorHospitalSchedule(
      String serial) async {
    final result = await _hospitalRepository.doctorHospitalSchedule(
      SerialRequest(serial: serial),
    );

    return result.when(
      success: (response) => Result.success(
        List.from(
          response.map(
            (e) => HospitalMapper.mapHospitalSchedule(e),
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<DoctorHospitalSlotResponse>> getDoctorHospitalSLot(
      DoctorHospitalSlotRequest request) async {
    return _hospitalRepository.doctorHospitalSlot(request);
  }

  Future<Result<DoctorPriceResponse>> getDoctorPrice(
      DoctorPriceRequest request) async {
    return _hospitalRepository.doctorPrice(request);
  }
}

final hospitalServiceProvider = Provider<HospitalService>((ref) {
  final hospital = ref.read(hospitalRepositoryProvider);
  return HospitalService(hospital);
});
