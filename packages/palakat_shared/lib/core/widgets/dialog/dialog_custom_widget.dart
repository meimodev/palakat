import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/theme.dart';

/// A customizable bottom sheet dialog widget.
///
/// This widget provides a consistent bottom sheet dialog with a title header
/// and close button. It can be used for various picker dialogs and forms.
Future<T?> showDialogCustomWidget<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  bool scrollControlled = true,
  bool dismissible = true,
  bool dragAble = true,
  VoidCallback? onPopBottomSheet,
  Widget? closeIcon,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: scrollControlled,
    isDismissible: dismissible,
    enableDrag: dragAble,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(BaseSize.customRadius(BaseSize.radiusMd)),
      ),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.symmetric(horizontal: BaseSize.w12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Gap.h24,
          _DialogHeader(
            title: title,
            closeIcon: closeIcon,
            onClose: () {
              if (onPopBottomSheet != null) {
                onPopBottomSheet();
              }
              context.pop();
            },
          ),
          Gap.h16,
          content,
          Gap.h48,
        ],
      ),
    ),
  );
}

/// Internal header widget for the dialog
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({
    required this.title,
    required this.onClose,
    this.closeIcon,
  });

  final String title;
  final VoidCallback onClose;
  final Widget? closeIcon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Spacer for symmetry
        const SizedBox(width: 40),
        Expanded(
          child: Text(
            title,
            style: BaseTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: BaseColor.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minHeight: BaseSize.w24,
            minWidth: BaseSize.w24,
          ),
          icon:
              closeIcon ??
              Icon(
                Icons.close,
                size: BaseSize.w24,
                color: BaseColor.primaryText,
              ),
          onPressed: onClose,
        ),
      ],
    );
  }
}
