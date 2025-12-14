import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Palakat'**
  String get appTitle;

  /// No description provided for @appTitle_admin.
  ///
  /// In en, this message translates to:
  /// **'Palakat Admin'**
  String get appTitle_admin;

  /// No description provided for @nav_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get nav_dashboard;

  /// No description provided for @nav_members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get nav_members;

  /// No description provided for @nav_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get nav_activity;

  /// No description provided for @nav_revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get nav_revenue;

  /// No description provided for @nav_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get nav_expense;

  /// No description provided for @nav_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get nav_report;

  /// No description provided for @nav_church.
  ///
  /// In en, this message translates to:
  /// **'Church'**
  String get nav_church;

  /// No description provided for @nav_document.
  ///
  /// In en, this message translates to:
  /// **'Document'**
  String get nav_document;

  /// No description provided for @nav_approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get nav_approval;

  /// No description provided for @nav_financial.
  ///
  /// In en, this message translates to:
  /// **'Financial'**
  String get nav_financial;

  /// No description provided for @nav_billing.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get nav_billing;

  /// No description provided for @nav_account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get nav_account;

  /// No description provided for @nav_section_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get nav_section_report;

  /// No description provided for @nav_section_administration.
  ///
  /// In en, this message translates to:
  /// **'Administration'**
  String get nav_section_administration;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get nav_songs;

  /// No description provided for @nav_operations.
  ///
  /// In en, this message translates to:
  /// **'Ops'**
  String get nav_operations;

  /// No description provided for @approval_title.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get approval_title;

  /// No description provided for @approval_filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get approval_filterAll;

  /// No description provided for @approval_filterMyAction.
  ///
  /// In en, this message translates to:
  /// **'My Action'**
  String get approval_filterMyAction;

  /// No description provided for @approval_filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get approval_filterByDate;

  /// No description provided for @approval_noMoreApprovals.
  ///
  /// In en, this message translates to:
  /// **'No more approvals'**
  String get approval_noMoreApprovals;

  /// No description provided for @approval_sectionPendingYourAction.
  ///
  /// In en, this message translates to:
  /// **'Pending Your Action'**
  String get approval_sectionPendingYourAction;

  /// No description provided for @approval_sectionPendingOthers.
  ///
  /// In en, this message translates to:
  /// **'Pending Others'**
  String get approval_sectionPendingOthers;

  /// No description provided for @approval_allCaughtUpTitle.
  ///
  /// In en, this message translates to:
  /// **'All caught up!'**
  String get approval_allCaughtUpTitle;

  /// No description provided for @approval_allCaughtUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No pending approvals requiring your action'**
  String get approval_allCaughtUpSubtitle;

  /// Text describing how many approvals are waiting for review
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 approval waiting for your review} other{{count} approvals waiting for your review}}'**
  String approval_pendingReviewCount(int count);

  /// No description provided for @approval_emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No approvals found'**
  String get approval_emptyTitle;

  /// No description provided for @approval_emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get approval_emptySubtitle;

  /// No description provided for @approval_errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get approval_errorTitle;

  /// No description provided for @approval_confirmApproveTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve Activity?'**
  String get approval_confirmApproveTitle;

  /// No description provided for @approval_confirmRejectTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Activity?'**
  String get approval_confirmRejectTitle;

  /// No description provided for @approval_confirmApproveDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to approve this activity? This action cannot be undone.'**
  String get approval_confirmApproveDescription;

  /// No description provided for @approval_confirmRejectDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reject this activity? This action cannot be undone.'**
  String get approval_confirmRejectDescription;

  /// Label for activity type SERVICE
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get activityType_service;

  /// Label for activity type EVENT
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get activityType_event;

  /// Label for activity type ANNOUNCEMENT
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get activityType_announcement;

  /// Snackbar text shown after approving an activity
  ///
  /// In en, this message translates to:
  /// **'Approved: {activityTitle}'**
  String approval_snackbarApproved(String activityTitle);

  /// Snackbar text shown after rejecting an activity
  ///
  /// In en, this message translates to:
  /// **'Rejected: {activityTitle}'**
  String approval_snackbarRejected(String activityTitle);

  /// No description provided for @admin_billing_title.
  ///
  /// In en, this message translates to:
  /// **'Billing Management'**
  String get admin_billing_title;

  /// No description provided for @admin_billing_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage church billing, payments, and view payment history.'**
  String get admin_billing_subtitle;

  /// No description provided for @admin_approval_title.
  ///
  /// In en, this message translates to:
  /// **'Approvals'**
  String get admin_approval_title;

  /// No description provided for @admin_account_title.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get admin_account_title;

  /// No description provided for @admin_account_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account information and settings'**
  String get admin_account_subtitle;

  /// No description provided for @admin_activity_title.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get admin_activity_title;

  /// No description provided for @admin_activity_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor and manage all church activity.'**
  String get admin_activity_subtitle;

  /// No description provided for @admin_revenue_title.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get admin_revenue_title;

  /// No description provided for @admin_revenue_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage all revenue sources.'**
  String get admin_revenue_subtitle;

  /// No description provided for @admin_member_title.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get admin_member_title;

  /// No description provided for @admin_financial_title.
  ///
  /// In en, this message translates to:
  /// **'Financial Account Numbers'**
  String get admin_financial_title;

  /// No description provided for @admin_financial_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage financial account numbers for your church.'**
  String get admin_financial_subtitle;

  /// No description provided for @admin_documentSettings_title.
  ///
  /// In en, this message translates to:
  /// **'Document Settings'**
  String get admin_documentSettings_title;

  /// No description provided for @admin_documentSettings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage document identity numbers and view recent approvals.'**
  String get admin_documentSettings_subtitle;

  /// No description provided for @admin_documentIdentityNumber_title.
  ///
  /// In en, this message translates to:
  /// **'Document Identity Number'**
  String get admin_documentIdentityNumber_title;

  /// No description provided for @admin_documentIdentityNumber_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Current template used for new documents.'**
  String get admin_documentIdentityNumber_subtitle;

  /// No description provided for @admin_documentDirectory_title.
  ///
  /// In en, this message translates to:
  /// **'Document Directory'**
  String get admin_documentDirectory_title;

  /// No description provided for @admin_documentDirectory_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A record of all approved church documents.'**
  String get admin_documentDirectory_subtitle;

  /// No description provided for @admin_church_title.
  ///
  /// In en, this message translates to:
  /// **'Church Profile'**
  String get admin_church_title;

  /// No description provided for @admin_church_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your church\'s public information and columns.'**
  String get admin_church_subtitle;

  /// No description provided for @btn_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get btn_continue;

  /// No description provided for @btn_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btn_cancel;

  /// No description provided for @btn_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btn_save;

  /// No description provided for @btn_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btn_delete;

  /// No description provided for @btn_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get btn_retry;

  /// No description provided for @btn_signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get btn_signIn;

  /// No description provided for @btn_signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get btn_signOut;

  /// No description provided for @btn_signOutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get btn_signOutConfirm;

  /// No description provided for @btn_signOutMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out? You will need to sign in again to access your account.'**
  String get btn_signOutMessage;

  /// No description provided for @btn_resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get btn_resendCode;

  /// No description provided for @btn_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get btn_submit;

  /// No description provided for @btn_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get btn_edit;

  /// No description provided for @btn_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get btn_add;

  /// No description provided for @btn_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get btn_close;

  /// No description provided for @btn_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get btn_confirm;

  /// No description provided for @btn_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get btn_back;

  /// No description provided for @btn_addAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Add Account Number'**
  String get btn_addAccountNumber;

  /// No description provided for @btn_generateReport.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get btn_generateReport;

  /// No description provided for @btn_recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get btn_recordPayment;

  /// No description provided for @btn_exportReceipt.
  ///
  /// In en, this message translates to:
  /// **'Export Receipt'**
  String get btn_exportReceipt;

  /// No description provided for @btn_approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get btn_approve;

  /// No description provided for @btn_reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get btn_reject;

  /// No description provided for @btn_export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get btn_export;

  /// No description provided for @btn_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get btn_remove;

  /// No description provided for @btn_create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get btn_create;

  /// No description provided for @btn_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get btn_update;

  /// No description provided for @btn_addRule.
  ///
  /// In en, this message translates to:
  /// **'Add Rule'**
  String get btn_addRule;

  /// No description provided for @btn_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get btn_viewAll;

  /// No description provided for @btn_saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get btn_saveChanges;

  /// No description provided for @btn_updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get btn_updatePassword;

  /// No description provided for @lbl_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get lbl_email;

  /// No description provided for @lbl_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get lbl_phone;

  /// No description provided for @lbl_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get lbl_password;

  /// No description provided for @lbl_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get lbl_language;

  /// No description provided for @lbl_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get lbl_name;

  /// No description provided for @lbl_notSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get lbl_notSpecified;

  /// No description provided for @lbl_locationPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get lbl_locationPosition;

  /// No description provided for @lbl_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get lbl_address;

  /// No description provided for @lbl_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get lbl_city;

  /// No description provided for @lbl_state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get lbl_state;

  /// No description provided for @lbl_zipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get lbl_zipCode;

  /// No description provided for @lbl_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get lbl_description;

  /// No description provided for @lbl_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get lbl_amount;

  /// No description provided for @lbl_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get lbl_search;

  /// No description provided for @lbl_generationType.
  ///
  /// In en, this message translates to:
  /// **'Generation Type'**
  String get lbl_generationType;

  /// No description provided for @lbl_selectChurch.
  ///
  /// In en, this message translates to:
  /// **'Select Church'**
  String get lbl_selectChurch;

  /// No description provided for @lbl_selectColumn.
  ///
  /// In en, this message translates to:
  /// **'Select Column'**
  String get lbl_selectColumn;

  /// No description provided for @lbl_searchChurches.
  ///
  /// In en, this message translates to:
  /// **'Search churches...'**
  String get lbl_searchChurches;

  /// No description provided for @lbl_searchColumns.
  ///
  /// In en, this message translates to:
  /// **'Search columns...'**
  String get lbl_searchColumns;

  /// No description provided for @lbl_noChurchesFound.
  ///
  /// In en, this message translates to:
  /// **'No churches found'**
  String get lbl_noChurchesFound;

  /// No description provided for @lbl_noColumnsFound.
  ///
  /// In en, this message translates to:
  /// **'No columns found'**
  String get lbl_noColumnsFound;

  /// No description provided for @lbl_selectChurchFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a church first'**
  String get lbl_selectChurchFirst;

  /// No description provided for @lbl_selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select {type} Account'**
  String lbl_selectAccount(Object type);

  /// No description provided for @lbl_searchAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Search account number or description...'**
  String get lbl_searchAccountNumber;

  /// No description provided for @lbl_noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results found for \"{query}\"'**
  String lbl_noResultsFor(Object query);

  /// No description provided for @lbl_noAccountNumbers.
  ///
  /// In en, this message translates to:
  /// **'No account numbers available'**
  String get lbl_noAccountNumbers;

  /// No description provided for @lbl_churchNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Church information not available'**
  String get lbl_churchNotAvailable;

  /// No description provided for @lbl_template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get lbl_template;

  /// No description provided for @lbl_na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get lbl_na;

  /// No description provided for @lbl_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get lbl_unknown;

  /// No description provided for @lbl_you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get lbl_you;

  /// No description provided for @lbl_reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get lbl_reminder;

  /// No description provided for @lbl_targetAudience.
  ///
  /// In en, this message translates to:
  /// **'Target Audience'**
  String get lbl_targetAudience;

  /// No description provided for @lbl_hashId.
  ///
  /// In en, this message translates to:
  /// **'# {id}'**
  String lbl_hashId(String id);

  /// No description provided for @lbl_negativeAmount.
  ///
  /// In en, this message translates to:
  /// **'- {amount}'**
  String lbl_negativeAmount(String amount);

  /// No description provided for @timePeriod_morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get timePeriod_morning;

  /// No description provided for @timePeriod_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get timePeriod_afternoon;

  /// No description provided for @timePeriod_evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get timePeriod_evening;

  /// No description provided for @reminder_tenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes before'**
  String get reminder_tenMinutes;

  /// No description provided for @reminder_thirtyMinutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get reminder_thirtyMinutes;

  /// No description provided for @reminder_oneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminder_oneHour;

  /// No description provided for @reminder_twoHour.
  ///
  /// In en, this message translates to:
  /// **'2 hours before'**
  String get reminder_twoHour;

  /// No description provided for @status_approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get status_approved;

  /// No description provided for @status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// No description provided for @status_rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get status_rejected;

  /// No description provided for @status_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get status_draft;

  /// No description provided for @status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_completed;

  /// No description provided for @status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get status_cancelled;

  /// No description provided for @status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get status_active;

  /// No description provided for @status_inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get status_inactive;

  /// No description provided for @status_unconfirmed.
  ///
  /// In en, this message translates to:
  /// **'Unconfirmed'**
  String get status_unconfirmed;

  /// No description provided for @err_networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get err_networkError;

  /// No description provided for @err_serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get err_serverError;

  /// No description provided for @err_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get err_unauthorized;

  /// No description provided for @err_invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email/phone or password.'**
  String get err_invalidCredentials;

  /// No description provided for @err_requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get err_requiredField;

  /// No description provided for @err_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format.'**
  String get err_invalidEmail;

  /// No description provided for @err_invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number format.'**
  String get err_invalidPhone;

  /// No description provided for @err_somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get err_somethingWentWrong;

  /// No description provided for @err_noData.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get err_noData;

  /// No description provided for @err_loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data.'**
  String get err_loadFailed;

  /// No description provided for @err_badRequest.
  ///
  /// In en, this message translates to:
  /// **'Bad request'**
  String get err_badRequest;

  /// No description provided for @err_forbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get err_forbidden;

  /// No description provided for @err_notFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get err_notFound;

  /// No description provided for @err_conflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get err_conflict;

  /// No description provided for @err_validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get err_validationError;

  /// No description provided for @err_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get err_error;

  /// No description provided for @err_accountLocked.
  ///
  /// In en, this message translates to:
  /// **'Your account is temporarily locked. Please wait 5 minutes and try again.'**
  String get err_accountLocked;

  /// No description provided for @err_statusWithCode.
  ///
  /// In en, this message translates to:
  /// **'{code} • {label}'**
  String err_statusWithCode(Object code, Object label);

  /// No description provided for @auth_welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get auth_welcomeBack;

  /// No description provided for @auth_signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your admin account'**
  String get auth_signInSubtitle;

  /// No description provided for @auth_verifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get auth_verifyOtp;

  /// No description provided for @auth_enterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code sent to'**
  String get auth_enterCode;

  /// No description provided for @auth_verificationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Verification Successful'**
  String get auth_verificationSuccessful;

  /// No description provided for @auth_enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Phone Number'**
  String get auth_enterPhoneNumber;

  /// No description provided for @auth_phoneHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 08123456789'**
  String get auth_phoneHint;

  /// No description provided for @auth_otpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP code has been sent'**
  String get auth_otpSent;

  /// No description provided for @auth_resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} seconds'**
  String auth_resendIn(Object seconds);

  /// No description provided for @dashboard_title.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard_title;

  /// No description provided for @dashboard_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Summary of your church activities.'**
  String get dashboard_subtitle;

  /// Dashboard recent activity label
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get dashboard_recentActivity;

  /// No description provided for @dashboard_recent_memberRegistered_title.
  ///
  /// In en, this message translates to:
  /// **'New Member Registered'**
  String get dashboard_recent_memberRegistered_title;

  /// No description provided for @dashboard_recent_memberRegistered_desc.
  ///
  /// In en, this message translates to:
  /// **'John Doe joined the congregation'**
  String get dashboard_recent_memberRegistered_desc;

  /// No description provided for @dashboard_recent_donationReceived_title.
  ///
  /// In en, this message translates to:
  /// **'Donation Received'**
  String get dashboard_recent_donationReceived_title;

  /// No description provided for @dashboard_recent_donationReceived_desc.
  ///
  /// In en, this message translates to:
  /// **'Tithes and offerings collected'**
  String get dashboard_recent_donationReceived_desc;

  /// No description provided for @dashboard_recent_eventApproved_title.
  ///
  /// In en, this message translates to:
  /// **'Event Approved'**
  String get dashboard_recent_eventApproved_title;

  /// No description provided for @dashboard_recent_eventApproved_desc.
  ///
  /// In en, this message translates to:
  /// **'Youth Fellowship meeting scheduled'**
  String get dashboard_recent_eventApproved_desc;

  /// No description provided for @dashboard_recent_expenseRecorded_title.
  ///
  /// In en, this message translates to:
  /// **'Expense Recorded'**
  String get dashboard_recent_expenseRecorded_title;

  /// No description provided for @dashboard_recent_expenseRecorded_desc.
  ///
  /// In en, this message translates to:
  /// **'Utility bills payment'**
  String get dashboard_recent_expenseRecorded_desc;

  /// No description provided for @dashboard_totalMembers.
  ///
  /// In en, this message translates to:
  /// **'Total Members'**
  String get dashboard_totalMembers;

  /// No description provided for @dashboard_totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get dashboard_totalRevenue;

  /// No description provided for @dashboard_totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get dashboard_totalExpense;

  /// No description provided for @dashboard_membersChange.
  ///
  /// In en, this message translates to:
  /// **'Members this month'**
  String get dashboard_membersChange;

  /// No description provided for @dashboard_overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get dashboard_overview;

  /// No description provided for @dashboard_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get dashboard_statistics;

  /// No description provided for @msg_pressBackToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get msg_pressBackToExit;

  /// No description provided for @memberCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No members} =1{1 member} other{{count} members}}'**
  String memberCount(num count);

  /// No description provided for @lang_indonesian.
  ///
  /// In en, this message translates to:
  /// **'Bahasa Indonesia'**
  String get lang_indonesian;

  /// No description provided for @lang_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get lang_english;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settings_accountSettings;

  /// No description provided for @settings_membershipSettings.
  ///
  /// In en, this message translates to:
  /// **'Membership Settings'**
  String get settings_membershipSettings;

  /// No description provided for @settings_noMembership.
  ///
  /// In en, this message translates to:
  /// **'No membership available'**
  String get settings_noMembership;

  /// No description provided for @card_overdueBills_title.
  ///
  /// In en, this message translates to:
  /// **'Overdue Bills'**
  String get card_overdueBills_title;

  /// No description provided for @card_overdueBills_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Bills that require urgent attention'**
  String get card_overdueBills_subtitle;

  /// No description provided for @card_paymentHistory_title.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get card_paymentHistory_title;

  /// No description provided for @card_paymentHistory_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View all payment transactions and history.'**
  String get card_paymentHistory_subtitle;

  /// No description provided for @card_billingItems_title.
  ///
  /// In en, this message translates to:
  /// **'Billing Items'**
  String get card_billingItems_title;

  /// No description provided for @card_billingItems_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage church billing and payment records.'**
  String get card_billingItems_subtitle;

  /// No description provided for @card_billingItems_subtitleWithTotal.
  ///
  /// In en, this message translates to:
  /// **'Manage church billing and payment records. Total items: {total}'**
  String card_billingItems_subtitleWithTotal(int total);

  /// No description provided for @card_approvalRules_title.
  ///
  /// In en, this message translates to:
  /// **'Approval Rules'**
  String get card_approvalRules_title;

  /// No description provided for @card_approvalRules_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure approval routing rules and requirements'**
  String get card_approvalRules_subtitle;

  /// No description provided for @card_memberDirectory_title.
  ///
  /// In en, this message translates to:
  /// **'Member Directory'**
  String get card_memberDirectory_title;

  /// No description provided for @card_memberDirectory_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A record of all church members.'**
  String get card_memberDirectory_subtitle;

  /// No description provided for @card_accountNumbers_title.
  ///
  /// In en, this message translates to:
  /// **'Account Numbers'**
  String get card_accountNumbers_title;

  /// No description provided for @card_accountNumbers_subtitle.
  ///
  /// In en, this message translates to:
  /// **'List of all financial account numbers for your church.'**
  String get card_accountNumbers_subtitle;

  /// No description provided for @card_basicInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get card_basicInfo_title;

  /// No description provided for @card_basicInfo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Church details and contact information'**
  String get card_basicInfo_subtitle;

  /// No description provided for @card_location_title.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get card_location_title;

  /// No description provided for @card_location_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Church address and geographical information'**
  String get card_location_subtitle;

  /// No description provided for @card_columnManagement_title.
  ///
  /// In en, this message translates to:
  /// **'Column Management'**
  String get card_columnManagement_title;

  /// No description provided for @card_columnManagement_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage church organizational columns'**
  String get card_columnManagement_subtitle;

  /// No description provided for @card_positionManagement_title.
  ///
  /// In en, this message translates to:
  /// **'Position Management'**
  String get card_positionManagement_title;

  /// No description provided for @card_positionManagement_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage church leadership positions'**
  String get card_positionManagement_subtitle;

  /// No description provided for @card_revenueRecords_title.
  ///
  /// In en, this message translates to:
  /// **'Revenue Records'**
  String get card_revenueRecords_title;

  /// No description provided for @card_revenueRecords_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage church revenue.'**
  String get card_revenueRecords_subtitle;

  /// No description provided for @card_revenueLog_title.
  ///
  /// In en, this message translates to:
  /// **'Revenue Log'**
  String get card_revenueLog_title;

  /// No description provided for @card_revenueLog_subtitle.
  ///
  /// In en, this message translates to:
  /// **'A record of all logged revenue.'**
  String get card_revenueLog_subtitle;

  /// No description provided for @card_expenseRecords_title.
  ///
  /// In en, this message translates to:
  /// **'Expense Records'**
  String get card_expenseRecords_title;

  /// No description provided for @card_expenseRecords_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Track and manage church expenses.'**
  String get card_expenseRecords_subtitle;

  /// No description provided for @card_activityList_title.
  ///
  /// In en, this message translates to:
  /// **'Activity List'**
  String get card_activityList_title;

  /// No description provided for @card_activityList_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View all church activities and events.'**
  String get card_activityList_subtitle;

  /// No description provided for @card_documentList_title.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get card_documentList_title;

  /// No description provided for @card_documentList_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage church documents and files.'**
  String get card_documentList_subtitle;

  /// No description provided for @card_reportList_title.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get card_reportList_title;

  /// No description provided for @card_reportList_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate and view church reports.'**
  String get card_reportList_subtitle;

  /// No description provided for @card_reportHistory_title.
  ///
  /// In en, this message translates to:
  /// **'Report History'**
  String get card_reportHistory_title;

  /// No description provided for @card_paymentInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get card_paymentInfo_title;

  /// No description provided for @card_paymentInfo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Details about payment methods and accounts'**
  String get card_paymentInfo_subtitle;

  /// No description provided for @card_recentActivity_title.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get card_recentActivity_title;

  /// No description provided for @card_recentActivity_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest church activities and events'**
  String get card_recentActivity_subtitle;

  /// No description provided for @card_statistics_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get card_statistics_title;

  /// No description provided for @card_statistics_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Church performance metrics and analytics'**
  String get card_statistics_subtitle;

  /// No description provided for @card_overview_title.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get card_overview_title;

  /// No description provided for @card_overview_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Summary of key church information'**
  String get card_overview_subtitle;

  /// No description provided for @card_accountSettings_title.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get card_accountSettings_title;

  /// No description provided for @card_accountSettings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your personal account preferences'**
  String get card_accountSettings_subtitle;

  /// No description provided for @card_churchInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Church Information'**
  String get card_churchInfo_title;

  /// No description provided for @card_churchInfo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Basic church details and settings'**
  String get card_churchInfo_subtitle;

  /// No description provided for @card_financialSummary_title.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get card_financialSummary_title;

  /// No description provided for @card_financialSummary_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of church financial status'**
  String get card_financialSummary_subtitle;

  /// No description provided for @card_accountInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get card_accountInfo_title;

  /// No description provided for @card_accountInfo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and personal information'**
  String get card_accountInfo_subtitle;

  /// No description provided for @card_securitySettings_title.
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get card_securitySettings_title;

  /// No description provided for @card_securitySettings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account security'**
  String get card_securitySettings_subtitle;

  /// No description provided for @card_languageSettings_title.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get card_languageSettings_title;

  /// No description provided for @card_languageSettings_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get card_languageSettings_subtitle;

  /// No description provided for @card_accountActions_title.
  ///
  /// In en, this message translates to:
  /// **'Account Actions'**
  String get card_accountActions_title;

  /// No description provided for @card_accountActions_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your account session'**
  String get card_accountActions_subtitle;

  /// No description provided for @drawer_addMember_title.
  ///
  /// In en, this message translates to:
  /// **'Add Member'**
  String get drawer_addMember_title;

  /// No description provided for @drawer_addMember_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new member'**
  String get drawer_addMember_subtitle;

  /// No description provided for @drawer_editMember_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Member'**
  String get drawer_editMember_title;

  /// No description provided for @drawer_editMember_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update member information'**
  String get drawer_editMember_subtitle;

  /// No description provided for @drawer_addApprovalRule_title.
  ///
  /// In en, this message translates to:
  /// **'Add Approval Rule'**
  String get drawer_addApprovalRule_title;

  /// No description provided for @drawer_addApprovalRule_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new approval rule'**
  String get drawer_addApprovalRule_subtitle;

  /// No description provided for @drawer_editApprovalRule_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Approval Rule'**
  String get drawer_editApprovalRule_title;

  /// No description provided for @drawer_editApprovalRule_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update approval rule information'**
  String get drawer_editApprovalRule_subtitle;

  /// No description provided for @drawer_activityDetails_title.
  ///
  /// In en, this message translates to:
  /// **'Activity Details'**
  String get drawer_activityDetails_title;

  /// No description provided for @drawer_activityDetails_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View detailed information about this activity'**
  String get drawer_activityDetails_subtitle;

  /// No description provided for @drawer_revenueDetails_title.
  ///
  /// In en, this message translates to:
  /// **'Revenue Details'**
  String get drawer_revenueDetails_title;

  /// No description provided for @drawer_revenueDetails_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View detailed information about this revenue entry'**
  String get drawer_revenueDetails_subtitle;

  /// No description provided for @drawer_expenseDetails_title.
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get drawer_expenseDetails_title;

  /// No description provided for @drawer_expenseDetails_subtitle.
  ///
  /// In en, this message translates to:
  /// **'View detailed information about this expense entry'**
  String get drawer_expenseDetails_subtitle;

  /// No description provided for @drawer_editChurchInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Church Information'**
  String get drawer_editChurchInfo_title;

  /// No description provided for @drawer_editChurchInfo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your church details'**
  String get drawer_editChurchInfo_subtitle;

  /// No description provided for @drawer_editLocation_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get drawer_editLocation_title;

  /// No description provided for @drawer_editLocation_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update address and coordinates for your church'**
  String get drawer_editLocation_subtitle;

  /// No description provided for @drawer_addColumn_title.
  ///
  /// In en, this message translates to:
  /// **'Add Column'**
  String get drawer_addColumn_title;

  /// No description provided for @drawer_addColumn_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new column'**
  String get drawer_addColumn_subtitle;

  /// No description provided for @drawer_editColumn_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Column'**
  String get drawer_editColumn_title;

  /// No description provided for @drawer_editColumn_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update column information'**
  String get drawer_editColumn_subtitle;

  /// No description provided for @drawer_addPosition_title.
  ///
  /// In en, this message translates to:
  /// **'Add Position'**
  String get drawer_addPosition_title;

  /// No description provided for @drawer_addPosition_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new position'**
  String get drawer_addPosition_subtitle;

  /// No description provided for @drawer_editPosition_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Position'**
  String get drawer_editPosition_title;

  /// No description provided for @drawer_editPosition_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update position information'**
  String get drawer_editPosition_subtitle;

  /// No description provided for @drawer_addAccountNumber_title.
  ///
  /// In en, this message translates to:
  /// **'Add Account Number'**
  String get drawer_addAccountNumber_title;

  /// No description provided for @drawer_addAccountNumber_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a new financial account number'**
  String get drawer_addAccountNumber_subtitle;

  /// No description provided for @drawer_editAccountNumber_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Account Number'**
  String get drawer_editAccountNumber_title;

  /// No description provided for @drawer_editAccountNumber_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the account number details'**
  String get drawer_editAccountNumber_subtitle;

  /// No description provided for @drawer_generateReport_title.
  ///
  /// In en, this message translates to:
  /// **'Generate Report'**
  String get drawer_generateReport_title;

  /// No description provided for @drawer_generateReport_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Configure the newly generate report'**
  String get drawer_generateReport_subtitle;

  /// No description provided for @drawer_editDocumentId_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Document Identity Number'**
  String get drawer_editDocumentId_title;

  /// No description provided for @drawer_editDocumentId_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update the template used for new documents'**
  String get drawer_editDocumentId_subtitle;

  /// No description provided for @drawer_paymentHistory_title.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get drawer_paymentHistory_title;

  /// No description provided for @drawer_paymentHistory_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete payment transaction history'**
  String get drawer_paymentHistory_subtitle;

  /// No description provided for @drawer_billingDetails_title.
  ///
  /// In en, this message translates to:
  /// **'Billing Details'**
  String get drawer_billingDetails_title;

  /// No description provided for @drawer_editAccountInfo_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Account Information'**
  String get drawer_editAccountInfo_title;

  /// No description provided for @drawer_editAccountInfo_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your profile details'**
  String get drawer_editAccountInfo_subtitle;

  /// No description provided for @drawer_changePassword_title.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get drawer_changePassword_title;

  /// No description provided for @drawer_changePassword_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your account secure with a strong password'**
  String get drawer_changePassword_subtitle;

  /// No description provided for @lbl_ruleId.
  ///
  /// In en, this message translates to:
  /// **'Rule ID'**
  String get lbl_ruleId;

  /// No description provided for @lbl_ruleName.
  ///
  /// In en, this message translates to:
  /// **'Rule Name'**
  String get lbl_ruleName;

  /// No description provided for @lbl_ruleDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get lbl_ruleDescription;

  /// No description provided for @lbl_activityType.
  ///
  /// In en, this message translates to:
  /// **'Activity Type (Optional)'**
  String get lbl_activityType;

  /// No description provided for @lbl_financialType.
  ///
  /// In en, this message translates to:
  /// **'Financial Type (Optional)'**
  String get lbl_financialType;

  /// No description provided for @lbl_financialAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Financial Account Number *'**
  String get lbl_financialAccountNumber;

  /// No description provided for @lbl_positions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get lbl_positions;

  /// No description provided for @lbl_memberId.
  ///
  /// In en, this message translates to:
  /// **'Member ID'**
  String get lbl_memberId;

  /// No description provided for @lbl_maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get lbl_maritalStatus;

  /// No description provided for @lbl_gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get lbl_gender;

  /// No description provided for @lbl_dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get lbl_dateOfBirth;

  /// No description provided for @lbl_churchName.
  ///
  /// In en, this message translates to:
  /// **'Church Name'**
  String get lbl_churchName;

  /// Label for church address field
  ///
  /// In en, this message translates to:
  /// **'Church Address'**
  String get lbl_churchAddress;

  /// Label for contact person field
  ///
  /// In en, this message translates to:
  /// **'Contact Person'**
  String get lbl_contactPerson;

  /// No description provided for @lbl_phoneNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone Number (Optional)'**
  String get lbl_phoneNumberOptional;

  /// No description provided for @lbl_emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get lbl_emailOptional;

  /// No description provided for @lbl_descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get lbl_descriptionOptional;

  /// No description provided for @lbl_latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get lbl_latitude;

  /// No description provided for @lbl_longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get lbl_longitude;

  /// No description provided for @lbl_accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get lbl_accountNumber;

  /// No description provided for @lbl_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get lbl_type;

  /// No description provided for @lbl_columnId.
  ///
  /// In en, this message translates to:
  /// **'Column ID'**
  String get lbl_columnId;

  /// No description provided for @lbl_columnName.
  ///
  /// In en, this message translates to:
  /// **'Column Name'**
  String get lbl_columnName;

  /// No description provided for @lbl_positionId.
  ///
  /// In en, this message translates to:
  /// **'Position ID'**
  String get lbl_positionId;

  /// No description provided for @lbl_positionName.
  ///
  /// In en, this message translates to:
  /// **'Position Name'**
  String get lbl_positionName;

  /// No description provided for @lbl_reportType.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get lbl_reportType;

  /// No description provided for @lbl_dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get lbl_dateRange;

  /// No description provided for @lbl_allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get lbl_allTime;

  /// No description provided for @lbl_revenueId.
  ///
  /// In en, this message translates to:
  /// **'Revenue ID'**
  String get lbl_revenueId;

  /// No description provided for @lbl_expenseId.
  ///
  /// In en, this message translates to:
  /// **'Expense ID'**
  String get lbl_expenseId;

  /// No description provided for @lbl_activityId.
  ///
  /// In en, this message translates to:
  /// **'Activity ID'**
  String get lbl_activityId;

  /// No description provided for @lbl_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get lbl_title;

  /// No description provided for @lbl_activityDateTime.
  ///
  /// In en, this message translates to:
  /// **'Activity Date & Time'**
  String get lbl_activityDateTime;

  /// No description provided for @lbl_note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get lbl_note;

  /// No description provided for @lbl_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get lbl_activity;

  /// No description provided for @lbl_approveOn.
  ///
  /// In en, this message translates to:
  /// **'Approve On'**
  String get lbl_approveOn;

  /// No description provided for @lbl_requestedAt.
  ///
  /// In en, this message translates to:
  /// **'Requested At'**
  String get lbl_requestedAt;

  /// No description provided for @lbl_createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created At'**
  String get lbl_createdAt;

  /// No description provided for @lbl_updatedAt.
  ///
  /// In en, this message translates to:
  /// **'Updated At'**
  String get lbl_updatedAt;

  /// No description provided for @lbl_method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get lbl_method;

  /// No description provided for @lbl_transactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get lbl_transactionId;

  /// No description provided for @lbl_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get lbl_notes;

  /// No description provided for @lbl_paidDate.
  ///
  /// In en, this message translates to:
  /// **'Paid Date'**
  String get lbl_paidDate;

  /// No description provided for @lbl_payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get lbl_payments;

  /// No description provided for @lbl_bill.
  ///
  /// In en, this message translates to:
  /// **'Bill'**
  String get lbl_bill;

  /// No description provided for @lbl_optional.
  ///
  /// In en, this message translates to:
  /// **'(Optional)'**
  String get lbl_optional;

  /// No description provided for @lbl_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get lbl_active;

  /// No description provided for @lbl_baptized.
  ///
  /// In en, this message translates to:
  /// **'Baptized'**
  String get lbl_baptized;

  /// No description provided for @lbl_sidi.
  ///
  /// In en, this message translates to:
  /// **'SIDI'**
  String get lbl_sidi;

  /// No description provided for @lbl_noFilters.
  ///
  /// In en, this message translates to:
  /// **'No filters'**
  String get lbl_noFilters;

  /// No description provided for @lbl_adminUser.
  ///
  /// In en, this message translates to:
  /// **'Admin User'**
  String get lbl_adminUser;

  /// No description provided for @lbl_fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get lbl_fullName;

  /// No description provided for @lbl_position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get lbl_position;

  /// No description provided for @lbl_currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get lbl_currentPassword;

  /// No description provided for @lbl_newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get lbl_newPassword;

  /// No description provided for @lbl_confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get lbl_confirmNewPassword;

  /// No description provided for @lbl_changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get lbl_changePassword;

  /// No description provided for @lbl_changePasswordDesc.
  ///
  /// In en, this message translates to:
  /// **'Update your password regularly for security'**
  String get lbl_changePasswordDesc;

  /// No description provided for @lbl_signOutDesc.
  ///
  /// In en, this message translates to:
  /// **'Sign out from your current session'**
  String get lbl_signOutDesc;

  /// No description provided for @desc_ruleActive.
  ///
  /// In en, this message translates to:
  /// **'This rule is currently active'**
  String get desc_ruleActive;

  /// No description provided for @desc_ruleInactive.
  ///
  /// In en, this message translates to:
  /// **'This rule is inactive and will not be enforced'**
  String get desc_ruleInactive;

  /// No description provided for @desc_activityTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'When set, this rule only applies to activities of the selected type.'**
  String get desc_activityTypeFilter;

  /// No description provided for @desc_financialFilter.
  ///
  /// In en, this message translates to:
  /// **'When set, this rule only applies to activities with matching financial data.'**
  String get desc_financialFilter;

  /// No description provided for @section_basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get section_basicInformation;

  /// No description provided for @section_ruleInformation.
  ///
  /// In en, this message translates to:
  /// **'Rule Information'**
  String get section_ruleInformation;

  /// No description provided for @section_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get section_status;

  /// No description provided for @section_activityTypeFilter.
  ///
  /// In en, this message translates to:
  /// **'Activity Type Filter'**
  String get section_activityTypeFilter;

  /// No description provided for @section_financialFilter.
  ///
  /// In en, this message translates to:
  /// **'Financial Filter'**
  String get section_financialFilter;

  /// No description provided for @section_requiredApprovers.
  ///
  /// In en, this message translates to:
  /// **'Required Approvers'**
  String get section_requiredApprovers;

  /// No description provided for @section_activityInformation.
  ///
  /// In en, this message translates to:
  /// **'Activity Information'**
  String get section_activityInformation;

  /// No description provided for @section_approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get section_approval;

  /// No description provided for @section_approvalStatus.
  ///
  /// In en, this message translates to:
  /// **'Approval Status'**
  String get section_approvalStatus;

  /// No description provided for @section_personInCharge.
  ///
  /// In en, this message translates to:
  /// **'Person In Charge'**
  String get section_personInCharge;

  /// No description provided for @section_schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get section_schedule;

  /// No description provided for @section_financialRecord.
  ///
  /// In en, this message translates to:
  /// **'Financial Record'**
  String get section_financialRecord;

  /// No description provided for @section_announcementDetails.
  ///
  /// In en, this message translates to:
  /// **'Announcement Details'**
  String get section_announcementDetails;

  /// No description provided for @section_timestamps.
  ///
  /// In en, this message translates to:
  /// **'Timestamps'**
  String get section_timestamps;

  /// No description provided for @section_locationDetails.
  ///
  /// In en, this message translates to:
  /// **'Location Details'**
  String get section_locationDetails;

  /// No description provided for @section_reportDetails.
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get section_reportDetails;

  /// No description provided for @section_paymentInformation.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get section_paymentInformation;

  /// No description provided for @section_positionInformation.
  ///
  /// In en, this message translates to:
  /// **'Position Information'**
  String get section_positionInformation;

  /// No description provided for @section_memberInThisPosition.
  ///
  /// In en, this message translates to:
  /// **'Member in this Position'**
  String get section_memberInThisPosition;

  /// No description provided for @section_registeredMembers.
  ///
  /// In en, this message translates to:
  /// **'Registered Members ({count})'**
  String section_registeredMembers(int count);

  /// No description provided for @publish_basicInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Title and target audience'**
  String get publish_basicInfoSubtitle;

  /// No description provided for @publish_hintEnterActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter activity title'**
  String get publish_hintEnterActivityTitle;

  /// No description provided for @publish_targetAudienceBipra.
  ///
  /// In en, this message translates to:
  /// **'Target Audience (BIPRA)'**
  String get publish_targetAudienceBipra;

  /// No description provided for @publish_selectTargetGroup.
  ///
  /// In en, this message translates to:
  /// **'Select target group'**
  String get publish_selectTargetGroup;

  /// No description provided for @publish_targetGroup.
  ///
  /// In en, this message translates to:
  /// **'Target Group'**
  String get publish_targetGroup;

  /// No description provided for @publish_locationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where will this take place?'**
  String get publish_locationSubtitle;

  /// No description provided for @publish_hintLocationExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., Church Hall, Host Name'**
  String get publish_hintLocationExample;

  /// No description provided for @publish_lblLocationName.
  ///
  /// In en, this message translates to:
  /// **'Location Name'**
  String get publish_lblLocationName;

  /// No description provided for @publish_pinOnMapOptional.
  ///
  /// In en, this message translates to:
  /// **'Pin on Map (optional)'**
  String get publish_pinOnMapOptional;

  /// No description provided for @publish_tapToSelectLocationOptional.
  ///
  /// In en, this message translates to:
  /// **'Tap to select location on map (optional)'**
  String get publish_tapToSelectLocationOptional;

  /// No description provided for @publish_locationSelected.
  ///
  /// In en, this message translates to:
  /// **'Location Selected'**
  String get publish_locationSelected;

  /// No description provided for @publish_scheduleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When will this happen?'**
  String get publish_scheduleSubtitle;

  /// No description provided for @publish_hintAdditionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Any other details attendees should know'**
  String get publish_hintAdditionalNotes;

  /// No description provided for @publish_eventSchedule.
  ///
  /// In en, this message translates to:
  /// **'Event Schedule'**
  String get publish_eventSchedule;

  /// No description provided for @publish_reminderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'When to notify attendees'**
  String get publish_reminderSubtitle;

  /// No description provided for @publish_announcementDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Content and attachments'**
  String get publish_announcementDetailsSubtitle;

  /// No description provided for @publish_hintAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Write your announcement here...'**
  String get publish_hintAnnouncement;

  /// No description provided for @publish_uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get publish_uploadFile;

  /// No description provided for @publish_supportedFileTypes.
  ///
  /// In en, this message translates to:
  /// **'JPG, PNG, PDF, DOC, DOCX'**
  String get publish_supportedFileTypes;

  /// No description provided for @publish_fillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields'**
  String get publish_fillAllRequiredFields;

  /// No description provided for @publish_financialRecordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional: Attach revenue or expense'**
  String get publish_financialRecordSubtitle;

  /// No description provided for @publish_addFinancialRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Financial Record'**
  String get publish_addFinancialRecord;

  /// No description provided for @publish_removeFinancialRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Financial Record?'**
  String get publish_removeFinancialRecordTitle;

  /// No description provided for @publish_removeFinancialRecordContent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this financial record? This action cannot be undone.'**
  String get publish_removeFinancialRecordContent;

  /// No description provided for @publish_publishedNotice.
  ///
  /// In en, this message translates to:
  /// **'Published activities can only be managed on mobile app by the corresponding supervisor.'**
  String get publish_publishedNotice;

  /// Title for church registration request bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Request Church Registration'**
  String get churchRequest_title;

  /// Description text for church registration request bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to request registration for your church. We\'ll review and add it to our system.'**
  String get churchRequest_description;

  /// Section title for requester information
  ///
  /// In en, this message translates to:
  /// **'Requester Information'**
  String get churchRequest_requesterInformation;

  /// Section title for church information
  ///
  /// In en, this message translates to:
  /// **'Church Information'**
  String get churchRequest_churchInformation;

  /// Hint for contact person name input
  ///
  /// In en, this message translates to:
  /// **'Enter contact person name'**
  String get churchRequest_hintEnterContactPersonName;

  /// Hint/example for phone number input
  ///
  /// In en, this message translates to:
  /// **'0812-3456-7890'**
  String get churchRequest_hintPhoneExample;

  /// Button text while submitting church request
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get churchRequest_submitting;

  /// Submit button text for church request
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get churchRequest_submitRequest;

  /// Error message shown when validation fails before submitting
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors above before submitting'**
  String get churchRequest_fixErrorsBeforeSubmitting;

  /// Error message shown when form state validation fails
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields correctly'**
  String get churchRequest_fillAllRequiredFieldsCorrectly;

  /// Success message when church request is submitted
  ///
  /// In en, this message translates to:
  /// **'Church registration request submitted successfully!'**
  String get churchRequest_submittedSuccessfully;

  /// Validation message when address is too short
  ///
  /// In en, this message translates to:
  /// **'Please enter a complete address'**
  String get churchRequest_validation_completeAddress;

  /// Validation message when phone number is too short
  ///
  /// In en, this message translates to:
  /// **'Phone number must be at least {min} digits'**
  String churchRequest_validation_phoneMinDigits(int min);

  /// Validation message when phone number is too long
  ///
  /// In en, this message translates to:
  /// **'Phone number must not exceed {max} digits'**
  String churchRequest_validation_phoneMaxDigits(int max);

  /// Validation message when phone number does not start with 0
  ///
  /// In en, this message translates to:
  /// **'Phone number must start with 0'**
  String get churchRequest_validation_phoneMustStartWithZero;

  /// Error message with detail for church request
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String churchRequest_errorWithDetail(String error);

  /// No description provided for @hint_enterChurchName.
  ///
  /// In en, this message translates to:
  /// **'Enter church name'**
  String get hint_enterChurchName;

  /// No description provided for @hint_enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get hint_enterPhoneNumber;

  /// No description provided for @hint_enterEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get hint_enterEmailAddress;

  /// No description provided for @hint_describeYourChurch.
  ///
  /// In en, this message translates to:
  /// **'Describe your church (visible to members)'**
  String get hint_describeYourChurch;

  /// No description provided for @hint_enterChurchAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter church address'**
  String get hint_enterChurchAddress;

  /// No description provided for @hint_latitudeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. -6.1754'**
  String get hint_latitudeExample;

  /// No description provided for @hint_longitudeExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 106.8272'**
  String get hint_longitudeExample;

  /// No description provided for @hint_enterAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter account number'**
  String get hint_enterAccountNumber;

  /// No description provided for @hint_enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter description'**
  String get hint_enterDescription;

  /// No description provided for @hint_enterColumnName.
  ///
  /// In en, this message translates to:
  /// **'Enter column name'**
  String get hint_enterColumnName;

  /// No description provided for @hint_enterPositionName.
  ///
  /// In en, this message translates to:
  /// **'Enter position name'**
  String get hint_enterPositionName;

  /// No description provided for @hint_enterMemberName.
  ///
  /// In en, this message translates to:
  /// **'Enter member name'**
  String get hint_enterMemberName;

  /// No description provided for @hint_enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get hint_enterFullName;

  /// No description provided for @hint_enterYourPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get hint_enterYourPhoneNumber;

  /// No description provided for @hint_enterYourPosition.
  ///
  /// In en, this message translates to:
  /// **'Enter your position'**
  String get hint_enterYourPosition;

  /// No description provided for @hint_enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter current password'**
  String get hint_enterCurrentPassword;

  /// No description provided for @hint_enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter new password'**
  String get hint_enterNewPassword;

  /// No description provided for @hint_reEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get hint_reEnterNewPassword;

  /// No description provided for @hint_documentIdExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., DOC-2024-001'**
  String get hint_documentIdExample;

  /// No description provided for @hint_approvalRuleExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. Financial Transactions'**
  String get hint_approvalRuleExample;

  /// No description provided for @hint_describeApprovalRule.
  ///
  /// In en, this message translates to:
  /// **'Describe when this approval is required'**
  String get hint_describeApprovalRule;

  /// No description provided for @hint_allActivityTypes.
  ///
  /// In en, this message translates to:
  /// **'All activity types'**
  String get hint_allActivityTypes;

  /// No description provided for @hint_noFinancialFilter.
  ///
  /// In en, this message translates to:
  /// **'No financial filter'**
  String get hint_noFinancialFilter;

  /// No description provided for @hint_selectPositionsToApprove.
  ///
  /// In en, this message translates to:
  /// **'Select positions to approve...'**
  String get hint_selectPositionsToApprove;

  /// No description provided for @hint_signInCredentials.
  ///
  /// In en, this message translates to:
  /// **'e.g. name@company.com or 1234-5678-9012'**
  String get hint_signInCredentials;

  /// No description provided for @hint_searchApprovalRules.
  ///
  /// In en, this message translates to:
  /// **'Search approval rules...'**
  String get hint_searchApprovalRules;

  /// No description provided for @hint_searchBillingItems.
  ///
  /// In en, this message translates to:
  /// **'Search billing items...'**
  String get hint_searchBillingItems;

  /// No description provided for @hint_searchByAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Search by account number, activity title...'**
  String get hint_searchByAccountNumber;

  /// No description provided for @hint_searchByReportName.
  ///
  /// In en, this message translates to:
  /// **'Search by report name...'**
  String get hint_searchByReportName;

  /// No description provided for @hint_searchNameColumnPosition.
  ///
  /// In en, this message translates to:
  /// **'Search name / column / position ...'**
  String get hint_searchNameColumnPosition;

  /// No description provided for @hint_searchByTitleDescription.
  ///
  /// In en, this message translates to:
  /// **'Search by title, description, or supervisor name ...'**
  String get hint_searchByTitleDescription;

  /// No description provided for @hint_searchAccountNumberDescription.
  ///
  /// In en, this message translates to:
  /// **'Search by account number or description...'**
  String get hint_searchAccountNumberDescription;

  /// No description provided for @dlg_selectPosition_title.
  ///
  /// In en, this message translates to:
  /// **'Select Position'**
  String get dlg_selectPosition_title;

  /// No description provided for @hint_searchPositions.
  ///
  /// In en, this message translates to:
  /// **'Search by position name'**
  String get hint_searchPositions;

  /// No description provided for @tbl_billId.
  ///
  /// In en, this message translates to:
  /// **'Bill ID'**
  String get tbl_billId;

  /// No description provided for @tbl_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get tbl_description;

  /// No description provided for @tbl_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get tbl_amount;

  /// No description provided for @tbl_dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get tbl_dueDate;

  /// No description provided for @tbl_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get tbl_status;

  /// No description provided for @tbl_paymentId.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get tbl_paymentId;

  /// No description provided for @tbl_accountId.
  ///
  /// In en, this message translates to:
  /// **'Account ID'**
  String get tbl_accountId;

  /// No description provided for @tbl_method.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get tbl_method;

  /// No description provided for @tbl_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tbl_date;

  /// No description provided for @tbl_accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get tbl_accountNumber;

  /// No description provided for @tbl_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tbl_activity;

  /// No description provided for @tbl_requestDate.
  ///
  /// In en, this message translates to:
  /// **'Request Date'**
  String get tbl_requestDate;

  /// No description provided for @tbl_approvalDate.
  ///
  /// In en, this message translates to:
  /// **'Approval Date'**
  String get tbl_approvalDate;

  /// No description provided for @tbl_paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get tbl_paymentMethod;

  /// No description provided for @tbl_title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get tbl_title;

  /// No description provided for @tbl_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get tbl_type;

  /// No description provided for @tbl_supervisor.
  ///
  /// In en, this message translates to:
  /// **'Supervisor'**
  String get tbl_supervisor;

  /// No description provided for @tbl_approval.
  ///
  /// In en, this message translates to:
  /// **'Approval'**
  String get tbl_approval;

  /// No description provided for @tbl_approvers.
  ///
  /// In en, this message translates to:
  /// **'Approvers'**
  String get tbl_approvers;

  /// No description provided for @tbl_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tbl_name;

  /// No description provided for @tbl_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get tbl_phone;

  /// No description provided for @tbl_birth.
  ///
  /// In en, this message translates to:
  /// **'Birth'**
  String get tbl_birth;

  /// No description provided for @tbl_bipra.
  ///
  /// In en, this message translates to:
  /// **'BIPRA'**
  String get tbl_bipra;

  /// No description provided for @tbl_positions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get tbl_positions;

  /// No description provided for @tbl_ruleName.
  ///
  /// In en, this message translates to:
  /// **'Rule Name'**
  String get tbl_ruleName;

  /// No description provided for @tbl_filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get tbl_filters;

  /// No description provided for @tbl_documentName.
  ///
  /// In en, this message translates to:
  /// **'Document Name'**
  String get tbl_documentName;

  /// No description provided for @tbl_createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get tbl_createdDate;

  /// No description provided for @tbl_reportName.
  ///
  /// In en, this message translates to:
  /// **'Report Name'**
  String get tbl_reportName;

  /// No description provided for @tbl_by.
  ///
  /// In en, this message translates to:
  /// **'By'**
  String get tbl_by;

  /// No description provided for @tbl_on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get tbl_on;

  /// No description provided for @tbl_file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get tbl_file;

  /// No description provided for @opt_manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get opt_manual;

  /// No description provided for @opt_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get opt_system;

  /// No description provided for @financeType_revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get financeType_revenue;

  /// No description provided for @financeType_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get financeType_expense;

  /// No description provided for @inventoryCondition_good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get inventoryCondition_good;

  /// No description provided for @inventoryCondition_used.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get inventoryCondition_used;

  /// No description provided for @inventoryCondition_new.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get inventoryCondition_new;

  /// No description provided for @inventoryCondition_notApplicable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get inventoryCondition_notApplicable;

  /// No description provided for @paymentMethod_cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentMethod_cash;

  /// No description provided for @paymentMethod_cashless.
  ///
  /// In en, this message translates to:
  /// **'Cashless'**
  String get paymentMethod_cashless;

  /// No description provided for @billingType_subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get billingType_subscription;

  /// No description provided for @billingType_oneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get billingType_oneTime;

  /// No description provided for @billingType_recurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get billingType_recurring;

  /// No description provided for @billingStatus_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get billingStatus_pending;

  /// No description provided for @billingStatus_paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get billingStatus_paid;

  /// No description provided for @billingStatus_overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get billingStatus_overdue;

  /// No description provided for @billingStatus_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get billingStatus_cancelled;

  /// No description provided for @billingStatus_refunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get billingStatus_refunded;

  /// No description provided for @reportType_incomingDocument.
  ///
  /// In en, this message translates to:
  /// **'Incoming Document'**
  String get reportType_incomingDocument;

  /// No description provided for @reportTitle_incomingDocument.
  ///
  /// In en, this message translates to:
  /// **'Incoming Document Report'**
  String get reportTitle_incomingDocument;

  /// No description provided for @reportDesc_incomingDocument.
  ///
  /// In en, this message translates to:
  /// **'Generate a report for documents received.'**
  String get reportDesc_incomingDocument;

  /// No description provided for @reportType_congregation.
  ///
  /// In en, this message translates to:
  /// **'Congregation'**
  String get reportType_congregation;

  /// No description provided for @reportTitle_congregation.
  ///
  /// In en, this message translates to:
  /// **'Congregation Report'**
  String get reportTitle_congregation;

  /// No description provided for @reportDesc_congregation.
  ///
  /// In en, this message translates to:
  /// **'Generate a report on the congregation.'**
  String get reportDesc_congregation;

  /// No description provided for @reportType_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get reportType_services;

  /// No description provided for @reportTitle_services.
  ///
  /// In en, this message translates to:
  /// **'Services Report'**
  String get reportTitle_services;

  /// No description provided for @reportDesc_services.
  ///
  /// In en, this message translates to:
  /// **'Generate a report of all services.'**
  String get reportDesc_services;

  /// No description provided for @reportType_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get reportType_activity;

  /// No description provided for @reportTitle_activity.
  ///
  /// In en, this message translates to:
  /// **'Activity Report'**
  String get reportTitle_activity;

  /// No description provided for @reportDesc_activity.
  ///
  /// In en, this message translates to:
  /// **'Generate a report of all activities.'**
  String get reportDesc_activity;

  /// No description provided for @tbl_linkedApprovalRule.
  ///
  /// In en, this message translates to:
  /// **'Linked Approval Rule'**
  String get tbl_linkedApprovalRule;

  /// No description provided for @dlg_deleteRule_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Rule'**
  String get dlg_deleteRule_title;

  /// No description provided for @dlg_deleteRule_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this approval rule?'**
  String get dlg_deleteRule_content;

  /// No description provided for @dlg_deleteMember_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Member'**
  String get dlg_deleteMember_title;

  /// No description provided for @dlg_deleteMember_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this member? This action cannot be undone.'**
  String get dlg_deleteMember_content;

  /// No description provided for @dlg_deletePosition_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Position'**
  String get dlg_deletePosition_title;

  /// No description provided for @dlg_deletePosition_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this position? This action cannot be undone.'**
  String get dlg_deletePosition_content;

  /// No description provided for @dlg_deleteColumn_title.
  ///
  /// In en, this message translates to:
  /// **'Delete Column'**
  String get dlg_deleteColumn_title;

  /// No description provided for @dlg_deleteColumn_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this column? This action cannot be undone.'**
  String get dlg_deleteColumn_content;

  /// No description provided for @dlg_signOut_title.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get dlg_signOut_title;

  /// No description provided for @dlg_signOut_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get dlg_signOut_content;

  /// No description provided for @dlg_recordPayment_title.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get dlg_recordPayment_title;

  /// No description provided for @dlg_confirmAction_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Action'**
  String get dlg_confirmAction_title;

  /// No description provided for @dlg_confirmDelete_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get dlg_confirmDelete_title;

  /// No description provided for @filter_allStatus.
  ///
  /// In en, this message translates to:
  /// **'All Status'**
  String get filter_allStatus;

  /// No description provided for @filter_allActivityTypes.
  ///
  /// In en, this message translates to:
  /// **'All activity types'**
  String get filter_allActivityTypes;

  /// No description provided for @filter_noFinancialFilter.
  ///
  /// In en, this message translates to:
  /// **'No financial filter'**
  String get filter_noFinancialFilter;

  /// No description provided for @filter_paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get filter_paymentMethod;

  /// No description provided for @filter_items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get filter_items;

  /// No description provided for @filter_allPositions.
  ///
  /// In en, this message translates to:
  /// **'All Positions'**
  String get filter_allPositions;

  /// No description provided for @filter_allWithLabel.
  ///
  /// In en, this message translates to:
  /// **'All {label}'**
  String filter_allWithLabel(String label);

  /// No description provided for @tooltip_clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get tooltip_clearSearch;

  /// No description provided for @msg_tryDifferentSearchTerm.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get msg_tryDifferentSearchTerm;

  /// No description provided for @pagination_showingRows.
  ///
  /// In en, this message translates to:
  /// **'Showing {showing} of {total} rows'**
  String pagination_showingRows(int showing, int total);

  /// No description provided for @pagination_rowsPerPage.
  ///
  /// In en, this message translates to:
  /// **'Rows per page'**
  String get pagination_rowsPerPage;

  /// No description provided for @pagination_page.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get pagination_page;

  /// No description provided for @pagination_ofPageCount.
  ///
  /// In en, this message translates to:
  /// **'of {pageCount}'**
  String pagination_ofPageCount(int pageCount);

  /// No description provided for @pagination_previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get pagination_previous;

  /// No description provided for @pagination_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get pagination_next;

  /// No description provided for @dateRangeFilter_quickRangesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Quick ranges'**
  String get dateRangeFilter_quickRangesTooltip;

  /// No description provided for @dateRangeFilter_thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get dateRangeFilter_thisWeek;

  /// No description provided for @dateRangeFilter_lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last week'**
  String get dateRangeFilter_lastWeek;

  /// No description provided for @dateRangeFilter_thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get dateRangeFilter_thisMonth;

  /// No description provided for @dateRangeFilter_lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get dateRangeFilter_lastMonth;

  /// No description provided for @dateRangeFilter_clearTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear date range'**
  String get dateRangeFilter_clearTooltip;

  /// No description provided for @dateRangePreset_allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get dateRangePreset_allTime;

  /// No description provided for @dateRangePreset_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dateRangePreset_today;

  /// No description provided for @dateRangePreset_thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get dateRangePreset_thisWeek;

  /// No description provided for @dateRangePreset_thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dateRangePreset_thisMonth;

  /// No description provided for @dateRangePreset_lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get dateRangePreset_lastWeek;

  /// No description provided for @dateRangePreset_lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get dateRangePreset_lastMonth;

  /// No description provided for @dateRangePreset_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom Range'**
  String get dateRangePreset_custom;

  /// No description provided for @msg_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get msg_saved;

  /// No description provided for @msg_created.
  ///
  /// In en, this message translates to:
  /// **'Created successfully'**
  String get msg_created;

  /// No description provided for @msg_updated.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get msg_updated;

  /// No description provided for @msg_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get msg_deleted;

  /// No description provided for @msg_approvalRuleCreated.
  ///
  /// In en, this message translates to:
  /// **'Approval rule created successfully'**
  String get msg_approvalRuleCreated;

  /// No description provided for @msg_approvalRuleUpdated.
  ///
  /// In en, this message translates to:
  /// **'Approval rule updated successfully'**
  String get msg_approvalRuleUpdated;

  /// No description provided for @msg_approvalRuleDeleted.
  ///
  /// In en, this message translates to:
  /// **'Approval rule deleted successfully'**
  String get msg_approvalRuleDeleted;

  /// No description provided for @msg_recordedPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded successfully'**
  String get msg_recordedPayment;

  /// No description provided for @msg_templateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Template updated successfully'**
  String get msg_templateUpdated;

  /// No description provided for @msg_documentTemplateWarning.
  ///
  /// In en, this message translates to:
  /// **'Changing the identity number template may cause certain numbers to be skipped.'**
  String get msg_documentTemplateWarning;

  /// No description provided for @msg_reportGenerated.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully'**
  String get msg_reportGenerated;

  /// No description provided for @msg_signedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get msg_signedOut;

  /// No description provided for @msg_passwordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get msg_passwordChanged;

  /// No description provided for @msg_accountUpdated.
  ///
  /// In en, this message translates to:
  /// **'Account information updated successfully'**
  String get msg_accountUpdated;

  /// No description provided for @msg_activityNotFound.
  ///
  /// In en, this message translates to:
  /// **'Activity not found'**
  String get msg_activityNotFound;

  /// No description provided for @msg_activityApproved.
  ///
  /// In en, this message translates to:
  /// **'Activity approved successfully'**
  String get msg_activityApproved;

  /// No description provided for @msg_activityRejected.
  ///
  /// In en, this message translates to:
  /// **'Activity rejected successfully'**
  String get msg_activityRejected;

  /// No description provided for @msg_noApproversAssigned.
  ///
  /// In en, this message translates to:
  /// **'No approvers assigned'**
  String get msg_noApproversAssigned;

  /// No description provided for @btn_viewAllPaymentsWithCount.
  ///
  /// In en, this message translates to:
  /// **'View All {count} payments'**
  String btn_viewAllPaymentsWithCount(int count);

  /// No description provided for @lbl_memberWithId.
  ///
  /// In en, this message translates to:
  /// **'#{membershipId} • {name}'**
  String lbl_memberWithId(String membershipId, String name);

  /// No description provided for @lbl_fileSizeMb.
  ///
  /// In en, this message translates to:
  /// **'{size} MB'**
  String lbl_fileSizeMb(String size);

  /// No description provided for @lbl_dateRangeStartEnd.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String lbl_dateRangeStartEnd(String start, String end);

  /// No description provided for @msg_generatedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on {date}'**
  String msg_generatedOn(String date);

  /// No description provided for @msg_noGenerationDate.
  ///
  /// In en, this message translates to:
  /// **'No generation date'**
  String get msg_noGenerationDate;

  /// No description provided for @msg_exportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Export functionality coming soon'**
  String get msg_exportComingSoon;

  /// No description provided for @msg_downloadReportToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'To view the full report details, please download the file.'**
  String get msg_downloadReportToViewDetails;

  /// No description provided for @msg_willBeRemindedAt.
  ///
  /// In en, this message translates to:
  /// **'Will be reminded at {reminderDate}'**
  String msg_willBeRemindedAt(String reminderDate);

  /// No description provided for @msg_approverCount.
  ///
  /// In en, this message translates to:
  /// **'{count} approver(s)'**
  String msg_approverCount(int count);

  /// No description provided for @msg_opening.
  ///
  /// In en, this message translates to:
  /// **'Opening...'**
  String get msg_opening;

  /// No description provided for @msg_openingReport.
  ///
  /// In en, this message translates to:
  /// **'Opening {reportName}...'**
  String msg_openingReport(String reportName);

  /// No description provided for @msg_cannotOpenReportFile.
  ///
  /// In en, this message translates to:
  /// **'Cannot open the report file.'**
  String get msg_cannotOpenReportFile;

  /// No description provided for @msg_reportGenerationMayTakeAWhile.
  ///
  /// In en, this message translates to:
  /// **'Generating report might take a while, depending on the data requested.'**
  String get msg_reportGenerationMayTakeAWhile;

  /// No description provided for @msg_saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get msg_saveFailed;

  /// No description provided for @msg_createFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create'**
  String get msg_createFailed;

  /// No description provided for @msg_updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update'**
  String get msg_updateFailed;

  /// No description provided for @msg_deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get msg_deleteFailed;

  /// No description provided for @msg_createApprovalRuleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create approval rule'**
  String get msg_createApprovalRuleFailed;

  /// No description provided for @msg_updateApprovalRuleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update approval rule'**
  String get msg_updateApprovalRuleFailed;

  /// No description provided for @msg_deleteApprovalRuleFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete approval rule'**
  String get msg_deleteApprovalRuleFailed;

  /// No description provided for @msg_recordPaymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to record payment'**
  String get msg_recordPaymentFailed;

  /// No description provided for @msg_generateReportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate report'**
  String get msg_generateReportFailed;

  /// No description provided for @msg_invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get msg_invalidPassword;

  /// No description provided for @msg_passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get msg_passwordMismatch;

  /// No description provided for @msg_invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL provided'**
  String get msg_invalidUrl;

  /// No description provided for @msg_operationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get msg_operationFailed;

  /// No description provided for @msg_serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get msg_serverError;

  /// No description provided for @msg_badRequest.
  ///
  /// In en, this message translates to:
  /// **'Bad Request'**
  String get msg_badRequest;

  /// No description provided for @msg_unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized'**
  String get msg_unauthorized;

  /// No description provided for @msg_forbidden.
  ///
  /// In en, this message translates to:
  /// **'Forbidden'**
  String get msg_forbidden;

  /// No description provided for @msg_notFound.
  ///
  /// In en, this message translates to:
  /// **'Not Found'**
  String get msg_notFound;

  /// No description provided for @msg_conflict.
  ///
  /// In en, this message translates to:
  /// **'Conflict'**
  String get msg_conflict;

  /// No description provided for @msg_validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation Error'**
  String get msg_validationError;

  /// No description provided for @msg_tooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too Many Requests'**
  String get msg_tooManyRequests;

  /// No description provided for @msg_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get msg_error;

  /// No description provided for @msg_checkInput.
  ///
  /// In en, this message translates to:
  /// **'Check your input'**
  String get msg_checkInput;

  /// No description provided for @msg_signInAgain.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again'**
  String get msg_signInAgain;

  /// No description provided for @msg_insufficientPermissions.
  ///
  /// In en, this message translates to:
  /// **'Insufficient permissions'**
  String get msg_insufficientPermissions;

  /// No description provided for @msg_resourceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get msg_resourceNotFound;

  /// No description provided for @msg_stateConflict.
  ///
  /// In en, this message translates to:
  /// **'State conflict'**
  String get msg_stateConflict;

  /// No description provided for @msg_validationFailed.
  ///
  /// In en, this message translates to:
  /// **'Validation failed'**
  String get msg_validationFailed;

  /// No description provided for @msg_slowDown.
  ///
  /// In en, this message translates to:
  /// **'Slow down'**
  String get msg_slowDown;

  /// No description provided for @msg_tryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get msg_tryAgainLater;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_required;

  /// No description provided for @validation_passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get validation_passwordRequired;

  /// No description provided for @validation_requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_requiredField;

  /// No description provided for @validation_invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validation_invalidEmail;

  /// No description provided for @validation_invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get validation_invalidPhone;

  /// No description provided for @validation_invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get validation_invalidUrl;

  /// No description provided for @validation_invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get validation_invalidNumber;

  /// No description provided for @validation_invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid date'**
  String get validation_invalidDate;

  /// No description provided for @validation_minLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at least {min} characters'**
  String validation_minLength(int min);

  /// No description provided for @validation_maxLength.
  ///
  /// In en, this message translates to:
  /// **'Must be no more than {max} characters'**
  String validation_maxLength(int max);

  /// No description provided for @validation_passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get validation_passwordTooShort;

  /// No description provided for @validation_passwordTooWeak.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one uppercase letter, one lowercase letter, and one number'**
  String get validation_passwordTooWeak;

  /// No description provided for @validation_passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get validation_passwordMismatch;

  /// No description provided for @validation_confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get validation_confirmPassword;

  /// No description provided for @validation_currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required'**
  String get validation_currentPasswordRequired;

  /// No description provided for @validation_newPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'New password is required'**
  String get validation_newPasswordRequired;

  /// No description provided for @validation_invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get validation_invalidAmount;

  /// No description provided for @validation_amountTooLow.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get validation_amountTooLow;

  /// No description provided for @validation_amountTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds maximum limit'**
  String get validation_amountTooHigh;

  /// No description provided for @validation_invalidAccountNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid account number'**
  String get validation_invalidAccountNumber;

  /// No description provided for @validation_accountNumberExists.
  ///
  /// In en, this message translates to:
  /// **'This account number already exists'**
  String get validation_accountNumberExists;

  /// No description provided for @validation_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get validation_nameRequired;

  /// No description provided for @validation_titleRequired.
  ///
  /// In en, this message translates to:
  /// **'Title is required'**
  String get validation_titleRequired;

  /// No description provided for @validation_descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get validation_descriptionRequired;

  /// No description provided for @validation_addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Address is required'**
  String get validation_addressRequired;

  /// No description provided for @validation_phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get validation_phoneRequired;

  /// No description provided for @validation_emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email address is required'**
  String get validation_emailRequired;

  /// No description provided for @validation_dateRequired.
  ///
  /// In en, this message translates to:
  /// **'Date is required'**
  String get validation_dateRequired;

  /// No description provided for @validation_timeRequired.
  ///
  /// In en, this message translates to:
  /// **'Time is required'**
  String get validation_timeRequired;

  /// No description provided for @validation_selectionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please make a selection'**
  String get validation_selectionRequired;

  /// No description provided for @validation_churchRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a church'**
  String get validation_churchRequired;

  /// No description provided for @validation_columnRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a column'**
  String get validation_columnRequired;

  /// No description provided for @validation_positionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a position'**
  String get validation_positionRequired;

  /// No description provided for @validation_activityTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select an activity type'**
  String get validation_activityTypeRequired;

  /// No description provided for @validation_financialTypeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a financial type'**
  String get validation_financialTypeRequired;

  /// No description provided for @validation_approverRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one approver is required'**
  String get validation_approverRequired;

  /// No description provided for @validation_ruleNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Rule name is required'**
  String get validation_ruleNameRequired;

  /// No description provided for @validation_positionsRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one position must be selected'**
  String get validation_positionsRequired;

  /// No description provided for @validation_financialAccountRequired.
  ///
  /// In en, this message translates to:
  /// **'Financial account number is required when financial type is selected'**
  String get validation_financialAccountRequired;

  /// No description provided for @validation_duplicateEntry.
  ///
  /// In en, this message translates to:
  /// **'This entry already exists'**
  String get validation_duplicateEntry;

  /// No description provided for @validation_invalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format'**
  String get validation_invalidFormat;

  /// No description provided for @validation_futureDate.
  ///
  /// In en, this message translates to:
  /// **'Date must be in the future'**
  String get validation_futureDate;

  /// No description provided for @validation_pastDate.
  ///
  /// In en, this message translates to:
  /// **'Date must be in the past'**
  String get validation_pastDate;

  /// No description provided for @validation_invalidRange.
  ///
  /// In en, this message translates to:
  /// **'Invalid date range'**
  String get validation_invalidRange;

  /// No description provided for @validation_startDateAfterEnd.
  ///
  /// In en, this message translates to:
  /// **'Start date must be before end date'**
  String get validation_startDateAfterEnd;

  /// No description provided for @validation_coordinatesRequired.
  ///
  /// In en, this message translates to:
  /// **'Coordinates are required'**
  String get validation_coordinatesRequired;

  /// No description provided for @validation_invalidLatitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get validation_invalidLatitude;

  /// No description provided for @validation_invalidLongitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get validation_invalidLongitude;

  /// No description provided for @loading_data.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loading_data;

  /// No description provided for @loading_members.
  ///
  /// In en, this message translates to:
  /// **'Loading members...'**
  String get loading_members;

  /// No description provided for @loading_activities.
  ///
  /// In en, this message translates to:
  /// **'Loading activities...'**
  String get loading_activities;

  /// No description provided for @loading_revenue.
  ///
  /// In en, this message translates to:
  /// **'Loading revenue...'**
  String get loading_revenue;

  /// No description provided for @loading_expenses.
  ///
  /// In en, this message translates to:
  /// **'Loading expenses...'**
  String get loading_expenses;

  /// No description provided for @loading_reports.
  ///
  /// In en, this message translates to:
  /// **'Loading reports...'**
  String get loading_reports;

  /// No description provided for @loading_documents.
  ///
  /// In en, this message translates to:
  /// **'Loading documents...'**
  String get loading_documents;

  /// No description provided for @loading_approvals.
  ///
  /// In en, this message translates to:
  /// **'Loading approvals...'**
  String get loading_approvals;

  /// No description provided for @loading_billing.
  ///
  /// In en, this message translates to:
  /// **'Loading billing...'**
  String get loading_billing;

  /// No description provided for @loading_financial.
  ///
  /// In en, this message translates to:
  /// **'Loading financial data...'**
  String get loading_financial;

  /// No description provided for @loading_church.
  ///
  /// In en, this message translates to:
  /// **'Loading church information...'**
  String get loading_church;

  /// No description provided for @loading_account.
  ///
  /// In en, this message translates to:
  /// **'Loading account information...'**
  String get loading_account;

  /// No description provided for @loading_please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get loading_please_wait;

  /// No description provided for @loading_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get loading_saving;

  /// No description provided for @loading_deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get loading_deleting;

  /// No description provided for @error_loadingData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get error_loadingData;

  /// No description provided for @error_loadingMembers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load members'**
  String get error_loadingMembers;

  /// No description provided for @error_loadingActivities.
  ///
  /// In en, this message translates to:
  /// **'Failed to load activities'**
  String get error_loadingActivities;

  /// No description provided for @error_loadingRevenue.
  ///
  /// In en, this message translates to:
  /// **'Failed to load revenue'**
  String get error_loadingRevenue;

  /// No description provided for @error_loadingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Failed to load expenses'**
  String get error_loadingExpenses;

  /// No description provided for @error_loadingReports.
  ///
  /// In en, this message translates to:
  /// **'Failed to load reports'**
  String get error_loadingReports;

  /// No description provided for @error_loadingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Failed to load documents'**
  String get error_loadingDocuments;

  /// No description provided for @error_loadingApprovals.
  ///
  /// In en, this message translates to:
  /// **'Failed to load approvals'**
  String get error_loadingApprovals;

  /// No description provided for @error_loadingBilling.
  ///
  /// In en, this message translates to:
  /// **'Failed to load billing'**
  String get error_loadingBilling;

  /// No description provided for @error_loadingFinancial.
  ///
  /// In en, this message translates to:
  /// **'Failed to load financial data'**
  String get error_loadingFinancial;

  /// No description provided for @error_loadingChurch.
  ///
  /// In en, this message translates to:
  /// **'Failed to load church information'**
  String get error_loadingChurch;

  /// No description provided for @error_loadingAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to load account information'**
  String get error_loadingAccount;

  /// No description provided for @error_connectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Please check your internet connection.'**
  String get error_connectionFailed;

  /// No description provided for @error_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out. Please try again.'**
  String get error_timeout;

  /// No description provided for @error_unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get error_unexpectedError;

  /// No description provided for @noData_available.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData_available;

  /// No description provided for @noData_members.
  ///
  /// In en, this message translates to:
  /// **'No members found'**
  String get noData_members;

  /// No description provided for @noData_activities.
  ///
  /// In en, this message translates to:
  /// **'No activities found'**
  String get noData_activities;

  /// No description provided for @noData_revenue.
  ///
  /// In en, this message translates to:
  /// **'No revenue records found'**
  String get noData_revenue;

  /// No description provided for @noData_expenses.
  ///
  /// In en, this message translates to:
  /// **'No expense records found'**
  String get noData_expenses;

  /// No description provided for @noData_reports.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noData_reports;

  /// No description provided for @noData_documents.
  ///
  /// In en, this message translates to:
  /// **'No documents found'**
  String get noData_documents;

  /// No description provided for @noData_approvals.
  ///
  /// In en, this message translates to:
  /// **'No approval rules found'**
  String get noData_approvals;

  /// No description provided for @noData_billing.
  ///
  /// In en, this message translates to:
  /// **'No billing items found'**
  String get noData_billing;

  /// No description provided for @noData_financial.
  ///
  /// In en, this message translates to:
  /// **'No financial account numbers found'**
  String get noData_financial;

  /// No description provided for @noData_church.
  ///
  /// In en, this message translates to:
  /// **'No church information available'**
  String get noData_church;

  /// No description provided for @noData_results.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noData_results;

  /// No description provided for @noData_matchingCriteria.
  ///
  /// In en, this message translates to:
  /// **'No data matches your search criteria'**
  String get noData_matchingCriteria;

  /// No description provided for @noData_positions.
  ///
  /// In en, this message translates to:
  /// **'No positions available'**
  String get noData_positions;

  /// No description provided for @noData_activityLink.
  ///
  /// In en, this message translates to:
  /// **'Not linked to any activity'**
  String get noData_activityLink;

  /// No description provided for @tooltip_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get tooltip_refresh;

  /// No description provided for @tooltip_viewActivityDetails.
  ///
  /// In en, this message translates to:
  /// **'View Activity Details'**
  String get tooltip_viewActivityDetails;

  /// No description provided for @tooltip_downloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get tooltip_downloadReport;

  /// No description provided for @tooltip_baptized.
  ///
  /// In en, this message translates to:
  /// **'Baptized'**
  String get tooltip_baptized;

  /// No description provided for @tooltip_sidi.
  ///
  /// In en, this message translates to:
  /// **'SIDI'**
  String get tooltip_sidi;

  /// No description provided for @tooltip_appLinked.
  ///
  /// In en, this message translates to:
  /// **'App Linked'**
  String get tooltip_appLinked;

  /// No description provided for @footer_copyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Palakat. All rights reserved.'**
  String footer_copyright(int year);

  /// No description provided for @time_justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get time_justNow;

  /// No description provided for @time_minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String time_minutesAgo(int count);

  /// No description provided for @time_hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String time_hoursAgo(int count);

  /// No description provided for @time_daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String time_daysAgo(int count);

  /// Stat card change text showing increase from last month
  ///
  /// In en, this message translates to:
  /// **'+{change} from last month'**
  String stat_changeFromLastMonth(String change);

  /// Stat card change text showing percentage increase from last month
  ///
  /// In en, this message translates to:
  /// **'+{change}% from last month'**
  String stat_changePercentFromLastMonth(String change);

  /// Text showing count of recent activities
  ///
  /// In en, this message translates to:
  /// **'{count} recent activities'**
  String dashboard_recentActivitiesCount(int count);

  /// Empty state text for recent activities section
  ///
  /// In en, this message translates to:
  /// **'Recent transactions and member updates will be shown here.'**
  String get dashboard_recentActivitiesEmpty;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
