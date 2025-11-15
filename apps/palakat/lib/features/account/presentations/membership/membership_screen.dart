import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart' as model;

class MembershipScreen extends ConsumerWidget {
  const MembershipScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(membershipControllerProvider.notifier);
    final state = ref.watch(membershipControllerProvider);

    return ScaffoldWidget(
      loading: state.loading,
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
          Gap.h16,
          Material(
            color: BaseColor.cardBackground1,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            surfaceTintColor: BaseColor.blue[50],
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
                          color: BaseColor.blue[100],
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.church_outlined,
                          size: BaseSize.w16,
                          color: BaseColor.blue[700],
                        ),
                      ),
                      Gap.w12,
                      Expanded(
                        child: Text(
                          "Church Membership",
                          style: BaseTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BaseColor.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap.h16,
                  InputWidget<model.Church>.dropdown(
                    label: "identify your church membership",
                    hint: "Church",
                    currentInputValue: state.church,
                    errorText: state.errorChurch,
                    endIcon: Assets.icons.line.homeOutline,
                    onChanged: controller.onChangedChurch,
                    optionLabel: (model.Church option) => option.name,
                    onPressedWithResult: () async =>
                        await showDialogChurchPickerWidget(context: context),
                  ),
                  Gap.h12,
                  InputWidget<model.Column>.dropdown(
                    label: "identify your column number",
                    hint: "Column",
                    currentInputValue: state.column,
                    errorText: state.errorColumn,
                    endIcon: Assets.icons.line.homeOutline,
                    onChanged: controller.onChangedColumn,
                    optionLabel: (model.Column option) => option.name,
                    onPressedWithResult: () async =>
                        await showDialogColumnPickerWidget(context: context),
                  ),
                  Gap.h12,
                  InputWidget<bool>.binaryOption(
                    currentInputValue: state.baptize,
                    options: const [true, false],
                    label: "status baptis anda",
                    onChanged: controller.onChangedBaptize,
                    optionLabel: (bool option) => option ? "Baptis" : "Belum Baptis",
                    errorText: state.errorBaptize,
                  ),
                  Gap.h12,
                  InputWidget<bool>.binaryOption(
                    currentInputValue: state.sidi,
                    options: const [true, false],
                    label: "status sidi anda",
                    onChanged: controller.onChangedSidi,
                    optionLabel: (bool option) => option ? "Sidi" : "Belum Sidi",
                    errorText: state.errorSidi,
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
                context.pushNamed(AppRoute.home);
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
