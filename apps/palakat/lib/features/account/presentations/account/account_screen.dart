import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat_shared/core/extension/date_time_extension.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/account/presentations/account/account_controller.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(accountControllerProvider.notifier);
    final state = ref.watch(accountControllerProvider);

    return ScaffoldWidget(
      loading: state.loading ,
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
            title: "Account",
            leadIcon: Assets.icons.line.chevronBackOutline,
            leadIconColor: Colors.black,
            onPressedLeadIcon: context.pop,
          ),
          Gap.h16,
          Material(
            color: BaseColor.cardBackground1,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            surfaceTintColor: BaseColor.teal[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(BaseSize.w16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: BaseSize.w32,
                        height: BaseSize.w32,
                        decoration: BoxDecoration(
                          color: BaseColor.teal[100],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person_outline,
                          size: BaseSize.w16,
                          color: BaseColor.teal[700],
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Text(
                          "Personal Information",
                          style: BaseTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BaseColor.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap.h16,
                  InputWidget.text(
                    hint: "Phone Number",
                    label: "active phone to receive authentication message",
                    currentInputValue: state.phone,
                    textInputType: TextInputType.number,
                    onChanged: controller.onChangedTextPhone,
                    validators: (val) => state.errorPhone,
                    errorText: state.errorPhone,
                  ),
                  Gap.h12,
                  InputWidget.text(
                    hint: "Full Name",
                    label: "name without degree for your church membership",
                    currentInputValue: state.name,
                    errorText: state.errorName,
                    onChanged: controller.onChangedTextName,
                  ),
                  Gap.h12,
                  InputWidget<DateTime>.dropdown(
                    label: "use to determine your BIPRA membership",
                    hint: "Date Of Birth",
                    currentInputValue: state.dob,
                    errorText: state.errorDob,
                    endIcon: Assets.icons.line.calendarOutline,
                    optionLabel: (DateTime option) => option.ddMmmmYyyy,
                    onChanged: controller.onChangedDOB,
                    onPressedWithResult: () async =>
                        await showDialogDatePickerWidget(context: context),
                  ),
                  Gap.h12,
                  InputWidget<Gender>.binaryOption(
                    label: "use to determine your BIPRA membership",
                    currentInputValue: state.gender,
                    options: Gender.values,
                    onChanged: controller.onChangedGender,
                    errorText: state.errorGender,
                    optionLabel: (Gender option) => option.name,
                  ),
                  Gap.h12,
                  InputWidget<MaritalStatus>.binaryOption(
                    label: "use to determine your BIPRA membership",
                    currentInputValue: state.maritalStatus,
                    options: MaritalStatus.values,
                    onChanged: controller.onChangedMaritalStatus,
                    errorText: state.errorMarried,
                    optionLabel: (MaritalStatus option) => option.name,
                  ),
                ],
              ),
            ),
          ),
          Gap.h16,
          ButtonWidget.primary(
            text: "Submit",
            onTap: () async {
              final success = await controller.submit();
              if (context.mounted) {
                if (!success) {
                  showSnackBar(context, "Please Fill All the field");
                  controller.publish();
                  return;
                }
                context.pushNamed(AppRoute.membership);
              }
            },
          ),
        ],
      ),
    );
  }

  void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
