import 'package:flutter/material.dart';
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
        child: ButtonWidget.primary(
          text: "Submit",
          onTap: () {
            context.pushNamed(AppRoute.membership);
          },
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
            onChanged: (value) {
              print(value);
            },
          ),
          Gap.h12,
          InputWidget.text(
            hint: "Full Name",
            label: "name without degree for your church membership",
            onChanged: (value) {
              print(value);
            },
          ),
          Gap.h12,
          InputWidget.dropdown(
            label: "use to determine your BIPRA membership",
            hint: "Date Of Birth",
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
            currentInputValue: "Male",
            options: ["Male", "Female"],
            label: "use to determine your BIPRA membership",
            onChanged: print,
          ),
          Gap.h12,
          InputWidget.binaryOption(
            currentInputValue: "Married",
            options: ["Married", "Not Married"],
            label: "use to determine your BIPRA membership",
            onChanged: print,
          ),
        ],
      ),
    );
  }
}
