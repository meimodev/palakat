import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halo_hermina/core/assets/assets.gen.dart';
import 'package:halo_hermina/core/constants/constants.dart';
import 'package:halo_hermina/core/utils/utils.dart';
import 'package:halo_hermina/core/widgets/checkbox/checkbox_widget.dart';
import 'package:halo_hermina/core/widgets/widgets.dart';

// INFO: This page just for example for using widget
class WidgetExampleScreen extends ConsumerWidget {
  const WidgetExampleScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          Assets.images.logo.image(width: BaseSize.h12),
          SizedBox(
            height: BaseSize.h4,
          ),
          Padding(
            padding: horizontalPaddingSmall,
            child: Row(
              children: [
                Flexible(
                  child: ButtonWidget.primary(
                    color: BaseColor.black,
                    overlayColor: BaseColor.white.withOpacity(.5),
                    isShrink: true,
                    icon: Assets.icons.fill.account.svg(
                      colorFilter: BaseColor.white.filterSrcIn,
                    ),
                    text: "Login",
                    onTap: () => {},
                  ),
                ),
                Gap.h8,
                Flexible(
                  child: ButtonWidget.outlined(
                    isShrink: true,
                    outlineColor: BaseColor.blue,
                    textColor: BaseColor.blue,
                    overlayColor: BaseColor.blue[100]!,
                    icon: Assets.icons.fill.account.svg(
                      colorFilter: BaseColor.blue.filterSrcIn,
                    ),
                    text: "Login",
                    onTap: () => {},
                  ),
                ),
                ButtonWidget.primaryIcon(
                  icon: Assets.icons.fill.account.svg(
                    colorFilter: BaseColor.white.filterSrcIn,
                  ),
                  onTap: () => {},
                ),
                ButtonWidget.outlinedIcon(
                  icon: Assets.icons.fill.account.svg(
                    colorFilter: BaseColor.primary3.filterSrcIn,
                  ),
                  onTap: () => {},
                ),
              ],
            ),
          ),
          Padding(
            padding: horizontalPaddingSmall,
            child: Row(
              children: [
                ButtonWidget.text(
                  buttonSize: ButtonSize.large,
                  text: "Lorem",
                  onTap: () => {},
                ),
                ButtonWidget.text(
                  text: "Lorem",
                  onTap: () => {},
                ),
                ButtonWidget.text(
                  icon: Assets.icons.fill.account.svg(
                    colorFilter: BaseColor.primary3.filterSrcIn,
                  ),
                  buttonSize: ButtonSize.small,
                  text: "Lorem",
                  onTap: () => {},
                ),
              ],
            ),
          ),
          Padding(
            padding: horizontalPaddingSmall,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SwitchWidget.primary(
                      size: SwitchSize.large,
                      isEnabled: false,
                      value: true,
                      onChanged: (val) {},
                      label: "Test",
                    ),
                    SwitchWidget.primary(
                      value: true,
                      onChanged: (val) {},
                      label: "Test",
                    ),
                    SwitchWidget.primary(
                      size: SwitchSize.small,
                      value: false,
                      onChanged: (val) {},
                      label: "Test",
                    )
                  ],
                ),
                Gap.h8,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CheckBoxWidget.primary(
                      size: CheckboxSize.large,
                      isEnabled: false,
                      value: true,
                      onChanged: (val) {},
                      label: "Test",
                    ),
                    CheckBoxWidget.primary(
                      value: true,
                      onChanged: (val) {},
                      label: "Test",
                    ),
                    CheckBoxWidget.primary(
                      size: CheckboxSize.small,
                      value: false,
                      onChanged: (val) {},
                      label: "Test",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
