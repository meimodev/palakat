import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat_shared/core/config/app_config.dart';
import 'package:palakat_shared/core/config/sectioned_env_loader.dart';
import 'package:palakat_shared/core/widgets/file_transfer_progress_banner.dart';
import 'package:palakat_shared/core/widgets/socket_connection_banner.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/services.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';
import 'package:palakat_shared/core/theme/theme.dart';

import 'core/layout/app_scaffold.dart';
import 'core/services/admin_approval_realtime_listener.dart';
import 'core/services/church_change_version_poller.dart';
import 'core/navigation/page_transitions.dart';
import 'features/account/presentation/screens/account_screen.dart';
import 'features/activity/presentation/screens/activity_screen.dart';
import 'features/approval/presentation/screens/approval_screen.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/screens/signin_screen.dart';
import 'features/billing/presentation/screens/billing_screen.dart';
import 'features/church/presentation/screens/church_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/document/presentation/screens/document_screen.dart';
import 'features/finance/presentation/screens/finance_screen.dart';
import 'features/financial/presentation/screens/financial_account_list_screen.dart';
import 'features/member/presentation/screens/member_screen.dart';
import 'features/report/presentation/screens/report_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables with error handling for web
  try {
    await SectionedEnvLoader.load();
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Using default or build-time environment variables');
  }
  _logStartupEnvStatus();
  // Initialize Hive and open the auth box for cached session restore
  await LocalStorageService.initHive();
  runApp(const ProviderScope(child: PalakatAdminApp()));
}

void _logStartupEnvStatus() {
  final apiBaseUrl = dotenv.env['API_BASE_URL']?.trim() ?? '';
  final apiBaseVersion = dotenv.env['API_BASE_VERSION']?.trim() ?? '';
  final apiBasePort = dotenv.env['API_BASE_PORT']?.trim() ?? '';
  final parsedBaseUrl = Uri.tryParse(apiBaseUrl);
  final host = parsedBaseUrl?.host ?? '-';

  debugPrint(
    'Startup env status: '
    'platform=${kIsWeb ? 'web' : 'non-web'}, '
    'apiBaseUrlPresent=${apiBaseUrl.isNotEmpty}, '
    'apiBaseVersionPresent=${apiBaseVersion.isNotEmpty}, '
    'apiBasePortPresent=${apiBasePort.isNotEmpty}, '
    'apiBaseUrlHost=$host',
  );

  try {
    final config = AppConfig.fromEnv();
    debugPrint('Startup env config ok: apiBaseUrl=${config.apiBaseUrl}');
  } catch (e) {
    debugPrint('Startup env config invalid: $e');
  }
}

class PalakatAdminApp extends ConsumerWidget {
  const PalakatAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);

    intl.Intl.defaultLocale = locale.languageCode;

    return ScreenUtilInit(
      designSize: const Size(360, 640),
      ensureScreenSize: true,
      minTextAdapt: false,
      enableScaleText: () => false,
      fontSizeResolver: (fontSize, instance) =>
          kIsWeb ? fontSize.toDouble() : instance.setSp(fontSize),
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        onGenerateTitle: (context) => context.l10n.appTitle_admin,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: router,
        builder: (context, child) => FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: AdminApprovalRealtimeListener(
            child: ChurchChangeVersionPoller(
              child: FileTransferProgressBanner(child: child),
            ),
          ),
        ),
        // Localization configuration - Requirements: 1.2, 1.4
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (prev, next) {
    refresh.value++;
  });
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: refresh,
    redirect: (context, state) {
      // Rely solely on AuthService's cached auth state
      final localStorageService = ref.read(localStorageServiceProvider);
      final isAuthed = localStorageService.isAuthenticated;
      final goingToSignIn = state.matchedLocation == '/signin';
      String? route;
      if (!isAuthed && !goingToSignIn) route = '/signin';
      if (isAuthed && goingToSignIn) route = '/dashboard';
      return route;
    },
    routes: [
      GoRoute(
        path: '/signin',
        name: 'signin',
        pageBuilder: (context, state) => SmoothPageTransition<void>(
          key: state.pageKey,
          name: 'signin',
          child: const SignInScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => SocketConnectionBanner(
          blockInteractionWhenNotConnected: false,
          child: AppScaffold(child: child),
        ),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'dashboard',
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/member',
            name: 'member',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'member',
              child: const MemberScreen(),
            ),
          ),
          GoRoute(
            path: '/approval',
            name: 'approval',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'approval',
              child: const ApprovalScreen(),
            ),
          ),
          GoRoute(
            path: '/activity',
            name: 'activity',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'activity',
              child: const ActivityScreen(),
            ),
          ),
          GoRoute(
            path: '/billing',
            name: 'billing',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'billing',
              child: const BillingScreen(),
            ),
          ),
          GoRoute(
            path: '/church',
            name: 'church',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'church',
              child: const ChurchScreen(),
            ),
          ),
          GoRoute(
            path: '/document',
            name: 'document',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'document',
              child: const DocumentScreen(),
            ),
          ),
          GoRoute(
            path: '/finance',
            name: 'finance',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'finance',
              child: const FinanceScreen(),
            ),
          ),
          GoRoute(
            path: '/report',
            name: 'report',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'report',
              child: const ReportScreen(),
            ),
          ),
          GoRoute(
            path: '/account',
            name: 'account',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'account',
              child: const AccountScreen(),
            ),
          ),
          GoRoute(
            path: '/financial',
            name: 'financial',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'financial',
              child: const FinancialAccountListScreen(),
            ),
          ),
        ],
      ),
    ],
  );
});
