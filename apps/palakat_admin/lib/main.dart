import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/services.dart';
import 'package:palakat_shared/core/extension/build_context_extension.dart';

import 'core/layout/app_scaffold.dart';
import 'core/navigation/page_transitions.dart';
import 'core/theme/theme.dart';
import 'features/account/presentation/screens/account_screen.dart';
import 'features/activity/presentation/screens/activity_screen.dart';
import 'features/approval/presentation/screens/approval_screen.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/screens/signin_screen.dart';
import 'features/billing/presentation/screens/billing_screen.dart';
import 'features/church/presentation/screens/church_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/document/presentation/screens/document_screen.dart';
import 'features/expense/presentation/screens/expense_screen.dart';
import 'features/financial/presentation/screens/financial_account_list_screen.dart';
import 'features/member/presentation/screens/member_screen.dart';
import 'features/report/presentation/screens/report_screen.dart';
import 'features/revenue/presentation/screens/revenue_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables with error handling for web
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Using default or build-time environment variables');
  }
  // Initialize Hive and open the auth box for cached session restore
  await LocalStorageService.initHive();
  runApp(const ProviderScope(child: PalakatAdminApp()));
}

class PalakatAdminApp extends ConsumerWidget {
  const PalakatAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeControllerProvider);

    intl.Intl.defaultLocale = locale.languageCode;

    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle_admin,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
      // Localization configuration - Requirements: 1.2, 1.4
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
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
        builder: (context, state, child) => AppScaffold(child: child),
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
            path: '/revenue',
            name: 'revenue',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'revenue',
              child: const RevenueScreen(),
            ),
          ),
          GoRoute(
            path: '/expense',
            name: 'expense',
            pageBuilder: (context, state) => SmoothPageTransition<void>(
              key: state.pageKey,
              name: 'expense',
              child: const ExpenseScreen(),
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
