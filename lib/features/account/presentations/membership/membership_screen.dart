import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';

class MembershipScreen extends StatelessWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      persistBottomWidget: Padding(
        padding: EdgeInsets.only(
          bottom: BaseSize.h24,
          left: BaseSize.w12,
          right: BaseSize.w12,
          top: BaseSize.h6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScreenTitleWidget.primary(
            title: "Membership",
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h48,
          InputWidget<Church>.dropdown(
            label: "identify your church membership",
            hint: "Church",
            endIcon: Assets.icons.line.homeOutline,
            onChanged: print,
            optionLabel: (Church option) => option.name,
            onPressedWithResult: () async =>
                await showDialogChurchPickerWidget(context: context),
          ),
          Gap.h12,
          InputWidget.text(
            label: "identify your column number",
            hint: "Column",
            textInputType: TextInputType.number,
            onChanged: (value) {},
          ),
          Gap.h12,
          InputWidget<String>.binaryOption(
            currentInputValue: "Baptis",
            options: const ["Baptis", "Belum Baptis"],
            label: "status baptis anda",
            onChanged: print,
            optionLabel: (String option) => option,
          ),
          Gap.h12,
          InputWidget<String>.binaryOption(
            currentInputValue: "Belum Sidi",
            options: const ["Sidi", "Belum Sidi"],
            label: "status sidi anda",
            onChanged: print,
            optionLabel: (String option) => option,
          ),
          Gap.h24,
          ButtonWidget.primary(
            text: "Submit",
            onTap: () {
              context.goNamed(AppRoute.home);
            },
          ),
        ],
      ),
    );
  }
}
