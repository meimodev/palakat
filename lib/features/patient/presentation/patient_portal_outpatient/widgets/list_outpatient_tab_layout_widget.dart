import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';


class ListOutPatientTabLayoutWidget<T extends Enum> extends StatefulWidget {
  const ListOutPatientTabLayoutWidget({
    super.key,
    required this.activeTab,
    required this.tabOptions,
    required this.itemBuilder,
  });

  final T activeTab;
  final Map<T, String> tabOptions;
  final Widget Function(T activeTab) itemBuilder;

  @override
  State<ListOutPatientTabLayoutWidget<T>> createState() =>
      _ListOutPatientTabLayoutWidgetState<T>();
}

class _ListOutPatientTabLayoutWidgetState<T extends Enum>
    extends State<ListOutPatientTabLayoutWidget<T>> {
  late T activeTab;

  @override
  void initState() {
    super.initState();
    activeTab = widget.activeTab;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SegmentedControlWidget<T>(
          activeTextStyle: TypographyTheme.textMSemiBold.toPrimary,
          unActiveTextStyle: TypographyTheme.textMRegular.toNeutral60,
          value: activeTab,
          options: widget.tabOptions,
          onValueChanged: (value) {
            setState(() => activeTab = value);
          },
        ),
        Gap.h24,
        widget.itemBuilder(activeTab),
        Gap.h24,
      ],
    );
  }
}
