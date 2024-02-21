import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class HelpAccordionWidget extends StatelessWidget {
  final List<Map<String, dynamic>> data;

  const HelpAccordionWidget({
    super.key,
    required this.data,
  });

  List<AccordionSectionWidget> get _buildSection {
    return data
        .map(
          (e) => AccordionSectionWidget(
            isOpen: false,
            header: Text(
              e['header'],
              style: TypographyTheme.bodyRegular.toNeutral80,
            ),
            content: Text(
              e['content'],
              style: TypographyTheme.textLRegular.toNeutral60,
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AccordionWidget(
      disableScrolling: true,
      maxOpenSections: 1,
      headerBackgroundColor: Colors.transparent,
      headerBackgroundColorOpened: Colors.transparent,
      scaleWhenAnimating: false,
      openAndCloseAnimation: true,
      sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
      sectionClosingHapticFeedback: SectionHapticFeedback.light,
      contentBorderWidth: 0,
      contentBorderColor: Colors.transparent,
      children: _buildSection,
    );
  }
}
