import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/assets/assets.gen.dart';
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat/core/utils/utils.dart';
import 'package:palakat/core/widgets/input/input_widget.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({
    super.key,
    this.title,
    this.onLeadingPressed,
    this.subtitle,
    this.hasLeading = true,
    this.isDarkMode = false,
    this.backgroundColor = Colors.white,
    this.backIconColor,
    this.titleColor,
    this.height,
    this.actions,
    this.widgetTitle,
    this.searching = false,
    this.onChangedTextSearch,
    this.onTapButtonCloseSearch,
    this.tecSearch,
    this.backIcon,
  });

  final bool hasLeading;
  final String? title;
  final List<Widget>? actions;
  final String? subtitle;
  final VoidCallback? onLeadingPressed;
  final Color? titleColor;
  final Color? backgroundColor;
  final Color? backIconColor;
  final double? height;
  final bool isDarkMode;
  final Widget? widgetTitle;
  final bool searching;
  final void Function(String value)? onChangedTextSearch;
  final void Function()? onTapButtonCloseSearch;
  final TextEditingController? tecSearch;
  final SvgGenImage? backIcon;

  @override
  Size get preferredSize => Size.fromHeight(height ?? BaseSize.h56);

  static double get _iconSize => BaseSize.w24;

  static const String _key = 'common_app_bar';
  static const widgetKey = Key(_key);
  static const leadingEmptyKey = Key('${_key}_leading_button_empty');
  static const leadingKey = Key('${_key}_leading_button');
  static const titleKey = Key('${_key}_title');
  static const subtitleKey = Key('${_key}_subtitle');
  static const actionEmptyKey = Key('${_key}_action_button_empty');
  static const actionKey = Key('${_key}_action_button');
  static const topBarKey = Key('${_key}_top_bar');

  @override
  Widget build(BuildContext context) {
    final Widget leadingIcon = IconButton(
      padding: EdgeInsets.zero,
      key: leadingKey,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      constraints: BoxConstraints(
        minHeight: _iconSize,
        minWidth: _iconSize,
      ),
      icon: (backIcon ?? Assets.icons.line.chevronLeft).svg(
        width: _iconSize,
        height: _iconSize,
        colorFilter:
            ColorFilter.mode(backIconColor ?? Colors.black, BlendMode.srcIn),
      ),
      iconSize: _iconSize.r,
      splashRadius: _iconSize.r,
      onPressed: onLeadingPressed ?? () => context.pop(),
    );

    return AppBar(
      systemOverlayStyle: const SystemUiOverlayStyle(
        systemNavigationBarColor: BaseColor.transparent,
        statusBarBrightness: Brightness.light,
        statusBarColor: BaseColor.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      elevation: 0,
      key: widgetKey,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: preferredSize,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Appbar
            Container(
              height: height ?? BaseSize.h56,
              padding: horizontalPaddingSmall,
              child: searching
                  ? _BuildSearchingLayout(
                      onTapButtonCloseSearch: onTapButtonCloseSearch,
                      onChangedTextSearch: onChangedTextSearch,
                      tecSearch: tecSearch,
                      leadingIcon: leadingIcon,
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Leading button
                            if (hasLeading) ...[
                              leadingIcon,
                              Gap.w16,
                            ],
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Title
                                widgetTitle != null
                                    ? widgetTitle!
                                    : Text(
                                        title ?? '',
                                        key: titleKey,
                                        style: isDarkMode
                                            ? BaseTypography
                                                .heading3SemiBold.toWhite
                                                .copyWith(color: titleColor)
                                            : BaseTypography.heading3SemiBold
                                                .copyWith(color: titleColor),
                                      ),

                                // Subtitle
                                if (subtitle != null)
                                  Text(
                                    subtitle ?? '',
                                    key: subtitleKey,
                                    style: BaseTypography.textLRegular,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: actions ?? [],
                        )
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildSearchingLayout extends StatelessWidget {
  const _BuildSearchingLayout({
    this.onTapButtonCloseSearch,
    this.onChangedTextSearch,
    this.tecSearch,
    required this.leadingIcon,
  });

  final void Function()? onTapButtonCloseSearch;
  final void Function(String value)? onChangedTextSearch;
  final TextEditingController? tecSearch;
  final Widget leadingIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: BaseSize.customHeight(0),
      ),
      child: Row(
        children: [
          leadingIcon,
          Gap.w16,
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: BaseColor.neutral.shade20),
                borderRadius: BorderRadius.circular(BaseSize.radiusMd),
              ),
              child: InputFormWidget(
                clearBorder: true,
                controller: tecSearch,
                onChanged: onChangedTextSearch,
                hintText: "Search",
                maxLines: 1,
                prefixIcon: GestureDetector(
                  onTap: onTapButtonCloseSearch,
                  child: Assets.icons.line.search.svg(
                    width: BaseSize.customWidth(20),
                    height: BaseSize.customWidth(20),
                    colorFilter: BaseColor.neutral.shade50.filterSrcIn,
                  ),
                ),
                suffixIcon: GestureDetector(
                  onTap: onTapButtonCloseSearch,
                  child: Assets.icons.line.times.svg(
                    width: BaseSize.customWidth(20),
                    height: BaseSize.customWidth(20),
                    colorFilter: BaseColor.neutral.shade50.filterSrcIn,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
