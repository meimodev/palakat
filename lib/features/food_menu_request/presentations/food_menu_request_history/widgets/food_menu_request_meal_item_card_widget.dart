import 'package:flutter/material.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

class FoodMenuRequestMealItemCard<T> extends StatelessWidget {
  const FoodMenuRequestMealItemCard({
    super.key,
    this.imageUrl = "",
    required this.title,
    required this.description,
    this.header = "",
    this.marginTop,
    this.padding,
    this.onPressedCard,
    this.useRadio = false,
    this.groupValue,
    this.identifierValue,
    this.onChangedValue,
  }) : assert(
            !(useRadio &&
                (groupValue == null ||
                    identifierValue == null ||
                    onChangedValue == null)),
            "if useRadio be true then groupValue, identifierValue, onChangedValue cannot be null");

  final String imageUrl;
  final String title;
  final List<String> description;
  final String header;

  final SizedBox? marginTop;
  final EdgeInsetsGeometry? padding;

  final void Function()? onPressedCard;

  final bool useRadio;
  final T? groupValue;
  final T? identifierValue;
  final void Function(T value)? onChangedValue;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressedCard,
      child: Padding(
        padding: padding ?? EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            marginTop != null
                ? const SizedBox()
                : Divider(
                    thickness: 1,
                    color: BaseColor.neutral.shade10,
                  ),
            marginTop ?? Gap.h16,
            header.isNotEmpty
                ? Text(
                    header,
                    style: TypographyTheme.textMRegular.toNeutral50,
                  )
                : const SizedBox(),
            header.isNotEmpty ? Gap.h12 : const SizedBox(),
            Row(
              children: [
                imageUrl.isEmpty
                    ? const SizedBox()
                    : Container(
                        width: BaseSize.customWidth(80),
                        height: BaseSize.customHeight(80),
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(BaseSize.radiusLg),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                imageUrl.isEmpty ? const SizedBox() : Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        title,
                        style: TypographyTheme.textMSemiBold.toNeutral80,
                      ),
                      for (int i = 0; i < description.length; i++) ...[
                        Gap.customGapHeight(6),
                        Text(
                          description[i],
                          style: TypographyTheme.textXSRegular.toNeutral60,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                useRadio ? Gap.w12 : const SizedBox(),
                useRadio ? _buildRadio() : const SizedBox(),
              ],
            ),
            Gap.h16,
          ],
        ),
      ),
    );
  }

  Widget _buildRadio() {
    return RadioWidget<T>.primary(
      value: identifierValue as T,
      groupValue: groupValue as T,
      size: RadioSize.small,
      onChanged: (value) {
        if (onChangedValue != null) {
          onChangedValue!(value);
        }
      },
    );
  }
}
