// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Palakat';

  @override
  String get nav_dashboard => 'Dashboard';

  @override
  String get nav_members => 'Members';

  @override
  String get nav_activity => 'Activity';

  @override
  String get nav_revenue => 'Revenue';

  @override
  String get nav_expense => 'Expense';

  @override
  String get nav_report => 'Report';

  @override
  String get nav_church => 'Church';

  @override
  String get nav_document => 'Document';

  @override
  String get nav_approval => 'Approval';

  @override
  String get nav_financial => 'Financial';

  @override
  String get nav_billing => 'Billing';

  @override
  String get nav_account => 'Account';

  @override
  String get nav_section_report => 'Report';

  @override
  String get nav_section_administration => 'Administration';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_songs => 'Songs';

  @override
  String get nav_operations => 'Ops';

  @override
  String get btn_continue => 'Continue';

  @override
  String get btn_cancel => 'Cancel';

  @override
  String get btn_save => 'Save';

  @override
  String get btn_delete => 'Delete';

  @override
  String get btn_retry => 'Retry';

  @override
  String get btn_signIn => 'Sign In';

  @override
  String get btn_signOut => 'Sign Out';

  @override
  String get btn_signOutConfirm => 'Sign Out?';

  @override
  String get btn_signOutMessage =>
      'Are you sure you want to sign out? You will need to sign in again to access your account.';

  @override
  String get btn_resendCode => 'Resend Code';

  @override
  String get btn_submit => 'Submit';

  @override
  String get btn_edit => 'Edit';

  @override
  String get btn_add => 'Add';

  @override
  String get btn_close => 'Close';

  @override
  String get btn_confirm => 'Confirm';

  @override
  String get btn_back => 'Back';

  @override
  String get lbl_email => 'Email';

  @override
  String get lbl_phone => 'Phone Number';

  @override
  String get lbl_password => 'Password';

  @override
  String get lbl_language => 'Language';

  @override
  String get lbl_name => 'Name';

  @override
  String get lbl_address => 'Address';

  @override
  String get lbl_date => 'Date';

  @override
  String get lbl_time => 'Time';

  @override
  String get lbl_description => 'Description';

  @override
  String get lbl_amount => 'Amount';

  @override
  String get lbl_search => 'Search';

  @override
  String get lbl_selectChurch => 'Select Church';

  @override
  String get lbl_selectColumn => 'Select Column';

  @override
  String get lbl_searchChurches => 'Search churches...';

  @override
  String get lbl_searchColumns => 'Search columns...';

  @override
  String get lbl_noChurchesFound => 'No churches found';

  @override
  String get lbl_noColumnsFound => 'No columns found';

  @override
  String get lbl_selectChurchFirst => 'Please select a church first';

  @override
  String lbl_selectAccount(String type) {
    return 'Select $type Account';
  }

  @override
  String get lbl_searchAccountNumber =>
      'Search account number or description...';

  @override
  String lbl_noResultsFor(String query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get lbl_noAccountNumbers => 'No account numbers available';

  @override
  String get lbl_churchNotAvailable => 'Church information not available';

  @override
  String get status_approved => 'Approved';

  @override
  String get status_pending => 'Pending';

  @override
  String get status_rejected => 'Rejected';

  @override
  String get status_draft => 'Draft';

  @override
  String get status_completed => 'Completed';

  @override
  String get status_cancelled => 'Cancelled';

  @override
  String get status_active => 'Active';

  @override
  String get status_inactive => 'Inactive';

  @override
  String get status_unconfirmed => 'Unconfirmed';

  @override
  String get err_networkError => 'Network error. Please check your connection.';

  @override
  String get err_serverError => 'Server error. Please try again later.';

  @override
  String get err_unauthorized =>
      'Your session has expired. Please sign in again.';

  @override
  String get err_invalidCredentials => 'Invalid email/phone or password.';

  @override
  String get err_requiredField => 'This field is required.';

  @override
  String get err_invalidEmail => 'Invalid email format.';

  @override
  String get err_invalidPhone => 'Invalid phone number format.';

  @override
  String get err_somethingWentWrong =>
      'Something went wrong. Please try again.';

  @override
  String get err_noData => 'No data available.';

  @override
  String get err_loadFailed => 'Failed to load data.';

  @override
  String get err_badRequest => 'Bad request';

  @override
  String get err_forbidden => 'Forbidden';

  @override
  String get err_notFound => 'Not found';

  @override
  String get err_conflict => 'Conflict';

  @override
  String get err_validationError => 'Validation error';

  @override
  String get err_error => 'Error';

  @override
  String get err_accountLocked =>
      'Your account is temporarily locked. Please wait 5 minutes and try again.';

  @override
  String err_statusWithCode(int code, String label) {
    return '$code • $label';
  }

  @override
  String get auth_welcomeBack => 'Welcome Back';

  @override
  String get auth_signInSubtitle => 'Sign in to your admin account';

  @override
  String get auth_verifyOtp => 'Verify OTP';

  @override
  String get auth_enterCode => 'Enter the verification code sent to';

  @override
  String get auth_verificationSuccessful => 'Verification Successful';

  @override
  String get auth_enterPhoneNumber => 'Enter Phone Number';

  @override
  String get auth_phoneHint => 'Example: 08123456789';

  @override
  String get auth_otpSent => 'OTP code has been sent';

  @override
  String auth_resendIn(int seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get dashboard_subtitle => 'Summary of your church activities.';

  @override
  String get dashboard_totalMembers => 'Total Members';

  @override
  String get dashboard_totalRevenue => 'Total Revenue';

  @override
  String get dashboard_totalExpense => 'Total Expense';

  @override
  String get dashboard_recentActivity => 'Recent Activity';

  @override
  String get dashboard_overview => 'Overview';

  @override
  String get dashboard_statistics => 'Statistics';

  @override
  String get msg_pressBackToExit => 'Press back again to exit';

  @override
  String memberCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
      zero: 'No members',
    );
    return '$_temp0';
  }

  @override
  String get lang_indonesian => 'Bahasa Indonesia';

  @override
  String get lang_english => 'English';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_accountSettings => 'Account Settings';

  @override
  String get settings_membershipSettings => 'Membership Settings';

  @override
  String get settings_noMembership => 'No membership available';
}
