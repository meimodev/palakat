import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/presentation.dart';

String _about =
    "Established in 1996, RS Hermina Kemayoran is strategically located on the business area of Kemayoran, Central Jakarta. The Hospital provides maternity, pediatric and cardiology. Offering personal and quality maternity services, the Hospital has become the preferred women’s and children’s care by surrounding residents in Central Jakarta area. The Hospital has 125 beds, with the products of Hemodialysis and Cath Lab.";

List<String> _facilities = [
  "Cathlab (Cardiac Catheterization and Angiography)",
  "CT Scan",
  "Echocardiography",
  "EEG (Electroencephalography)",
  "Hemodialysis",
];

List<Map<String, dynamic>> _visitedHours = [
  {"title": 'Afternoon', "time": "10:00 - 11:00"},
  {"title": 'Afternoon', "time": "10:00 - 11:00"},
];

class HospitalProfileSegmentWidget extends ConsumerWidget {
  const HospitalProfileSegmentWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(ourHospitalDetailControllerProvider.notifier);
    final state = ref.watch(ourHospitalDetailControllerProvider);

    return Column(
      children: [
        CardWidget(
          icon: Assets.icons.line.hospital3,
          title: LocaleKeys.text_about.tr(),
          content: [
            Text(
              _about,
              style: TypographyTheme.textMRegular.toNeutral60,
            )
          ],
        ),
        Gap.h24,
        CardWidget(
          icon: Assets.icons.line.mapPin,
          title: LocaleKeys.text_location.tr(),
          content: [
            SizedBox(
              height: BaseSize.customHeight(168),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(BaseSize.radiusLg),
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: controller.initialMapsPosition,
                  myLocationEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: (GoogleMapController gmapController) {
                    if (!controller.mapController.isCompleted) {
                      controller.mapController.complete(gmapController);
                    }
                  },
                  markers: state.hospitalLocationMarker,
                  scrollGesturesEnabled: false,
                ),
              ),
            ),
            Gap.h20,
            Text(
              'Hermina Tower, Jl. Selangit B-10 Kavling 4, Kemayoran, Central Jakarta, Indonesia',
              style: TypographyTheme.textMRegular.toNeutral60,
            )
          ],
        ),
        Gap.h24,
        CardWidget(
          icon: Assets.icons.line.hospitalBed,
          title: LocaleKeys.text_facilities.tr(),
          content: [BulletListWidget(list: _facilities)],
        ),
        Gap.h24,
        CardWidget(
          icon: Assets.icons.line.clock,
          title: LocaleKeys.text_visitHours.tr(),
          content: _createVisitedHourContent(),
        ),
        Gap.h24,
        CardWidget(
          icon: Assets.icons.line.phone,
          title: LocaleKeys.text_contactUs.tr(),
          content: [
            _createContactUsItem(
              LocaleKeys.text_phone.tr(),
              '+622128282929',
            ),
            Gap.h20,
            _createContactUsItem(
              LocaleKeys.text_callCenter.tr(),
              '1500 488',
            ),
            Gap.h20,
            _createContactUsItem(
              "Instagram",
              '@rsuherminakemayoran',
            ),
            Gap.h20,
            _createContactUsItem(
              LocaleKeys.text_email.tr(),
              'z@herminahospitals.com',
            ),
            Gap.h20,
          ],
        ),
      ],
    );
  }
}

List<Widget> _createVisitedHourContent() {
  return _visitedHours
      .map(
        (visitedHour) => Container(
          padding: EdgeInsets.only(
            top: _visitedHours.indexOf(visitedHour) == 0 ? 0 : BaseSize.h16,
            bottom:
                _visitedHours.indexOf(visitedHour) == _visitedHours.length - 1
                    ? 0
                    : BaseSize.h16,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: _visitedHours.indexOf(visitedHour) ==
                        _visitedHours.length - 1
                    ? 0
                    : 1,
                color: BaseColor.neutral.shade10,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  visitedHour['title'],
                  style: TypographyTheme.textMRegular.toNeutral60,
                ),
              ),
              Text(
                visitedHour['time'],
                style: TypographyTheme.textMRegular.toNeutral60,
              ),
            ],
          ),
        ),
      )
      .toList();
}

Widget _createContactUsItem(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: TypographyTheme.textMRegular.toNeutral60,
      ),
      Gap.customGapHeight(10),
      Text(
        value,
        style: TypographyTheme.textLRegular.toNeutral80,
      ),
    ],
  );
}
