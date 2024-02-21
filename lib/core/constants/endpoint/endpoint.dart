class Endpoint {
  static const _firstPrefix = 'api';
  static const _apiVersion = 'v1';
  static const _publicSuffix = 'public';

  static String getPublicPrefix(String service) {
    return '/$_firstPrefix/$service/$_apiVersion/$_publicSuffix';
  }

  static String getPrefix(String service) {
    return '/$_firstPrefix/$service/$_apiVersion';
  }

  // [Api Service]
  static const String _userService = 'mhe-user';
  static const String _authService = 'mhe-auth';
  static const String _featureService = 'mhe-feature';
  static const String _generalDataService = 'mhe-general-data';
  static const String _deliveryService = 'mhe-delivery';
  static const String _patientService = 'mhe-patient';
  static const String _mediaService = 'mhe-media';
  static const String _contentService = 'mhe-content';
  static const String _otpService = 'mhe-otp';
  static const String _appointmentService = 'mhe-appointment';
  static const String _hospitalService = 'mhe-hospital';
  static const String _reviewService = 'mhe-review';
  static const String _pushNotificationService = 'mhe-push-notification';
  static const String _notificationService = 'mhe-notification';

  // [Feature]
  static String featureSet = '${getPublicPrefix(_featureService)}/feature-set';
  static String userFeature = '${getPrefix(_featureService)}/user-feature';

  // [General Data]
  static String generalData =
      '${getPublicPrefix(_generalDataService)}/general-data/{category}';

  // [Signup]
  static String register = '${getPublicPrefix(_userService)}/register';
  static String checkUserWithEmail = '$register/check-email';
  static String checkUserWithPhone = '$register/check-phone';
  static String resendEmail = '$register/resend-email';
  static String verifyEmail = '$register/verify-email';

  // [Login]
  static String login = '${getPublicPrefix(_authService)}/login';
  static String socialProvider =
      '${getPublicPrefix(_authService)}/social-provider';
  static String socialProviderCheckEmail = '$socialProvider/check-email';
  static String loginSocial = '$login/social';
  static String refresh = '$login/refresh';
  static String checkPhone =
      '${getPublicPrefix(_userService)}/login/check-phone';
  static String session = '${getPublicPrefix(_authService)}/session/context';

  // [Password]
  static String forgotPassword =
      '${getPublicPrefix(_userService)}/password/email';
  static String resetPassword =
      '${getPublicPrefix(_userService)}/password/reset';

  // [Profile]
  static String profile = '${getPrefix(_userService)}/profile';
  static String changePassword = '$profile/change-password';

  // [Address]
  static String userAddress = '${getPrefix(_deliveryService)}/user-address';
  static String userAddressDetail = '$userAddress/{serial}';

  // [Patient User]
  static String patientUser = '${getPrefix(_patientService)}/user/patient';
  static String patientUserMrn = '$patientUser/mrn';
  static String patientUserForm = '$patientUser/form';
  static String patientUserDetail = '$patientUser/{serial}';
  static String patientPortal = '$patientUser-portal';
  static String patientPortalCheckStatus = '$patientUser-portal/check-status';

  // [Media]
  static String fileConfig = '${getPublicPrefix(_mediaService)}/config/{code}';
  static String file = '${getPrefix(_mediaService)}/file';

  // [Content]
  static String content = '${getPrefix(_contentService)}/content';
  static String contentPageDetail = '${getPrefix(_contentService)}/page/{code}';

  // [Review]
  static String rating = '${getPrefix(_reviewService)}/rating';

  // [OTP]
  static String requestOtpPublic = '${getPublicPrefix(_otpService)}/otp';
  static String requestOtp = '${getPrefix(_otpService)}/otp';

  // [Appointment]
  static String appointment =
      '${getPrefix(_appointmentService)}/user/appointment';
  static String appointmentCancel = '$appointment/{serial}/cancel';
  static String appointmentManagePersonal =
      '$appointment/{serial}/manage-personal';
  static String appointmentReschedule = '$appointment/{serial}/reschedule';
  static String appointmentDoctorDetail = '$appointment/{serial}';
  static String appointmentType =
      '${getPublicPrefix(_appointmentService)}/appointment/type';

  // [Self Check-in]
  static String selfCheckin = '${getPrefix(_appointmentService)}/self-checkin';

  // [Push notification]
  static String deviceToken =
      '${getPrefix(_pushNotificationService)}/device-token';
  static String deviceTokenDetail = '$deviceToken/{userSerial}';

  // [Notification]
  static String notification =
      '${getPrefix(_notificationService)}/user/notification';
  static String notificationRead = '$notification/{serial}/read';
  static String notificationReadAll = '$notification/read-all';

  // [Hospital]
  static String hospital = '${getPublicPrefix(_hospitalService)}/hospital';
  static String specialist = '${getPublicPrefix(_hospitalService)}/specialist';
  static String location = '${getPublicPrefix(_hospitalService)}/location';
  static String doctor = '${getPublicPrefix(_hospitalService)}/doctor';
  static String doctorDetail =
      '${getPublicPrefix(_hospitalService)}/doctor/{serial}';
  static String doctorPrice = '${getPrefix(_hospitalService)}/doctor-price';
  static String doctorSchedule =
      '${getPrefix(_hospitalService)}/doctor-schedule';
  static String doctorHospitalSchedule =
      '${getPublicPrefix(_hospitalService)}/doctor-hospital-schedule/{serial}';
  static String doctorHospitalSlot =
      '${getPrefix(_hospitalService)}/doctor-hospital-slot';
}
