import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/features/data.dart';

class HospitalRepository {
  final HospitalApi _hospitalApi;

  HospitalRepository(
    this._hospitalApi,
  );

  Future<Result<PaginationResponse<DoctorResponse>>> doctors(
      DoctorListRequest request) {
    // print(request.toJson());

    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       2,
    //       (index) => {
    //         "serial": "4974f67d-4465-4795-808b-ac9c4de35cbd",
    //         "name": "Yesaya Baringin, Sp.B",
    //         "keys": {
    //           "hospital_13041_telehealID": "102020119",
    //           "hospital_102_astraID": "102020119"
    //         },
    //         "genderSerial": "da1ac75c-7c8c-11ee-a3c7-facbc05e35bc",
    //         "gender": {
    //           "serial": "da1ac75c-7c8c-11ee-a3c7-facbc05e35bc",
    //           "category": "gender",
    //           "value": "Laki-Laki",
    //           "keys": {"primary": "531", "value": "Laki-Laki"}
    //         },
    //         "hospitals": [
    //           {
    //             "serial": "cfc928a7-bfd1-42c0-96f7-91d50ae52733",
    //             "name": "RS HERMINA KEMAYORAN (ICT HEALTH DEMO 1)",
    //             "latitude": -6.2439287,
    //             "offset7": 0,
    //             "timezone": "WIB",
    //             "longitude": 106.6283291,
    //             "keys": {"telehealID": "13041", "astraID": "102"},
    //             "createdAt": "2023-11-16T07:30:02.630Z",
    //             "createdBy": null,
    //             "updatedAt": "2023-11-30T09:09:58.163Z",
    //             "updatedBy": null,
    //             "content": null
    //           }
    //         ],
    //         "specialistSerial": null,
    //         "specialist": null,
    //         "content": null
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => DoctorResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _hospitalApi.doctors(request);
  }

  Future<Result<DoctorResponse>> doctorBySerial(SerialRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     DoctorResponse.fromJson({
    //       "serial": "string",
    //       "name": "dr. Leon Gerald, SpPD",
    //       "specialist": {
    //         "serial": "string",
    //         "name": "Internal Medicine - Internist"
    //       },
    //       "hospitals": [
    //         {"serial": "1", "name": "RSH Kemayoran"},
    //         {"serial": "2", "name": "RSH Podomoro"},
    //         {"serial": "3", "name": "RSH Tangerang"}
    //       ],
    //       "content": {
    //         "pictureURL":
    //             "https://images.unsplash.com/photo-1461988320302-91bde64fc8e4?ixid=2yJhcHBfaWQiOjEyMDd9&&fm=jpg&w=356&h=200&fit=max",
    //         "about":
    //             "dr. Leon Gerald, SpPD is an internal medicine doctor who handles various complaints and health problems in adult and elderly patients. Treatment includes all internal organs. In addition, dr. Leon Gerald, SpPD also treats non-surgical diseases, covering almost the entire human body with various complaints and symptoms.",
    //         "educations": [
    //           {
    //             "doctorSerial": "string",
    //             "year": "2008",
    //             "school": "Pendidikan Kedokteran Umum - Universitas Indonesia"
    //           },
    //           {
    //             "doctorSerial": "string",
    //             "year": "2018",
    //             "school":
    //                 "Pendidikan Spesialis Internal Diseases - Universitas Indonesia"
    //           },
    //         ],
    //       }
    //     }),
    //   ),
    // );

    return _hospitalApi.doctorBySerial(request);
  }

  Future<Result<PaginationWithNearestResponse<HospitalResponse>>> hospitals(
      HospitalListRequest request) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //       PaginationWithNearestResponse<HospitalResponse>.fromJson(
    //     {
    //       "nearest": request.page == 1
    //           ? List.generate(
    //               3,
    //               (index) => {
    //                 "serial": index.toString(),
    //                 "name": "nearest ${index.toString()}"
    //               },
    //             ).toList()
    //           : [],
    //       "data": List.generate(
    //         20,
    //         (index) => {
    //           "serial":
    //               ((request.page * request.pageSize) - request.pageSize + index)
    //                   .toString(),
    //           "name":
    //               "hospital ${((request.page * request.pageSize) - request.pageSize + index).toString()}"
    //         },
    //       ).toList(),
    //       "total": 100,
    //       "currentPage": 1,
    //       "totalPage": 5
    //     },
    //     (eachData) => HospitalResponse.fromJson(
    //       eachData as Map<String, dynamic>,
    //     ),
    //   )),
    // );

    return _hospitalApi.hospitals(request);
  }

  Future<Result<PaginationResponse<SerialNameResponse>>> selectHospitals(
      PaginationRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       20,
    //       (index) => {
    //         "serial":
    //             (request.page * request.pageSize) - request.pageSize + index,
    //         "name":
    //             "hospital ${((request.page * request.pageSize) - request.pageSize + index).toString()}"
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => SerialNameResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _hospitalApi.selectHospitals(request);
  }

  Future<Result<PaginationResponse<SerialNameResponse>>> selectSpecialists(
      PaginationRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       20,
    //       (index) => {
    //         "serial": index.toString(),
    //         "name": "specialist ${index.toString()}"
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => SerialNameResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _hospitalApi.selectSpecialist(request);
  }

  Future<Result<PaginationWithNearestResponse<LocationResponse>>> locations(
      LocationListRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //       PaginationWithNearestResponse<LocationResponse>.fromJson(
    //     {
    //       "nearest": [
    //         {
    //           "serial": "f823e573-7816-424d-b4f8-90cde378de40",
    //           "name": "Jakarta",
    //           "createdAt": "2023-11-29T06:23:19.386Z",
    //           "createdBy": "e33453e5-c865-4f37-af9d-ba975f5dfa7a",
    //           "updatedAt": "2023-11-29T06:23:19.386Z",
    //           "updatedBy": "e33453e5-c865-4f37-af9d-ba975f5dfa7a",
    //           "hospitals": [
    //             {
    //               "serial": "bae07091-e522-4503-80df-c6bab19d40b5",
    //               "name": "RS HERMINA GRAND WISATA",
    //               "latitude": -6.2515754,
    //               "offset7": 0,
    //               "timezone": "WIB",
    //               "longitude": 106.6090020,
    //               "keys": {"telehealID": "53566", "astraID": "112"},
    //               "createdAt": "2023-11-16T07:30:02.630Z",
    //               "createdBy": null,
    //               "updatedAt": "2024-01-12T07:14:41.861Z",
    //               "updatedBy": null,
    //               "content": null
    //             },
    //             {
    //               "serial": "cfc928a7-bfd1-42c0-96f7-91d50ae52733",
    //               "name": "RS HERMINA KEMAYORAN (ICT HEALTH DEMO 1)",
    //               "latitude": -6.2439287,
    //               "offset7": 0,
    //               "timezone": "WIB",
    //               "longitude": 106.6283291,
    //               "keys": {"telehealID": "13041", "astraID": "102"},
    //               "createdAt": "2023-11-16T07:30:02.630Z",
    //               "createdBy": null,
    //               "updatedAt": "2023-11-30T09:09:58.163Z",
    //               "updatedBy": null,
    //               "content": null
    //             }
    //           ]
    //         }
    //       ],
    //       "data": [
    //         {
    //           "serial": "53ac11e4-15f5-4199-9ce2-f5f613ec5eeb",
    //           "name": "Makassar",
    //           "createdAt": "2023-12-01T03:21:01.636Z",
    //           "createdBy": "e33453e5-c865-4f37-af9d-ba975f5dfa7a",
    //           "updatedAt": "2023-12-01T03:21:01.636Z",
    //           "updatedBy": "e33453e5-c865-4f37-af9d-ba975f5dfa7a",
    //           "hospitals": [
    //             {
    //               "serial": "ebed9b4e-111d-4a2a-b929-c99e456ec2bb",
    //               "name": "RS HERMINA MAKASSAR",
    //               "latitude": -5.1635933,
    //               "offset7": 0,
    //               "timezone": "WIB",
    //               "longitude": 119.4581200,
    //               "keys": {"telehealID": "55159", "astraID": "124"},
    //               "createdAt": "2023-11-16T07:30:02.630Z",
    //               "createdBy": null,
    //               "updatedAt": "2024-01-12T07:11:30.506Z",
    //               "updatedBy": null,
    //               "content": null
    //             }
    //           ]
    //         },
    //         {
    //           "serial": "d2dbae84-cc6f-4dab-bc50-112768763e43",
    //           "name": "Bekasi",
    //           "createdAt": "2023-12-01T03:20:38.897Z",
    //           "createdBy": "e33453e5-c865-4f37-af9d-ba975f5dfa7a",
    //           "updatedAt": "2023-12-01T03:20:38.897Z",
    //           "updatedBy": "e33453e5-c865-4f37-af9d-ba975f5dfa7a",
    //           "hospitals": [
    //             {
    //               "serial": "c771c99d-28f4-479d-8ca3-b11438f8386f",
    //               "name": "RS HERMINA BEKASI",
    //               "latitude": -6.2404898,
    //               "offset7": 0,
    //               "timezone": "WIB",
    //               "longitude": 106.6280560,
    //               "keys": {"telehealID": "53565", "astraID": "103"},
    //               "createdAt": "2023-11-16T07:30:02.630Z",
    //               "createdBy": null,
    //               "updatedAt": "2023-11-30T09:09:17.389Z",
    //               "updatedBy": null,
    //               "content": null
    //             }
    //           ]
    //         }
    //       ],
    //       "currentPage": 1,
    //       "total": 2,
    //       "totalPage": 1
    //     },
    //     (eachData) => LocationResponse.fromJson(
    //       eachData as Map<String, dynamic>,
    //     ),
    //   )),
    // );

    return _hospitalApi.locations(request);
  }

  Future<Result<PaginationResponse<DoctorResponse>>> selectDoctors(
      PaginationRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(PaginationResponse.fromJson({
    //     "data": List.generate(
    //       20,
    //       (index) => {
    //         "serial": index.toString(),
    //         "name": "doctor ${index.toString()}"
    //       },
    //     ).toList(),
    //     "total": 100,
    //     "currentPage": 1,
    //     "totalPage": 5
    //   }, (p0) => DoctorResponse.fromJson(p0 as Map<String, dynamic>))),
    // );

    return _hospitalApi.selectDoctors(request);
  }

  Future<Result<List<DoctorScheduleResponse>>> doctorSchedule(
      DoctorScheduleRequest request) {
    // print(request.toJson());
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     List.generate(
    //       7,
    //       (index) => {
    //         "doctorSerial": index.toString(),
    //         "hospitalSerial": "hospital ${index.toString()}",
    //         "day": index + 1
    //       },
    //     ).map((e) => DoctorScheduleResponse.fromJson(e)).toList(),
    //   ),
    // );

    return _hospitalApi.doctorSchedule(request);
  }

  Future<Result<List<DoctorHospitalScheduleResponse>>> doctorHospitalSchedule(
      SerialRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     List.generate(
    //       3,
    //       (index) => {
    //         "serial": (index + 1).toString(),
    //         "name": "Hospital ${(index + 1).toString()}",
    //         "schedules": [
    //           {
    //             "doctorSerial": "string",
    //             "hospitalSerial": "string",
    //             "day": 1,
    //             "timeFrom": "08:00",
    //             "timeTo": "10:00"
    //           },
    //           {
    //             "doctorSerial": "string",
    //             "hospitalSerial": "string",
    //             "day": 1,
    //             "timeFrom": "11:00",
    //             "timeTo": "12:00"
    //           },
    //           {
    //             "doctorSerial": "string",
    //             "hospitalSerial": "string",
    //             "day": Random().nextInt(7),
    //             "timeFrom": "08:00",
    //             "timeTo": "10:00"
    //           },
    //         ]
    //       },
    //     ).map((e) => DoctorHospitalScheduleResponse.fromJson(e)).toList(),
    //   ),
    // );

    return _hospitalApi.doctorHospitalSchedule(request);
  }

  Future<Result<DoctorHospitalSlotResponse>> doctorHospitalSlot(
      DoctorHospitalSlotRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     DoctorHospitalSlotResponse.fromJson({
    //       "times": ['08:00', '09:00', '10:00', '11:00'],
    //     }),
    //   ),
    // );

    return _hospitalApi.doctorHospitalSlot(request);
  }

  Future<Result<DoctorPriceResponse>> doctorPrice(DoctorPriceRequest request) {
    // return Future.delayed(
    //   const Duration(seconds: 1),
    //   () => Result.success(
    //     DoctorPriceResponse.fromJson({
    //       "price": 250000,
    //     }),
    //   ),
    // );

    return _hospitalApi.doctorPrice(request);
  }
}

final hospitalRepositoryProvider =
    Provider.autoDispose<HospitalRepository>((ref) {
  return HospitalRepository(
    ref.read(hospitalApiProvider),
  );
});
