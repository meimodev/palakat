import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class QuestionnaireWidget extends StatelessWidget {
  const QuestionnaireWidget({
    super.key,
    required this.options,
    required this.onValueChanged,
    required this.text,
    required this.index,
    this.value,
  });

  final Map<bool, String> options;
  final void Function(bool value) onValueChanged;
  final String text;
  final int index;
  final bool? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        index == 0 ? const SizedBox() : Gap.h20,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${index + 1}.",
              style: TypographyTheme.bodyRegular.toNeutral80,
            ),
            Gap.w4,
            Expanded(
              child: Text(
                text,
                style: TypographyTheme.bodyRegular.toNeutral80,
              ),
            ),
          ],
        ),
        Gap.h16,
        SegmentedSelectWidget<bool>(
          value: value,
          options: options,
          onValueChanged: onValueChanged,
        ),
      ],
    );
  }
}
