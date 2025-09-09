class AppConstants {
  // Authentication constants
  static const int otpTimerDurationSeconds = 120;
  static const int otpLength = 6;
  static const String demoOtpCode = "123456"; // TODO: Remove in production

  // UI constants
  static const double defaultDesignWidth = 360.0;
  static const double defaultDesignHeight = 640.0;

  // Timer constants
  static const Duration timerInterval = Duration(seconds: 1);
  static const Duration networkTimeout = Duration(seconds: 30);

  // Validation constants
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 15;
}
