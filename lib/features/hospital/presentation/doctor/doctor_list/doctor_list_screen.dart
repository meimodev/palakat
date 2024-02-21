import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/model/model.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({
    super.key,
    this.specialist,
    this.location,
    this.doctorName,
  });
  final SerialName? specialist;
  final Location? location;
  final String? doctorName;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  DoctorListController get controller =>
      ref.read(doctorListControllerProvider.notifier);

  @override
  void initState() {
    safeRebuild(
      () => controller.init(
        widget.specialist,
        widget.location,
        widget.doctorName,
      ),
    );
    super.initState();
  }

  void showFilter() {
    controller.onOpenFilter();
    showCustomDialogWidget(
      context,
      isScrollControlled: true,
      title: "Filter",
      hideLeftButton: true,
      btnRightText: LocaleKeys.text_submit.tr(),
      headerActionIcon: Assets.icons.line.rotate.svg(),
      headerActionOnTap: () {
        controller.clearAllFilter();
      },
      onTap: () {
        controller.submitFilter();
        Navigator.pop(context);
      },
      content: const DoctorFilterWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorListControllerProvider);

    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        title: LocaleKeys.text_resultDoctor.tr(),
        actions: [
          GestureDetector(
            onTap: () {
              showFilter();
            },
            child: Assets.icons.line.filter.svg(
              width: BaseSize.w24,
              height: BaseSize.w24,
            ),
          ),
          Gap.w4
        ],
      ),
      child: Column(
        children: [
          if (state.location != null) ...[
            Gap.h12,
            GestureDetector(
              onTap: () {
                showFilter();
              },
              child: Padding(
                padding: horizontalPadding,
                child: Row(
                  children: [
                    Assets.icons.line.mapPin.svg(
                        width: BaseSize.w20,
                        height: BaseSize.w20,
                        colorFilter: BaseColor.primary3.filterSrcIn),
                    Gap.customGapWidth(6),
                    Text(
                      state.location?.name ?? "",
                      style: TypographyTheme.textLSemiBold
                          .fontColor(BaseColor.primary3),
                    )
                  ],
                ),
              ),
            ),
            Gap.h20,
            SizedBox(
              height: BaseSize.h36,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: horizontalPadding,
                separatorBuilder: (_, __) => Gap.customGapWidth(10),
                itemCount: controller.filterHospital.length,
                itemBuilder: (context, index) {
                  final hospital = controller.filterHospital[index];

                  bool isSelected = false;

                  if (hospital.serial == 'all') {
                    isSelected = controller.isAllFilterHospital;
                  } else {
                    isSelected = ((state.hospitals
                                ?.where((element) =>
                                    element.serial == hospital.serial)
                                .isNotEmpty) ??
                            false) &&
                        !controller.isAllFilterHospital;
                  }

                  return ChipsWidget(
                    onTap: () => controller.handleFilterHospital(hospital),
                    title: hospital.name,
                    isSelected: isSelected,
                    size: ChipsSize.small,
                  );
                },
              ),
            )
          ],
          Gap.h8,
          Expanded(
            child: ListBuilderWidget(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: horizontalPadding.add(
                EdgeInsets.symmetric(vertical: BaseSize.h12),
              ),
              data: state.doctors,
              separatorBuilder: (context, index) => Gap.h12,
              isLoading: state.isLoading,
              isLoadingBottom: state.hasMore,
              onEdgeBottom: controller.handleGetMore,
              onRefresh: () async => await controller.handleRefresh(),
              itemBuilder: (context, index, item) {
                return DoctorListItemWidget(
                  name: item.name,
                  onTap: () {
                    context.pushNamed(
                      AppRoute.doctorDetail,
                      extra: RouteParam(
                        params: {
                          RouteParamKey.serial: item.serial,
                        },
                      ),
                    );
                  },
                  hospitals: item.hospitals.map((e) => e.name).toList(),
                  specialist: item.specialist?.name,
                  image: item.content?.pictureURL ?? "",
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
