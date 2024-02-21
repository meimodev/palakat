class ApiFaultCode {
  // [MHE otp]
  static const mheOtpSms = 102001;
  static const mheOtpWa = 103001;
  static const mheOtpIsMandatory = 107007;
  static const mheOtpIsInvalid = 107008;

  // [MHE Auth]
  static const mheAuthNotRegistered = 101002;

  // [MHE User]
  static const mheUserRegisterOtpIncorrect = 101005;
  static const mheUserOtpIncorrect = 101014;

  // [MHE Patient]
  static const mhePatientUserPatientAlreadyRegistered = 107001;
  static const mhePatientCreatePatientOtpIncorrect = 107002;
  static const mhePatientOtpNotVerified = 107003;
  static const mhePatientDataIncompleted = 107005;
}
