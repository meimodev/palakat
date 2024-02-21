import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/pagination/pagination.dart';
import 'package:halo_hermina/core/datasources/datasources.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientListController extends StateNotifier<PatientListState> {
  final BuildContext context;
  final PatientService patientService;

  PatientListController(this.context, this.patientService)
      : super(const PatientListState());

  void init() {
    getData(isRefresh: true);
  }

  Future handleRefresh() async {
    await getData(isRefresh: true, withLoading: false);
  }

  Future handleGetMore() async {
    print("more");
    if (state.hasMore) {
      state = state.copyWith(
        page: state.page + 1,
      );

      await getData();
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
        state = state.copyWith(isLoadingMore: true);
      }
    } else {
      if (isRefresh) {
        state = state.copyWith(page: 1);
      }
    }

    var result = await patientService.getPatientUsers(
      PaginationRequest(
        page: state.page,
        pageSize: Pagination.pageSize,
      ),
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
          patients:
              isRefresh ? response.data : [...state.patients, ...response.data],
          hasMore: response.totalPage > state.page,
        );

        return true;
      },
      failure: (error, _) {
        state = state.copyWith(
          isLoading: false,
          isLoadingMore: false,
        );
        var message = NetworkExceptions.getErrorMessage(error);

        Snackbar.error(message: message);

        return false;
      },
    );
  }
}

final patientListControllerProvider = StateNotifierProvider.family
    .autoDispose<PatientListController, PatientListState, BuildContext>(
  (ref, context) {
    return PatientListController(context, ref.read(patientServiceProvider));
  },
);
