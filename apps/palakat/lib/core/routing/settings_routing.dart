import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

/// GoRoute configuration for the settings screen.
///
/// Requirements: 1.1
final settingsRouting = GoRoute(
  path: '/settings',
  name: AppRoute.settings,
  builder: (context, state) => const SettingsScreen(),
  routes: [
    GoRoute(
      path: 'activity-alarms',
      name: AppRoute.alarmSettings,
      builder: (context, state) => const AlarmSettingsScreen(),
    ),
  ],
);
