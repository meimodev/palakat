import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';

class ListItemExpandableCardWidget extends StatelessWidget {
  const ListItemExpandableCardWidget({
    super.key,
    required this.title,
    required this.contents,
  });

  final String title;
  final List<Map<String, dynamic>> contents;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        scrollOnExpand: false,
        scrollOnCollapse: false,
        child: ExpandablePanel(
          theme: const ExpandableThemeData(
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            tapBodyToCollapse: true,
            hasIcon: true,
            useInkWell: false,
          ),
          header: Text(
            title,
            style: TypographyTheme.textLRegular.toNeutral80,
          ),
          collapsed: Column(
            children: [
              Gap.h20,
              Divider(color: BaseColor.neutral.shade10),
            ],
          ),
          expanded: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < contents.length; i++)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    i == 0
                        ? Divider(color: BaseColor.neutral.shade10)
                        : const SizedBox(),
                    i == 0 ? Gap.h20 : const SizedBox(),
                    Text(
                      contents[i]["title"],
                      style: TypographyTheme.textLRegular.toNeutral80.copyWith(
                          color: contents[i]["important"] ?? false
                              ? BaseColor.error
                              : null),
                    ),
                    Gap.h4,
                    Text(
                      contents[i]["value"],
                      style: TypographyTheme.textMRegular.toNeutral60,
                    ),
                    Text(
                      contents[i]["reference"],
                      style: TypographyTheme.textMRegular.toNeutral60,
                    ),
                    Gap.h20,
                    Divider(color: BaseColor.neutral.shade10),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
