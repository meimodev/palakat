import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/widgets/widgets.dart';
import 'package:palakat/features/presentation.dart';

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
          Gap.h48,
          InputWidget<Church>.dropdown(
            label: "identify your church membership",
            hint: "Church",
            currentInputValue: state.church,
            errorText: state.errorChurch,
            endIcon: Assets.icons.line.homeOutline,
            onChanged: controller.onChangedChurch,
            optionLabel: (Church option) => option.name,
            onPressedWithResult: () async =>
                await showDialogChurchPickerWidget(context: context),
          ),
          Gap.h12,
          InputWidget.text(
            label: "identify your column number",
            hint: "Column",
            textInputType: TextInputType.number,
            onChanged: controller.onChangedColumn,
            currentInputValue: state.column?.id.toString(),
            errorText: state.errorColumn,
            validators: (val) => state.errorColumn,
          ),
          Gap.h12,
          InputWidget<String>.binaryOption(
            currentInputValue: state.baptize,
            options: const ["Baptis", "Belum Baptis"],
            label: "status baptis anda",
            onChanged: controller.onChangedBaptize,
            optionLabel: (String option) => option,
            errorText: state.errorBaptize,
          ),
          Gap.h12,
          InputWidget<String>.binaryOption(
            currentInputValue: state.sidi,
            options: const ["Sidi", "Belum Sidi"],
            label: "status sidi anda",
            onChanged: controller.onChangedSidi,
            optionLabel: (String option) => option,
            errorText: state.errorSidi,
          ),
          Gap.h24,
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
