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
  String get appTitle_admin => 'Palakat Admin';

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
  String get nav_articles => 'Articles';

  @override
  String get songBook_title => 'Song Book';

  @override
  String get songBook_categoriesTitle => 'Song Categories';

  @override
  String get songBook_searchHint => 'Search song title or number';

  @override
  String get songBook_emptyTitle => 'No songs found';

  @override
  String get songBook_emptySubtitle => 'Try searching with different keywords';

  @override
  String get articles_title => 'Articles';

  @override
  String get article_titleFallback => 'Article';

  @override
  String article_likesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count likes',
      one: '1 like',
      zero: '0 likes',
    );
    return '$_temp0';
  }

  @override
  String get articleType_preachingMaterial => 'Preaching Material';

  @override
  String get articleType_gameInstruction => 'Game Instruction';

  @override
  String get map_selectLocationTitle => 'Select Location';

  @override
  String get map_confirmLocation => 'Confirm Location';

  @override
  String get map_locationAccessError =>
      'Unable to access location. Please check location permissions.';

  @override
  String get songDetail_errorLoadingSong => 'Error loading song';

  @override
  String get supervisedActivities_title => 'Supervised Activities';

  @override
  String get supervisedActivities_subtitle =>
      'Activities you are responsible for';

  @override
  String get filter_activityType_label => 'Activity Type';

  @override
  String get filter_activityType_hint => 'Select activity type';

  @override
  String get filter_activityType_allTitle => 'All types';

  @override
  String get filter_activityType_allSubtitle => 'Showing all activity types';

  @override
  String get filter_activityType_allSheetSubtitle => 'Show all activity types';

  @override
  String get activityType_service_desc => 'Church services and worship';

  @override
  String get activityType_event_desc => 'Events and gatherings';

  @override
  String get activityType_announcement_desc => 'Announcements and notices';

  @override
  String get filters_applied => 'Filters applied';

  @override
  String get btn_clearAll => 'Clear all';

  @override
  String get btn_clearFilters => 'Clear filters';

  @override
  String get supervisedActivities_emptyFilteredTitle =>
      'No activities match your filters';

  @override
  String get supervisedActivities_emptyFilteredSubtitle =>
      'Try adjusting your filters to see more results';

  @override
  String get supervisedActivities_emptyTitle => 'No supervised activities';

  @override
  String get supervisedActivities_emptySubtitle =>
      'Activities you supervise will appear here';

  @override
  String get notificationSettings_title => 'Notification Settings';

  @override
  String get notificationSettings_permissionStatus_title => 'Permission Status';

  @override
  String get notificationSettings_permissionEnabled => 'Enabled';

  @override
  String get notificationSettings_permissionDisabled => 'Disabled';

  @override
  String get notificationSettings_permissionEnabledDesc =>
      'You will receive notifications for activities, approvals, and announcements.';

  @override
  String get notificationSettings_permissionDisabledDesc =>
      'Enable notifications to stay updated on activities, approvals, and important announcements.';

  @override
  String get notificationSettings_enableNotifications => 'Enable Notifications';

  @override
  String get notificationPermission_rationale_title => 'Stay Updated';

  @override
  String get notificationPermission_rationale_benefit_activities =>
      'Get notified about new activities and events';

  @override
  String get notificationPermission_rationale_benefit_approvals =>
      'Receive approval requests that need your attention';

  @override
  String get notificationPermission_rationale_benefit_announcements =>
      'Don\'t miss important church announcements';

  @override
  String get notificationPermission_btn_notNow => 'Not Now';

  @override
  String get notificationPermission_consequence_title => 'You\'ll Miss Out On';

  @override
  String get notificationPermission_consequence_item_activities =>
      'Activity notifications and event updates';

  @override
  String get notificationPermission_consequence_item_approvals =>
      'Approval requests that need your action';

  @override
  String get notificationPermission_consequence_item_announcements =>
      'Important church announcements and updates';

  @override
  String get notificationPermission_btn_enableInSettings =>
      'Enable in Settings';

  @override
  String get notificationPermission_btn_continueWithoutNotifications =>
      'Continue Without Notifications';

  @override
  String get notificationSettings_errorLoadingPermissionStatus =>
      'Error loading permission status';

  @override
  String notificationSettings_errorLoadingSettings(String error) {
    return 'Error loading settings: $error';
  }

  @override
  String get notificationSettings_preferences_title =>
      'Notification Preferences';

  @override
  String get notificationSettings_preferences_subtitle =>
      'Choose which types of notifications you want to receive';

  @override
  String get notificationSettings_channel_activityUpdates_title =>
      'Activity Updates';

  @override
  String get notificationSettings_channel_activityUpdates_subtitle =>
      'Notifications about church activities and events';

  @override
  String get notificationSettings_channel_approvalRequests_title =>
      'Approval Requests';

  @override
  String get notificationSettings_channel_approvalRequests_subtitle =>
      'Notifications requiring your approval';

  @override
  String get notificationSettings_channel_generalAnnouncements_title =>
      'General Announcements';

  @override
  String get notificationSettings_channel_generalAnnouncements_subtitle =>
      'General church announcements and updates';

  @override
  String get notificationSettings_soundVibration_title => 'Sound & Vibration';

  @override
  String get notificationSettings_sound_title => 'Sound';

  @override
  String get notificationSettings_sound_subtitle =>
      'Play sound when notifications arrive';

  @override
  String get notificationSettings_vibration_title => 'Vibration';

  @override
  String get notificationSettings_vibration_subtitle =>
      'Vibrate when notifications arrive';

  @override
  String get nav_operations => 'Ops';

  @override
  String get operations_title => 'Operations';

  @override
  String get operations_noPositionsSubtitle =>
      'You don\'t have any operational positions yet';

  @override
  String get operationsCategory_publishing => 'Publishing';

  @override
  String get operationsCategory_financial => 'Financial';

  @override
  String get operationsCategory_reports => 'Reports';

  @override
  String get operationsItem_publish_service_title => 'Publish Service';

  @override
  String get operationsItem_publish_service_desc =>
      'Create and publish church service activities';

  @override
  String get operationsItem_publish_event_title => 'Publish Event';

  @override
  String get operationsItem_publish_event_desc =>
      'Create and publish church events';

  @override
  String get operationsItem_publish_announcement_title =>
      'Publish Announcement';

  @override
  String get operationsItem_publish_announcement_desc =>
      'Create and publish announcements';

  @override
  String get operationsItem_add_income_title => 'Add Revenue';

  @override
  String get operationsItem_add_income_desc =>
      'Record church income and offerings';

  @override
  String get operationsItem_add_expense_title => 'Add Expense';

  @override
  String get operationsItem_add_expense_desc => 'Record church expenses';

  @override
  String get operationsItem_generate_report_title => 'Generate Report';

  @override
  String get operationsItem_generate_report_desc =>
      'Create activity and financial reports';

  @override
  String get operations_noOperationsAvailable => 'No operations available';

  @override
  String get approval_title => 'Approvals';

  @override
  String get approval_filterAll => 'All';

  @override
  String get approval_filterMyAction => 'My Action';

  @override
  String get approval_filterByDate => 'Filter by date';

  @override
  String get approval_noMoreApprovals => 'No more approvals';

  @override
  String get approval_sectionPendingYourAction => 'Pending Your Action';

  @override
  String get approval_sectionPendingOthers => 'Pending Others';

  @override
  String get approval_allCaughtUpTitle => 'All caught up!';

  @override
  String get approval_allCaughtUpSubtitle =>
      'No pending approvals requiring your action';

  @override
  String approval_pendingReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count approvals waiting for your review',
      one: '1 approval waiting for your review',
    );
    return '$_temp0';
  }

  @override
  String get approval_emptyTitle => 'No approvals found';

  @override
  String get approval_emptySubtitle => 'Try adjusting your filters';

  @override
  String get approval_errorTitle => 'Something went wrong';

  @override
  String get approval_confirmApproveTitle => 'Approve Activity?';

  @override
  String get approval_confirmRejectTitle => 'Reject Activity?';

  @override
  String get approval_confirmApproveDescription =>
      'Are you sure you want to approve this activity? This action cannot be undone.';

  @override
  String get approval_confirmRejectDescription =>
      'Are you sure you want to reject this activity? This action cannot be undone.';

  @override
  String get approvalDetail_title => 'Approval Details';

  @override
  String get approvalDetail_notFound =>
      'Approval not found. It may have been removed or is unavailable.';

  @override
  String get approvalDetail_waitingOthers =>
      'Waiting on other approver to either accept or reject this approval';

  @override
  String get approvalDetail_activitySummary_title => 'Activity Summary';

  @override
  String get approvalDetail_financialData_title => 'Financial Data';

  @override
  String get approvalDetail_viewOnMapTooltip => 'View on Map';

  @override
  String get approvalDetail_viewActivityDetails_title =>
      'View Activity Details';

  @override
  String get approvalDetail_viewActivityDetails_subtitle =>
      'See full activity information';

  @override
  String get approvalDetail_accountDescription_label => 'Account Description';

  @override
  String get lbl_coordinates => 'Coordinates';

  @override
  String get activityType_service => 'Service';

  @override
  String get activityType_event => 'Event';

  @override
  String get activityType_announcement => 'Announcement';

  @override
  String approval_snackbarApproved(String activityTitle) {
    return 'Approved: $activityTitle';
  }

  @override
  String approval_snackbarRejected(String activityTitle) {
    return 'Rejected: $activityTitle';
  }

  @override
  String get admin_billing_title => 'Billing Management';

  @override
  String get admin_billing_subtitle =>
      'Manage church billing, payments, and view payment history.';

  @override
  String get admin_approval_title => 'Approvals';

  @override
  String get admin_account_title => 'Account';

  @override
  String get admin_account_subtitle =>
      'Manage your account information and settings';

  @override
  String get admin_activity_title => 'Activity';

  @override
  String get admin_activity_subtitle =>
      'Monitor and manage all church activity.';

  @override
  String get admin_revenue_title => 'Revenue';

  @override
  String get admin_revenue_subtitle => 'Track and manage all revenue sources.';

  @override
  String get admin_member_title => 'Member';

  @override
  String get admin_financial_title => 'Financial Account Numbers';

  @override
  String get admin_financial_subtitle =>
      'Manage financial account numbers for your church.';

  @override
  String get admin_documentSettings_title => 'Document Settings';

  @override
  String get admin_documentSettings_subtitle =>
      'Manage document identity numbers and view recent approvals.';

  @override
  String get admin_documentIdentityNumber_title => 'Document Identity Number';

  @override
  String get admin_documentIdentityNumber_subtitle =>
      'Current template used for new documents.';

  @override
  String get admin_documentDirectory_title => 'Document Directory';

  @override
  String get admin_documentDirectory_subtitle =>
      'A record of all approved church documents.';

  @override
  String get admin_church_title => 'Church Profile';

  @override
  String get admin_church_subtitle =>
      'Manage your church\'s public information and columns.';

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
  String get btn_addAccountNumber => 'Add Account Number';

  @override
  String get btn_generateReport => 'Generate Report';

  @override
  String get btn_recordPayment => 'Record Payment';

  @override
  String get btn_exportReceipt => 'Export Receipt';

  @override
  String get btn_approve => 'Approve';

  @override
  String get btn_reject => 'Reject';

  @override
  String get btn_export => 'Export';

  @override
  String get btn_remove => 'Remove';

  @override
  String get btn_create => 'Create';

  @override
  String get btn_update => 'Update';

  @override
  String get btn_transfer => 'Transfer';

  @override
  String get btn_addRule => 'Add Rule';

  @override
  String get btn_viewAll => 'View All';

  @override
  String get btn_saveChanges => 'Save Changes';

  @override
  String get btn_updatePassword => 'Update Password';

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
  String get lbl_notSpecified => 'Not specified';

  @override
  String get lbl_locationPosition => 'Position';

  @override
  String get lbl_address => 'Address';

  @override
  String get lbl_city => 'City';

  @override
  String get lbl_state => 'State';

  @override
  String get lbl_zipCode => 'Zip Code';

  @override
  String get lbl_date => 'Date';

  @override
  String get lbl_time => 'Time';

  @override
  String get lbl_description => 'Description';

  @override
  String get lbl_amount => 'Amount';

  @override
  String get lbl_currency => 'Currency';

  @override
  String get lbl_openingBalance => 'Opening Balance';

  @override
  String get lbl_balance => 'Balance';

  @override
  String get lbl_from => 'From';

  @override
  String get lbl_to => 'To';

  @override
  String get lbl_search => 'Search';

  @override
  String get lbl_generationType => 'Generation Type';

  @override
  String get lbl_scope => 'Scope';

  @override
  String get lbl_deviceId => 'Device ID';

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
  String lbl_selectAccount(Object type) {
    return 'Select $type Account';
  }

  @override
  String get lbl_searchAccountNumber =>
      'Search account number or description...';

  @override
  String lbl_noResultsFor(Object query) {
    return 'No results found for \"$query\"';
  }

  @override
  String get lbl_noAccountNumbers => 'No account numbers available';

  @override
  String get lbl_churchNotAvailable => 'Church information not available';

  @override
  String get lbl_template => 'Template';

  @override
  String get lbl_na => 'N/A';

  @override
  String get lbl_unknown => 'Unknown';

  @override
  String get lbl_you => 'You';

  @override
  String get lbl_reminder => 'Reminder';

  @override
  String get lbl_targetAudience => 'Target Audience';

  @override
  String lbl_hashId(String id) {
    return '# $id';
  }

  @override
  String lbl_negativeAmount(String amount) {
    return '- $amount';
  }

  @override
  String get timePeriod_morning => 'Morning';

  @override
  String get timePeriod_afternoon => 'Afternoon';

  @override
  String get timePeriod_evening => 'Evening';

  @override
  String get reminder_tenMinutes => '10 minutes before';

  @override
  String get reminder_thirtyMinutes => '30 minutes before';

  @override
  String get reminder_oneHour => '1 hour before';

  @override
  String get reminder_twoHour => '2 hours before';

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
  String err_statusWithCode(Object code, Object label) {
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
  String auth_resendIn(Object seconds) {
    return 'Resend in $seconds seconds';
  }

  @override
  String get dashboard_title => 'Dashboard';

  @override
  String get dashboard_subtitle => 'Summary of your church activities.';

  @override
  String get dashboard_recentActivity => 'Recent Activity';

  @override
  String get dashboard_recent_memberRegistered_title => 'New Member Registered';

  @override
  String get dashboard_recent_memberRegistered_desc =>
      'John Doe joined the congregation';

  @override
  String get dashboard_recent_donationReceived_title => 'Donation Received';

  @override
  String get dashboard_recent_donationReceived_desc =>
      'Tithes and offerings collected';

  @override
  String get dashboard_recent_eventApproved_title => 'Event Approved';

  @override
  String get dashboard_recent_eventApproved_desc =>
      'Youth Fellowship meeting scheduled';

  @override
  String get dashboard_recent_expenseRecorded_title => 'Expense Recorded';

  @override
  String get dashboard_recent_expenseRecorded_desc => 'Utility bills payment';

  @override
  String get dashboard_totalMembers => 'Total Members';

  @override
  String get dashboard_totalRevenue => 'Total Revenue';

  @override
  String get dashboard_totalExpense => 'Total Expense';

  @override
  String get dashboard_membersChange => 'Members this month';

  @override
  String get dashboard_overview => 'Overview';

  @override
  String get dashboard_statistics => 'Statistics';

  @override
  String get msg_pressBackToExit => 'Press back again to exit';

  @override
  String memberCount(num count) {
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
  String get membership_title => 'Membership';

  @override
  String get membership_churchMembership_title => 'Church Membership';

  @override
  String get membership_churchNotRegisteredInfo =>
      'If your church is not registered in our system, you won\'t be able to find it in the list below.';

  @override
  String get membership_notBaptized => 'Not baptized';

  @override
  String get membership_notSidi => 'Not SIDI';

  @override
  String membership_churchRequestAcceptedOn(String churchName, String date) {
    return 'Your church registration request for \'$churchName\' was accepted on $date. We\'ll notify you once it\'s processed.';
  }

  @override
  String membership_churchRequestProcessing(String churchName) {
    return 'Your church registration request for \'$churchName\' is being processed.';
  }

  @override
  String membership_churchRequestCompleted(String churchName) {
    return 'Thanks to you, \'$churchName\' can now be selected from the list below.';
  }

  @override
  String get settings_noMembership => 'No membership available';

  @override
  String get settings_versionUnknown => 'Version unknown';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String settings_versionWithBuild(String version, String buildNumber) {
    return 'Version $version (Build $buildNumber)';
  }

  @override
  String get card_overdueBills_title => 'Overdue Bills';

  @override
  String get card_overdueBills_subtitle =>
      'Bills that require urgent attention';

  @override
  String get card_paymentHistory_title => 'Payment History';

  @override
  String get card_paymentHistory_subtitle =>
      'View all payment transactions and history.';

  @override
  String get card_billingItems_title => 'Billing Items';

  @override
  String get card_billingItems_subtitle =>
      'Manage church billing and payment records.';

  @override
  String card_billingItems_subtitleWithTotal(int total) {
    return 'Manage church billing and payment records. Total items: $total';
  }

  @override
  String get card_approvalRules_title => 'Approval Rules';

  @override
  String get card_approvalRules_subtitle =>
      'Configure approval routing rules and requirements';

  @override
  String get card_memberDirectory_title => 'Member Directory';

  @override
  String get card_memberDirectory_subtitle => 'A record of all church members.';

  @override
  String get card_accountNumbers_title => 'Account Numbers';

  @override
  String get card_accountNumbers_subtitle =>
      'List of all financial account numbers for your church.';

  @override
  String get card_cashAccounts_title => 'Cash Accounts';

  @override
  String get card_cashAccounts_subtitle =>
      'Manage cash accounts and view balances.';

  @override
  String get card_cashMutations_title => 'Cash Mutations';

  @override
  String get card_cashMutations_subtitle =>
      'Track cash movements between accounts.';

  @override
  String get card_basicInfo_title => 'Basic Information';

  @override
  String get card_basicInfo_subtitle =>
      'Church details and contact information';

  @override
  String get card_location_title => 'Location';

  @override
  String get card_location_subtitle =>
      'Church address and geographical information';

  @override
  String get card_columnManagement_title => 'Column Management';

  @override
  String get card_columnManagement_subtitle =>
      'Manage church organizational columns';

  @override
  String get card_positionManagement_title => 'Position Management';

  @override
  String get card_positionManagement_subtitle =>
      'Manage church leadership positions';

  @override
  String get card_revenueRecords_title => 'Revenue Records';

  @override
  String get card_revenueRecords_subtitle => 'Track and manage church revenue.';

  @override
  String get card_revenueLog_title => 'Revenue Log';

  @override
  String get card_revenueLog_subtitle => 'A record of all logged revenue.';

  @override
  String get card_expenseRecords_title => 'Expense Records';

  @override
  String get card_expenseRecords_subtitle =>
      'Track and manage church expenses.';

  @override
  String get card_activityList_title => 'Activity List';

  @override
  String get card_activityList_subtitle =>
      'View all church activities and events.';

  @override
  String get card_documentList_title => 'Documents';

  @override
  String get card_documentList_subtitle => 'Manage church documents and files.';

  @override
  String get card_reportList_title => 'Reports';

  @override
  String get card_reportList_subtitle => 'Generate and view church reports.';

  @override
  String get card_reportHistory_title => 'Report History';

  @override
  String get card_paymentInfo_title => 'Payment Information';

  @override
  String get card_paymentInfo_subtitle =>
      'Details about payment methods and accounts';

  @override
  String get card_recentActivity_title => 'Recent Activity';

  @override
  String get card_recentActivity_subtitle =>
      'Latest church activities and events';

  @override
  String get card_statistics_title => 'Statistics';

  @override
  String get card_statistics_subtitle =>
      'Church performance metrics and analytics';

  @override
  String get card_overview_title => 'Overview';

  @override
  String get card_overview_subtitle => 'Summary of key church information';

  @override
  String get card_accountSettings_title => 'Account Settings';

  @override
  String get card_accountSettings_subtitle =>
      'Manage your personal account preferences';

  @override
  String get card_churchInfo_title => 'Church Information';

  @override
  String get card_churchInfo_subtitle => 'Basic church details and settings';

  @override
  String get card_financialSummary_title => 'Financial Summary';

  @override
  String get card_financialSummary_subtitle =>
      'Overview of church financial status';

  @override
  String get card_accountInfo_title => 'Account Information';

  @override
  String get card_accountInfo_subtitle =>
      'Manage your profile and personal information';

  @override
  String get card_securitySettings_title => 'Security Settings';

  @override
  String get card_securitySettings_subtitle => 'Manage your account security';

  @override
  String get card_languageSettings_title => 'Language Settings';

  @override
  String get card_languageSettings_subtitle => 'Choose your preferred language';

  @override
  String get card_accountActions_title => 'Account Actions';

  @override
  String get card_accountActions_subtitle => 'Manage your account session';

  @override
  String get drawer_addMember_title => 'Add Member';

  @override
  String get drawer_addMember_subtitle => 'Create a new member';

  @override
  String get drawer_editMember_title => 'Edit Member';

  @override
  String get drawer_editMember_subtitle => 'Update member information';

  @override
  String get drawer_addApprovalRule_title => 'Add Approval Rule';

  @override
  String get drawer_addApprovalRule_subtitle => 'Create a new approval rule';

  @override
  String get drawer_editApprovalRule_title => 'Edit Approval Rule';

  @override
  String get drawer_editApprovalRule_subtitle =>
      'Update approval rule information';

  @override
  String get drawer_activityDetails_title => 'Activity Details';

  @override
  String get drawer_activityDetails_subtitle =>
      'View detailed information about this activity';

  @override
  String get drawer_revenueDetails_title => 'Revenue Details';

  @override
  String get drawer_revenueDetails_subtitle =>
      'View detailed information about this revenue entry';

  @override
  String get drawer_expenseDetails_title => 'Expense Details';

  @override
  String get drawer_expenseDetails_subtitle =>
      'View detailed information about this expense entry';

  @override
  String get drawer_editChurchInfo_title => 'Edit Church Information';

  @override
  String get drawer_editChurchInfo_subtitle => 'Update your church details';

  @override
  String get drawer_editLocation_title => 'Edit Location';

  @override
  String get drawer_editLocation_subtitle =>
      'Update address and coordinates for your church';

  @override
  String get drawer_addColumn_title => 'Add Column';

  @override
  String get drawer_addColumn_subtitle => 'Create a new column';

  @override
  String get drawer_editColumn_title => 'Edit Column';

  @override
  String get drawer_editColumn_subtitle => 'Update column information';

  @override
  String get drawer_addPosition_title => 'Add Position';

  @override
  String get drawer_addPosition_subtitle => 'Create a new position';

  @override
  String get drawer_editPosition_title => 'Edit Position';

  @override
  String get drawer_editPosition_subtitle => 'Update position information';

  @override
  String get drawer_addAccountNumber_title => 'Add Account Number';

  @override
  String get drawer_addAccountNumber_subtitle =>
      'Create a new financial account number';

  @override
  String get drawer_editAccountNumber_title => 'Edit Account Number';

  @override
  String get drawer_editAccountNumber_subtitle =>
      'Update the account number details';

  @override
  String get drawer_generateReport_title => 'Generate Report';

  @override
  String get drawer_generateReport_subtitle =>
      'Configure the newly generate report';

  @override
  String get drawer_editDocumentId_title => 'Edit Document Identity Number';

  @override
  String get drawer_editDocumentId_subtitle =>
      'Update the template used for new documents';

  @override
  String get drawer_paymentHistory_title => 'Payment History';

  @override
  String get drawer_paymentHistory_subtitle =>
      'Complete payment transaction history';

  @override
  String get drawer_billingDetails_title => 'Billing Details';

  @override
  String get drawer_editAccountInfo_title => 'Edit Account Information';

  @override
  String get drawer_editAccountInfo_subtitle => 'Update your profile details';

  @override
  String get drawer_changePassword_title => 'Change Password';

  @override
  String get drawer_changePassword_subtitle =>
      'Keep your account secure with a strong password';

  @override
  String get lbl_ruleId => 'Rule ID';

  @override
  String get lbl_ruleName => 'Rule Name';

  @override
  String get lbl_ruleDescription => 'Description (Optional)';

  @override
  String get lbl_activityType => 'Activity Type (Optional)';

  @override
  String get lbl_financialType => 'Financial Type (Optional)';

  @override
  String get lbl_financialAccountNumber => 'Financial Account Number *';

  @override
  String get lbl_positions => 'Positions';

  @override
  String get lbl_memberId => 'Member ID';

  @override
  String get lbl_maritalStatus => 'Marital Status';

  @override
  String get maritalStatus_single => 'Single';

  @override
  String get maritalStatus_married => 'Married';

  @override
  String get lbl_gender => 'Gender';

  @override
  String get gender_male => 'Male';

  @override
  String get gender_female => 'Female';

  @override
  String get account_personalInformation_title => 'Personal Information';

  @override
  String get account_phoneLabel_locked => 'Phone number (cannot be changed)';

  @override
  String get account_phoneLabel_active =>
      'Active phone to receive authentication message';

  @override
  String get account_fullNameLabel =>
      'Name without degree for your church membership';

  @override
  String get account_emailLabel_optional =>
      'Optional email for notifications and communication';

  @override
  String get account_bipraHint => 'Used to determine your BIPRA membership';

  @override
  String get account_claim_title => 'Claim Account';

  @override
  String get account_claimedSubtitle_locked =>
      'Account is claimed and cannot be unclaimed';

  @override
  String get account_claimedSubtitle_unlocked =>
      'Claimed account can only be modified by the owner, not the church';

  @override
  String get account_claimConfirm_title => 'Claim Account?';

  @override
  String get account_claimConfirm_message =>
      'Once the account is claimed, it cannot be unclaimed. Proceed?';

  @override
  String get auth_cancelRegistration_title => 'Cancel Registration?';

  @override
  String get auth_cancelRegistration_message =>
      'Your registration progress will be lost. Are you sure you want to go back?';

  @override
  String get btn_stay => 'Stay';

  @override
  String get btn_goBack => 'Go Back';

  @override
  String get lbl_dateOfBirth => 'Date of Birth';

  @override
  String get lbl_churchName => 'Church Name';

  @override
  String get lbl_churchAddress => 'Church Address';

  @override
  String get lbl_contactPerson => 'Contact Person';

  @override
  String get lbl_phoneNumberOptional => 'Phone Number (Optional)';

  @override
  String get lbl_emailOptional => 'Email (Optional)';

  @override
  String get lbl_descriptionOptional => 'Description (Optional)';

  @override
  String get lbl_latitude => 'Latitude';

  @override
  String get lbl_longitude => 'Longitude';

  @override
  String get lbl_accountNumber => 'Account Number';

  @override
  String get lbl_type => 'Type';

  @override
  String get lbl_columnId => 'Column ID';

  @override
  String get lbl_columnName => 'Column Name';

  @override
  String get lbl_positionId => 'Position ID';

  @override
  String get lbl_positionName => 'Position Name';

  @override
  String get lbl_reportType => 'Report Type';

  @override
  String get lbl_dateRange => 'Date Range';

  @override
  String get lbl_allTime => 'All Time';

  @override
  String get lbl_revenueId => 'Revenue ID';

  @override
  String get lbl_expenseId => 'Expense ID';

  @override
  String get lbl_activityId => 'Activity ID';

  @override
  String get lbl_title => 'Title';

  @override
  String get lbl_activityDateTime => 'Activity Date & Time';

  @override
  String get lbl_note => 'Note';

  @override
  String get lbl_activity => 'Activity';

  @override
  String get lbl_approveOn => 'Approve On';

  @override
  String get lbl_requestedAt => 'Requested At';

  @override
  String get lbl_createdAt => 'Created At';

  @override
  String get lbl_updatedAt => 'Updated At';

  @override
  String get lbl_method => 'Method';

  @override
  String get lbl_transactionId => 'Transaction ID';

  @override
  String get lbl_notes => 'Notes';

  @override
  String get lbl_paidDate => 'Paid Date';

  @override
  String get lbl_payments => 'Payments';

  @override
  String get lbl_bill => 'Bill';

  @override
  String get lbl_optional => '(Optional)';

  @override
  String get lbl_active => 'Active';

  @override
  String get lbl_baptized => 'Baptized';

  @override
  String get lbl_sidi => 'SIDI';

  @override
  String get lbl_noFilters => 'No filters';

  @override
  String get lbl_adminUser => 'Admin User';

  @override
  String get lbl_fullName => 'Full Name';

  @override
  String get lbl_position => 'Position';

  @override
  String get lbl_currentPassword => 'Current Password';

  @override
  String get lbl_newPassword => 'New Password';

  @override
  String get lbl_confirmNewPassword => 'Confirm New Password';

  @override
  String get lbl_changePassword => 'Change Password';

  @override
  String get lbl_changePasswordDesc =>
      'Update your password regularly for security';

  @override
  String get lbl_signOutDesc => 'Sign out from your current session';

  @override
  String get desc_ruleActive => 'This rule is currently active';

  @override
  String get desc_ruleInactive =>
      'This rule is inactive and will not be enforced';

  @override
  String get desc_activityTypeFilter =>
      'When set, this rule only applies to activities of the selected type.';

  @override
  String get desc_financialFilter =>
      'When set, this rule only applies to activities with matching financial data.';

  @override
  String get section_basicInformation => 'Basic Information';

  @override
  String get section_ruleInformation => 'Rule Information';

  @override
  String get section_status => 'Status';

  @override
  String get section_activityTypeFilter => 'Activity Type Filter';

  @override
  String get section_financialFilter => 'Financial Filter';

  @override
  String get section_requiredApprovers => 'Required Approvers';

  @override
  String get section_activityInformation => 'Activity Information';

  @override
  String get section_approval => 'Approval';

  @override
  String get section_approvalStatus => 'Approval Status';

  @override
  String get section_personInCharge => 'Person In Charge';

  @override
  String get section_schedule => 'Schedule';

  @override
  String get section_financialRecord => 'Financial Record';

  @override
  String get section_announcementDetails => 'Announcement Details';

  @override
  String get section_timestamps => 'Timestamps';

  @override
  String get section_locationDetails => 'Location Details';

  @override
  String get section_reportDetails => 'Report Details';

  @override
  String get section_paymentInformation => 'Payment Information';

  @override
  String get section_positionInformation => 'Position Information';

  @override
  String get section_memberInThisPosition => 'Member in this Position';

  @override
  String section_registeredMembers(int count) {
    return 'Registered Members ($count)';
  }

  @override
  String get publish_basicInfoSubtitle => 'Title and target audience';

  @override
  String get publish_hintEnterActivityTitle => 'Enter activity title';

  @override
  String get publish_targetAudienceBipra => 'Target Audience (BIPRA)';

  @override
  String get publish_selectTargetGroup => 'Select target group';

  @override
  String get publish_targetGroup => 'Target Group';

  @override
  String get publish_publishToColumnOnly_title => 'Publish to my column only';

  @override
  String get publish_publishToColumnOnly_subtitle =>
      'Only members in your column will see this activity';

  @override
  String get publish_publishToColumnOnly_subtitleNoColumn =>
      'You are not assigned to a column';

  @override
  String get lbl_general => 'General';

  @override
  String get btn_clear => 'Clear';

  @override
  String get publish_locationSubtitle => 'Where will this take place?';

  @override
  String get publish_hintLocationExample => 'e.g., Church Hall, Host Name';

  @override
  String get publish_lblLocationName => 'Location Name';

  @override
  String get publish_pinOnMapOptional => 'Pin on Map (optional)';

  @override
  String get publish_tapToSelectLocationOptional =>
      'Tap to select location on map (optional)';

  @override
  String get publish_locationSelected => 'Location Selected';

  @override
  String get publish_scheduleSubtitle => 'When will this happen?';

  @override
  String get publish_hintAdditionalNotes =>
      'Any other details attendees should know';

  @override
  String get publish_eventSchedule => 'Event Schedule';

  @override
  String get publish_reminderSubtitle => 'When to notify attendees';

  @override
  String get publish_announcementDetailsSubtitle => 'Content and attachments';

  @override
  String get publish_hintAnnouncement => 'Write your announcement here...';

  @override
  String get publish_uploadFile => 'Upload File';

  @override
  String get publish_supportedFileTypes => 'JPG, PNG, PDF, DOC, DOCX';

  @override
  String get publish_fillAllRequiredFields => 'Please fill all required fields';

  @override
  String get publish_financialRecordSubtitle =>
      'Optional: Attach revenue or expense';

  @override
  String get publish_addFinancialRecord => 'Add Financial Record';

  @override
  String get publish_removeFinancialRecordTitle => 'Remove Financial Record?';

  @override
  String get publish_removeFinancialRecordContent =>
      'Are you sure you want to remove this financial record? This action cannot be undone.';

  @override
  String get publish_publishedNotice =>
      'Published activities can only be managed on mobile app by the corresponding supervisor.';

  @override
  String get publish_publishedByYou => 'Published By You';

  @override
  String get publish_noPublishedActivities => 'No published activities';

  @override
  String get publish_noPublishedActivitiesSubtitle =>
      'Start publishing activities to see them here';

  @override
  String get churchRequest_title => 'Request Church Registration';

  @override
  String get churchRequest_status_onReview => 'On Review';

  @override
  String get churchRequest_status_onProgress => 'On Progress';

  @override
  String get churchRequest_statusMessage_onReview =>
      'Your request is under review and will be processed soon.';

  @override
  String get churchRequest_statusMessage_onProgress =>
      'Your request is being processed.';

  @override
  String get churchRequest_statusMessage_completed =>
      'Your church has been registered! You can now select it when editing membership data.';

  @override
  String get churchRequest_description =>
      'Fill in the details below to request registration for your church. We\'ll review and add it to our system.';

  @override
  String get churchRequest_requesterInformation => 'Requester Information';

  @override
  String get churchRequest_churchInformation => 'Church Information';

  @override
  String get churchRequest_hintEnterContactPersonName =>
      'Enter contact person name';

  @override
  String get churchRequest_hintPhoneExample => '0812-3456-7890';

  @override
  String get churchRequest_submitting => 'Submitting...';

  @override
  String get churchRequest_submitRequest => 'Submit Request';

  @override
  String get churchRequest_fixErrorsBeforeSubmitting =>
      'Please fix the errors above before submitting';

  @override
  String get churchRequest_fillAllRequiredFieldsCorrectly =>
      'Please fill in all required fields correctly';

  @override
  String get churchRequest_submittedSuccessfully =>
      'Church registration request submitted successfully!';

  @override
  String get churchRequest_validation_completeAddress =>
      'Please enter a complete address';

  @override
  String churchRequest_validation_phoneMinDigits(int min) {
    return 'Phone number must be at least $min digits';
  }

  @override
  String churchRequest_validation_phoneMaxDigits(int max) {
    return 'Phone number must not exceed $max digits';
  }

  @override
  String get churchRequest_validation_phoneMustStartWithZero =>
      'Phone number must start with 0';

  @override
  String churchRequest_errorWithDetail(String error) {
    return 'Error: $error';
  }

  @override
  String get hint_enterChurchName => 'Enter church name';

  @override
  String get hint_enterPhoneNumber => 'Enter phone number';

  @override
  String get hint_enterEmailAddress => 'Enter email address';

  @override
  String get hint_describeYourChurch =>
      'Describe your church (visible to members)';

  @override
  String get hint_enterChurchAddress => 'Enter church address';

  @override
  String get hint_latitudeExample => 'e.g. -6.1754';

  @override
  String get hint_longitudeExample => 'e.g. 106.8272';

  @override
  String get hint_enterAccountNumber => 'Enter account number';

  @override
  String get hint_selectActivity => 'Select an activity';

  @override
  String get hint_enterDescription => 'Enter description';

  @override
  String get hint_enterColumnName => 'Enter column name';

  @override
  String get hint_enterPositionName => 'Enter position name';

  @override
  String get hint_enterMemberName => 'Enter member name';

  @override
  String get hint_enterFullName => 'Enter your full name';

  @override
  String get hint_enterYourPhoneNumber => 'Enter your phone number';

  @override
  String get hint_enterYourPosition => 'Enter your position';

  @override
  String get hint_enterCurrentPassword => 'Enter current password';

  @override
  String get hint_enterNewPassword => 'Enter new password';

  @override
  String get hint_reEnterNewPassword => 'Re-enter new password';

  @override
  String get hint_documentIdExample => 'e.g., DOC-2024-001';

  @override
  String get hint_approvalRuleExample => 'e.g. Financial Transactions';

  @override
  String get hint_describeApprovalRule =>
      'Describe when this approval is required';

  @override
  String get hint_allActivityTypes => 'All activity types';

  @override
  String get hint_noFinancialFilter => 'No financial filter';

  @override
  String get hint_selectPositionsToApprove => 'Select positions to approve...';

  @override
  String get hint_signInCredentials =>
      'e.g. name@company.com or 1234-5678-9012';

  @override
  String get hint_searchApprovalRules => 'Search approval rules...';

  @override
  String get hint_searchBillingItems => 'Search billing items...';

  @override
  String get hint_searchByAccountNumber =>
      'Search by account number, activity title...';

  @override
  String get hint_searchByReportName => 'Search by report name...';

  @override
  String get hint_searchNameColumnPosition =>
      'Search name / column / position ...';

  @override
  String get hint_searchByTitleDescription =>
      'Search by title, description, or supervisor name ...';

  @override
  String get hint_searchAccountNumberDescription =>
      'Search by account number or description...';

  @override
  String get dlg_selectPosition_title => 'Select Position';

  @override
  String get hint_searchPositions => 'Search by position name';

  @override
  String get tbl_billId => 'Bill ID';

  @override
  String get tbl_description => 'Description';

  @override
  String get tbl_amount => 'Amount';

  @override
  String get tbl_dueDate => 'Due Date';

  @override
  String get tbl_status => 'Status';

  @override
  String get tbl_paymentId => 'Payment ID';

  @override
  String get tbl_accountId => 'Account ID';

  @override
  String get tbl_method => 'Method';

  @override
  String get tbl_date => 'Date';

  @override
  String get tbl_accountNumber => 'Account Number';

  @override
  String get tbl_activity => 'Activity';

  @override
  String get tbl_requestDate => 'Request Date';

  @override
  String get tbl_approvalDate => 'Approval Date';

  @override
  String get tbl_paymentMethod => 'Payment Method';

  @override
  String get tbl_title => 'Title';

  @override
  String get tbl_type => 'Type';

  @override
  String get tbl_currency => 'Currency';

  @override
  String get tbl_openingBalance => 'Opening Balance';

  @override
  String get tbl_balance => 'Balance';

  @override
  String get tbl_from => 'From';

  @override
  String get tbl_to => 'To';

  @override
  String get tbl_linkedApprovalRule => 'Linked Approval Rule';

  @override
  String get tbl_supervisor => 'Supervisor';

  @override
  String get tbl_approval => 'Approval';

  @override
  String get tbl_approvers => 'Approvers';

  @override
  String get tbl_name => 'Name';

  @override
  String get tbl_phone => 'Phone';

  @override
  String get tbl_birth => 'Birth';

  @override
  String get tbl_bipra => 'BIPRA';

  @override
  String get tbl_positions => 'Positions';

  @override
  String get tbl_ruleName => 'Rule Name';

  @override
  String get tbl_filters => 'Filters';

  @override
  String get tbl_documentName => 'Document Name';

  @override
  String get tbl_createdDate => 'Created Date';

  @override
  String get tbl_reportName => 'Report Name';

  @override
  String get tbl_by => 'By';

  @override
  String get tbl_on => 'On';

  @override
  String get tbl_file => 'File';

  @override
  String get opt_manual => 'Manual';

  @override
  String get opt_system => 'System';

  @override
  String get financeType_revenue => 'Revenue';

  @override
  String get financeType_expense => 'Expense';

  @override
  String get inventoryCondition_good => 'Good';

  @override
  String get inventoryCondition_used => 'Used';

  @override
  String get inventoryCondition_new => 'New';

  @override
  String get inventoryCondition_notApplicable => 'N/A';

  @override
  String get paymentMethod_cash => 'Cash';

  @override
  String get paymentMethod_cashless => 'Cashless';

  @override
  String get paymentMethod_cash_desc => 'Physical currency';

  @override
  String get paymentMethod_cashless_desc => 'Digital payment';

  @override
  String get lbl_selected => 'Selected';

  @override
  String get billingType_subscription => 'Subscription';

  @override
  String get billingType_oneTime => 'One-time';

  @override
  String get billingType_recurring => 'Recurring';

  @override
  String get billingStatus_pending => 'Pending';

  @override
  String get billingStatus_paid => 'Paid';

  @override
  String get billingStatus_overdue => 'Overdue';

  @override
  String get billingStatus_cancelled => 'Cancelled';

  @override
  String get billingStatus_refunded => 'Refunded';

  @override
  String get reportType_incomingDocument => 'Document';

  @override
  String get reportTitle_incomingDocument => 'Document Report';

  @override
  String get reportDesc_incomingDocument =>
      'Generate a report for documents received.';

  @override
  String get reportType_outcomingDocument => 'Outgoing Document';

  @override
  String get reportTitle_outcomingDocument => 'Outgoing Document Report';

  @override
  String get reportDesc_outcomingDocument =>
      'Generate a report for documents sent.';

  @override
  String get reportType_congregation => 'Congregation';

  @override
  String get reportTitle_congregation => 'Congregation Report';

  @override
  String get reportDesc_congregation =>
      'Generate a report on the congregation.';

  @override
  String get reportType_services => 'Services';

  @override
  String get reportTitle_services => 'Services Report';

  @override
  String get reportDesc_services => 'Generate a report of all services.';

  @override
  String get reportType_activity => 'Activity';

  @override
  String get reportTitle_activity => 'Activity Report';

  @override
  String get reportDesc_activity => 'Generate a report for all activities.';

  @override
  String get reportType_financial => 'Financial';

  @override
  String get reportTitle_financial => 'Financial Report';

  @override
  String get reportDesc_financial => 'Generate a financial report.';

  @override
  String get lbl_financialSubtype => 'Financial Variant';

  @override
  String get financialSubtype_revenue => 'Revenue';

  @override
  String get financialSubtype_expense => 'Expense';

  @override
  String get financialSubtype_mutation => 'Mutation';

  @override
  String get lbl_documentInput => 'Document Variant';

  @override
  String get documentInput_income => 'Incoming';

  @override
  String get documentInput_outcome => 'Outgoing';

  @override
  String get lbl_congregationSubtype => 'Congregation Variant';

  @override
  String get congregationSubtype_wartaJemaat => 'Warta Jemaat';

  @override
  String get congregationSubtype_hutJemaat => 'HUT Jemaat';

  @override
  String get congregationSubtype_keanggotaan => 'Keanggotaan';

  @override
  String get dlg_deleteRule_title => 'Delete Rule';

  @override
  String get dlg_deleteRule_content =>
      'Are you sure you want to delete this approval rule?';

  @override
  String get dlg_deleteMember_title => 'Delete Member';

  @override
  String get dlg_deleteMember_content =>
      'Are you sure you want to delete this member? This action cannot be undone.';

  @override
  String get dlg_deletePosition_title => 'Delete Position';

  @override
  String get dlg_deletePosition_content =>
      'Are you sure you want to delete this position? This action cannot be undone.';

  @override
  String get dlg_deleteColumn_title => 'Delete Column';

  @override
  String get dlg_deleteColumn_content =>
      'Are you sure you want to delete this column? This action cannot be undone.';

  @override
  String get dlg_signOut_title => 'Sign Out';

  @override
  String get dlg_signOut_content => 'Are you sure you want to sign out?';

  @override
  String get dlg_recordPayment_title => 'Record Payment';

  @override
  String get dlg_selectFinanceType_title => 'Select Finance Type';

  @override
  String get dlg_confirmAction_title => 'Confirm Action';

  @override
  String get dlg_confirmDelete_title => 'Confirm Delete';

  @override
  String get filter_allStatus => 'All Status';

  @override
  String get filter_allActivityTypes => 'All activity types';

  @override
  String get filter_noFinancialFilter => 'No financial filter';

  @override
  String get filter_paymentMethod => 'Payment Method';

  @override
  String get filter_items => 'Items';

  @override
  String get filter_allPositions => 'All Positions';

  @override
  String filter_allWithLabel(String label) {
    return 'All $label';
  }

  @override
  String get tooltip_clearSearch => 'Clear search';

  @override
  String get msg_tryDifferentSearchTerm => 'Try a different search term';

  @override
  String pagination_showingRows(int showing, int total) {
    return 'Showing $showing of $total rows';
  }

  @override
  String get pagination_rowsPerPage => 'Rows per page';

  @override
  String get pagination_page => 'Page';

  @override
  String pagination_ofPageCount(int pageCount) {
    return 'of $pageCount';
  }

  @override
  String get pagination_previous => 'Previous';

  @override
  String get pagination_next => 'Next';

  @override
  String get dateRangeFilter_quickRangesTooltip => 'Quick ranges';

  @override
  String get dateRangeFilter_thisWeek => 'This week';

  @override
  String get dateRangeFilter_lastWeek => 'Last week';

  @override
  String get dateRangeFilter_thisMonth => 'This month';

  @override
  String get dateRangeFilter_lastMonth => 'Last month';

  @override
  String get dateRangeFilter_clearTooltip => 'Clear date range';

  @override
  String get dateRangePreset_allTime => 'All Time';

  @override
  String get dateRangePreset_today => 'Today';

  @override
  String get dateRangePreset_thisWeek => 'This Week';

  @override
  String get dateRangePreset_thisMonth => 'This Month';

  @override
  String get dateRangePreset_lastWeek => 'Last Week';

  @override
  String get dateRangePreset_lastMonth => 'Last Month';

  @override
  String get dateRangePreset_custom => 'Custom Range';

  @override
  String get msg_saved => 'Saved successfully';

  @override
  String get msg_created => 'Created successfully';

  @override
  String get msg_updated => 'Updated successfully';

  @override
  String get msg_deleted => 'Deleted successfully';

  @override
  String get msg_approvalRuleCreated => 'Approval rule created successfully';

  @override
  String get msg_approvalRuleUpdated => 'Approval rule updated successfully';

  @override
  String get msg_approvalRuleDeleted => 'Approval rule deleted successfully';

  @override
  String get msg_recordedPayment => 'Payment recorded successfully';

  @override
  String get msg_templateUpdated => 'Template updated successfully';

  @override
  String get msg_documentTemplateWarning =>
      'Changing the identity number template may cause certain numbers to be skipped.';

  @override
  String get msg_reportGenerated => 'Report generated successfully';

  @override
  String get msg_signedOut => 'Signed out successfully';

  @override
  String get msg_passwordChanged => 'Password changed successfully';

  @override
  String get msg_accountUpdated => 'Account information updated successfully';

  @override
  String get msg_activityNotFound => 'Activity not found';

  @override
  String get msg_activityApproved => 'Activity approved successfully';

  @override
  String get msg_activityRejected => 'Activity rejected successfully';

  @override
  String get msg_noApproversAssigned => 'No approvers assigned';

  @override
  String btn_viewAllPaymentsWithCount(int count) {
    return 'View All $count payments';
  }

  @override
  String lbl_memberWithId(String membershipId, String name) {
    return '#$membershipId • $name';
  }

  @override
  String lbl_fileSizeMb(String size) {
    return '$size MB';
  }

  @override
  String lbl_dateRangeStartEnd(String start, String end) {
    return '$start - $end';
  }

  @override
  String msg_generatedOn(String date) {
    return 'Generated on $date';
  }

  @override
  String get msg_noGenerationDate => 'No generation date';

  @override
  String get msg_exportComingSoon => 'Export functionality coming soon';

  @override
  String get msg_downloadReportToViewDetails =>
      'To view the full report details, please download the file.';

  @override
  String msg_willBeRemindedAt(String reminderDate) {
    return 'Will be reminded at $reminderDate';
  }

  @override
  String msg_approverCount(int count) {
    return '$count approver(s)';
  }

  @override
  String get msg_opening => 'Opening...';

  @override
  String msg_openingReport(String reportName) {
    return 'Opening $reportName...';
  }

  @override
  String get msg_cannotOpenReportFile => 'Cannot open the report file.';

  @override
  String get msg_reportGenerationMayTakeAWhile =>
      'Generating report might take a while, depending on the data requested.';

  @override
  String get msg_saveFailed => 'Failed to save';

  @override
  String get msg_createFailed => 'Failed to create';

  @override
  String get msg_updateFailed => 'Failed to update';

  @override
  String get msg_deleteFailed => 'Failed to delete';

  @override
  String get msg_createApprovalRuleFailed => 'Failed to create approval rule';

  @override
  String get msg_updateApprovalRuleFailed => 'Failed to update approval rule';

  @override
  String get msg_deleteApprovalRuleFailed => 'Failed to delete approval rule';

  @override
  String get msg_recordPaymentFailed => 'Failed to record payment';

  @override
  String get msg_generateReportFailed => 'Failed to generate report';

  @override
  String get msg_invalidPassword => 'Password must be at least 6 characters';

  @override
  String get msg_passwordMismatch => 'Passwords do not match';

  @override
  String get msg_invalidUrl => 'Invalid URL provided';

  @override
  String get msg_operationFailed => 'Operation failed';

  @override
  String get msg_serverError => 'Server Error';

  @override
  String get msg_badRequest => 'Bad Request';

  @override
  String get msg_unauthorized => 'Unauthorized';

  @override
  String get msg_forbidden => 'Forbidden';

  @override
  String get msg_notFound => 'Not Found';

  @override
  String get msg_conflict => 'Conflict';

  @override
  String get msg_validationError => 'Validation Error';

  @override
  String get msg_tooManyRequests => 'Too Many Requests';

  @override
  String get msg_error => 'Error';

  @override
  String get msg_checkInput => 'Check your input';

  @override
  String get msg_signInAgain => 'Please sign in again';

  @override
  String get unauthorized_signInRequired_title => 'Sign in required';

  @override
  String get unauthorized_signInRequired_message =>
      'This feature is available for signed-in users. Please sign in to continue.';

  @override
  String get msg_insufficientPermissions => 'Insufficient permissions';

  @override
  String get msg_resourceNotFound => 'Resource not found';

  @override
  String get msg_stateConflict => 'State conflict';

  @override
  String get msg_validationFailed => 'Validation failed';

  @override
  String get msg_slowDown => 'Slow down';

  @override
  String get msg_tryAgainLater => 'Please try again later';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_passwordRequired => 'Please enter your password';

  @override
  String get validation_requiredField => 'This field is required';

  @override
  String get validation_invalidEmail => 'Please enter a valid email address';

  @override
  String get validation_invalidPhone => 'Please enter a valid phone number';

  @override
  String get validation_invalidUrl => 'Please enter a valid URL';

  @override
  String get validation_invalidNumber => 'Please enter a valid number';

  @override
  String get validation_accountsMustBeDifferent => 'Accounts must be different';

  @override
  String get validation_invalidDate => 'Please enter a valid date';

  @override
  String validation_minLength(int min) {
    return 'Must be at least $min characters';
  }

  @override
  String validation_maxLength(int max) {
    return 'Must be no more than $max characters';
  }

  @override
  String get validation_passwordTooShort =>
      'Password must be at least 6 characters';

  @override
  String get validation_passwordTooWeak =>
      'Password must contain at least one uppercase letter, one lowercase letter, and one number';

  @override
  String get validation_passwordMismatch => 'Passwords do not match';

  @override
  String get validation_confirmPassword => 'Please confirm your password';

  @override
  String get validation_currentPasswordRequired =>
      'Current password is required';

  @override
  String get validation_newPasswordRequired => 'New password is required';

  @override
  String get validation_invalidAmount => 'Please enter a valid amount';

  @override
  String get validation_amountTooLow => 'Amount must be greater than 0';

  @override
  String get validation_amountTooHigh => 'Amount exceeds maximum limit';

  @override
  String get validation_invalidAccountNumber =>
      'Please enter a valid account number';

  @override
  String get validation_accountNumberExists =>
      'This account number already exists';

  @override
  String get validation_nameRequired => 'Name is required';

  @override
  String get validation_titleRequired => 'Title is required';

  @override
  String get validation_descriptionRequired => 'Description is required';

  @override
  String get validation_addressRequired => 'Address is required';

  @override
  String get validation_phoneRequired => 'Phone number is required';

  @override
  String get validation_emailRequired => 'Email address is required';

  @override
  String get validation_dateRequired => 'Date is required';

  @override
  String get validation_timeRequired => 'Time is required';

  @override
  String get validation_selectionRequired => 'Please make a selection';

  @override
  String get validation_churchRequired => 'Please select a church';

  @override
  String get validation_columnRequired => 'Please select a column';

  @override
  String get validation_positionRequired => 'Please select a position';

  @override
  String get validation_activityTypeRequired =>
      'Please select an activity type';

  @override
  String get validation_financialTypeRequired =>
      'Please select a financial type';

  @override
  String get validation_approverRequired => 'At least one approver is required';

  @override
  String get validation_ruleNameRequired => 'Rule name is required';

  @override
  String get validation_positionsRequired =>
      'At least one position must be selected';

  @override
  String get validation_financialAccountRequired =>
      'Financial account number is required when financial type is selected';

  @override
  String get validation_duplicateEntry => 'This entry already exists';

  @override
  String get validation_invalidFormat => 'Invalid format';

  @override
  String get validation_futureDate => 'Date must be in the future';

  @override
  String get validation_pastDate => 'Date must be in the past';

  @override
  String get validation_invalidRange => 'Invalid date range';

  @override
  String get validation_startDateAfterEnd =>
      'Start date must be before end date';

  @override
  String get validation_coordinatesRequired => 'Coordinates are required';

  @override
  String get validation_invalidLatitude =>
      'Latitude must be between -90 and 90';

  @override
  String get validation_invalidLongitude =>
      'Longitude must be between -180 and 180';

  @override
  String get loading_data => 'Loading data...';

  @override
  String get loading_members => 'Loading members...';

  @override
  String get loading_activities => 'Loading activities...';

  @override
  String get loading_revenue => 'Loading revenue...';

  @override
  String get loading_expenses => 'Loading expenses...';

  @override
  String get loading_reports => 'Loading reports...';

  @override
  String get loading_documents => 'Loading documents...';

  @override
  String get loading_approvals => 'Loading approvals...';

  @override
  String get loading_billing => 'Loading billing...';

  @override
  String get loading_financial => 'Loading financial data...';

  @override
  String get loading_church => 'Loading church information...';

  @override
  String get loading_account => 'Loading account information...';

  @override
  String get loading_please_wait => 'Please wait...';

  @override
  String get loading_saving => 'Saving...';

  @override
  String get loading_deleting => 'Deleting...';

  @override
  String get error_loadingData => 'Failed to load data';

  @override
  String get error_loadingMembers => 'Failed to load members';

  @override
  String get error_loadingActivities => 'Failed to load activities';

  @override
  String get error_loadingRevenue => 'Failed to load revenue';

  @override
  String get error_loadingExpenses => 'Failed to load expenses';

  @override
  String get error_loadingReports => 'Failed to load reports';

  @override
  String get error_loadingDocuments => 'Failed to load documents';

  @override
  String get error_loadingApprovals => 'Failed to load approvals';

  @override
  String get error_loadingBilling => 'Failed to load billing';

  @override
  String get error_loadingFinancial => 'Failed to load financial data';

  @override
  String get error_loadingChurch => 'Failed to load church information';

  @override
  String get error_loadingAccount => 'Failed to load account information';

  @override
  String get error_connectionFailed =>
      'Connection failed. Please check your internet connection.';

  @override
  String get error_timeout => 'Request timed out. Please try again.';

  @override
  String get error_unexpectedError => 'An unexpected error occurred';

  @override
  String get noData_available => 'No data available';

  @override
  String get noData_members => 'No members found';

  @override
  String get noData_activities => 'No activities found';

  @override
  String get noData_revenue => 'No revenue records found';

  @override
  String get noData_expenses => 'No expense records found';

  @override
  String get noData_reports => 'No reports found';

  @override
  String get noData_documents => 'No documents found';

  @override
  String get noData_approvals => 'No approval rules found';

  @override
  String get noData_billing => 'No billing items found';

  @override
  String get noData_financial => 'No financial account numbers found';

  @override
  String get noData_church => 'No church information available';

  @override
  String get noData_results => 'No results found';

  @override
  String get noData_matchingCriteria => 'No data matches your search criteria';

  @override
  String get noData_positions => 'No positions available';

  @override
  String get noData_activityLink => 'Not linked to any activity';

  @override
  String get tooltip_refresh => 'Refresh';

  @override
  String get tooltip_viewActivityDetails => 'View Activity Details';

  @override
  String get tooltip_downloadReport => 'Download Report';

  @override
  String get tooltip_baptized => 'Baptized';

  @override
  String get tooltip_sidi => 'SIDI';

  @override
  String get tooltip_appLinked => 'App Linked';

  @override
  String footer_copyright(int year) {
    return '© $year Palakat. All rights reserved.';
  }

  @override
  String get time_justNow => 'Just now';

  @override
  String time_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String time_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String time_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String stat_changeFromLastMonth(String change) {
    return '+$change from last month';
  }

  @override
  String stat_changePercentFromLastMonth(String change) {
    return '+$change% from last month';
  }

  @override
  String dashboard_recentActivitiesCount(int count) {
    return '$count recent activities';
  }

  @override
  String get dashboard_recentActivitiesEmpty =>
      'Recent transactions and member updates will be shown here.';
}
