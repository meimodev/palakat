import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/routing/app_routing.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/hospital/domain/doctor.dart';
import 'package:halo_hermina/features/hospital/domain/hospital_list_item.dart';
import 'package:halo_hermina/features/hospital/presentation/hospital/our_hospital_list/widgets/our_hospital_item_widget.dart';
import 'package:halo_hermina/features/presentation.dart';

enum OurHospitalSegment { profile, doctor }

List<Doctor> _doctors = [];

class OurHospitalDetailScreen extends ConsumerStatefulWidget {
  const OurHospitalDetailScreen({Key? key}) : super(key: key);

  @override
  ConsumerState createState() => _OurHospitalDetailScreenState();
}

class _OurHospitalDetailScreenState
    extends ConsumerState<OurHospitalDetailScreen> {
  OurHospitalDetailController get controller =>
      ref.read(ourHospitalDetailControllerProvider.notifier);

  OurHospitalDetailState get state =>
      ref.watch(ourHospitalDetailControllerProvider);

  @override
  void initState() {
    super.initState();
    safeRebuild(() {
      controller.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<OurHospitalSegment, String> ourHospitalSegments = {
      OurHospitalSegment.profile: LocaleKeys.text_profile.tr(),
      OurHospitalSegment.doctor: LocaleKeys.text_doctor.tr(),
    };
    return ScaffoldWidget(
      type: ScaffoldType.normal,
      appBar: AppBarWidget(
        title: LocaleKeys.text_detailHospital.tr(),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: horizontalPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Gap.h20,
            OurHospitalListItemWidget(
              item: HospitalListItem(
                name: "Hermina Kemayoran",
                location: "DKI Jakarta",
                imageUrl:
                    "https://images.unsplash.com/photo-1626315869436-d6781ba69d6e",
                distance: "2.3 Km",
              ),
              imageHeight: 112,
              imageWidth: 112,
              alignCenter: false,
              padding: EdgeInsets.zero,
              onPressedItem: null,
            ),
            Gap.h24,
            SegmentedControlWidget<OurHospitalSegment>(
                value: state.selectedSegment,
                options: ourHospitalSegments,
                onValueChanged: (val) {
                  controller.changeSegment(val);
                }),
            Gap.h16,
            if (state.selectedSegment == OurHospitalSegment.doctor)
              DoctorSegmentWidget(
                doctors: _doctors,
                onPressedDoctorCard: (Doctor doctor) {
                  context.pushNamed(AppRoute.doctorProfile);
                },
              )
            else
              const HospitalProfileSegmentWidget(),
          ],
        ),
      ),
    );
  }
}
