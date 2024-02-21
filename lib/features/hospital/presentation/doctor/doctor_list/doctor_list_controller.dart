import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/model/model.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/snackbar/snackbar_widget.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/data.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorListController extends StateNotifier<DoctorListState> {
  DoctorListController(this.hospitalService) : super(const DoctorListState()) {
    // DO SOMETHING
  }
  final HospitalService hospitalService;
  final doctorNameController = TextEditingController();
  final specialistController = TextEditingController();
  final locationController = TextEditingController();

  bool get isAllFilterHospital =>
      state.hospitals?.isEqual(state.location?.hospitals ?? []) ?? false;

  List<Hospital> get filterHospital {
    return [
      Hospital(serial: "all", name: LocaleKeys.text_all.tr()),
      ...state.location?.hospitals ?? [],
    ];
  }

  void init(
    SerialName? specialist,
    Location? location,
    String? doctorName,
  ) {
    state = state.copyWith(
      specialist: specialist,
      location: location,
      searchText: doctorName,
      hospitals: location?.hospitals,
    );

    getData(isRefresh: true);
  }

  void onOpenFilter() {
    state = state.copyWith(
      tempSpecialist: state.specialist,
      tempDays: state.days,
      tempHospitals: state.hospitals,
      tempGender: state.gender,
      tempLocation: state.location,
    );

    specialistController.text = state.specialist?.name ?? "";
    locationController.text = state.location?.name ?? "";
    doctorNameController.text = state.searchText ?? "";
  }

  void setSelectedSpecialist(SerialName value) {
    state = state.copyWith(tempSpecialist: value);
    specialistController.text = value.name;
  }

  void setSelectedLocation(Location value) {
    state = state.copyWith(
      tempLocation: value,
      tempHospitals: value.hospitals,
    );
    locationController.text = value.name;
  }

  void setSelectedDay(List<int> values) {
    state = state.copyWith(tempDays: values);
  }

  void onRemoveDay(int value) {
    state = state.copyWith(
      tempDays: state.tempDays.where((element) => element != value).toList(),
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

  void handleFilterHospital(Hospital value) {
    if (value.serial == 'all') {
      state = state.copyWith(hospitals: state.location?.hospitals);
    } else {
      if (isAllFilterHospital) {
        state = state.copyWith(hospitals: [value]);
      } else {
        if (((state.hospitals
                ?.where((element) => element.serial == value.serial)
                .isNotEmpty) ??
            false)) {
          final curr = state.hospitals;
          curr?.removeWhere((element) => element.serial == value.serial);
          state = state.copyWith(hospitals: curr);
        } else {
          state = state.copyWith(hospitals: [...state.hospitals ?? [], value]);
        }
      }
    }

    getData(isRefresh: true, withLoading: true);
  }

  void setGender(String? val) {
    state = state.copyWith(tempGender: val);
  }

  void clearAllFilter() {
    state = state.copyWith(
      tempSpecialist: null,
      tempDays: [],
      tempHospitals: [],
      tempGender: null,
      tempLocation: null,
    );
    doctorNameController.clear();

    submitFilter();
  }

  void submitFilter() {
    state = state.copyWith(
      specialist: state.tempSpecialist,
      days: state.tempDays,
      hospitals: state.tempHospitals,
      gender: state.tempGender,
      location: state.tempLocation,
      searchText: doctorNameController.text,
      tempSpecialist: null,
      tempDays: [],
      tempHospitals: [],
      tempGender: null,
      tempLocation: null,
    );
    locationController.clear();
    specialistController.clear();
    doctorNameController.clear();

    getData();
  }

  Future handleRefresh() async {
    await getData(isRefresh: true, withLoading: false);
  }

  Future handleGetMore() async {
    if (state.hasMore) {
      state = state.copyWith(
        page: state.page + 1,
      );

      await getData(withLoading: false);
    }
  }

  Future getData({
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

    var result = await hospitalService.getDoctors(
      DoctorListRequest(
        page: state.page,
        pageSize: Pagination.pageSize,
        search: state.searchText,
        day: state.days.map((e) => e.toString()).toList(),
        hospitalSerial: state.hospitals?.map((e) => e.serial).toList(),
        specialistSerial:
            state.specialist != null ? [state.specialist!.serial] : null,
        genderSerial: state.gender,
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          isLoading: false,
          doctors:
              isRefresh ? response.data : [...state.doctors, ...response.data],
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
}

final doctorListControllerProvider =
    StateNotifierProvider.autoDispose<DoctorListController, DoctorListState>(
        (ref) {
  return DoctorListController(ref.read(hospitalServiceProvider));
});
