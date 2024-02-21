import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

class PatientListScreen extends ConsumerStatefulWidget {
  const PatientListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PatientListScreenState();
}

class _PatientListScreenState extends ConsumerState<PatientListScreen> {
  PatientListController get controller =>
      ref.read(patientListControllerProvider(context).notifier);

  @override
  void initState() {
    safeRebuild(() => controller.init());
    super.initState();
  }

  Widget _emptyWidget() {
    return Padding(
      padding: horizontalPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.images.accountAdd.image(
            width: BaseSize.customHeight(100),
            height: BaseSize.customHeight(100),
          ),
          Gap.h16,
          Text(
            LocaleKeys.text_noPatientAdded.tr(),
            style: TypographyTheme.textLBold.toNeutral80,
          ),
          Gap.h12,
          Text(
            "${LocaleKeys.text_patientHaveNotBeenAddedYet.tr()} ${LocaleKeys.text_youCanAddMoreThanOnePatientList.tr()}",
            style: TypographyTheme.textSRegular.toNeutral60,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(patientListControllerProvider(context));

    return ScaffoldWidget(
      appBar: AppBarWidget(
        title: LocaleKeys.text_patientList.tr(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: !state.isLoading && state.patients.isEmpty
                ? _emptyWidget()
                : ListBuilderWidget(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: horizontalPadding.add(
                      EdgeInsets.only(top: BaseSize.h12),
                    ),
                    data: state.patients,
                    separatorBuilder: (context, index) => Gap.h16,
                    isLoading: state.isLoading,
                    isLoadingBottom: state.hasMore,
                    onEdgeBottom: controller.handleGetMore,
                    onRefresh: () async => await controller.handleRefresh(),
                    itemBuilder: (context, index, item) {
                      return PatientCardWidget(
                        name: item.name,
                        dob: item.dateOfBirth?.ddMmmmYyyy ?? "",
                        phone: item.phone,
                        status: item.status,
                        onTap: () {
                          context.pushNamed(
                            AppRoute.patientDetail,
                            extra: RouteParam(params: {
                              RouteParamKey.serial: item.serial,
                            }),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: horizontalPadding.add(
              EdgeInsets.symmetric(vertical: BaseSize.h12),
            ),
            child: ButtonWidget.primary(
              text: LocaleKeys.prefix_addNew.tr(namedArgs: {
                "value": LocaleKeys.text_patient.tr(),
              }),
              onTap: () async {
                await context.pushNamed(
                  AppRoute.patientForm,
                  extra: const RouteParam(
                    params: {
                      RouteParamKey.formType: FormType.add,
                    },
                  ),
                );

                if (context.mounted) controller.getData(isRefresh: true);
              },
            ),
          ),
        ],
      ),
    );
  }
}
