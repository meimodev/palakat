import 'package:go_router/go_router.dart';
import 'package:palakat/core/routing/app_routing.dart';
import 'package:palakat/features/presentation.dart';

final authenticationRouting = GoRoute(
  path: '/authentication',
  name: AppRoute.authentication,
  builder: (context, state) => const PhoneInputScreen(),
  routes: [
    GoRoute(
      path: 'otp-verification',
      name: AppRoute.otpVerification,
      builder: (context, state) => const OtpVerificationScreen(),
    ),
  ],
);
