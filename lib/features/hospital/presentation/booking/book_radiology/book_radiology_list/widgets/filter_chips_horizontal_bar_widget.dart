import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class FilterChipsHorizontalBarWidget extends StatefulWidget {
  const FilterChipsHorizontalBarWidget({
    super.key,
    required this.filters,
    required this.onChangedFilter,
  });

  final List<String> filters;
  final void Function(String? filter) onChangedFilter;

  @override
  State<FilterChipsHorizontalBarWidget> createState() =>
      _FilterChipsHorizontalBarWidgetState();
}

class _FilterChipsHorizontalBarWidgetState
    extends State<FilterChipsHorizontalBarWidget> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.onChangedFilter(null);
  }

  @override
  Widget build(BuildContext context) {
    final filters = [LocaleKeys.text_all.tr(), ...widget.filters];
    return SizedBox(
      height: BaseSize.customHeight(38),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          return Padding(
            padding: EdgeInsets.only(
              left: BaseSize.customWidth(index == 0 ? 0 : 10),
            ),
            child: ChipsWidget(
              title: filter,
              isSelected: selectedIndex == index,
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
                if (selectedIndex == 0) {
                  widget.onChangedFilter(null);
                  return;
                }
                widget.onChangedFilter(filter);
              },
            ),
          );
        },
      ),
    );
  }
}
