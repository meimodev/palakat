import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/datasources/network/network.dart';
import 'package:halo_hermina/core/model/serial_name.dart';
import 'package:halo_hermina/core/utils/debounce.dart';
import 'package:halo_hermina/features/application.dart';
import 'package:halo_hermina/features/presentation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AppointmentTypeSelectController
    extends StateNotifier<AppointmentTypeSelectState> {
  AppointmentTypeSelectController(this.appointmentService)
      : super(
          AppointmentTypeSelectState(),
        );
  final AppointmentService appointmentService;
  final Debounce debounce = Debounce(const Duration(milliseconds: 500));
  final PagingController<int, SerialName> pagingController = PagingController(
    firstPageKey: 1,
  );
  final searchController = TextEditingController();

  String get search => searchController.text;

  void init() async {
    state = state.copyWith(initScreen: true);
    pagingController.addPageRequestListener((pageKey) {
      _loadData(pageKey);
    });
  }

  void clearSearch() {
    searchController.text = '';
    pagingController.refresh();
  }

  void onSearchChange(String val) {
    debounce.dispose();
    debounce.call(() {
      pagingController.refresh();
    });
  }

  Future<void> _loadData(int pageKey) async {
    final result = await appointmentService.selectAppointmentTypes(
      PaginationRequest(
        page: pageKey,
        pageSize: Pagination.pageSize,
        search: search,
      ),
    );
    result.when(
      success: (data) {
        var items = data.data;
        final isLastPage = items.length < Pagination.pageSize;
        if (isLastPage) {
          pagingController.appendLastPage(items);
        } else {
          final nextPageKey = pageKey + 1;
          pagingController.appendPage(items, nextPageKey);
        }
      },
      failure: (error, _) {
        final message = NetworkExceptions.getErrorMessage(error);
        pagingController.error = message;
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    debounce.dispose();
    pagingController.dispose();
  }
}

final appointmentTypeSelectControllerProvider = StateNotifierProvider
    .autoDispose<AppointmentTypeSelectController, AppointmentTypeSelectState>(
  (ref) {
    return AppointmentTypeSelectController(
        ref.read(appointmentServiceProvider));
  },
);
