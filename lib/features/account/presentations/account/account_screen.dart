import 'package:flutter/material.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/utils/extensions/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      presistBottomWidget: Padding(
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
            title: "Account",
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h48,
           InputWidget.text(
            hint: "Phone Number",
            label: "active phone to receive authentication message",
            textInputType: TextInputType.number,
            onChanged: print,
            validators: (val) {
              print("validator $val");
            },
          ),
          Gap.h12,
          InputWidget.text(
            hint: "Full Name",
            label: "name without degree for your church membership",
            validators: (p0) {

            },
            onChanged: print,
          ),
          Gap.h12,
          InputWidget.dropdown(
            label: "use to determine your BIPRA membership",
            hint: "Date Of Birth",
            validators: (p0) {

            },
            endIcon: Assets.icons.line.calendarOutline,
            onPressedWithResult: () async {
              final DateTime? result = await showDialogDatePickerWidget(
                context: context,
              );
              return result?.ddMmmmYyyy;
            },
            onChanged: print,
          ),
          Gap.h12,
          InputWidget.binaryOption(
            label: "use to determine your BIPRA membership",
            currentInputValue: Gender.male.name,
            options: Gender.values.map((e) => e.name).toList(),
            onChanged: print,
            validators: (val) {

            },
          ),
          Gap.h12,
          InputWidget.binaryOption(
            label: "use to determine your BIPRA membership",
            currentInputValue: MaritalStatus.single.name,
            options: MaritalStatus.values.map((e) => e.name).toList(),
            onChanged: print,
          ),
          Gap.h24,
          ButtonWidget.primary(
            text: "Submit",
            onTap: () {
              context.pushNamed(AppRoute.membership);
            },
          )
        ],
      ),
    );
  }
}
