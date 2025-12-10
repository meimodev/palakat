import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat_shared/core/theme/color_constants.dart';
import 'package:palakat_shared/core/theme/size_constants.dart';

/// Service for displaying popup notifications when the app is in foreground.
/// Shows a brief popup for ~3 seconds that can be tapped to navigate to the activity.
class NotificationPopupService {
  static final NotificationPopupService _instance =
      NotificationPopupService._internal();
  factory NotificationPopupService() => _instance;
  NotificationPopupService._internal();

  OverlayEntry? _currentOverlay;
  Timer? _dismissTimer;

  /// Shows a popup notification that appears briefly and can be tapped to navigate
  void showNotificationPopup({
    required BuildContext context,
    required String title,
    required String body,
    required Map<String, dynamic> notificationData,
    required int currentMembershipId,
  }) {
    // Dismiss any existing popup
    _dismissCurrentPopup();

    // Create the overlay entry
    _currentOverlay = OverlayEntry(
      builder: (overlayContext) => _NotificationPopupWidget(
        title: title,
        body: body,
        onTap: () {
          _dismissCurrentPopup();
          _handleNotificationTap(
            context,
            notificationData,
            currentMembershipId,
          );
        },
        onDismiss: _dismissCurrentPopup,
      ),
    );

    // Insert the overlay
    final overlay = Overlay.of(context);
    overlay.insert(_currentOverlay!);

    // Auto-dismiss after 3 seconds (enough time to read and tap)
    _dismissTimer = Timer(const Duration(seconds: 3), _dismissCurrentPopup);
  }

  void _dismissCurrentPopup() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  void _handleNotificationTap(
    BuildContext context,
    Map<String, dynamic> data,
    int currentMembershipId,
  ) {
    final activityId = _parseIntValue(data['activityId']);
    final notificationType = data['type'] as String?;

    if (activityId == null) return;

    if (notificationType == 'APPROVAL_REQUIRED' ||
        notificationType == 'APPROVAL_CONFIRMED' ||
        notificationType == 'APPROVAL_REJECTED') {
      context.pushNamed(
        AppRoute.approvalDetail,
        extra: RouteParam(
          params: {
            'activityId': activityId,
            'currentMembershipId': currentMembershipId,
          },
        ),
      );
    } else {
      context.pushNamed(
        AppRoute.activityDetail,
        pathParameters: {'activityId': activityId.toString()},
      );
    }
  }

  int? _parseIntValue(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class _NotificationPopupWidget extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationPopupWidget({
    required this.title,
    required this.body,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationPopupWidget> createState() =>
      _NotificationPopupWidgetState();
}

class _NotificationPopupWidgetState extends State<_NotificationPopupWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + BaseSize.h8,
      left: BaseSize.w16,
      right: BaseSize.w16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: widget.onTap,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < 0) {
                  widget.onDismiss();
                }
              },
              child: Container(
                padding: EdgeInsets.all(BaseSize.w16),
                decoration: BoxDecoration(
                  color: BaseColor.white,
                  borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                  boxShadow: [
                    BoxShadow(
                      color: BaseColor.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(BaseSize.w8),
                      decoration: BoxDecoration(
                        color: BaseColor.primary[100],
                        borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: BaseColor.primary[700],
                        size: 24,
                      ),
                    ),
                    SizedBox(width: BaseSize.w12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: BaseColor.neutral[900],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: BaseSize.h4),
                          Text(
                            widget.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: BaseColor.neutral[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: BaseColor.neutral[400]),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
