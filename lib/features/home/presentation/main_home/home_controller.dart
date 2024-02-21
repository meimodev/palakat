import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:permission_handler/permission_handler.dart' as p;

class HomeController extends StateNotifier<HomeState> {
  HomeController(
    this.appointmentService,
    this.selfCheckinService,
    this.sharedService,
    this.authService,
  ) : super(const HomeState());

  final AppointmentService appointmentService;
  final SelfCheckinService selfCheckinService;
  final SharedService sharedService;
  final AuthenticationService authService;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;

  final itemKey = GlobalKey();
  final scrollController = ScrollController();

  bool get errorGps =>
      !state.isGpsEnabled ||
      state.currentLatitude == null ||
      state.currentLongitude == null;

  void init() {
    if (authService.isLoggedIn) {
      getTodayAppointments(isRefresh: true);
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

  Future handleRefresh() async {
    if (authService.isLoggedIn) {
      await getTodayAppointments(isRefresh: true);
    }
    //
  }

  Future getTodayAppointments({bool isRefresh = true}) async {
    state = state.copyWith(isLoadingAppointment: true);

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
          isLoadingAppointment: false,
          todayAppointments: response.data,
        );

        bool hasCanSelfCheckin =
            response.data.where((element) => element.canSelfCheckin).isNotEmpty;

        if (response.data.isNotEmpty && hasCanSelfCheckin && isRefresh) {
          initLocation();
        }

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoadingAppointment: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
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

        getTodayAppointments(isRefresh: false);

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

    scrollController.dispose();

    super.dispose();
  }
}

final homeControllerProvider =
    StateNotifierProvider.autoDispose<HomeController, HomeState>((ref) {
  return HomeController(
    ref.read(appointmentServiceProvider),
    ref.read(selfCheckinServiceProvider),
    ref.read(sharedServiceProvider),
    ref.read(authenticationServiceProvider),
  );
});
