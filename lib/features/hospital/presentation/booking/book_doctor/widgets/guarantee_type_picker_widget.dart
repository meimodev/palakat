import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/localization/localization.dart';
import 'package:halo_hermina/core/utils/extensions/extension.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';
import 'package:halo_hermina/features/domain.dart';
import 'package:halo_hermina/features/presentation.dart';

class GuaranteeTypePickerWidget extends StatefulWidget {
  const GuaranteeTypePickerWidget({
    super.key,
    this.onSelectedGuaranteeType,
    this.selectedType,
  });

  final void Function(AppointmentGuaranteeType? type)? onSelectedGuaranteeType;
  final AppointmentGuaranteeType? selectedType;

  @override
  State<GuaranteeTypePickerWidget> createState() =>
      GuaranteeTypePickerWidgetState();
}

class GuaranteeTypePickerWidgetState extends State<GuaranteeTypePickerWidget> {
  AppointmentGuaranteeType? type;
  bool enable = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      type = widget.selectedType;
      enable = widget.onSelectedGuaranteeType != null;
    });
  }

  @override
  void didUpdateWidget(covariant GuaranteeTypePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    safeRebuild(() {
      if (oldWidget.selectedType != widget.selectedType) {
        setState(() {
          type = widget.selectedType;
        });
      }
    });
  }

  void _handleOnClick(BuildContext context) {
    showModalBottomSheet<dynamic>(
      isScrollControlled: false,
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(BaseSize.customRadius(16)),
        ),
      ),
      builder: (context) {
        return BottomSheetChooseType(
          value: type,
          onSelectedGuaranteeType: (value) {
            setState(() {
              type = value;
            });
            if (widget.onSelectedGuaranteeType != null) {
              widget.onSelectedGuaranteeType!(value);
            }
            context.pop();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.text_guaranteeType.tr(),
          style: TypographyTheme.textMRegular.toNeutral60,
        ),
        Gap.h12,
        InkWell(
          onTap: enable ? () => _handleOnClick(context) : null,
          borderRadius: BorderRadius.circular(BaseSize.radiusLg),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: BaseSize.w16,
              vertical: BaseSize.h20,
            ),
            decoration: BoxDecoration(
              color: enable ? Colors.transparent : BaseColor.neutral.shade20,
              border: Border.all(
                color: BaseColor.neutral.shade20,
              ),
              borderRadius: BorderRadius.circular(BaseSize.radiusLg),
            ),
            child: Center(
              child: Row(
                children: [
                  Expanded(
                    child: type == null
                        ? Text(
                            "${LocaleKeys.text_choose.tr()} ${LocaleKeys.text_guaranteeType.tr()}",
                            style: TypographyTheme.textLSemiBold.toNeutral60,
                          )
                        : Text(
                            type?.label ?? "",
                            style: TypographyTheme.textLSemiBold.copyWith(
                              color: enable
                                  ? BaseColor.neutral.shade80
                                  : BaseColor.neutral.shade50,
                            ),
                          ),
                  ),
                  Assets.icons.line.chevronRight.svg(
                    width: BaseSize.w24,
                    height: BaseSize.h24,
                    colorFilter: enable
                        ? BaseColor.neutral.shade80.filterSrcIn
                        : BaseColor.neutral.shade50.filterSrcIn,
                  ),
                ],
              ),
            ),
          ),
        ),
        Gap.h20,
      ],
    );
  }
}

class BottomSheetChooseType extends StatefulWidget {
  const BottomSheetChooseType({
    super.key,
    required this.onSelectedGuaranteeType,
    this.value,
  });

  final AppointmentGuaranteeType? value;
  final void Function(AppointmentGuaranteeType? type) onSelectedGuaranteeType;

  @override
  State<BottomSheetChooseType> createState() => _BottomSheetChooseTypeState();
}

class _BottomSheetChooseTypeState extends State<BottomSheetChooseType> {
  final options = [
    AppointmentGuaranteeType.personal,
    AppointmentGuaranteeType.insurance,
  ];
  AppointmentGuaranteeType? selected;

  @override
  void initState() {
    setState(() {
      selected = widget.value;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
              child: Center(
                child: Assets.icons.fill.slidePanel.svg(),
              ),
            ),
            Gap.h12,
            Padding(
              padding: horizontalPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    LocaleKeys.text_guaranteeType.tr(),
                    style: TypographyTheme.bodySemiBold.toNeutral80,
                    textAlign: TextAlign.center,
                  ),
                  GestureDetector(
                    child: Assets.icons.line.times.svg(),
                    onTap: () => Navigator.pop(context),
                  )
                ],
              ),
            ),
            Gap.h28,
            Padding(
              padding: horizontalPadding,
              child: Column(
                children: options
                    .map(
                      (e) => Column(
                        children: [
                          GuaranteeTypeCardWidget(
                            label: e.label,
                            isSelected: e == selected,
                            onTap: () {
                              setState(() {
                                selected = e;
                              });
                            },
                          ),
                          if (options.last != e) Gap.h16,
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            Gap.h24,
            Padding(
              padding: horizontalPadding,
              child: ButtonWidget.primary(
                buttonSize: ButtonSize.medium,
                isEnabled: selected != null,
                text: LocaleKeys.text_submit.tr(),
                onTap: () {
                  widget.onSelectedGuaranteeType(selected);
                },
              ),
            ),
            Gap.h20,
          ],
        )
      ],
    );
  }
}
