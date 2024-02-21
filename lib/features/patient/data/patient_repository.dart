import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class PatientRepository {
  final PatientApi _patientApi;

  PatientRepository(
    this._patientApi,
  );

  Future<Result<SuccessResponse>> registerPatientMRN(
      RegisterPatientMRNRequest request) {
    return _patientApi.registerPatientMRN(request);
  }

  Future<Result<SuccessResponse>> registerPatientForm(
      RegisterPatientFormRequest request) {
    return _patientApi.registerPatientForm(request);
  }

  Future<Result<PaginationResponse<PatientResponse>>> patientUsers(
      PaginationRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       5,
    //       (index) => {
    //         "serial": index.toString(),
    //         "name": "patient lorem ${index.toString()}",
    //         "mrn": "string",
    //         "firstName": "string",
    //         "lastName": "string",
    //         "dateOfBirth": "2023-11-08T06:57:20.405Z",
    //         "email": "string",
    //         "phone": "08949120121",
    //         "isPrimaryMrn": true,
    //         "status": "VERIFIED",
    //         "gender": {"name": "Female"},
    //         "approvalStatus": "APPROVED | PENDING | REJECTED"
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => PatientResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _patientApi.patientUsers(request);
  }

  Future<Result<PatientResponse>> patientUserBySerial(SerialRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     PatientResponse.fromJson({
    //       "serial": "string",
    //       "name": "string",
    //       "mrn": "string",
    //       "firstName": "Udin",
    //       "lastName": "Loerm",
    //       "dateOfBirth": "2023-11-08T06:57:20.405Z",
    //       "email": "string",
    //       "phone": "08948923121",
    //       "isPrimaryMrn": true,
    //       "status": "UNVERIFIED",
    //       "approvalStatus": "APPROVED | PENDING | REJECTED",
    //       "rejectedBy": "string",
    //       "rejectedReason": "string",
    //       "approvedBy": "string",
    //       "verifiedBy": "string",
    //       "registerFrom": "MRN | BACKOFFICE | FORM",
    //       "titleSerial": "string",
    //       "genderSerial": "string",
    //       "provinceSerial": "string",
    //       "citySerial": "string",
    //       "districtSerial": "string",
    //       "religionSerial": "string",
    //       "maritalSerial": "string",
    //       "educationSerial": "string",
    //       "occupationSerial": "string",
    //       "citizenshipSerial": "string",
    //       "ethnicSerial": "string",
    //       "villageSerial": "string",
    //       "placeOfBirth": "Jakarta",
    //       "ktpNumber": "00941241212412",
    //       "passportNumber": "string",
    //       "rtNumber": "string",
    //       "rwNumber": "string",
    //       "address":
    //           "Sunt duis deserunt cupidatat adipisicing et mollit minim elit do. Sit voluptate veniam adipisicing sint sint excepteur dolor irure proident laboris nostrud cillum tempor ut. Consequat veniam est nulla nostrud minim do commodo aute. Non officia nulla proident esse. Nostrud officia do amet id commodo exercitation elit et nulla minim exercitation nulla enim nisi.",
    //       "postalCode": "string",
    //       "photoSerial": "string",
    //       "identityCardSerial": "string",
    //       "gender": {"serial": "string", "name": "Male"},
    //       "title": {"serial": "string", "name": "Mr"},
    //       "province": {"serial": "string", "name": "Banten"},
    //       "city": {"serial": "string", "name": "Tangerang"},
    //       "district": {"serial": "string", "name": "Serpong"},
    //       "religion": {"serial": "string", "name": "Islam"},
    //       "marital": {"serial": "string", "name": "Single"},
    //       "education": {"serial": "string", "name": "string"},
    //       "occupation": {"serial": "string", "name": "Designer"},
    //       "citizenship": {"serial": "string", "name": "Indonesia"},
    //       "ethnic": {"serial": "string", "name": "Batak"},
    //       "village": {"serial": "string", "name": "Karawaci"},
    //       "photo": {
    //         "serial": "string",
    //         "url":
    //             "https://images.unsplash.com/photo-1461988320302-91bde64fc8e4?ixid=2yJhcHBfaWQiOjEyMDd9&&fm=jpg&w=356&h=200&fit=max"
    //       },
    //       "identityCard": {
    //         "serial": "string",
    //         "url":
    //             "https://images.unsplash.com/photo-1461988320302-91bde64fc8e4?ixid=2yJhcHBfaWQiOjEyMDd9&&fm=jpg&w=356&h=200&fit=max"
    //       },
    //       "identityType": {"serial": "string", "name": "KTP"}
    //     }),
    //   ),
    // );

    return _patientApi.patientUserBySerial(request);
  }

  Future<Result<PaginationResponse<SerialNameResponse>>> selectPatientUsers(
      PaginationRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       20,
    //       (index) => {
    //         "serial": index.toString(),
    //         "name": "patient ${index.toString()}"
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => SerialNameResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _patientApi.selectPatientUsers(request);
  }

  Future<Result<SuccessResponse>> activatePatientPortal(
      ActivatePatientPortalFormRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 3),
    //   () => Future.value(
    //     const Result.success(
    //       SuccessResponse(success: true),
    //     ),
    //   ),
    // );

    return _patientApi.activatePatientPortal(request);
  }

  Future<Result<PatientPortalStatusResponse>> checkPatientPortalStatus() {
    // return Future.delayed(
    //   const Duration(seconds: 3),
    //   () => Future.value(
    //      Result.success(
    //       PatientPortalStatusResponse.fromJson({
    //         "status": "NOT_ACTIVATED"
    //       }),
    //     ),
    //   ),
    // );

    return _patientApi.checkPatientPortalStatus();
  }
}

final patientRepositoryProvider =
    Provider.autoDispose<PatientRepository>((ref) {
  return PatientRepository(
    ref.read(patientApiProvider),
  );
});
