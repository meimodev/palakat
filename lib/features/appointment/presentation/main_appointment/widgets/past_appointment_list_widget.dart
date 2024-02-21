import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class PastAppointmentListWidget extends ConsumerStatefulWidget {
  const PastAppointmentListWidget({super.key});

  @override
  ConsumerState<PastAppointmentListWidget> createState() =>
      _PastAppointmentListWidgetState();
}

class _PastAppointmentListWidgetState
    extends ConsumerState<PastAppointmentListWidget> {
  MainAppointmentController get controller =>
      ref.read(mainAppointmentControllerProvider.notifier);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mainAppointmentControllerProvider);

    if (!state.loadingPast && state.pastAppointments.isEmpty) {
      if (state.searching) {
        return const EmptySearchLayoutWidget();
      } else {
        return LayoutBuilder(
          builder: (context, constraints) => RefreshIndicator(
            onRefresh: () async => await controller.handleRefreshUpcomingTab(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: EmptyAppointment(
                  placeholder: LocaleKeys.text_YouDontHaveAnyHistory.tr(),
                ),
              ),
            ),
          ),
        );
      }
    }

    return ListBuilderWidget<Appointment>(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: horizontalPadding,
      isLoading: state.loadingPast,
      isLoadingBottom: state.hasMorePastPage,
      data: state.pastAppointments,
      onEdgeBottom: controller.handleGetMorePast,
      onRefresh: () async => await controller.handleRefreshPastTab(),
      itemBuilder: (context, index, appointment) {
        return Padding(
          padding: EdgeInsets.only(bottom: BaseSize.h12),
          child: AppointmentCard.past(
            name: appointment.patient?.name ?? "",
            date: appointment.date.dMmmYyyyHhMm,
            hospital: appointment.hospital?.name ?? "",
            doctor: appointment.doctor?.name ?? "",
            specialist: appointment.specialist?.name ?? "",
            onTap: () {
              context.pushNamed(
                AppRoute.appointmentDetail,
                extra: RouteParam(
                  params: {
                    RouteParamKey.serial: appointment.serial,
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
