import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class AppointmentScreen extends ConsumerWidget {
  const AppointmentScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(mainAppointmentControllerProvider.notifier);
    final state = ref.watch(mainAppointmentControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.authGradient,
      appBar: AppBarWidget(
        backgroundColor: Colors.transparent,
        hasLeading: false,
        title: LocaleKeys.text_appointment.tr(),
        titleColor: BaseColor.primary4,
        searching: state.searching,
        height: BaseSize.h72,
        onTapButtonCloseSearch: controller.handleOnCloseSearch,
        onChangedTextSearch: controller.handleOnChangeSearch,
        tecSearch: controller.searchController,
        actions: controller.isLoggedIn
            ? [
                AppointmentActionSearchWidget(
                  onSubmitSearch: controller.handleOnSearch,
                ),
                AppointmentActionFilterWidget(
                  onOpenDialog: () {
                    controller.onOpenFilter();
                  },
                  onResetFilter: () {
                    controller.clearAllFilter();
                    context.pop();
                  },
                  onSubmitFilter: () {
                    controller.submitFilter();
                  },
                )
              ]
            : [],
      ),
      child: controller.isLoggedIn
          ? AppointmentAuthorizedLayoutWidget(
              selectedFilter: state.selectedFilter,
              onValueChanged: (FilterTab value) {
                controller.setSelectedFilter(value);
              },
            )
          : AppointmentUnauthorizedLayoutWidget(
              onTapLoginButton: () {
                context.pushNamed(AppRoute.login);
              },
            ),
    );
  }
}
