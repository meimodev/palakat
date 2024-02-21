import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'widgets.dart';

class PatientPortalListActiveHistoryPatientDropdownWidget
    extends StatefulWidget {
  const PatientPortalListActiveHistoryPatientDropdownWidget({
    super.key,
    required this.onTapSubmit,
    required this.patientList,
  });

  final Function(int selectedPatientListIndex) onTapSubmit;
  final List<Map<String, dynamic>> patientList;

  @override
  State<PatientPortalListActiveHistoryPatientDropdownWidget> createState() =>
      _PatientPortalListActiveHistoryPatientDropdownWidgetState();
}

class _PatientPortalListActiveHistoryPatientDropdownWidgetState
    extends State<PatientPortalListActiveHistoryPatientDropdownWidget> {
  int selectedIndex = 0;
  String? patientName;

  @override
  void initState() {
    super.initState();
    patientName = widget.patientList[selectedIndex]["name"];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showCustomDialogWidget(
          context,
          isScrollControlled: true,
          title: LocaleKeys.text_profile.tr(),
          hideLeftButton: true,
          btnRightText: LocaleKeys.text_submit.tr(),
          headerActionIcon: Assets.icons.line.rotate.svg(),
          onTap: () {
            setState(() {
              patientName = widget.patientList[selectedIndex]["name"];
            });
            Navigator.pop(context);
            widget.onTapSubmit(selectedIndex);
          },
          content: _BuildBottomSheet(
            patientList: widget.patientList,
            selectedIndex: selectedIndex,
            onTapProfileItem: (int index) {
              selectedIndex = index;
            },
          ),
        );
      },
      child: Row(
        children: [
          Text(
            patientName!,
            style: TypographyTheme.heading3SemiBold.copyWith(
              color: BaseColor.primary4,
            ),
          ),
          Gap.w8,
          Assets.icons.line.chevronDown.svg(
            width: BaseSize.w24,
            height: BaseSize.w24,
            colorFilter: BaseColor.primary4.filterSrcIn,
          ),
        ],
      ),
    );
  }
}

class _BuildBottomSheet extends StatefulWidget {
  const _BuildBottomSheet({
    required this.patientList,
    required this.selectedIndex,
    required this.onTapProfileItem,
  });

  final List<Map<String, dynamic>> patientList;
  final int selectedIndex;
  final void Function(int selectedIndex) onTapProfileItem;

  @override
  State<_BuildBottomSheet> createState() => _BuildBottomSheetState();
}

class _BuildBottomSheetState extends State<_BuildBottomSheet> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      selectedIndex = widget.selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w24),
      shrinkWrap: true,
      itemCount: widget.patientList.length,
      itemBuilder: (context, index) {
        final patient = widget.patientList[index];
        return ListItemCardPatientWidget(
          name: patient["name"],
          gender: patient["gender"],
          dob: patient["dob"],
          activate: selectedIndex == index,
          onTap: () {
            setState(() {
              selectedIndex = index;
            });
            widget.onTapProfileItem(selectedIndex);
          },
        );
      },
    );
  }
}
