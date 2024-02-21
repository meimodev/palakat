import 'package:go_router/go_router.dart';
import 'package:palakat/features/presentation.dart';

final authenticationRouting = GoRoute(
  path: 'authentication',
  builder: (context, state) => const MainScreen(),
  routes: const [

    // GoRoute(
    //   path: 'profile',
    //   name: AppRoute.profile,
    //   builder: (context, state) => const ProfileScreen(),
    // ),
    // GoRoute(
    //   path: 'patient-list',
    //   name: AppRoute.patientList,
    //   builder: (context, state) => const PatientListScreen(),
    // ),
    // GoRoute(
    //   path: 'patient-form',
    //   name: AppRoute.patientForm,
    //   builder: (context, state) => const PatientFormScreen(),
    // ),


  ],
);