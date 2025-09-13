import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final operationsRouting = GoRoute(
  path: '/operations',
  name: AppRoute.operations,
  builder: (context, state) => const OperationsScreen(),
);
