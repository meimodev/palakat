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

  /// The application title
  ///
  /// In id, this message translates to:
  /// **'Palakat'**
  String get appTitle;

  /// Navigation label for dashboard
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get nav_dashboard;

  /// Navigation label for members
  ///
  /// In id, this message translates to:
  /// **'Anggota'**
  String get nav_members;

  /// Navigation label for activity
  ///
  /// In id, this message translates to:
  /// **'Kegiatan'**
  String get nav_activity;

  /// Navigation label for revenue
  ///
  /// In id, this message translates to:
  /// **'Pendapatan'**
  String get nav_revenue;

  /// Navigation label for expense
  ///
  /// In id, this message translates to:
  /// **'Pengeluaran'**
  String get nav_expense;

  /// Navigation label for report
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get nav_report;

  /// Navigation label for church
  ///
  /// In id, this message translates to:
  /// **'Gereja'**
  String get nav_church;

  /// Navigation label for document
  ///
  /// In id, this message translates to:
  /// **'Dokumen'**
  String get nav_document;

  /// Navigation label for approval
  ///
  /// In id, this message translates to:
  /// **'Persetujuan'**
  String get nav_approval;

  /// Navigation label for financial
  ///
  /// In id, this message translates to:
  /// **'Keuangan'**
  String get nav_financial;

  /// Navigation label for billing
  ///
  /// In id, this message translates to:
  /// **'Tagihan'**
  String get nav_billing;

  /// Navigation label for account
  ///
  /// In id, this message translates to:
  /// **'Akun'**
  String get nav_account;

  /// Navigation section label for report
  ///
  /// In id, this message translates to:
  /// **'Laporan'**
  String get nav_section_report;

  /// Navigation section label for administration
  ///
  /// In id, this message translates to:
  /// **'Administrasi'**
  String get nav_section_administration;

  /// Navigation label for home
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get nav_home;

  /// Navigation label for songs
  ///
  /// In id, this message translates to:
  /// **'Lagu'**
  String get nav_songs;

  /// Navigation label for operations
  ///
  /// In id, this message translates to:
  /// **'Ops'**
  String get nav_operations;

  /// Button text for continue
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get btn_continue;

  /// Button text for cancel
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get btn_cancel;

  /// Button text for save
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get btn_save;

  /// Button text for delete
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get btn_delete;

  /// Button text for retry
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get btn_retry;

  /// Button text for sign in
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get btn_signIn;

  /// Button text for sign out
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get btn_signOut;

  /// Sign out confirmation title
  ///
  /// In id, this message translates to:
  /// **'Keluar?'**
  String get btn_signOutConfirm;

  /// Sign out confirmation message
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin keluar? Anda perlu masuk kembali untuk mengakses akun Anda.'**
  String get btn_signOutMessage;

  /// Button text for resend code
  ///
  /// In id, this message translates to:
  /// **'Kirim Ulang Kode'**
  String get btn_resendCode;

  /// Button text for submit
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get btn_submit;

  /// Button text for edit
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get btn_edit;

  /// Button text for add
  ///
  /// In id, this message translates to:
  /// **'Tambah'**
  String get btn_add;

  /// Button text for close
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get btn_close;

  /// Button text for confirm
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi'**
  String get btn_confirm;

  /// Button text for back
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get btn_back;

  /// Label for email field
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get lbl_email;

  /// Label for phone field
  ///
  /// In id, this message translates to:
  /// **'Nomor Telepon'**
  String get lbl_phone;

  /// Label for password field
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get lbl_password;

  /// Label for language setting
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get lbl_language;

  /// Label for name field
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get lbl_name;

  /// Label for address field
  ///
  /// In id, this message translates to:
  /// **'Alamat'**
  String get lbl_address;

  /// Label for date field
  ///
  /// In id, this message translates to:
  /// **'Tanggal'**
  String get lbl_date;

  /// Label for time field
  ///
  /// In id, this message translates to:
  /// **'Waktu'**
  String get lbl_time;

  /// Label for description field
  ///
  /// In id, this message translates to:
  /// **'Deskripsi'**
  String get lbl_description;

  /// Label for amount field
  ///
  /// In id, this message translates to:
  /// **'Jumlah'**
  String get lbl_amount;

  /// Label for search field
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get lbl_search;

  /// Label for select church dialog
  ///
  /// In id, this message translates to:
  /// **'Pilih Gereja'**
  String get lbl_selectChurch;

  /// Label for select column dialog
  ///
  /// In id, this message translates to:
  /// **'Pilih Kolom'**
  String get lbl_selectColumn;

  /// Hint for search churches field
  ///
  /// In id, this message translates to:
  /// **'Cari gereja...'**
  String get lbl_searchChurches;

  /// Hint for search columns field
  ///
  /// In id, this message translates to:
  /// **'Cari kolom...'**
  String get lbl_searchColumns;

  /// Message when no churches found
  ///
  /// In id, this message translates to:
  /// **'Tidak ada gereja ditemukan'**
  String get lbl_noChurchesFound;

  /// Message when no columns found
  ///
  /// In id, this message translates to:
  /// **'Tidak ada kolom ditemukan'**
  String get lbl_noColumnsFound;

  /// Message to select church first
  ///
  /// In id, this message translates to:
  /// **'Silakan pilih gereja terlebih dahulu'**
  String get lbl_selectChurchFirst;

  /// Label for select account dialog
  ///
  /// In id, this message translates to:
  /// **'Pilih Akun {type}'**
  String lbl_selectAccount(String type);

  /// Hint for search account number field
  ///
  /// In id, this message translates to:
  /// **'Cari nomor akun atau deskripsi...'**
  String get lbl_searchAccountNumber;

  /// Message when no results found for query
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil untuk \"{query}\"'**
  String lbl_noResultsFor(String query);

  /// Message when no account numbers available
  ///
  /// In id, this message translates to:
  /// **'Tidak ada nomor akun tersedia'**
  String get lbl_noAccountNumbers;

  /// Message when church information not available
  ///
  /// In id, this message translates to:
  /// **'Informasi gereja tidak tersedia'**
  String get lbl_churchNotAvailable;

  /// Status label for approved
  ///
  /// In id, this message translates to:
  /// **'Disetujui'**
  String get status_approved;

  /// Status label for pending
  ///
  /// In id, this message translates to:
  /// **'Menunggu'**
  String get status_pending;

  /// Status label for rejected
  ///
  /// In id, this message translates to:
  /// **'Ditolak'**
  String get status_rejected;

  /// Status label for draft
  ///
  /// In id, this message translates to:
  /// **'Draf'**
  String get status_draft;

  /// Status label for completed
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get status_completed;

  /// Status label for cancelled
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get status_cancelled;

  /// Status label for active
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get status_active;

  /// Status label for inactive
  ///
  /// In id, this message translates to:
  /// **'Tidak Aktif'**
  String get status_inactive;

  /// Status label for unconfirmed
  ///
  /// In id, this message translates to:
  /// **'Belum Dikonfirmasi'**
  String get status_unconfirmed;

  /// Error message for network error
  ///
  /// In id, this message translates to:
  /// **'Kesalahan jaringan. Periksa koneksi Anda.'**
  String get err_networkError;

  /// Error message for server error
  ///
  /// In id, this message translates to:
  /// **'Kesalahan server. Coba lagi nanti.'**
  String get err_serverError;

  /// Error message for unauthorized
  ///
  /// In id, this message translates to:
  /// **'Sesi Anda telah berakhir. Silakan masuk kembali.'**
  String get err_unauthorized;

  /// Error message for invalid credentials
  ///
  /// In id, this message translates to:
  /// **'Email/telepon atau kata sandi salah.'**
  String get err_invalidCredentials;

  /// Error message for required field
  ///
  /// In id, this message translates to:
  /// **'Kolom ini wajib diisi.'**
  String get err_requiredField;

  /// Error message for invalid email
  ///
  /// In id, this message translates to:
  /// **'Format email tidak valid.'**
  String get err_invalidEmail;

  /// Error message for invalid phone
  ///
  /// In id, this message translates to:
  /// **'Format nomor telepon tidak valid.'**
  String get err_invalidPhone;

  /// Error message for generic error
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan. Silakan coba lagi.'**
  String get err_somethingWentWrong;

  /// Error message for no data
  ///
  /// In id, this message translates to:
  /// **'Tidak ada data.'**
  String get err_noData;

  /// Error message for load failed
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data.'**
  String get err_loadFailed;

  /// Error label for bad request (400)
  ///
  /// In id, this message translates to:
  /// **'Permintaan tidak valid'**
  String get err_badRequest;

  /// Error label for forbidden (403)
  ///
  /// In id, this message translates to:
  /// **'Akses ditolak'**
  String get err_forbidden;

  /// Error label for not found (404)
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan'**
  String get err_notFound;

  /// Error label for conflict (409)
  ///
  /// In id, this message translates to:
  /// **'Konflik data'**
  String get err_conflict;

  /// Error label for validation error (422)
  ///
  /// In id, this message translates to:
  /// **'Kesalahan validasi'**
  String get err_validationError;

  /// Generic error label
  ///
  /// In id, this message translates to:
  /// **'Kesalahan'**
  String get err_error;

  /// Error message for account locked (403)
  ///
  /// In id, this message translates to:
  /// **'Akun Anda terkunci sementara. Silakan tunggu 5 menit dan coba lagi.'**
  String get err_accountLocked;

  /// Error status with code
  ///
  /// In id, this message translates to:
  /// **'{code} • {label}'**
  String err_statusWithCode(int code, String label);

  /// Auth welcome back title
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang Kembali'**
  String get auth_welcomeBack;

  /// Auth sign in subtitle
  ///
  /// In id, this message translates to:
  /// **'Masuk ke akun admin Anda'**
  String get auth_signInSubtitle;

  /// Auth verify OTP title
  ///
  /// In id, this message translates to:
  /// **'Verifikasi OTP'**
  String get auth_verifyOtp;

  /// Auth enter code instruction
  ///
  /// In id, this message translates to:
  /// **'Masukkan kode verifikasi yang dikirim ke'**
  String get auth_enterCode;

  /// Auth verification successful message
  ///
  /// In id, this message translates to:
  /// **'Verifikasi Berhasil'**
  String get auth_verificationSuccessful;

  /// Auth enter phone number title
  ///
  /// In id, this message translates to:
  /// **'Masukkan Nomor Telepon'**
  String get auth_enterPhoneNumber;

  /// Auth phone number hint
  ///
  /// In id, this message translates to:
  /// **'Contoh: 08123456789'**
  String get auth_phoneHint;

  /// Auth OTP sent message
  ///
  /// In id, this message translates to:
  /// **'Kode OTP telah dikirim'**
  String get auth_otpSent;

  /// Auth resend countdown
  ///
  /// In id, this message translates to:
  /// **'Kirim ulang dalam {seconds} detik'**
  String auth_resendIn(int seconds);

  /// Dashboard title
  ///
  /// In id, this message translates to:
  /// **'Dasbor'**
  String get dashboard_title;

  /// Dashboard subtitle
  ///
  /// In id, this message translates to:
  /// **'Ringkasan kegiatan gereja Anda.'**
  String get dashboard_subtitle;

  /// Dashboard total members label
  ///
  /// In id, this message translates to:
  /// **'Total Anggota'**
  String get dashboard_totalMembers;

  /// Dashboard total revenue label
  ///
  /// In id, this message translates to:
  /// **'Total Pendapatan'**
  String get dashboard_totalRevenue;

  /// Dashboard total expense label
  ///
  /// In id, this message translates to:
  /// **'Total Pengeluaran'**
  String get dashboard_totalExpense;

  /// Dashboard recent activity label
  ///
  /// In id, this message translates to:
  /// **'Aktivitas Terbaru'**
  String get dashboard_recentActivity;

  /// Dashboard overview label
  ///
  /// In id, this message translates to:
  /// **'Ringkasan'**
  String get dashboard_overview;

  /// Dashboard statistics label
  ///
  /// In id, this message translates to:
  /// **'Statistik'**
  String get dashboard_statistics;

  /// Message shown when user presses back to exit
  ///
  /// In id, this message translates to:
  /// **'Tekan kembali untuk keluar'**
  String get msg_pressBackToExit;

  /// Member count with pluralization
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Tidak ada anggota} =1{1 anggota} other{{count} anggota}}'**
  String memberCount(int count);

  /// Indonesian language name
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get lang_indonesian;

  /// English language name
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get lang_english;
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
