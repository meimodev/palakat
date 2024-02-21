import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class CoachmarkDesc extends StatefulWidget {
  const CoachmarkDesc({
    super.key,
    required this.title,
    required this.description,
    required this.skip,
    required this.next,
    required this.step,
    this.onSkip,
    this.onNext,
  });

  final String title;
  final String description;
  final String skip;
  final String next;
  final String step;
  final void Function()? onSkip;
  final void Function()? onNext;

  @override
  State<CoachmarkDesc> createState() => _CoachmarkDescState();
}

class _CoachmarkDescState extends State<CoachmarkDesc>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: TypographyTheme.textSSemiBold
                .fontColor(BaseColor.neutral.shade80),
          ),
          const SizedBox(height: 16),
          Text(
            widget.description,
            style: TypographyTheme.textSRegular
                .fontColor(BaseColor.neutral.shade50),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.step,
                style:
                    TypographyTheme.textSRegular.fontColor(BaseColor.primary3),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ButtonWidget.text(
                    textColor: BaseColor.neutral.shade50,
                    text: widget.skip,
                    buttonSize: ButtonSize.small,
                    onTap: widget.onSkip,
                  ),
                  const SizedBox(width: 16),
                  ButtonWidget.primary(
                    isShrink: true,
                    text: widget.next,
                    buttonSize: ButtonSize.small,
                    onTap: widget.onNext,
                  ),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
