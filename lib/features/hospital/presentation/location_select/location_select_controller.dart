import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/network/network.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationSelectController extends StateNotifier<LocationSelectState> {
  LocationSelectController(this.hospitalService)
      : super(const LocationSelectState());
  final HospitalService hospitalService;
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));
  final searchController = TextEditingController();

  String get search => searchController.text;

  void init() async {
    state = state.copyWith(
      initScreen: true,
    );

    await setPosition();
    getData(isRefresh: true);
  }

  void clearSearch() {
    searchController.text = '';
    getData(isRefresh: true);
  }

  void onSearchChange(String val) {
    debounce.dispose();
    debounce.call(() {
      getData(isRefresh: true);
    });
  }

  Future handleRefresh() async {
    await setPosition();
    await getData(isRefresh: true, withLoading: false);
  }

  Future setPosition() async {
    final permissionGranted = await PermissionUtil.request(
      Permission.locationWhenInUse,
    );

    if (!permissionGranted) {
      return;
    }

    final position = await MapsUtil.currentPosition();

    state = state.copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  Future handleGetMore() async {
    if (state.hasMore) {
      state = state.copyWith(
        page: state.page + 1,
      );

      await getData(withLoading: false);
    }
  }

  Future<void> getData({
    bool isRefresh = false,
    bool withLoading = true,
  }) async {
    if (withLoading) {
      if (isRefresh) {
        state = state.copyWith(isLoading: true, page: 1);
      } else {
        state = state.copyWith(isLoading: true);
      }
    } else {
      if (isRefresh) {
        state = state.copyWith(page: 1);
      }
    }

    bool usingParamLocation = state.page == 1;

    final result = await hospitalService.getLocations(
      LocationListRequest(
        page: state.page,
        pageSize: Pagination.pageSize,
        search: searchController.text,
        latitude: usingParamLocation ? state.latitude : null,
        longitude: usingParamLocation ? state.longitude : null,
      ),
    );
    result.when(
      success: (response) {
        state = state.copyWith(
          isLoading: false,
          nearests: usingParamLocation ? response.nearest : state.nearests,
          data: isRefresh ? response.data : [...state.data, ...response.data],
          hasMore: response.totalPage > state.page,
        );

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    debounce.dispose();
  }
}

final locationSelectControllerProvider = StateNotifierProvider.autoDispose<
    LocationSelectController, LocationSelectState>(
  (ref) {
    return LocationSelectController(ref.read(hospitalServiceProvider));
  },
);
