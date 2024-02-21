import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class ProfileItemWrapperWidget extends StatelessWidget {
  const ProfileItemWrapperWidget({
    Key? key,
    required this.hospital,
    required this.schedules,
    this.first = false,
    required this.onPressedBookAppointment,
  }) : super(key: key);

  final String hospital;
  final List<Map<String, dynamic>> schedules;
  final bool first;
  final void Function() onPressedBookAppointment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 0 : BaseSize.h40),
      child: ExpandablePanel(
        controller: ExpandableController(initialExpanded: true),
        theme: const ExpandableThemeData(
          headerAlignment: ExpandablePanelHeaderAlignment.center,
          tapBodyToCollapse: true,
          hasIcon: true,
          useInkWell: false,
        ),
        header: Text(
          hospital,
          style: TypographyTheme.textMSemiBold.toSecondary2,
        ),
        collapsed: const SizedBox(),
        expanded: Column(
          children: [
            Gap.h16,
            ..._buildSchedules(),
            ButtonWidget.primary(
              text: LocaleKeys.text_bookAppointment.tr(),
              onTap: onPressedBookAppointment,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSchedules() {
    return schedules.map((schedule) {
      List<String> times = List.of(schedule["times"]);
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule["day"],
                style: TypographyTheme.textMRegular.toNeutral70,
              ),
              Column(
                children: times.map((time) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: times.length > 1 ? BaseSize.h8 : 0,
                    ),
                    child: Text(
                      time,
                      style: TypographyTheme.textMRegular.toNeutral70,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Gap.h16,
          Divider(
            color: BaseColor.neutral.shade10,
          ),
        ],
      );
    }).toList();
  }
}
