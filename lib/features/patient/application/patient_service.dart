import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';

class PatientService {
  final PatientRepository _accountRepository;

  PatientService(this._accountRepository);

  Future<Result<SuccessResponse>> registerPatientMRN({
    required String mrn,
    DateTime? dateOfBirth,
    bool? isVisitFrontOffice,
    String? phone,
    String? otp,
  }) {
    return _accountRepository.registerPatientMRN(
      RegisterPatientMRNRequest(
        mrn: mrn,
        dateOfBirth: dateOfBirth,
        isVisitFrontOffice: isVisitFrontOffice,
        phone: phone,
        otp: otp,
      ),
    );
  }

  Future<Result<SuccessResponse>> registerPatientForm({
    int? step,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? titleSerial,
    String? placeOfBirth,
    IdentityType? identityType,
    String? identityNumber,
    String? genderSerial,
    String? address,
    String? rtNumber,
    String? rwNumber,
    String? provinceSerial,
    String? citySerial,
    String? districtSerial,
    String? villageSerial,
    String? postalCode,
    String? religionSerial,
    String? maritalSerial,
    String? educationSerial,
    String? occupationSerial,
    String? citizenshipSerial,
    String? ethnicSerial,
    String? identityCardSerial,
    String? photoSerial,
    String? otp,
    bool? isVisitFrontOffice,
  }) {
    return _accountRepository.registerPatientForm(
      RegisterPatientFormRequest(
        step: step,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        phone: phone,
        email: email,
        titleSerial: titleSerial,
        placeOfBirth: placeOfBirth,
        identityType: identityType,
        identityNumber: identityNumber,
        genderSerial: genderSerial,
        address: address,
        rtNumber: rtNumber,
        rwNumber: rwNumber,
        provinceSerial: provinceSerial,
        citySerial: citySerial,
        districtSerial: districtSerial,
        villageSerial: villageSerial,
        postalCode: postalCode,
        religionSerial: religionSerial,
        maritalSerial: maritalSerial,
        educationSerial: educationSerial,
        occupationSerial: occupationSerial,
        citizenshipSerial: citizenshipSerial,
        ethnicSerial: ethnicSerial,
        identityCardSerial: identityCardSerial,
        photoSerial: photoSerial,
        otp: otp,
        isVisitFrontOffice: isVisitFrontOffice,
      ),
    );
  }

  Future<Result<SuccessResponse>> activatePatientPortalForm({
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? email,
    String? phone,
    IdentityType? identityType,
    String? identityNumber,
    String? identityCardSerial,
    String? photoSerial,
    String? otp,
    String? pin,
  }) async {
    return _accountRepository.activatePatientPortal(
      ActivatePatientPortalFormRequest(
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
        email: email,
        phone: phone,
        identityType: identityType,
        identityNumber: identityNumber,
        identityCardSerial: identityCardSerial,
        photoSerial: photoSerial,
        otp: otp,
        pin: pin,
      ),
    );
  }

  Future<Result<PaginationResponse<Patient>>> getPatientUsers(
      PaginationRequest request) async {
    final result = await _accountRepository.patientUsers(request);

    return result.when(
      success: (response) => Result.success(
        PaginationResponse.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Patient.fromJson(
            eachData as Map<String, dynamic>,
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<Patient>> getPatientUserBySerial(String serial) async {
    final result = await _accountRepository.patientUserBySerial(
      SerialRequest(serial: serial),
    );

    return result.when(
      success: (response) => Result.success(
        Patient.fromJson(response.toJson()),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<PaginationResponse<SerialName>>> selectPatientUsers(
      PaginationRequest request) async {
    final result = await _accountRepository.selectPatientUsers(request);

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

  Future<Result<PatientPortalStatus>> checkPatientPortalStatus() async {
    final result = await _accountRepository.checkPatientPortalStatus();

    return result.when(
      success: (response) => Result.success(
        response.status
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }
}

final patientServiceProvider = Provider<PatientService>((ref) {
  final patient = ref.read(patientRepositoryProvider);
  return PatientService(patient);
});
