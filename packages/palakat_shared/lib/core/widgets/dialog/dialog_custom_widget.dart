import 'package:palakat_shared/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(SanctuaryLayout.radiusLarge),
      ),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12.0,
          12.0,
          12.0,
          MediaQuery.of(context).viewPadding.bottom + 12.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(SanctuaryLayout.radiusLarge),
            ),
            boxShadow: SanctuaryDepth.ambient(opacity: 0.05, blur: 28),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44.0,
                    height: 4.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(
                        SanctuaryLayout.pillRadius,
                      ),
                    ),
                  ),
                ),
                Gap.h16,
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
                Gap.h24,
              ],
            ),
          ),
        ),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Gap.w12,
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceContainerLow,
            foregroundColor: AppColors.onSurfaceVariant,
            padding: EdgeInsets.all(10.0),
            minimumSize: Size(40.0, 40.0),
          ),
          icon:
              closeIcon ??
              Icon(
                Icons.close,
                size: 20.0,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          onPressed: onClose,
        ),
      ],
    );
  }
}
