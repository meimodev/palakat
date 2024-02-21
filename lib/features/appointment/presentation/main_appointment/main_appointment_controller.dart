import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:permission_handler/permission_handler.dart' as p;
import 'package:url_launcher/url_launcher.dart';

class MainAppointmentController extends StateNotifier<MainAppointmentState> {
  MainAppointmentController(
    this.authService,
    this.appointmentService,
    this.selfCheckinService,
    this.sharedService,
  ) : super(const MainAppointmentState()) {
    if (isLoggedIn) {
      init();
    }
  }
  final AuthenticationService authService;
  final AppointmentService appointmentService;
  final SelfCheckinService selfCheckinService;
  final SharedService sharedService;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  final searchDebouncer = Debounce(const Duration(milliseconds: 200));
  final TextEditingController searchController = TextEditingController();
  final TextEditingController cancelReasonController = TextEditingController();

  bool get isLoggedIn => authService.isLoggedIn;
  String get cancelReasonText => cancelReasonController.text;
  String get searchText => searchController.text;
  bool get errorGps =>
      !state.isGpsEnabled ||
      state.currentLatitude == null ||
      state.currentLongitude == null;

  List<String> get doctorSerials =>
      state.doctors.map<String>((e) => e.toJson()['serial']).toList();
  List<String> get serviceSerials =>
      state.services.map<String>((e) => e.toJson()['serial']).toList();
  List<String> get hospitalSerials =>
      state.hospitals.map<String>((e) => e.toJson()['serial']).toList();
  List<String> get patientSerials =>
      state.patients.map<String>((e) => e.toJson()['serial']).toList();
  List<String> get specialistSerials =>
      state.specialists.map<String>((e) => e.toJson()['serial']).toList();

  void init() {
    if (state.selectedFilter == FilterTab.active) {
      getAppointmentActive();
      getAppointmentUpcoming(isRefresh: true);
    } else {
      getAppointmentPast(isRefresh: true);
    }
  }

  Future initLocation() async {
    final permissionGranted = await PermissionUtil.request(
      p.Permission.locationWhenInUse,
    );

    if (!permissionGranted) {
      return;
    }

    toggleLocationService();
  }

  Future toggleLocationService() async {
    final serviceStatusStream = MapsUtil.getStreamLocationService();

    bool isLocationActive = await MapsUtil.getLocationService();
    state = state.copyWith(isGpsEnabled: isLocationActive);

    if (isLocationActive) {
      toggleListeningPosition();
    }

    _serviceStatusStreamSubscription = serviceStatusStream.handleError((error) {
      _serviceStatusStreamSubscription?.cancel();
      _serviceStatusStreamSubscription = null;
      log(error);
    }).listen((serviceStatus) {
      if (serviceStatus == ServiceStatus.enabled) {
        state = state.copyWith(isGpsEnabled: true);
        toggleListeningPosition();
        log("gps: enabled");
      } else {
        if (_positionStreamSubscription != null) {
          _positionStreamSubscription?.cancel();
          _positionStreamSubscription = null;
        }
        log("gps: disabled");

        state = state.copyWith(isGpsEnabled: false);
      }
    });
  }

  void toggleListeningPosition() {
    if (_positionStreamSubscription == null) {
      final positionStream = MapsUtil.getStreamCurrentPosition();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) {
        log(position.toString());
        state = state.copyWith(
          currentLatitude: position.latitude,
          currentLongitude: position.longitude,
        );
      });
      _positionStreamSubscription?.pause();
    }

    if (_positionStreamSubscription == null) {
      return;
    }

    if (_positionStreamSubscription!.isPaused) {
      _positionStreamSubscription!.resume();
    } else {
      _positionStreamSubscription!.pause();
    }
  }

  bool checkInRadius(Appointment appointment) {
    return MapsUtil.inRadius(
      startLatitude: state.currentLatitude ?? 0,
      startLongitude: state.currentLongitude ?? 0,
      endLatitude: appointment.hospital?.latitude ?? 0,
      endLongitude: appointment.hospital?.longitude ?? 0,
      radiusInMeter: sharedService.getFeatureSetRadius(),
    );
  }

  void handleSelfCheckin(String serial, BuildContext context) async {
    state = state.copyWith(isLoadingSelfCheckin: true);

    final result = await selfCheckinService.selfCheckin(serial);

    result.when(
      success: (data) async {
        state = state.copyWith(isLoadingSelfCheckin: false);

        getAppointmentActive(withLoading: true);

        await showSelfCheckinDialogWidget(
          context: context,
          onPressedConfirm: () {
            context.pushNamed(AppRoute.selfCheckInConsultationVirtualQueue);
          },
          queueNumber: data.queueNumber.toString(),
          patientName: data.patient?.name ?? "",
          doctorName: data.doctor?.name ?? "",
          medicalRecordNumber: data.patient?.mrn ?? "",
        );
      },
      failure: (error, _) {
        state = state.copyWith(isLoadingSelfCheckin: false);

        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }

  void setSelectedFilter(FilterTab newValue) {
    if (newValue != state.selectedFilter) {
      state = state.copyWith(
        selectedFilter: newValue,
        searching: false,
      );

      searchController.clear();

      if (newValue == FilterTab.active) {
        getAppointmentActive();
        getAppointmentUpcoming(isRefresh: true);
      } else {
        getAppointmentPast(isRefresh: true);
      }
    }
  }

  void onOpenFilter() {
    state = state.copyWith(
      tempPatients: state.patients,
      tempDoctors: state.doctors,
      tempHospitals: state.hospitals,
      tempServices: state.services,
      tempSpecialists: state.specialists,
    );
  }

  void clearAllFilter() {
    state = state.copyWith(
      tempPatients: [],
      tempDoctors: [],
      tempHospitals: [],
      tempServices: [],
      tempSpecialists: [],
    );

    submitFilter();
  }

  void setSelectedServices(List<SerialName> values) {
    state = state.copyWith(tempServices: values);
  }

  void onRemoveService(SerialName value) {
    state = state.copyWith(
      tempServices: state.tempServices
          .where((element) => element.serial != value.serial)
          .toList(),
    );
  }

  void setSelectedDoctors(List<Doctor> values) {
    state = state.copyWith(tempDoctors: values);
  }

  void onRemoveDoctor(Doctor value) {
    state = state.copyWith(
      tempDoctors: state.tempDoctors
          .where((element) => element.serial != value.serial)
          .toList(),
    );
  }

  void setSelectedSpecialists(List<SerialName> values) {
    state = state.copyWith(tempSpecialists: values);
  }

  void onRemoveSpecialist(SerialName value) {
    state = state.copyWith(
      tempSpecialists: state.tempSpecialists
          .where((element) => element.serial != value.serial)
          .toList(),
    );
  }

  void setSelectedHospital(List<Hospital> values) {
    state = state.copyWith(tempHospitals: values);
  }

  void onRemoveHospital(Hospital value) {
    state = state.copyWith(
      tempHospitals: state.tempHospitals
          .where((element) => element.serial != value.serial)
          .toList(),
    );
  }

  void setSelectedPatient(List<SerialName> values) {
    state = state.copyWith(tempPatients: values);
  }

  void onRemovePatient(SerialName value) {
    state = state.copyWith(
      tempPatients: state.tempPatients
          .where((element) => element.serial != value.serial)
          .toList(),
    );
  }

  void submitFilter() {
    state = state.copyWith(
      patients: state.tempPatients,
      doctors: state.tempDoctors,
      hospitals: state.tempHospitals,
      services: state.tempServices,
      specialists: state.tempSpecialists,
      tempPatients: [],
      tempDoctors: [],
      tempHospitals: [],
      tempServices: [],
      tempSpecialists: [],
    );

    if (state.selectedFilter == FilterTab.active) {
      getAppointmentActive();
      getAppointmentUpcoming(isRefresh: true);
    } else {
      getAppointmentPast(isRefresh: true);
    }
  }

  void handleOnSearch() {
    state = state.copyWith(searching: true);
  }

  void handleOnCloseSearch() {
    state = state.copyWith(searching: false);
    searchController.clear();

    if (state.selectedFilter == FilterTab.active) {
      getAppointmentActive();
      getAppointmentUpcoming(isRefresh: true);
    } else {
      getAppointmentPast(isRefresh: true);
    }
  }

  void handleOnChangeSearch(String val) {
    searchDebouncer.dispose();

    searchDebouncer.call(() {
      if (!state.loadingUpcoming &&
          !state.loadingPast &&
          !state.loadingMorePast &&
          !state.loadingMoreUpcoming) {
        if (state.selectedFilter == FilterTab.active) {
          getAppointmentUpcoming(isRefresh: true);
        } else {
          getAppointmentPast(isRefresh: true);
        }
      }
    });
  }

  Future handleRefreshUpcomingTab() async {
    await Future.wait([
      getAppointmentActive(),
      getAppointmentUpcoming(isRefresh: true, withLoading: false),
    ]);
  }

  Future handleGetMoreUpcoming() async {
    if (state.hasMoreUpcomingPage) {
      state = state.copyWith(
        upcomingPage: state.upcomingPage + 1,
      );

      await getAppointmentUpcoming();
    }
  }

  Future handleRefreshPastTab() async {
    await getAppointmentPast(isRefresh: true, withLoading: false);
  }

  Future handleGetMorePast() async {
    if (state.hasMorePastPage) {
      state = state.copyWith(
        pastPage: state.pastPage + 1,
      );

      await getAppointmentPast();
    }
  }

  Future getAppointmentActive({bool withLoading = true}) async {
    if (withLoading) state = state.copyWith(loadingActive: true);

    var result = await appointmentService.getAppointments(
      AppointmentListRequest(
        page: 1,
        pageSize: 10,
        state: AppointmentState.active.name,
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          loadingActive: false,
          activeAppointments: response.data,
        );

        bool hasCanSelfCheckin =
            response.data.where((element) => element.canSelfCheckin).isNotEmpty;

        if (response.data.isNotEmpty && hasCanSelfCheckin) {
          initLocation();
        }

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          loadingActive: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }

  Future getAppointmentPast({
    bool isRefresh = false,
    bool withLoading = true,
  }) async {
    if (withLoading) {
      if (isRefresh) {
        state = state.copyWith(loadingPast: true, pastPage: 1);
      } else {
        state = state.copyWith(loadingMorePast: true);
      }
    }

    var result = await appointmentService.getAppointments(
      AppointmentListRequest(
        page: state.pastPage,
        pageSize: Pagination.pageSize,
        search: searchText,
        state: AppointmentState.past.name,
        doctorSerial: doctorSerials,
        hospitalSerial: hospitalSerials,
        patientSerial: patientSerials,
        specialistSerial: specialistSerials,
        types: serviceSerials,
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          loadingPast: false,
          loadingMorePast: false,
          pastAppointments: isRefresh
              ? response.data
              : [...state.pastAppointments, ...response.data],
          hasMorePastPage: response.totalPage > state.pastPage,
        );

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          loadingPast: false,
          loadingMorePast: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }

  Future getAppointmentUpcoming({
    bool isRefresh = false,
    bool withLoading = true,
  }) async {
    if (withLoading) {
      if (isRefresh) {
        state = state.copyWith(loadingUpcoming: true, upcomingPage: 1);
      } else {
        state = state.copyWith(loadingMoreUpcoming: true);
      }
    }

    var result = await appointmentService.getAppointments(
      AppointmentListRequest(
        page: state.upcomingPage,
        pageSize: Pagination.pageSize,
        search: searchText,
        state: AppointmentState.upcoming.name,
        doctorSerial: doctorSerials,
        hospitalSerial: hospitalSerials,
        patientSerial: patientSerials,
        specialistSerial: specialistSerials,
        types: serviceSerials,
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          loadingUpcoming: false,
          loadingMoreUpcoming: false,
          upcomingAppointments: isRefresh
              ? response.data
              : [...state.upcomingAppointments, ...response.data],
          hasMoreUpcomingPage: response.totalPage > state.upcomingPage,
        );

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          loadingUpcoming: false,
          loadingMoreUpcoming: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }

  void handleCancel(BuildContext context, String serial) async {
    final result = await appointmentService.cancel(
      serial,
      cancelReasonText,
    );

    result.when(
      success: (data) {
        cancelReasonController.clear();
        context.pop();

        if (state.selectedFilter == FilterTab.active) {
          getAppointmentActive();
          getAppointmentUpcoming(isRefresh: true);
        } else {
          getAppointmentPast(isRefresh: true);
        }

        showSuccessfullyCancelAppointmentDialog(
          context: context,
          onProceedTap: () {
            context.pop();
          },
        );
      },
      failure: (error, _) {
        state = state.copyWith();
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }

  void handleManage(
    AppointmentManageType type,
    String serial,
    String callCenter,
  ) async {
    if (type == AppointmentManageType.personal) {
      return handleManagePersonal(serial);
    } else {
      Uri uri = Uri(scheme: "tel", path: callCenter);
      if (await canLaunchUrl(uri)) {
        launchUrl(uri);
      } else {
        Snackbar.error(
          message: LocaleKeys.text_defaultPhoneAppsIsNotConfigured.tr(),
        );
      }
    }
  }

  void handleManagePersonal(String serial) async {
    state = state.copyWith(
      loadingActive: true,
      loadingUpcoming: true,
    );

    final result = await appointmentService.manage(serial);

    result.when(
      success: (data) {
        getAppointmentActive();
        getAppointmentUpcoming(isRefresh: true);

        Snackbar.success(
          message: LocaleKeys.text_manageAppointmentSuccessful.tr(),
        );
      },
      failure: (error, _) {
        state = state.copyWith(
          loadingActive: false,
          loadingUpcoming: false,
        );
        final message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);
      },
    );
  }

  @override
  void dispose() {
    if (_serviceStatusStreamSubscription != null) {
      _serviceStatusStreamSubscription!.cancel();
      _serviceStatusStreamSubscription = null;
    }

    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }
}

final mainAppointmentControllerProvider = StateNotifierProvider.autoDispose<
    MainAppointmentController, MainAppointmentState>((ref) {
  return MainAppointmentController(
    ref.read(authenticationServiceProvider),
    ref.read(appointmentServiceProvider),
    ref.read(selfCheckinServiceProvider),
    ref.read(sharedServiceProvider),
  );
});
