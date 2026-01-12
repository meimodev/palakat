import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
import 'package:palakat/features/notification/data/pusher_beams_controller.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/models/result.dart';
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
    final bottomPadding =
        MediaQuery.of(context).viewPadding.bottom +
        MediaQuery.of(context).viewInsets.bottom;

    return Container(
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
        top: BaseSize.w24,
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
          Center(
            child: Container(
              width: BaseSize.w56,
              height: BaseSize.w56,
              decoration: BoxDecoration(
                color: BaseColor.teal[50],
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FaIcon(
                AppIcons.security,
                size: BaseSize.w28,
                color: BaseColor.teal[700],
              ),
            ),
          ),
          Gap.h16,
          Text(
            title,
            style: BaseTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: BaseColor.black,
            ),
            textAlign: TextAlign.center,
          ),
          Gap.h12,
          Text(
            message,
            style: BaseTypography.bodyMedium.toSecondary,
            textAlign: TextAlign.center,
          ),
          Gap.h24,
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    side: BorderSide(color: BaseColor.neutral40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    cancelLabel,
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.secondaryText,
                    ),
                  ),
                ),
              ),
              Gap.w12,
              Expanded(
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BaseColor.teal[600],
                    foregroundColor: BaseColor.white,
                    padding: EdgeInsets.symmetric(vertical: BaseSize.h12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BaseSize.radiusMd),
                    ),
                  ),
                  child: Text(
                    confirmLabel,
                    style: BaseTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: BaseColor.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gap.h8,
        ],
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
    if (!_isAppInitialized) {
      // Store the data to be processed after app initialization
      _coldStartNotificationData = data;
      return;
    }

    final context =
        navigatorKey.currentState?.context ??
        navigatorKey.currentState?.overlay?.context ??
        navigatorKey.currentContext;

    if (context == null) {
      _coldStartNotificationData = data;
      return;
    }

    final navigationService = NotificationNavigationService(
      GoRouter.of(context),
    );
    navigationService.handleNotificationTap(data);
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      _handleReturnFromSettings();
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
  }

  void _handleColdStartNotification() {
    if (_coldStartNotificationData != null) {
      final router = ref.read(goRouterProvider);
      final navigationService = NotificationNavigationService(router);

      // Extract deep link data from notification payload
      final data = _extractDeepLinkData(_coldStartNotificationData!);

      // Navigate to the appropriate screen
      navigationService.handleNotificationTap(data);

      // Clear the cold start data
      _coldStartNotificationData = null;
    }
  }

  Map<String, dynamic> _extractDeepLinkData(Map<String, dynamic> payload) {
    // The payload might contain the data in different formats
    // Try to extract the actual notification data

    if (payload.containsKey('data')) {
      return payload['data'] as Map<String, dynamic>;
    }

    // If payload is a string representation, try to parse it
    if (payload.containsKey('payload')) {
      final payloadStr = payload['payload'] as String?;
      if (payloadStr != null) {
        // For now, return empty map as we need proper JSON parsing
        // In production, you'd parse the JSON string here
        return <String, dynamic>{};
      }
    }

    // Return the payload as-is if it already contains the expected keys
    return payload;
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
