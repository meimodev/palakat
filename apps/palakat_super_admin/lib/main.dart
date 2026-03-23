import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:palakat_shared/core/config/sectioned_env_loader.dart';
import 'package:palakat_shared/core/theme/theme.dart';
import 'package:palakat_shared/core/widgets/file_transfer_progress_banner.dart';
import 'package:palakat_shared/core/widgets/socket_connection_banner.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/services.dart';

import 'core/firebase/firebase_bootstrap.dart';
import 'core/navigation/router.dart';
import 'core/services/super_admin_auth_storage.dart';
import 'features/auth/application/super_admin_auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting();

  try {
    await SectionedEnvLoader.load();
  } catch (e) {
    debugPrint('Warning: Could not load .env file: $e');
    debugPrint('Using default or build-time environment variables');
  }

  await FirebaseBootstrap.initIfConfigured();

  await LocalStorageService.initHive();
  await SuperAdminAuthStorage.ensureBoxOpen();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

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
      fontSizeResolver: (fontSize, instance) => fontSize.toDouble(),
      splitScreenMode: true,
      builder: (context, child) => MaterialApp.router(
        onGenerateTitle: (context) => 'Palakat Super Admin',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: router,
        builder: (context, child) => FocusTraversalGroup(
          policy: WidgetOrderTraversalPolicy(),
          child: FileTransferProgressBanner(
            child: SocketConnectionBanner(
              blockInteractionWhenNotConnected: false,
              child: child,
              getSocket: (ref) => ref.read(superAdminSocketServiceProvider),
            ),
          ),
        ),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    );
  }
}
