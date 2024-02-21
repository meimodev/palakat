import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';

class AppointmentService {
  final AppointmentRepository _appointmentRepository;

  AppointmentService(
    this._appointmentRepository,
  );

  Future<Result<PaginationResponse<Appointment>>> getAppointments(
      AppointmentListRequest request) async {
    final result = await _appointmentRepository.appointments(request);

    return result.when(
      success: (response) => Result.success(
        PaginationResponse<Appointment>.fromJson(
          response.toJson((p0) => p0.toJson()),
          (eachData) => Appointment.fromJson(
            eachData as Map<String, dynamic>,
          ),
        ),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<Appointment>> getAppointmentDoctorBySerial(
      String serial) async {
    final result = await _appointmentRepository.appointmentDoctorBySerial(
      SerialRequest(serial: serial),
    );

    return result.when(
      success: (response) => Result.success(
        Appointment.fromJson(response.toJson()),
      ),
      failure: (e, st) => Result.failure(e, st),
    );
  }

  Future<Result<AppointmentResponse>> create(
    String doctorSerial,
    DateTime date,
    AppointmentGuaranteeType guaranteeType,
    String hospitalSerial,
    String patientSerial,
    String specialistSerial,
    AppointmentType type, {
    String? insuranceCardSerial,
    String? insurancePhotoSerial,
  }) {
    return _appointmentRepository.create(
      AppointmentCreateRequest(
        doctorSerial: doctorSerial,
        date: date,
        guaranteeType: guaranteeType,
        hospitalSerial: hospitalSerial,
        patientSerial: patientSerial,
        specialistSerial: specialistSerial,
        type: type,
        insuranceCardSerial: insuranceCardSerial,
        insurancePhotoSerial: insurancePhotoSerial,
      ),
    );
  }

  Future<Result<SuccessResponse>> reschedule(String serial, DateTime dateTime) {
    return _appointmentRepository.reschedule(
      AppointmentRescheduleRequest(
        serial: serial,
        dateTime: dateTime,
      ),
    );
  }

  Future<Result<SuccessResponse>> cancel(String serial, String reason) {
    return _appointmentRepository.cancel(
      AppointmentCancelRequest(serial: serial, reason: reason),
    );
  }

  Future<Result<SuccessResponse>> manage(String serial) {
    return _appointmentRepository.manage(
      SerialRequest(serial: serial),
    );
  }

  Future<Result<PaginationResponse<SerialName>>> selectAppointmentTypes(
      PaginationRequest request) async {
    final result = await _appointmentRepository.selectAppointmentTypes(request);

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
}

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  final appointment = ref.read(appointmentRepositoryProvider);
  return AppointmentService(appointment);
});
