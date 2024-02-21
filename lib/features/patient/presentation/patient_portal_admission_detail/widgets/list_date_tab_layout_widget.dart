import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

import 'widgets.dart';

class ListDateTabLayoutWidget<T extends Enum> extends StatefulWidget {
  const ListDateTabLayoutWidget({
    super.key,
    required this.lists,
    required this.activeTab,
    required this.tabOptions,
    required this.itemBuilder,
  });

  final List<Map<String, dynamic>> lists;
  final T activeTab;
  final Map<T, String> tabOptions;
  final Widget Function(
    Map<String, dynamic> filteredList,
    T activeTab,
    int i,
  ) itemBuilder;

  @override
  State<ListDateTabLayoutWidget<T>> createState() =>
      _ListDateTabLayoutWidgetState<T>();
}

class _ListDateTabLayoutWidgetState<T extends Enum>
    extends State<ListDateTabLayoutWidget<T>> {
  late T activeTab;

  @override
  void initState() {
    super.initState();
    activeTab = widget.activeTab;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.lists
        .where((element) =>
            element["type"].toString().toLowerCase() ==
            activeTab.name.toLowerCase())
        .toList();

    return Column(
      children: [
        SegmentedControlWidget<T>(
          activeTextStyle: TypographyTheme.textSSemiBold.toPrimary,
          unActiveTextStyle: TypographyTheme.textSRegular.toNeutral60,
          value: activeTab,
          options: widget.tabOptions,
          onValueChanged: (value) {
            setState(() => activeTab = value);
          },
        ),
        filteredList.isEmpty ? const EmptyListLayoutWidget() : const SizedBox(),
        for (int i = 0; i < filteredList.length; i++)
          widget.itemBuilder(filteredList[i], activeTab, i),
        Gap.h24,
      ],
    );
  }
}

