import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

import 'widgets.dart';

class AppointmentActionFilterWidget extends StatelessWidget {
  const AppointmentActionFilterWidget({
    super.key,
    required this.onSubmitFilter,
    required this.onResetFilter,
    required this.onOpenDialog,
  });

  final void Function() onSubmitFilter;
  final void Function() onResetFilter;
  final void Function() onOpenDialog;

  @override
  Widget build(BuildContext context) {
    return RippleTouch(
      borderRadius: BorderRadius.circular(BaseSize.h56),
      onTap: () {
        onOpenDialog();
        showCustomDialogWidget(
          context,
          isScrollControlled: true,
          title: LocaleKeys.text_filter.tr(),
          hideLeftButton: true,
          btnRightText: LocaleKeys.text_submit.tr(),
          headerActionIcon: Assets.icons.line.rotate.svg(),
          headerActionOnTap: () {
            onResetFilter();
          },
          onTap: () {
            onSubmitFilter();
            Navigator.pop(context);
          },
          content: const AppointmentFilterWidget(),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(BaseSize.h8),
        child: Assets.icons.line.filter.svg(
          colorFilter: BaseColor.primary4.filterSrcIn,
        ),
      ),
    );
  }
}
