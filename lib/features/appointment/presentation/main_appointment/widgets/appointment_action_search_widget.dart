import 'package:flutter/material.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class AppointmentActionSearchWidget extends StatelessWidget {
  const AppointmentActionSearchWidget({
    super.key,
    required this.onSubmitSearch,
  });

  final void Function() onSubmitSearch;

  @override
  Widget build(BuildContext context) {
    return RippleTouch(
      borderRadius: BorderRadius.circular(BaseSize.h56),
      onTap: onSubmitSearch,
      child: Padding(
        padding: EdgeInsets.all(BaseSize.h8),
        child: Assets.icons.line.search.svg(
          colorFilter: BaseColor.primary4.filterSrcIn,
        ),
      ),
    );
  }
}
