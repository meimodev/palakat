import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/features/food_menu_request/presentations/food_menu_request_history/widgets/widgets.dart';

class MenuListRadioGroupWidget extends StatefulWidget {
  const MenuListRadioGroupWidget({
    super.key,
    required this.menus,
    required this.onChangedRadioValue,
    required this.title,
    required this.subTitle,
    this.initialValue,
  });

  final List<Map<String, dynamic>> menus;
  final void Function(String value) onChangedRadioValue;
  final String title;
  final String subTitle;
  final String? initialValue;

  @override
  State<MenuListRadioGroupWidget> createState() =>
      _MenuListRadioGroupWidgetState();
}

class _MenuListRadioGroupWidgetState extends State<MenuListRadioGroupWidget> {
  String selectedMenu = "";

  @override
  void initState() {
    super.initState();
    final initVal = widget.initialValue ?? "";
    if (initVal.isNotEmpty) {
      safeSetState(() => selectedMenu = initVal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.title,
          style: TypographyTheme.textMSemiBold.toNeutral60,
        ),
        Gap.customGapHeight(6),
        Text(
          widget.subTitle,
          style: TypographyTheme.textSRegular.toNeutral50,
        ),
        Gap.h16,
        for (int i = 0; i < widget.menus.length; i++)
          FoodMenuRequestMealItemCard<String>(
            marginTop: i == 0 ? const SizedBox() : Gap.customGapHeight(12),
            title: widget.menus[i]['package'],
            imageUrl: widget.menus[i]['image'],
            description: widget.menus[i]['descriptions'],
            onPressedCard: () {
              final value = widget.menus[i]['package'];
              setState(() => selectedMenu = value);
              widget.onChangedRadioValue(value);
            },
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.customWidth(16),
              vertical: BaseSize.customHeight(16),
            ),
            useRadio: true,
            groupValue: selectedMenu,
            identifierValue: widget.menus[i]['package'],
            onChangedValue: (value) {
              setState(() => selectedMenu = value);
              widget.onChangedRadioValue(value);
            },
          ),
      ],
    );
  }
}
