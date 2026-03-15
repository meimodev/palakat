import 'dart:convert';
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/notification_display_service.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';
import 'package:palakat/core/services/notification_navigation_service.dart';
import 'package:palakat/core/services/permission_manager_service_provider.dart';
import 'package:palakat/core/services/realtime_notification_listener.dart';
import 'package:palakat/core/services/timezone_service.dart';
import 'package:palakat/features/activity_alarm/services/activity_alarm_scheduler_provider.dart';
import 'package:palakat/features/authentication/presentations/widgets/widgets.dart';
import 'package:palakat/features/notification/data/pusher_beams_controller.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/extension/approver_extension.dart';
import 'package:palakat_shared/core/models/activity.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/core/widgets/button/button_widget.dart';
import 'package:palakat_shared/core/widgets/file_transfer_progress_banner.dart';
import 'package:palakat_shared/core/widgets/socket_connection_banner.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/services.dart';

import 'core/constants/constants.dart';
import 'firebase_options.dart';

// Global variable to store notification tap data from cold start
Map<String, dynamic>? _coldStartNotificationData;

// Global flag to track if app is initialized
bool _isAppInitialized = false;
bool _isUnauthorizedSheetVisible = false;

Future<void> _handleUnauthorized() async {
  if (_isUnauthorizedSheetVisible) return;
  _isUnauthorizedSheetVisible = true;

  try {
    void scheduleShowSheet(int remainingAttempts) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          final context =
              navigatorKey.currentState?.context ??
              navigatorKey.currentState?.overlay?.context ??
              navigatorKey.currentContext;
          if (context == null) {
            if (remainingAttempts <= 0) {
              _isUnauthorizedSheetVisible = false;
              return;
            }
            scheduleShowSheet(remainingAttempts - 1);
            return;
          }

          final l10n = lookupAppLocalizations(Localizations.localeOf(context));
          final router = GoRouter.of(context);
          final currentUri = router.routerDelegate.currentConfiguration.uri;
          final returnTo = currentUri.path.startsWith('/authentication')
              ? null
              : currentUri.toString();

          showModalBottomSheet<void>(
            context: context,
            useRootNavigator: true,
            isScrollControlled: true,
            isDismissible: true,
            enableDrag: true,
            backgroundColor: BaseColor.transparent,
            builder: (context) {
              return _UnauthorizedBottomSheetContent(
                title: l10n.unauthorized_signInRequired_title,
                message: l10n.unauthorized_signInRequired_message,
                cancelLabel: l10n.btn_cancel,
                confirmLabel: l10n.btn_signIn,
                onCancel: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                onConfirm: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  if (returnTo == null || returnTo.isEmpty) {
                    router.go('/authentication');
                    return;
                  }
                  router.go(
                    '/authentication?returnTo=${Uri.encodeComponent(returnTo)}',
                  );
                },
              );
            },
          ).whenComplete(() {
            _isUnauthorizedSheetVisible = false;
          });
        } catch (_) {
          if (remainingAttempts <= 0) {
            _isUnauthorizedSheetVisible = false;
            return;
          }
          scheduleShowSheet(remainingAttempts - 1);
        }
      });
    }

    scheduleShowSheet(10);
  } catch (_) {
    _isUnauthorizedSheetVisible = false;
  }
}

class _UnauthorizedBottomSheetContent extends StatelessWidget {
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _UnauthorizedBottomSheetContent({
    required this.title,
    required this.message,
    required this.cancelLabel,
    required this.confirmLabel,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomPadding = media.viewPadding.bottom + media.viewInsets.bottom;
    final shouldStackActions =
        media.size.width < 360 ||
        MediaQuery.textScalerOf(context).scale(1) > 1.15;
    final sheetMaxWidth = media.size.width >= 768 ? 480.0 : double.infinity;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: sheetMaxWidth),
        child: Container(
          decoration: BoxDecoration(
            color: BaseColor.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(BaseSize.radiusLg),
              topRight: Radius.circular(BaseSize.radiusLg),
            ),
          ),
          padding: EdgeInsets.only(
            left: BaseSize.w24,
            right: BaseSize.w24,
            top: BaseSize.w16,
            bottom: BaseSize.w24 + bottomPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: BaseSize.w40,
                  height: BaseSize.h4,
                  decoration: BoxDecoration(
                    color: BaseColor.neutral30,
                    borderRadius: BorderRadius.circular(BaseSize.radiusSm),
                  ),
                ),
              ),
              Gap.h16,
              AuthSurfaceCard(
                icon: AppIcons.security,
                title: title,
                centeredHeader: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      message,
                      style: BaseTypography.bodyMedium.toSecondary,
                      textAlign: TextAlign.center,
                    ),
                    Gap.h24,
                    if (shouldStackActions) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ButtonWidget.primary(
                          text: confirmLabel,
                          onTap: onConfirm,
                        ),
                      ),
                      Gap.h12,
                      SizedBox(
                        width: double.infinity,
                        child: ButtonWidget.outlined(
                          text: cancelLabel,
                          onTap: onCancel,
                          outlineColor: BaseColor.neutral40,
                          textColor: BaseColor.secondaryText,
                          focusColor: BaseColor.neutral20,
                          overlayColor: BaseColor.neutral10,
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: ButtonWidget.outlined(
                              text: cancelLabel,
                              onTap: onCancel,
                              outlineColor: BaseColor.neutral40,
                              textColor: BaseColor.secondaryText,
                              focusColor: BaseColor.neutral20,
                              overlayColor: BaseColor.neutral10,
                            ),
                          ),
                          Gap.w12,
                          Expanded(
                            child: ButtonWidget.primary(
                              text: confirmLabel,
                              onTap: onConfirm,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Gap.h8,
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocalStorageService.initHive();

  await TimeZoneService.initialize();

  await Jiffy.setLocale('id');

  // Initialize notification display service for background notification handling
  final notificationService = NotificationDisplayServiceImpl();
  await notificationService.initialize();
  await notificationService.initializeChannels();

  // Set the shared instance so other parts of the app can use it
  setSharedNotificationDisplayService(notificationService);

  // Set up notification tap handler for cold start
  // This captures notification taps when the app is launched from a terminated state
  notificationService.setNotificationTapHandler((data) {
    _coldStartNotificationData = data;
  });

  runApp(
    ProviderScope(
      overrides: [
        socketServiceProvider.overrideWith((ref) {
          ref.keepAlive();
          final config = ref.watch(appConfigProvider);
          final localStorage = ref.watch(localStorageServiceProvider);

          final api = Uri.parse(config.apiBaseUrl);
          final wsBase =
              '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}';

          late final SocketService service;
          service = SocketService(
            url: wsBase,
            accessTokenProvider: () => localStorage.accessToken ?? '',
            refreshTokens: () async {
              final refreshToken = localStorage.refreshToken;
              if (refreshToken == null || refreshToken.isEmpty) {
                throw Failure('No refresh token available');
              }
              final tokens = await service.refresh(refreshToken: refreshToken);
              await localStorage.saveTokens(tokens);
              return tokens;
            },
            onUnauthorized: () async {
              unawaited(_handleUnauthorized());

              unawaited(() async {
                try {
                  final pusherBeamsController = ref.read(
                    pusherBeamsControllerProvider.notifier,
                  );
                  await pusherBeamsController.unregisterAllInterests();
                } catch (_) {}
              }());

              try {
                await localStorage.clearAllUserData();
              } catch (_) {}
            },
          );

          return service;
        }),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  ProviderSubscription<Locale>? _localeSubscription;

  @override
  void initState() {
    super.initState();

    ref.read(realtimeNotificationListenerProvider);
    _registerNotificationTapHandler();

    _localeSubscription = ref.listenManual(localeControllerProvider, (
      prev,
      next,
    ) {
      intl.Intl.defaultLocale = next.languageCode;
      unawaited(Jiffy.setLocale(next.languageCode));
    });

    // Add lifecycle observer to detect return from settings
    WidgetsBinding.instance.addObserver(this);

    // Mark app as initialized
    _isAppInitialized = true;

    // Handle cold start notification after app initialization
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshNotificationLaunchRouting();
      _handleColdStartNotification();
      _initializePermissionFlow();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _localeSubscription?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Detect return from settings (app resumed)
    // Requirements: 6.5
    if (state == AppLifecycleState.resumed) {
      unawaited(_handleAppResumed());
    }
  }

  void _registerNotificationTapHandler() {
    final notificationService = ref.read(
      notificationDisplayServiceSyncProvider,
    );
    notificationService?.setNotificationTapHandler(_onNotificationTapped);
  }

  void _onNotificationTapped(Map<String, dynamic> data) {
    if (!_isAppInitialized) {
      _coldStartNotificationData = data;
      return;
    }

    _routeNotificationTap(data);
  }

  void _routeNotificationTap(Map<String, dynamic> data) {
    final normalized = _extractDeepLinkData(data);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _coldStartNotificationData = normalized;
        return;
      }

      try {
        final router = ref.read(goRouterProvider);
        final navigationService = NotificationNavigationService(router);
        navigationService.handleNotificationTap(normalized);
      } catch (_) {
        _coldStartNotificationData = normalized;
      }
    });
  }

  Future<void> _handleAppResumed() async {
    await _refreshNotificationLaunchRouting();
    _handleColdStartNotification();
    await _handleReturnFromSettings();
  }

  Future<void> _refreshNotificationLaunchRouting() async {
    try {
      final service = ref.read(notificationDisplayServiceSyncProvider);
      await service?.refreshLaunchDetails();
    } catch (e) {
      debugPrint('[NotificationLaunch] Failed to refresh launch details: $e');
    }
  }

  /// Initialize permission flow on app startup
  /// Requirements: 4.1, 6.1
  Future<void> _initializePermissionFlow() async {
    final permissionManager = ref.read(permissionManagerServiceProvider);

    // Sync permission status with system
    await permissionManager.syncPermissionStatus();

    // Check if we should show rationale (first time or 7-day retry)
    final shouldShow = await permissionManager.shouldShowRationale();

    if (shouldShow && mounted) {
      // Show permission rationale and request if user allows
      final permissionState = ref.read(permissionStateProvider.notifier);
      await permissionState.requestPermissions();
    }
  }

  /// Handle return from settings - auto-register if permission granted
  /// Requirements: 6.5
  Future<void> _handleReturnFromSettings() async {
    final permissionManager = ref.read(permissionManagerServiceProvider);

    // Sync permission status with system
    await permissionManager.syncPermissionStatus();

    // Get updated permission state
    final state = await permissionManager.getPermissionState();

    // If permission was granted, try to register push notifications
    // using the controller (which coordinates with the rest of the app)
    if (state.status == PermissionStatus.granted) {
      // Get membership from local storage
      final localStorage = ref.read(localStorageServiceProvider);
      final membership = localStorage.currentMembership;
      final account = localStorage.currentAuth?.account;

      // Only register if user is signed in with valid membership
      if (membership != null && membership.id != null) {
        try {
          // Use the controller to register interests
          // This ensures proper coordination with the rest of the notification system
          final pusherBeamsController = ref.read(
            pusherBeamsControllerProvider.notifier,
          );
          await pusherBeamsController.registerInterests(
            membership,
            account: account,
          );
        } catch (e) {
          debugPrint('🔔 Push notification registration failed: $e');
        }
      }

      // Refresh permission state provider
      ref.read(permissionStateProvider.notifier).refresh();
    }

    await _refreshActivityAlarmsOnResume();
  }

  Future<void> _refreshActivityAlarmsOnResume() async {
    final localStorage = ref.read(localStorageServiceProvider);
    final membershipId =
        localStorage.currentMembership?.id ??
        localStorage.currentAuth?.account.membership?.id;

    if (membershipId == null) {
      return;
    }

    try {
      final scheduler = await ref.read(
        activityAlarmSchedulerServiceProvider.future,
      );
      final enabled = await scheduler.isEnabled(membershipId);
      if (!enabled) {
        return;
      }

      final homeRepo = ref.read(homeRepositoryProvider);
      final dashboardResult = await homeRepo.getHomeDashboard();

      var activities = <Activity>[];
      var didLoadActivities = false;
      dashboardResult.when(
        onSuccess: (response) {
          didLoadActivities = true;
          final nowLocal = DateTime.now();
          activities =
              response.data.thisWeekActivities
                  .where(
                    (activity) =>
                        activity.approvers.approvalStatus ==
                        ApprovalStatus.approved,
                  )
                  .where(
                    (activity) =>
                        (activity.activityType == ActivityType.event ||
                            activity.activityType == ActivityType.service) &&
                        activity.reminder != null,
                  )
                  .where(
                    (activity) => activity.date.toLocal().isAfter(nowLocal),
                  )
                  .toList()
                ..sort((a, b) => a.date.compareTo(b.date));
        },
        onFailure: (failure) {
          debugPrint(
            '[ActivityAlarm] Resume sync skipped because dashboard fetch failed: ${failure.message}',
          );
        },
      );

      if (!didLoadActivities) {
        return;
      }

      await scheduler.syncWeekAlarms(
        membershipId: membershipId,
        activities: activities,
      );
    } catch (e) {
      debugPrint('[ActivityAlarm] Resume sync failed: $e');
    }
  }

  void _handleColdStartNotification() {
    if (_coldStartNotificationData != null) {
      final data = _extractDeepLinkData(_coldStartNotificationData!);

      // Clear the cold start data
      _coldStartNotificationData = null;
      _routeNotificationTap(data);
    }
  }

  Map<String, dynamic> _extractDeepLinkData(Map<String, dynamic> payload) {
    // The payload might contain the data in different formats
    // Try to extract the actual notification data

    final normalizedPayload = _normalizeNotificationMap(payload);

    if (normalizedPayload.containsKey('data')) {
      final data = _decodeNotificationMap(normalizedPayload['data']);
      if (data != null) {
        return data;
      }
    }

    // If payload is a string representation, try to parse it
    if (normalizedPayload.containsKey('payload')) {
      final nestedPayload = _decodeNotificationMap(
        normalizedPayload['payload'],
      );
      if (nestedPayload != null) {
        return nestedPayload;
      }
    }

    // Return the payload as-is if it already contains the expected keys
    return normalizedPayload;
  }

  Map<String, dynamic>? _decodeNotificationMap(dynamic raw) {
    if (raw == null) {
      return null;
    }

    if (raw is Map) {
      return _normalizeNotificationMap(raw);
    }

    if (raw is! String) {
      return null;
    }

    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is Map) {
        return _normalizeNotificationMap(decoded);
      }
    } catch (_) {}

    return null;
  }

  Map<String, dynamic> _normalizeNotificationMap(
    Map<dynamic, dynamic> payload,
  ) {
    return payload.map((key, value) => MapEntry(key.toString(), value));
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.read(goRouterProvider);
    final locale = ref.watch(localeControllerProvider);

    intl.Intl.defaultLocale = locale.languageCode;

    final l10n = lookupAppLocalizations(locale);

    return ScreenUtilInit(
      designSize: const Size(360, 640),
      ensureScreenSize: true,
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
        routeInformationProvider: router.routeInformationProvider,
        title: l10n.appTitle,
        theme: BaseTheme.appTheme,
        builder: (context, child) => FocusTraversalGroup(
          // Use ReadingOrderTraversalPolicy with a try-catch wrapper
          // to prevent RenderBox layout errors during focus traversal
          policy: _SafeFocusTraversalPolicy(),
          child: FileTransferProgressBanner(
            child: SocketConnectionBanner(
              blockInteractionWhenNotConnected: false,
              child: child,
            ),
          ),
        ),
        // Localization configuration - Requirements: 1.1, 1.4
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}

/// Custom focus traversal policy that gracefully handles RenderBox layout errors
/// This prevents crashes when Flutter tries to find focusable widgets before
/// the overlay (_RenderTheater) is fully laid out, especially on web.
class _SafeFocusTraversalPolicy extends ReadingOrderTraversalPolicy {
  @override
  Iterable<FocusNode> sortDescendants(
    Iterable<FocusNode> descendants,
    FocusNode currentNode,
  ) {
    try {
      // Filter out nodes that don't have a valid render box yet
      final validDescendants = descendants.where((node) {
        try {
          final context = node.context;
          if (context == null) return false;
          final renderObject = context.findRenderObject();
          if (renderObject is! RenderBox) return false;
          // Check if the render box has been laid out
          return renderObject.hasSize;
        } catch (_) {
          return false;
        }
      });
      return super.sortDescendants(validDescendants, currentNode);
    } catch (_) {
      // If sorting fails, return empty list to prevent crash
      return const [];
    }
  }
}
