import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/core/services/notification_display_service.dart';
import 'package:palakat/core/services/notification_display_service_provider.dart';
import 'package:palakat/core/services/notification_navigation_service.dart';
import 'package:palakat/core/services/permission_manager_service_provider.dart';
import 'package:palakat/features/notification/data/pusher_beams_controller.dart';
import 'package:palakat_shared/core/models/permission_state.dart';
import 'package:palakat_shared/core/services/local_storage_service_provider.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/services.dart';

import 'core/constants/constants.dart';
import 'firebase_options.dart';

// Global variable to store notification tap data from cold start
Map<String, dynamic>? _coldStartNotificationData;

// Global flag to track if app is initialized
bool _isAppInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await LocalStorageService.initHive();

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
    }
  });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    ref.listen(localeControllerProvider, (prev, next) {
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
      await permissionState.requestPermissions(context);
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
        title: "PALAKAT",
        theme: BaseTheme.appTheme,
        // Localization configuration - Requirements: 1.1, 1.4
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
