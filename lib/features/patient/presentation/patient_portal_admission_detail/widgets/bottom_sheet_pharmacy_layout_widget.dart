import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';

import 'widgets.dart';

class BottomSheetPharmacyLayoutWidget extends StatelessWidget {
  const BottomSheetPharmacyLayoutWidget({super.key, required this.list});

  final List<Map<String, dynamic>> list;

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return const EmptyListLayoutWidget();
    }

    return Padding(
      padding: horizontalPadding,
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++)
            _buildListItem(
              title: list[i]["title"],
              contents: List<String>.of( list[i]["contents"]) ,
            ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required List<String> contents,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title.toUpperCase(),
          style: TypographyTheme.textLRegular.toNeutral80,
        ),
        for (int i = 0; i < contents.length; i++)
          Text(
            contents[i],
            style: TypographyTheme.textMRegular.toNeutral60,
          ),
        Gap.h40,
      ],
    );
  }
}
