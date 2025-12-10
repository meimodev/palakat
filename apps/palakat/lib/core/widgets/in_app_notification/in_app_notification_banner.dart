import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/themes/themes.dart';

/// Data class for in-app notification content
class InAppNotificationData {
  final String title;
  final String body;
  final String? type;
  final Map<String, dynamic>? data;

  const InAppNotificationData({
    required this.title,
    required this.body,
    this.type,
    this.data,
  });
}

/// A banner widget that displays in-app notifications at the top of the screen.
///
/// This widget slides down from the top, displays for a duration,
/// then slides back up. Tapping the banner triggers the onTap callback.
class InAppNotificationBanner extends StatefulWidget {
  final InAppNotificationData notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final Duration displayDuration;
  final Duration animationDuration;

  const InAppNotificationBanner({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.displayDuration = const Duration(seconds: 8),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animation and schedule auto-dismiss
    _animationController.forward();
    _scheduleAutoDismiss();
  }

  void _scheduleAutoDismiss() {
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  Future<void> _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss?.call();
  }

  void _handleTap() {
    widget.onTap?.call();
    _dismiss();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: GestureDetector(
              onTap: _handleTap,
              onVerticalDragEnd: (details) {
                // Swipe up or down to dismiss
                if (details.primaryVelocity != null &&
                    details.primaryVelocity!.abs() > 100) {
                  _dismiss();
                }
              },
              onHorizontalDragEnd: (details) {
                // Swipe left or right to dismiss
                if (details.primaryVelocity != null &&
                    details.primaryVelocity!.abs() > 100) {
                  _dismiss();
                }
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: BaseColor.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: BaseColor.shadow.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Row(
                      children: [
                        // Accent bar on the left
                        Container(
                          width: 4.w,
                          height: 72.h,
                          color: _getAccentColor(),
                        ),
                        // Content
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            child: Row(
                              children: [
                                // Icon
                                Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: _getAccentColor().withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(
                                    _getIcon(),
                                    color: _getAccentColor(),
                                    size: 22.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                // Text content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        widget.notification.title,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: BaseColor.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2.h),
                                      Text(
                                        widget.notification.body,
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: BaseColor.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                // Tap hint
                                Icon(
                                  Icons.chevron_right,
                                  color: BaseColor.neutral60,
                                  size: 20.sp,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getAccentColor() {
    final type = widget.notification.type;
    switch (type) {
      case 'APPROVAL_REQUIRED':
        return BaseColor.warning;
      case 'APPROVAL_REJECTED':
        return BaseColor.error;
      case 'APPROVAL_CONFIRMED':
        return BaseColor.success;
      case 'ACTIVITY_CREATED':
      default:
        return BaseColor.primary;
    }
  }

  IconData _getIcon() {
    final type = widget.notification.type;
    switch (type) {
      case 'APPROVAL_REQUIRED':
        return Icons.pending_actions;
      case 'APPROVAL_REJECTED':
        return Icons.cancel_outlined;
      case 'APPROVAL_CONFIRMED':
        return Icons.check_circle_outline;
      case 'ACTIVITY_CREATED':
      default:
        return Icons.notifications_active;
    }
  }
}
