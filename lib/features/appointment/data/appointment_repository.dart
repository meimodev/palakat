import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class AppointmentRepository {
  final AppointmentApi _appointmentApi;

  AppointmentRepository(
    this._appointmentApi,
  );

  Future<Result<PaginationResponse<AppointmentResponse>>> appointments(
      AppointmentListRequest request) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     PaginationResponse<AppointmentResponse>.fromJson(
    //       {
    //         "data": List.generate(
    //           3,
    //           (index) => {
    //             "serial": index.toString(),
    //             "type": "DOCTOR",
    //             "hhh": 12,
    //             "bookingID": "string",
    //             "isPreAppointment": true,
    //             "guaranteeType": "PERSONAL",
    //             "status": "SELF_CHECKIN",
    //             "insuranceStatus": "APPROVED",
    //             "cancelReason": null,
    //             "patient": {
    //               "serial": "string",
    //               "name": "Lorem ipsum color damet",
    //               "status": "VERIFIED",
    //               "firstName": "string",
    //               "lastName": "string",
    //               "mrn": "string | nullable",
    //               "dateOfBirth": "2023-11-24T07:44:26.625Z",
    //               "phone": "string",
    //               "email": "string | nullable",
    //               "gender": {
    //                 "serial": "string",
    //                 "name": "FEMALE",
    //               }
    //             },
    //             "date": "2023-11-24T07:44:26.625Z",
    //             "doctor": {
    //               "serial": "string",
    //               "name": "dr. Leon Gerald, SpPD",
    //               "pictureURL": ""
    //             },
    //             "hospital": {
    //               "serial": "string",
    //               "name": "RSH Kemayoran",
    //               "longitude": 106.6261811,
    //               "latitude": -6.1786837,
    //               "callCenter": "1500-488",
    //             },
    //             "specialist": {
    //               "serial": "string",
    //               "name": "Internal Medicine - Internist"
    //             },
    //             "currentJourney": "Registration",
    //             "canCancel": false,
    //             "canReschedule": true,
    //             "canManage": false,
    //             "canSelfCheckin": index % 2 == 0,
    //           },
    //         ).toList(),
    //         "total": 10,
    //         "currentPage": 1,
    //         "totalPage": 1
    //       },
    //       (data) => AppointmentResponse.fromJson(data as Map<String, dynamic>),
    //     ),
    //   ),
    // );

    return _appointmentApi.appointments(request);
  }

  Future<Result<AppointmentResponse>> appointmentDoctorBySerial(
      SerialRequest request) {
    // final guaranteeType = ['PERSONAL', 'INSURANCE'];
    // final status = [
    //   'CONFIRM',
    //   'DOCTOR_NOT_AVAILABLE',
    //   'CANCELED',
    //   'SLOT_TAKEN'
    // ];
    // final insuranceStatus = ['APPROVED', 'PENDING', 'REJECTED', null];
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     AppointmentResponse.fromJson({
    //       "serial": 1.toString(),
    //       "type": "DOCTOR",
    //       "queueNumber": 12,
    //       "bookingID": "string",
    //       "isPreAppointment": true,
    //       "guaranteeType": (guaranteeType..shuffle()).first,
    //       "status": (status..shuffle()).first,
    //       "insuranceStatus": (insuranceStatus..shuffle()).first,
    //       "cancelReason": null,
    //       "patient": {
    //         "serial": "string",
    //         "name": "Lorem ipsum color damet",
    //         "firstName": "string",
    //         "lastName": "string",
    //         "mrn": "string | nullable",
    //         "dateOfBirth": "2023-11-24T07:44:26.625Z",
    //         "phone": "string",
    //         "email": "string | nullable",
    //         "gender": {
    //           "serial": "string",
    //           "name": "FEMALE",
    //         }
    //       },
    //       "date": "2023-11-24T07:44:26.625Z",
    //       "doctor": {
    //         "serial": "string",
    //         "name": "dr. Leon Gerald, SpPD",
    //       },
    //       "hospital": {"serial": "string", "name": "RSH Kemayoran"},
    //       "specialist": {
    //         "serial": "string",
    //         "name": "Internal Medicine - Internist"
    //       },
    //       "currentJourney": "Registration",
    //       "canCancel": true,
    //       "canReschedule": true,
    //     }),
    //   ),
    // );

    return _appointmentApi.appointmentDoctorBySerial(request);
  }

  Future<Result<PaginationResponse<SerialNameResponse>>> selectAppointmentTypes(
      PaginationRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       20,
    //       (index) => {
    //         "serial": index.toString(),
    //         "name": "service ${index.toString()}"
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => SerialNameResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _appointmentApi.selectAppointmentTypes(request);
  }

  Future<Result<SuccessResponse>> cancel(AppointmentCancelRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _appointmentApi.cancel(request);
  }

  Future<Result<AppointmentResponse>> create(AppointmentCreateRequest request) {
    // print(request.toJson());
    // final guaranteeType = ['PERSONAL', 'INSURANCE'];
    // final status = [
    //   'CONFIRM',
    //   'DOCTOR_NOT_AVAILABLE',
    //   'CANCELED',
    //   'SLOT_TAKEN'
    // ];
    // final insuranceStatus = ['APPROVED', 'PENDING', 'REJECTED', null];
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     AppointmentResponse.fromJson({
    //       "serial": 1.toString(),
    //       "type": "DOCTOR",
    //       "queueNumber": 12,
    //       "bookingID": "string",
    //       "isPreAppointment": true,
    //       "guaranteeType": (guaranteeType..shuffle()).first,
    //       "status": (status..shuffle()).first,
    //       "insuranceStatus": (insuranceStatus..shuffle()).first,
    //       "cancelReason": null,
    //       "patient": {
    //         "serial": "string",
    //         "name": "Lorem ipsum color damet",
    //         "firstName": "string",
    //         "lastName": "string",
    //         "mrn": "string | nullable",
    //         "dateOfBirth": "2023-11-24T07:44:26.625Z",
    //         "phone": "string",
    //         "email": "string | nullable",
    //         "gender": {
    //           "serial": "string",
    //           "name": "FEMALE",
    //         }
    //       },
    //       "date": "2023-11-24T07:44:26.625Z",
    //       "doctor": {
    //         "serial": "string",
    //         "name": "dr. Leon Gerald, SpPD",
    //       },
    //       "hospital": {"serial": "string", "name": "RSH Kemayoran"},
    //       "specialist": {
    //         "serial": "string",
    //         "name": "Internal Medicine - Internist"
    //       },
    //       "currentJourney": "Registration",
    //       "canCancel": true,
    //       "canReschedule": true,
    //     }),
    //   ),
    // );

    return _appointmentApi.create(request);
  }

  Future<Result<SuccessResponse>> reschedule(
      AppointmentRescheduleRequest request) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _appointmentApi.reschedule(request);
  }

  Future<Result<SuccessResponse>> manage(SerialRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     SuccessResponse.fromJson(
    //       {
    //         "result": true,
    //       },
    //     ),
    //   ),
    // );

    return _appointmentApi.manage(request);
  }
}

final appointmentRepositoryProvider =
    Provider.autoDispose<AppointmentRepository>((ref) {
  return AppointmentRepository(
    ref.read(appointmentApiProvider),
  );
});
