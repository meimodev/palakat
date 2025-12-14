// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Palakat';

  @override
  String get appTitle_admin => 'Palakat Admin';

  @override
  String get nav_dashboard => 'Beranda';

  @override
  String get nav_members => 'Anggota';

  @override
  String get nav_activity => 'Kegiatan';

  @override
  String get nav_revenue => 'Pendapatan';

  @override
  String get nav_expense => 'Pengeluaran';

  @override
  String get nav_report => 'Laporan';

  @override
  String get nav_church => 'Gereja';

  @override
  String get nav_document => 'Dokumen';

  @override
  String get nav_approval => 'Persetujuan';

  @override
  String get nav_financial => 'Keuangan';

  @override
  String get nav_billing => 'Tagihan';

  @override
  String get nav_account => 'Akun';

  @override
  String get nav_section_report => 'Laporan';

  @override
  String get nav_section_administration => 'Administrasi';

  @override
  String get nav_home => 'Beranda';

  @override
  String get nav_songs => 'Lagu';

  @override
  String get nav_operations => 'Ops';

  @override
  String get approval_title => 'Persetujuan';

  @override
  String get approval_filterAll => 'Semua';

  @override
  String get approval_filterMyAction => 'Tindakan Saya';

  @override
  String get approval_filterByDate => 'Filter berdasarkan tanggal';

  @override
  String get approval_noMoreApprovals => 'Tidak ada persetujuan lagi';

  @override
  String get approval_sectionPendingYourAction => 'Menunggu Tindakan Anda';

  @override
  String get approval_sectionPendingOthers => 'Menunggu Tindakan Lain';

  @override
  String get approval_allCaughtUpTitle => 'Semua selesai!';

  @override
  String get approval_allCaughtUpSubtitle =>
      'Tidak ada persetujuan yang menunggu tindakan Anda';

  @override
  String approval_pendingReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count persetujuan menunggu tinjauan Anda',
      one: '1 persetujuan menunggu tinjauan Anda',
    );
    return '$_temp0';
  }

  @override
  String get approval_emptyTitle => 'Tidak ada persetujuan';

  @override
  String get approval_emptySubtitle => 'Coba sesuaikan filter Anda';

  @override
  String get approval_errorTitle => 'Terjadi kesalahan';

  @override
  String get approval_confirmApproveTitle => 'Setujui Kegiatan?';

  @override
  String get approval_confirmRejectTitle => 'Tolak Kegiatan?';

  @override
  String get approval_confirmApproveDescription =>
      'Apakah Anda yakin ingin menyetujui kegiatan ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get approval_confirmRejectDescription =>
      'Apakah Anda yakin ingin menolak kegiatan ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get activityType_service => 'Ibadah';

  @override
  String get activityType_event => 'Kegiatan';

  @override
  String get activityType_announcement => 'Pengumuman';

  @override
  String approval_snackbarApproved(String activityTitle) {
    return 'Disetujui: $activityTitle';
  }

  @override
  String approval_snackbarRejected(String activityTitle) {
    return 'Ditolak: $activityTitle';
  }

  @override
  String get admin_billing_title => 'Manajemen Tagihan';

  @override
  String get admin_billing_subtitle =>
      'Kelola tagihan gereja, pembayaran, dan lihat riwayat pembayaran.';

  @override
  String get admin_approval_title => 'Persetujuan';

  @override
  String get admin_account_title => 'Akun';

  @override
  String get admin_account_subtitle =>
      'Kelola informasi akun dan pengaturan Anda';

  @override
  String get admin_activity_title => 'Kegiatan';

  @override
  String get admin_revenue_title => 'Pendapatan';

  @override
  String get admin_revenue_subtitle =>
      'Lacak dan kelola semua sumber pendapatan.';

  @override
  String get admin_member_title => 'Anggota';

  @override
  String get admin_financial_title => 'Nomor Akun Keuangan';

  @override
  String get admin_financial_subtitle =>
      'Kelola nomor akun keuangan untuk gereja Anda.';

  @override
  String get admin_documentSettings_title => 'Pengaturan Dokumen';

  @override
  String get admin_documentSettings_subtitle =>
      'Kelola nomor identitas dokumen dan lihat persetujuan terbaru.';

  @override
  String get admin_documentIdentityNumber_title => 'Nomor Identitas Dokumen';

  @override
  String get admin_documentIdentityNumber_subtitle =>
      'Template saat ini yang digunakan untuk dokumen baru.';

  @override
  String get admin_documentDirectory_title => 'Direktori Dokumen';

  @override
  String get admin_documentDirectory_subtitle =>
      'Catatan semua dokumen gereja yang telah disetujui.';

  @override
  String get admin_church_title => 'Profil Gereja';

  @override
  String get admin_church_subtitle =>
      'Kelola informasi publik dan kolom gereja Anda.';

  @override
  String get btn_continue => 'Lanjutkan';

  @override
  String get btn_cancel => 'Batal';

  @override
  String get btn_save => 'Simpan';

  @override
  String get btn_delete => 'Hapus';

  @override
  String get btn_retry => 'Coba Lagi';

  @override
  String get btn_signIn => 'Masuk';

  @override
  String get btn_signOut => 'Keluar';

  @override
  String get btn_signOutConfirm => 'Keluar?';

  @override
  String get btn_signOutMessage =>
      'Apakah Anda yakin ingin keluar? Anda perlu masuk kembali untuk mengakses akun Anda.';

  @override
  String get btn_resendCode => 'Kirim Ulang Kode';

  @override
  String get btn_submit => 'Kirim';

  @override
  String get btn_edit => 'Ubah';

  @override
  String get btn_add => 'Tambah';

  @override
  String get btn_close => 'Tutup';

  @override
  String get btn_confirm => 'Konfirmasi';

  @override
  String get btn_back => 'Kembali';

  @override
  String get btn_addAccountNumber => 'Tambah Nomor Akun';

  @override
  String get btn_generateReport => 'Buat Laporan';

  @override
  String get btn_recordPayment => 'Catat Pembayaran';

  @override
  String get btn_exportReceipt => 'Ekspor Kwitansi';

  @override
  String get btn_approve => 'Setujui';

  @override
  String get btn_reject => 'Tolak';

  @override
  String get btn_export => 'Ekspor';

  @override
  String get btn_remove => 'Hapus';

  @override
  String get btn_create => 'Buat';

  @override
  String get btn_update => 'Perbarui';

  @override
  String get btn_addRule => 'Tambah Aturan';

  @override
  String get btn_viewAll => 'Lihat Semua';

  @override
  String get btn_saveChanges => 'Simpan Perubahan';

  @override
  String get btn_updatePassword => 'Perbarui Kata Sandi';

  @override
  String get lbl_email => 'Email';

  @override
  String get lbl_phone => 'Nomor Telepon';

  @override
  String get lbl_password => 'Kata Sandi';

  @override
  String get lbl_language => 'Bahasa';

  @override
  String get lbl_name => 'Nama';

  @override
  String get lbl_address => 'Alamat';

  @override
  String get lbl_date => 'Tanggal';

  @override
  String get lbl_time => 'Waktu';

  @override
  String get lbl_description => 'Deskripsi';

  @override
  String get lbl_amount => 'Jumlah';

  @override
  String get lbl_search => 'Cari';

  @override
  String get lbl_generationType => 'Jenis Pembuatan';

  @override
  String get lbl_selectChurch => 'Pilih Gereja';

  @override
  String get lbl_selectColumn => 'Pilih Kolom';

  @override
  String get lbl_searchChurches => 'Cari gereja...';

  @override
  String get lbl_searchColumns => 'Cari kolom...';

  @override
  String get lbl_noChurchesFound => 'Tidak ada gereja ditemukan';

  @override
  String get lbl_noColumnsFound => 'Tidak ada kolom ditemukan';

  @override
  String get lbl_selectChurchFirst => 'Silakan pilih gereja terlebih dahulu';

  @override
  String lbl_selectAccount(Object type) {
    return 'Pilih Akun $type';
  }

  @override
  String get lbl_searchAccountNumber => 'Cari nomor akun atau deskripsi...';

  @override
  String lbl_noResultsFor(Object query) {
    return 'Tidak ada hasil untuk \"$query\"';
  }

  @override
  String get lbl_noAccountNumbers => 'Tidak ada nomor akun tersedia';

  @override
  String get lbl_churchNotAvailable => 'Informasi gereja tidak tersedia';

  @override
  String get lbl_template => 'Template';

  @override
  String get lbl_na => 'N/A';

  @override
  String get lbl_unknown => 'Tidak diketahui';

  @override
  String get lbl_you => 'Anda';

  @override
  String get lbl_reminder => 'Pengingat';

  @override
  String get lbl_targetAudience => 'Target Audiens';

  @override
  String get timePeriod_morning => 'Pagi';

  @override
  String get timePeriod_afternoon => 'Siang';

  @override
  String get timePeriod_evening => 'Malam';

  @override
  String get reminder_tenMinutes => '10 menit sebelumnya';

  @override
  String get reminder_thirtyMinutes => '30 menit sebelumnya';

  @override
  String get reminder_oneHour => '1 jam sebelumnya';

  @override
  String get reminder_twoHour => '2 jam sebelumnya';

  @override
  String get status_approved => 'Disetujui';

  @override
  String get status_pending => 'Menunggu';

  @override
  String get status_rejected => 'Ditolak';

  @override
  String get status_draft => 'Draf';

  @override
  String get status_completed => 'Selesai';

  @override
  String get status_cancelled => 'Dibatalkan';

  @override
  String get status_active => 'Aktif';

  @override
  String get status_inactive => 'Tidak Aktif';

  @override
  String get status_unconfirmed => 'Belum Dikonfirmasi';

  @override
  String get err_networkError => 'Kesalahan jaringan. Periksa koneksi Anda.';

  @override
  String get err_serverError => 'Kesalahan server. Coba lagi nanti.';

  @override
  String get err_unauthorized =>
      'Sesi Anda telah berakhir. Silakan masuk kembali.';

  @override
  String get err_invalidCredentials => 'Email/telepon atau kata sandi salah.';

  @override
  String get err_requiredField => 'Kolom ini wajib diisi.';

  @override
  String get err_invalidEmail => 'Format email tidak valid.';

  @override
  String get err_invalidPhone => 'Format nomor telepon tidak valid.';

  @override
  String get err_somethingWentWrong => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get err_noData => 'Tidak ada data.';

  @override
  String get err_loadFailed => 'Gagal memuat data.';

  @override
  String get err_badRequest => 'Permintaan tidak valid';

  @override
  String get err_forbidden => 'Akses ditolak';

  @override
  String get err_notFound => 'Tidak ditemukan';

  @override
  String get err_conflict => 'Konflik data';

  @override
  String get err_validationError => 'Kesalahan validasi';

  @override
  String get err_error => 'Kesalahan';

  @override
  String get err_accountLocked =>
      'Akun Anda terkunci sementara. Silakan tunggu 5 menit dan coba lagi.';

  @override
  String err_statusWithCode(Object code, Object label) {
    return '$code • $label';
  }

  @override
  String get auth_welcomeBack => 'Selamat Datang Kembali';

  @override
  String get auth_signInSubtitle => 'Masuk ke akun admin Anda';

  @override
  String get auth_verifyOtp => 'Verifikasi OTP';

  @override
  String get auth_enterCode => 'Masukkan kode verifikasi yang dikirim ke';

  @override
  String get auth_verificationSuccessful => 'Verifikasi Berhasil';

  @override
  String get auth_enterPhoneNumber => 'Masukkan Nomor Telepon';

  @override
  String get auth_phoneHint => 'Contoh: 08123456789';

  @override
  String get auth_otpSent => 'Kode OTP telah dikirim';

  @override
  String auth_resendIn(Object seconds) {
    return 'Kirim ulang dalam $seconds detik';
  }

  @override
  String get dashboard_title => 'Dasbor';

  @override
  String get dashboard_subtitle => 'Ringkasan kegiatan gereja Anda.';

  @override
  String get dashboard_totalMembers => 'Total Anggota';

  @override
  String get dashboard_totalRevenue => 'Total Pendapatan';

  @override
  String get dashboard_totalExpense => 'Total Pengeluaran';

  @override
  String get dashboard_recentActivity => 'Aktivitas Terbaru';

  @override
  String get dashboard_overview => 'Ringkasan';

  @override
  String get dashboard_statistics => 'Statistik';

  @override
  String get msg_pressBackToExit => 'Tekan kembali untuk keluar';

  @override
  String memberCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anggota',
      one: '1 anggota',
      zero: 'Tidak ada anggota',
    );
    return '$_temp0';
  }

  @override
  String get lang_indonesian => 'Bahasa Indonesia';

  @override
  String get lang_english => 'English';

  @override
  String get settings_title => 'Pengaturan';

  @override
  String get settings_accountSettings => 'Pengaturan Akun';

  @override
  String get settings_membershipSettings => 'Pengaturan Keanggotaan';

  @override
  String get settings_noMembership => 'Tidak ada keanggotaan tersedia';

  @override
  String get card_overdueBills_title => 'Tagihan Terlambat';

  @override
  String get card_overdueBills_subtitle =>
      'Tagihan yang memerlukan perhatian segera';

  @override
  String get card_paymentHistory_title => 'Riwayat Pembayaran';

  @override
  String get card_paymentHistory_subtitle =>
      'Lihat semua transaksi dan riwayat pembayaran.';

  @override
  String get card_billingItems_title => 'Item Tagihan';

  @override
  String get card_billingItems_subtitle =>
      'Kelola tagihan dan catatan pembayaran gereja.';

  @override
  String card_billingItems_subtitleWithTotal(int total) {
    return 'Kelola tagihan dan catatan pembayaran gereja. Total item: $total';
  }

  @override
  String get card_approvalRules_title => 'Aturan Persetujuan';

  @override
  String get card_approvalRules_subtitle =>
      'Konfigurasi aturan routing persetujuan dan persyaratan';

  @override
  String get card_memberDirectory_title => 'Direktori Anggota';

  @override
  String get card_memberDirectory_subtitle => 'Catatan semua anggota gereja.';

  @override
  String get card_accountNumbers_title => 'Nomor Akun';

  @override
  String get card_accountNumbers_subtitle =>
      'Daftar semua nomor akun keuangan untuk gereja Anda.';

  @override
  String get card_basicInfo_title => 'Informasi Dasar';

  @override
  String get card_basicInfo_subtitle => 'Detail gereja dan informasi kontak';

  @override
  String get card_location_title => 'Lokasi';

  @override
  String get card_location_subtitle => 'Alamat gereja dan informasi geografis';

  @override
  String get card_columnManagement_title => 'Manajemen Kolom';

  @override
  String get card_columnManagement_subtitle => 'Kelola kolom organisasi gereja';

  @override
  String get card_positionManagement_title => 'Manajemen Jabatan';

  @override
  String get card_positionManagement_subtitle =>
      'Kelola jabatan kepemimpinan gereja';

  @override
  String get card_revenueRecords_title => 'Catatan Pendapatan';

  @override
  String get card_revenueRecords_subtitle =>
      'Lacak dan kelola pendapatan gereja.';

  @override
  String get card_revenueLog_title => 'Log Pendapatan';

  @override
  String get card_revenueLog_subtitle =>
      'Catatan semua pendapatan yang tercatat.';

  @override
  String get card_expenseRecords_title => 'Catatan Pengeluaran';

  @override
  String get card_expenseRecords_subtitle =>
      'Lacak dan kelola pengeluaran gereja.';

  @override
  String get card_activityList_title => 'Daftar Kegiatan';

  @override
  String get card_activityList_subtitle =>
      'Lihat semua kegiatan dan acara gereja.';

  @override
  String get card_documentList_title => 'Dokumen';

  @override
  String get card_documentList_subtitle => 'Kelola dokumen dan file gereja.';

  @override
  String get card_reportList_title => 'Laporan';

  @override
  String get card_reportList_subtitle => 'Buat dan lihat laporan gereja.';

  @override
  String get card_reportHistory_title => 'Riwayat Laporan';

  @override
  String get card_paymentInfo_title => 'Informasi Pembayaran';

  @override
  String get card_paymentInfo_subtitle =>
      'Detail tentang metode pembayaran dan akun';

  @override
  String get card_recentActivity_title => 'Aktivitas Terbaru';

  @override
  String get card_recentActivity_subtitle =>
      'Kegiatan dan acara gereja terbaru';

  @override
  String get card_statistics_title => 'Statistik';

  @override
  String get card_statistics_subtitle => 'Metrik kinerja dan analitik gereja';

  @override
  String get card_overview_title => 'Ringkasan';

  @override
  String get card_overview_subtitle => 'Ringkasan informasi kunci gereja';

  @override
  String get card_accountSettings_title => 'Pengaturan Akun';

  @override
  String get card_accountSettings_subtitle =>
      'Kelola preferensi akun pribadi Anda';

  @override
  String get card_churchInfo_title => 'Informasi Gereja';

  @override
  String get card_churchInfo_subtitle => 'Detail dasar gereja dan pengaturan';

  @override
  String get card_financialSummary_title => 'Ringkasan Keuangan';

  @override
  String get card_financialSummary_subtitle =>
      'Ringkasan status keuangan gereja';

  @override
  String get card_accountInfo_title => 'Informasi Akun';

  @override
  String get card_accountInfo_subtitle =>
      'Kelola profil dan informasi pribadi Anda';

  @override
  String get card_securitySettings_title => 'Pengaturan Keamanan';

  @override
  String get card_securitySettings_subtitle => 'Kelola keamanan akun Anda';

  @override
  String get card_languageSettings_title => 'Pengaturan Bahasa';

  @override
  String get card_languageSettings_subtitle =>
      'Pilih bahasa yang Anda inginkan';

  @override
  String get card_accountActions_title => 'Tindakan Akun';

  @override
  String get card_accountActions_subtitle => 'Kelola sesi akun Anda';

  @override
  String get drawer_addMember_title => 'Tambah Anggota';

  @override
  String get drawer_addMember_subtitle => 'Buat anggota baru';

  @override
  String get drawer_editMember_title => 'Ubah Anggota';

  @override
  String get drawer_editMember_subtitle => 'Perbarui informasi anggota';

  @override
  String get drawer_addApprovalRule_title => 'Tambah Aturan Persetujuan';

  @override
  String get drawer_addApprovalRule_subtitle => 'Buat aturan persetujuan baru';

  @override
  String get drawer_editApprovalRule_title => 'Ubah Aturan Persetujuan';

  @override
  String get drawer_editApprovalRule_subtitle =>
      'Perbarui informasi aturan persetujuan';

  @override
  String get drawer_activityDetails_title => 'Detail Kegiatan';

  @override
  String get drawer_activityDetails_subtitle =>
      'Lihat informasi detail tentang kegiatan ini';

  @override
  String get drawer_revenueDetails_title => 'Detail Pendapatan';

  @override
  String get drawer_revenueDetails_subtitle =>
      'Lihat informasi detail tentang entri pendapatan ini';

  @override
  String get drawer_expenseDetails_title => 'Detail Pengeluaran';

  @override
  String get drawer_expenseDetails_subtitle =>
      'Lihat informasi detail tentang entri pengeluaran ini';

  @override
  String get drawer_editChurchInfo_title => 'Ubah Informasi Gereja';

  @override
  String get drawer_editChurchInfo_subtitle => 'Perbarui detail gereja Anda';

  @override
  String get drawer_editLocation_title => 'Ubah Lokasi';

  @override
  String get drawer_editLocation_subtitle =>
      'Perbarui alamat dan koordinat gereja Anda';

  @override
  String get drawer_addColumn_title => 'Tambah Kolom';

  @override
  String get drawer_addColumn_subtitle => 'Buat kolom baru';

  @override
  String get drawer_editColumn_title => 'Ubah Kolom';

  @override
  String get drawer_editColumn_subtitle => 'Perbarui informasi kolom';

  @override
  String get drawer_addPosition_title => 'Tambah Jabatan';

  @override
  String get drawer_addPosition_subtitle => 'Buat jabatan baru';

  @override
  String get drawer_editPosition_title => 'Ubah Jabatan';

  @override
  String get drawer_editPosition_subtitle => 'Perbarui informasi jabatan';

  @override
  String get drawer_addAccountNumber_title => 'Tambah Nomor Akun';

  @override
  String get drawer_addAccountNumber_subtitle =>
      'Buat nomor akun keuangan baru';

  @override
  String get drawer_editAccountNumber_title => 'Ubah Nomor Akun';

  @override
  String get drawer_editAccountNumber_subtitle => 'Perbarui detail nomor akun';

  @override
  String get drawer_generateReport_title => 'Buat Laporan';

  @override
  String get drawer_generateReport_subtitle =>
      'Konfigurasi laporan yang baru dibuat';

  @override
  String get drawer_editDocumentId_title => 'Ubah Nomor Identitas Dokumen';

  @override
  String get drawer_editDocumentId_subtitle =>
      'Perbarui template yang digunakan untuk dokumen baru';

  @override
  String get drawer_paymentHistory_title => 'Riwayat Pembayaran';

  @override
  String get drawer_paymentHistory_subtitle =>
      'Riwayat transaksi pembayaran lengkap';

  @override
  String get drawer_billingDetails_title => 'Detail Tagihan';

  @override
  String get drawer_editAccountInfo_title => 'Ubah Informasi Akun';

  @override
  String get drawer_editAccountInfo_subtitle => 'Perbarui detail profil Anda';

  @override
  String get drawer_changePassword_title => 'Ubah Kata Sandi';

  @override
  String get drawer_changePassword_subtitle =>
      'Jaga keamanan akun Anda dengan kata sandi yang kuat';

  @override
  String get lbl_ruleId => 'ID Aturan';

  @override
  String get lbl_ruleName => 'Nama Aturan';

  @override
  String get lbl_ruleDescription => 'Deskripsi (Opsional)';

  @override
  String get lbl_activityType => 'Jenis Kegiatan (Opsional)';

  @override
  String get lbl_financialType => 'Jenis Keuangan (Opsional)';

  @override
  String get lbl_financialAccountNumber => 'Nomor Akun Keuangan *';

  @override
  String get lbl_positions => 'Jabatan';

  @override
  String get lbl_memberId => 'ID Anggota';

  @override
  String get lbl_maritalStatus => 'Status Pernikahan';

  @override
  String get lbl_gender => 'Jenis Kelamin';

  @override
  String get lbl_dateOfBirth => 'Tanggal Lahir';

  @override
  String get lbl_churchName => 'Nama Gereja';

  @override
  String get lbl_churchAddress => 'Alamat Gereja';

  @override
  String get lbl_contactPerson => 'Narahubung';

  @override
  String get lbl_phoneNumberOptional => 'Nomor Telepon (Opsional)';

  @override
  String get lbl_emailOptional => 'Email (Opsional)';

  @override
  String get lbl_descriptionOptional => 'Deskripsi (Opsional)';

  @override
  String get lbl_latitude => 'Lintang';

  @override
  String get lbl_longitude => 'Bujur';

  @override
  String get lbl_accountNumber => 'Nomor Akun';

  @override
  String get lbl_type => 'Jenis';

  @override
  String get lbl_columnId => 'ID Kolom';

  @override
  String get lbl_columnName => 'Nama Kolom';

  @override
  String get lbl_positionId => 'ID Jabatan';

  @override
  String get lbl_positionName => 'Nama Jabatan';

  @override
  String get lbl_reportType => 'Jenis Laporan';

  @override
  String get lbl_dateRange => 'Rentang Tanggal';

  @override
  String get lbl_allTime => 'Sepanjang Waktu';

  @override
  String get lbl_revenueId => 'ID Pendapatan';

  @override
  String get lbl_expenseId => 'ID Pengeluaran';

  @override
  String get lbl_activityId => 'ID Kegiatan';

  @override
  String get lbl_title => 'Judul';

  @override
  String get lbl_activityDateTime => 'Tanggal & Waktu Kegiatan';

  @override
  String get lbl_note => 'Catatan';

  @override
  String get lbl_activity => 'Kegiatan';

  @override
  String get lbl_approveOn => 'Disetujui Pada';

  @override
  String get lbl_requestedAt => 'Diminta Pada';

  @override
  String get lbl_createdAt => 'Dibuat Pada';

  @override
  String get lbl_updatedAt => 'Diperbarui Pada';

  @override
  String get lbl_method => 'Metode';

  @override
  String get lbl_transactionId => 'ID Transaksi';

  @override
  String get lbl_notes => 'Catatan';

  @override
  String get lbl_paidDate => 'Tanggal Bayar';

  @override
  String get lbl_payments => 'Pembayaran';

  @override
  String get lbl_bill => 'Tagihan';

  @override
  String get lbl_optional => '(Opsional)';

  @override
  String get lbl_active => 'Aktif';

  @override
  String get lbl_baptized => 'Dibaptis';

  @override
  String get lbl_sidi => 'SIDI';

  @override
  String get lbl_noFilters => 'Tidak ada filter';

  @override
  String get lbl_adminUser => 'Pengguna Admin';

  @override
  String get lbl_fullName => 'Nama Lengkap';

  @override
  String get lbl_position => 'Jabatan';

  @override
  String get lbl_currentPassword => 'Kata Sandi Saat Ini';

  @override
  String get lbl_newPassword => 'Kata Sandi Baru';

  @override
  String get lbl_confirmNewPassword => 'Konfirmasi Kata Sandi Baru';

  @override
  String get lbl_changePassword => 'Ubah Kata Sandi';

  @override
  String get lbl_changePasswordDesc =>
      'Perbarui kata sandi Anda secara berkala untuk keamanan';

  @override
  String get lbl_signOutDesc => 'Keluar dari sesi Anda saat ini';

  @override
  String get desc_ruleActive => 'Aturan ini sedang aktif';

  @override
  String get desc_ruleInactive =>
      'Aturan ini tidak aktif dan tidak akan diterapkan';

  @override
  String get desc_activityTypeFilter =>
      'Jika diatur, aturan ini hanya berlaku untuk aktivitas dengan jenis yang dipilih.';

  @override
  String get desc_financialFilter =>
      'Jika diatur, aturan ini hanya berlaku untuk aktivitas dengan data keuangan yang sesuai.';

  @override
  String get section_basicInformation => 'Informasi Dasar';

  @override
  String get section_ruleInformation => 'Informasi Aturan';

  @override
  String get section_status => 'Status';

  @override
  String get section_activityTypeFilter => 'Filter Jenis Kegiatan';

  @override
  String get section_financialFilter => 'Filter Keuangan';

  @override
  String get section_requiredApprovers => 'Penyetuju Wajib';

  @override
  String get section_activityInformation => 'Informasi Kegiatan';

  @override
  String get section_approval => 'Persetujuan';

  @override
  String get section_approvalStatus => 'Status Persetujuan';

  @override
  String get section_personInCharge => 'Penanggung Jawab';

  @override
  String get section_schedule => 'Jadwal';

  @override
  String get section_financialRecord => 'Catatan Keuangan';

  @override
  String get section_announcementDetails => 'Detail Pengumuman';

  @override
  String get section_timestamps => 'Waktu';

  @override
  String get section_locationDetails => 'Detail Lokasi';

  @override
  String get section_reportDetails => 'Detail Laporan';

  @override
  String get section_paymentInformation => 'Informasi Pembayaran';

  @override
  String get section_positionInformation => 'Informasi Jabatan';

  @override
  String get section_memberInThisPosition => 'Anggota dalam Jabatan Ini';

  @override
  String section_registeredMembers(int count) {
    return 'Anggota Terdaftar ($count)';
  }

  @override
  String get publish_basicInfoSubtitle => 'Judul dan target audiens';

  @override
  String get publish_hintEnterActivityTitle => 'Masukkan judul kegiatan';

  @override
  String get publish_targetAudienceBipra => 'Target Audiens (BIPRA)';

  @override
  String get publish_selectTargetGroup => 'Pilih kelompok target';

  @override
  String get publish_targetGroup => 'Kelompok Target';

  @override
  String get publish_locationSubtitle => 'Di mana kegiatan ini berlangsung?';

  @override
  String get publish_hintLocationExample =>
      'contoh: Aula Gereja, Nama Tuan Rumah';

  @override
  String get publish_lblLocationName => 'Nama Lokasi';

  @override
  String get publish_pinOnMapOptional => 'Pin di Peta (opsional)';

  @override
  String get publish_tapToSelectLocationOptional =>
      'Ketuk untuk memilih lokasi di peta (opsional)';

  @override
  String get publish_locationSelected => 'Lokasi Dipilih';

  @override
  String get publish_scheduleSubtitle => 'Kapan kegiatan ini berlangsung?';

  @override
  String get publish_hintAdditionalNotes =>
      'Detail lain yang perlu diketahui peserta';

  @override
  String get publish_eventSchedule => 'Jadwal Kegiatan';

  @override
  String get publish_reminderSubtitle => 'Kapan memberi notifikasi ke peserta';

  @override
  String get publish_announcementDetailsSubtitle => 'Konten dan lampiran';

  @override
  String get publish_hintAnnouncement => 'Tulis pengumuman Anda di sini...';

  @override
  String get publish_uploadFile => 'Unggah File';

  @override
  String get publish_supportedFileTypes => 'JPG, PNG, PDF, DOC, DOCX';

  @override
  String get publish_fillAllRequiredFields =>
      'Silakan isi semua kolom yang wajib';

  @override
  String get publish_financialRecordSubtitle =>
      'Opsional: Lampirkan pendapatan atau pengeluaran';

  @override
  String get publish_addFinancialRecord => 'Tambah Catatan Keuangan';

  @override
  String get publish_removeFinancialRecordTitle => 'Hapus Catatan Keuangan?';

  @override
  String get publish_removeFinancialRecordContent =>
      'Apakah Anda yakin ingin menghapus catatan keuangan ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get churchRequest_title => 'Permohonan Pendaftaran Gereja';

  @override
  String get churchRequest_description =>
      'Isi detail di bawah ini untuk mengajukan pendaftaran gereja Anda. Kami akan meninjau dan menambahkannya ke sistem kami.';

  @override
  String get churchRequest_requesterInformation => 'Informasi Pemohon';

  @override
  String get churchRequest_churchInformation => 'Informasi Gereja';

  @override
  String get churchRequest_hintEnterContactPersonName =>
      'Masukkan nama narahubung';

  @override
  String get churchRequest_hintPhoneExample => '0812-3456-7890';

  @override
  String get churchRequest_submitting => 'Mengirim...';

  @override
  String get churchRequest_submitRequest => 'Kirim Permintaan';

  @override
  String get churchRequest_fixErrorsBeforeSubmitting =>
      'Silakan perbaiki kesalahan di atas sebelum mengirim';

  @override
  String get churchRequest_fillAllRequiredFieldsCorrectly =>
      'Silakan isi semua kolom wajib dengan benar';

  @override
  String get churchRequest_submittedSuccessfully =>
      'Permohonan pendaftaran gereja berhasil dikirim!';

  @override
  String get churchRequest_validation_completeAddress =>
      'Silakan masukkan alamat lengkap';

  @override
  String churchRequest_validation_phoneMinDigits(int min) {
    return 'Nomor telepon minimal $min digit';
  }

  @override
  String churchRequest_validation_phoneMaxDigits(int max) {
    return 'Nomor telepon maksimal $max digit';
  }

  @override
  String get churchRequest_validation_phoneMustStartWithZero =>
      'Nomor telepon harus diawali 0';

  @override
  String churchRequest_errorWithDetail(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String get hint_enterChurchName => 'Masukkan nama gereja';

  @override
  String get hint_enterPhoneNumber => 'Masukkan nomor telepon';

  @override
  String get hint_enterEmailAddress => 'Masukkan alamat email';

  @override
  String get hint_describeYourChurch =>
      'Deskripsikan gereja Anda (terlihat oleh anggota)';

  @override
  String get hint_enterChurchAddress => 'Masukkan alamat gereja';

  @override
  String get hint_latitudeExample => 'contoh: -6.1754';

  @override
  String get hint_longitudeExample => 'contoh: 106.8272';

  @override
  String get hint_enterAccountNumber => 'Masukkan nomor akun';

  @override
  String get hint_enterDescription => 'Masukkan deskripsi';

  @override
  String get hint_enterColumnName => 'Masukkan nama kolom';

  @override
  String get hint_enterPositionName => 'Masukkan nama jabatan';

  @override
  String get hint_enterMemberName => 'Masukkan nama anggota';

  @override
  String get hint_enterFullName => 'Masukkan nama lengkap Anda';

  @override
  String get hint_enterYourPhoneNumber => 'Masukkan nomor telepon Anda';

  @override
  String get hint_enterYourPosition => 'Masukkan jabatan Anda';

  @override
  String get hint_enterCurrentPassword => 'Masukkan kata sandi saat ini';

  @override
  String get hint_enterNewPassword => 'Masukkan kata sandi baru';

  @override
  String get hint_reEnterNewPassword => 'Masukkan ulang kata sandi baru';

  @override
  String get hint_documentIdExample => 'contoh: DOC-2024-001';

  @override
  String get hint_approvalRuleExample => 'contoh: Transaksi Keuangan';

  @override
  String get hint_describeApprovalRule =>
      'Deskripsikan kapan persetujuan ini diperlukan';

  @override
  String get hint_allActivityTypes => 'Semua jenis kegiatan';

  @override
  String get hint_noFinancialFilter => 'Tanpa filter keuangan';

  @override
  String get hint_selectPositionsToApprove =>
      'Pilih jabatan untuk menyetujui...';

  @override
  String get hint_signInCredentials =>
      'contoh: nama@perusahaan.com atau 1234-5678-9012';

  @override
  String get hint_searchApprovalRules => 'Cari aturan persetujuan...';

  @override
  String get hint_searchBillingItems => 'Cari item tagihan...';

  @override
  String get hint_searchByAccountNumber =>
      'Cari berdasarkan nomor akun, judul kegiatan...';

  @override
  String get hint_searchByReportName => 'Cari berdasarkan nama laporan...';

  @override
  String get hint_searchNameColumnPosition => 'Cari nama / kolom / jabatan ...';

  @override
  String get hint_searchByTitleDescription =>
      'Cari berdasarkan judul, deskripsi, atau nama supervisor ...';

  @override
  String get hint_searchAccountNumberDescription =>
      'Cari nomor akun atau deskripsi...';

  @override
  String get dlg_selectPosition_title => 'Pilih Jabatan';

  @override
  String get hint_searchPositions => 'Cari berdasarkan nama jabatan';

  @override
  String get tbl_billId => 'ID Tagihan';

  @override
  String get tbl_description => 'Deskripsi';

  @override
  String get tbl_amount => 'Jumlah';

  @override
  String get tbl_dueDate => 'Tanggal Jatuh Tempo';

  @override
  String get tbl_status => 'Status';

  @override
  String get tbl_paymentId => 'ID Pembayaran';

  @override
  String get tbl_accountId => 'ID Akun';

  @override
  String get tbl_method => 'Metode';

  @override
  String get tbl_date => 'Tanggal';

  @override
  String get tbl_accountNumber => 'Nomor Akun';

  @override
  String get tbl_activity => 'Kegiatan';

  @override
  String get tbl_requestDate => 'Tanggal Permintaan';

  @override
  String get tbl_approvalDate => 'Tanggal Persetujuan';

  @override
  String get tbl_paymentMethod => 'Metode Pembayaran';

  @override
  String get tbl_title => 'Judul';

  @override
  String get tbl_type => 'Jenis';

  @override
  String get tbl_supervisor => 'Supervisor';

  @override
  String get tbl_approval => 'Persetujuan';

  @override
  String get tbl_approvers => 'Penyetuju';

  @override
  String get tbl_name => 'Nama';

  @override
  String get tbl_phone => 'Telepon';

  @override
  String get tbl_birth => 'Lahir';

  @override
  String get tbl_bipra => 'BIPRA';

  @override
  String get tbl_positions => 'Jabatan';

  @override
  String get tbl_ruleName => 'Nama Aturan';

  @override
  String get tbl_filters => 'Filter';

  @override
  String get tbl_documentName => 'Nama Dokumen';

  @override
  String get tbl_createdDate => 'Tanggal Dibuat';

  @override
  String get tbl_reportName => 'Nama Laporan';

  @override
  String get tbl_by => 'Oleh';

  @override
  String get tbl_on => 'Pada';

  @override
  String get tbl_file => 'File';

  @override
  String get opt_manual => 'Manual';

  @override
  String get opt_system => 'Sistem';

  @override
  String get reportType_incomingDocument => 'Dokumen Masuk';

  @override
  String get reportTitle_incomingDocument => 'Laporan Dokumen Masuk';

  @override
  String get reportDesc_incomingDocument =>
      'Buat laporan untuk dokumen yang diterima.';

  @override
  String get reportType_congregation => 'Jemaat';

  @override
  String get reportTitle_congregation => 'Laporan Jemaat';

  @override
  String get reportDesc_congregation => 'Buat laporan mengenai jemaat.';

  @override
  String get reportType_services => 'Ibadah';

  @override
  String get reportTitle_services => 'Laporan Ibadah';

  @override
  String get reportDesc_services => 'Buat laporan untuk semua ibadah.';

  @override
  String get reportType_activity => 'Kegiatan';

  @override
  String get reportTitle_activity => 'Laporan Kegiatan';

  @override
  String get reportDesc_activity => 'Buat laporan untuk semua kegiatan.';

  @override
  String get tbl_linkedApprovalRule => 'Aturan Persetujuan Terkait';

  @override
  String get dlg_deleteRule_title => 'Hapus Aturan';

  @override
  String get dlg_deleteRule_content =>
      'Apakah Anda yakin ingin menghapus aturan persetujuan ini?';

  @override
  String get dlg_deleteMember_title => 'Hapus Anggota';

  @override
  String get dlg_deleteMember_content =>
      'Apakah Anda yakin ingin menghapus anggota ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get dlg_deletePosition_title => 'Hapus Jabatan';

  @override
  String get dlg_deletePosition_content =>
      'Apakah Anda yakin ingin menghapus jabatan ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get dlg_deleteColumn_title => 'Hapus Kolom';

  @override
  String get dlg_deleteColumn_content =>
      'Apakah Anda yakin ingin menghapus kolom ini? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get dlg_signOut_title => 'Keluar';

  @override
  String get dlg_signOut_content => 'Apakah Anda yakin ingin keluar?';

  @override
  String get dlg_recordPayment_title => 'Catat Pembayaran';

  @override
  String get dlg_confirmAction_title => 'Konfirmasi Tindakan';

  @override
  String get dlg_confirmDelete_title => 'Konfirmasi Hapus';

  @override
  String get filter_allStatus => 'Semua Status';

  @override
  String get filter_allActivityTypes => 'Semua jenis kegiatan';

  @override
  String get filter_noFinancialFilter => 'Tanpa filter keuangan';

  @override
  String get filter_paymentMethod => 'Metode Pembayaran';

  @override
  String get filter_items => 'Item';

  @override
  String get filter_allPositions => 'Semua Jabatan';

  @override
  String filter_allWithLabel(String label) {
    return 'Semua $label';
  }

  @override
  String get tooltip_clearSearch => 'Hapus pencarian';

  @override
  String get msg_tryDifferentSearchTerm => 'Coba kata kunci pencarian lain';

  @override
  String pagination_showingRows(int showing, int total) {
    return 'Menampilkan $showing dari $total baris';
  }

  @override
  String get pagination_rowsPerPage => 'Baris per halaman';

  @override
  String get pagination_page => 'Halaman';

  @override
  String pagination_ofPageCount(int pageCount) {
    return 'dari $pageCount';
  }

  @override
  String get pagination_previous => 'Sebelumnya';

  @override
  String get pagination_next => 'Berikutnya';

  @override
  String get dateRangeFilter_quickRangesTooltip => 'Rentang cepat';

  @override
  String get dateRangeFilter_thisWeek => 'Minggu ini';

  @override
  String get dateRangeFilter_lastWeek => 'Minggu lalu';

  @override
  String get dateRangeFilter_thisMonth => 'Bulan ini';

  @override
  String get dateRangeFilter_lastMonth => 'Bulan lalu';

  @override
  String get dateRangeFilter_clearTooltip => 'Hapus rentang tanggal';

  @override
  String get msg_saved => 'Berhasil disimpan';

  @override
  String get msg_created => 'Berhasil dibuat';

  @override
  String get msg_updated => 'Berhasil diperbarui';

  @override
  String get msg_deleted => 'Berhasil dihapus';

  @override
  String get msg_approvalRuleCreated => 'Aturan persetujuan berhasil dibuat';

  @override
  String get msg_approvalRuleUpdated =>
      'Aturan persetujuan berhasil diperbarui';

  @override
  String get msg_approvalRuleDeleted => 'Aturan persetujuan berhasil dihapus';

  @override
  String get msg_recordedPayment => 'Pembayaran berhasil dicatat';

  @override
  String get msg_templateUpdated => 'Template berhasil diperbarui';

  @override
  String get msg_documentTemplateWarning =>
      'Mengubah template nomor identitas dapat menyebabkan beberapa nomor terlewati.';

  @override
  String get msg_reportGenerated => 'Laporan berhasil dibuat';

  @override
  String get msg_signedOut => 'Berhasil keluar';

  @override
  String get msg_passwordChanged => 'Kata sandi berhasil diubah';

  @override
  String get msg_accountUpdated => 'Informasi akun berhasil diperbarui';

  @override
  String get msg_activityNotFound => 'Kegiatan tidak ditemukan';

  @override
  String get msg_activityApproved => 'Kegiatan berhasil disetujui';

  @override
  String get msg_activityRejected => 'Kegiatan berhasil ditolak';

  @override
  String msg_generatedOn(String date) {
    return 'Dibuat pada $date';
  }

  @override
  String get msg_noGenerationDate => 'Tidak ada tanggal pembuatan';

  @override
  String get msg_exportComingSoon => 'Fitur ekspor akan segera hadir';

  @override
  String get msg_downloadReportToViewDetails =>
      'Untuk melihat detail laporan lengkap, silakan unduh file.';

  @override
  String msg_willBeRemindedAt(String reminderDate) {
    return 'Akan diingatkan pada $reminderDate';
  }

  @override
  String msg_approverCount(int count) {
    return '$count penyetuju';
  }

  @override
  String get msg_opening => 'Membuka...';

  @override
  String msg_openingReport(String reportName) {
    return 'Membuka $reportName...';
  }

  @override
  String get msg_cannotOpenReportFile => 'Tidak dapat membuka file laporan.';

  @override
  String get msg_reportGenerationMayTakeAWhile =>
      'Pembuatan laporan mungkin membutuhkan waktu, tergantung data yang diminta.';

  @override
  String get msg_saveFailed => 'Gagal menyimpan';

  @override
  String get msg_createFailed => 'Gagal membuat';

  @override
  String get msg_updateFailed => 'Gagal memperbarui';

  @override
  String get msg_deleteFailed => 'Gagal menghapus';

  @override
  String get msg_createApprovalRuleFailed => 'Gagal membuat aturan persetujuan';

  @override
  String get msg_updateApprovalRuleFailed =>
      'Gagal memperbarui aturan persetujuan';

  @override
  String get msg_deleteApprovalRuleFailed =>
      'Gagal menghapus aturan persetujuan';

  @override
  String get msg_recordPaymentFailed => 'Gagal mencatat pembayaran';

  @override
  String get msg_generateReportFailed => 'Gagal membuat laporan';

  @override
  String get msg_invalidPassword => 'Kata sandi harus minimal 6 karakter';

  @override
  String get msg_passwordMismatch => 'Kata sandi tidak cocok';

  @override
  String get msg_invalidUrl => 'URL tidak valid';

  @override
  String get msg_operationFailed => 'Operasi gagal';

  @override
  String get msg_serverError => 'Kesalahan Server';

  @override
  String get msg_badRequest => 'Permintaan Tidak Valid';

  @override
  String get msg_unauthorized => 'Tidak Diotorisasi';

  @override
  String get msg_forbidden => 'Akses Ditolak';

  @override
  String get msg_notFound => 'Tidak Ditemukan';

  @override
  String get msg_conflict => 'Konflik';

  @override
  String get msg_validationError => 'Kesalahan Validasi';

  @override
  String get msg_tooManyRequests => 'Terlalu Banyak Permintaan';

  @override
  String get msg_error => 'Kesalahan';

  @override
  String get msg_checkInput => 'Periksa masukan Anda';

  @override
  String get msg_signInAgain => 'Silakan masuk kembali';

  @override
  String get msg_insufficientPermissions => 'Izin tidak mencukupi';

  @override
  String get msg_resourceNotFound => 'Sumber daya tidak ditemukan';

  @override
  String get msg_stateConflict => 'Konflik status';

  @override
  String get msg_validationFailed => 'Validasi gagal';

  @override
  String get msg_slowDown => 'Perlambat';

  @override
  String get msg_tryAgainLater => 'Silakan coba lagi nanti';

  @override
  String get validation_required => 'Kolom ini wajib diisi';

  @override
  String get validation_requiredField => 'Kolom ini wajib diisi';

  @override
  String get validation_invalidEmail =>
      'Silakan masukkan alamat email yang valid';

  @override
  String get validation_invalidPhone =>
      'Silakan masukkan nomor telepon yang valid';

  @override
  String get validation_invalidUrl => 'Silakan masukkan URL yang valid';

  @override
  String get validation_invalidNumber => 'Silakan masukkan angka yang valid';

  @override
  String get validation_invalidDate => 'Silakan masukkan tanggal yang valid';

  @override
  String validation_minLength(int min) {
    return 'Harus minimal $min karakter';
  }

  @override
  String validation_maxLength(int max) {
    return 'Maksimal $max karakter';
  }

  @override
  String get validation_passwordTooShort =>
      'Kata sandi harus minimal 6 karakter';

  @override
  String get validation_passwordTooWeak =>
      'Kata sandi harus mengandung minimal satu huruf besar, satu huruf kecil, dan satu angka';

  @override
  String get validation_passwordMismatch => 'Kata sandi tidak cocok';

  @override
  String get validation_confirmPassword => 'Silakan konfirmasi kata sandi Anda';

  @override
  String get validation_currentPasswordRequired =>
      'Kata sandi saat ini diperlukan';

  @override
  String get validation_newPasswordRequired => 'Kata sandi baru diperlukan';

  @override
  String get validation_invalidAmount => 'Silakan masukkan jumlah yang valid';

  @override
  String get validation_amountTooLow => 'Jumlah harus lebih besar dari 0';

  @override
  String get validation_amountTooHigh => 'Jumlah melebihi batas maksimum';

  @override
  String get validation_invalidAccountNumber =>
      'Silakan masukkan nomor akun yang valid';

  @override
  String get validation_accountNumberExists => 'Nomor akun ini sudah ada';

  @override
  String get validation_nameRequired => 'Nama diperlukan';

  @override
  String get validation_titleRequired => 'Judul diperlukan';

  @override
  String get validation_descriptionRequired => 'Deskripsi diperlukan';

  @override
  String get validation_addressRequired => 'Alamat diperlukan';

  @override
  String get validation_phoneRequired => 'Nomor telepon diperlukan';

  @override
  String get validation_emailRequired => 'Alamat email diperlukan';

  @override
  String get validation_dateRequired => 'Tanggal diperlukan';

  @override
  String get validation_timeRequired => 'Waktu diperlukan';

  @override
  String get validation_selectionRequired => 'Silakan buat pilihan';

  @override
  String get validation_churchRequired => 'Silakan pilih gereja';

  @override
  String get validation_columnRequired => 'Silakan pilih kolom';

  @override
  String get validation_positionRequired => 'Silakan pilih jabatan';

  @override
  String get validation_activityTypeRequired => 'Silakan pilih jenis kegiatan';

  @override
  String get validation_financialTypeRequired => 'Silakan pilih jenis keuangan';

  @override
  String get validation_approverRequired => 'Minimal satu penyetuju diperlukan';

  @override
  String get validation_ruleNameRequired => 'Nama aturan diperlukan';

  @override
  String get validation_positionsRequired =>
      'Minimal satu posisi harus dipilih';

  @override
  String get validation_financialAccountRequired =>
      'Nomor akun keuangan diperlukan ketika jenis keuangan dipilih';

  @override
  String get validation_duplicateEntry => 'Entri ini sudah ada';

  @override
  String get validation_invalidFormat => 'Format tidak valid';

  @override
  String get validation_futureDate => 'Tanggal harus di masa depan';

  @override
  String get validation_pastDate => 'Tanggal harus di masa lalu';

  @override
  String get validation_invalidRange => 'Rentang tanggal tidak valid';

  @override
  String get validation_startDateAfterEnd =>
      'Tanggal mulai harus sebelum tanggal akhir';

  @override
  String get validation_coordinatesRequired => 'Koordinat diperlukan';

  @override
  String get validation_invalidLatitude => 'Lintang harus antara -90 dan 90';

  @override
  String get validation_invalidLongitude => 'Bujur harus antara -180 dan 180';

  @override
  String get loading_data => 'Memuat data...';

  @override
  String get loading_members => 'Memuat anggota...';

  @override
  String get loading_activities => 'Memuat kegiatan...';

  @override
  String get loading_revenue => 'Memuat pendapatan...';

  @override
  String get loading_expenses => 'Memuat pengeluaran...';

  @override
  String get loading_reports => 'Memuat laporan...';

  @override
  String get loading_documents => 'Memuat dokumen...';

  @override
  String get loading_approvals => 'Memuat persetujuan...';

  @override
  String get loading_billing => 'Memuat tagihan...';

  @override
  String get loading_financial => 'Memuat data keuangan...';

  @override
  String get loading_church => 'Memuat informasi gereja...';

  @override
  String get loading_account => 'Memuat informasi akun...';

  @override
  String get loading_please_wait => 'Mohon tunggu...';

  @override
  String get loading_saving => 'Menyimpan...';

  @override
  String get loading_deleting => 'Menghapus...';

  @override
  String get error_loadingData => 'Gagal memuat data';

  @override
  String get error_loadingMembers => 'Gagal memuat anggota';

  @override
  String get error_loadingActivities => 'Gagal memuat kegiatan';

  @override
  String get error_loadingRevenue => 'Gagal memuat pendapatan';

  @override
  String get error_loadingExpenses => 'Gagal memuat pengeluaran';

  @override
  String get error_loadingReports => 'Gagal memuat laporan';

  @override
  String get error_loadingDocuments => 'Gagal memuat dokumen';

  @override
  String get error_loadingApprovals => 'Gagal memuat persetujuan';

  @override
  String get error_loadingBilling => 'Gagal memuat tagihan';

  @override
  String get error_loadingFinancial => 'Gagal memuat data keuangan';

  @override
  String get error_loadingChurch => 'Gagal memuat informasi gereja';

  @override
  String get error_loadingAccount => 'Gagal memuat informasi akun';

  @override
  String get error_connectionFailed =>
      'Koneksi gagal. Periksa koneksi internet Anda.';

  @override
  String get error_timeout => 'Permintaan timeout. Silakan coba lagi.';

  @override
  String get error_unexpectedError => 'Terjadi kesalahan yang tidak terduga';

  @override
  String get noData_available => 'Tidak ada data tersedia';

  @override
  String get noData_members => 'Tidak ada anggota ditemukan';

  @override
  String get noData_activities => 'Tidak ada kegiatan ditemukan';

  @override
  String get noData_revenue => 'Tidak ada catatan pendapatan ditemukan';

  @override
  String get noData_expenses => 'Tidak ada catatan pengeluaran ditemukan';

  @override
  String get noData_reports => 'Tidak ada laporan ditemukan';

  @override
  String get noData_documents => 'Tidak ada dokumen ditemukan';

  @override
  String get noData_approvals => 'Tidak ada aturan persetujuan ditemukan';

  @override
  String get noData_billing => 'Tidak ada item tagihan ditemukan';

  @override
  String get noData_financial => 'Tidak ada nomor akun keuangan ditemukan';

  @override
  String get noData_church => 'Tidak ada informasi gereja tersedia';

  @override
  String get noData_results => 'Tidak ada hasil ditemukan';

  @override
  String get noData_matchingCriteria =>
      'Tidak ada data yang sesuai dengan kriteria pencarian Anda';

  @override
  String get noData_positions => 'Tidak ada posisi tersedia';

  @override
  String get noData_activityLink => 'Tidak terhubung ke kegiatan apapun';

  @override
  String get tooltip_refresh => 'Segarkan';

  @override
  String get tooltip_viewActivityDetails => 'Lihat Detail Kegiatan';

  @override
  String get tooltip_downloadReport => 'Unduh Laporan';

  @override
  String get tooltip_baptized => 'Dibaptis';

  @override
  String get tooltip_sidi => 'SIDI';

  @override
  String get tooltip_appLinked => 'Aplikasi Terhubung';

  @override
  String footer_copyright(int year) {
    return '© $year Palakat. Semua hak dilindungi.';
  }

  @override
  String get time_justNow => 'Baru saja';

  @override
  String time_minutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menit yang lalu',
      one: '1 menit yang lalu',
    );
    return '$_temp0';
  }

  @override
  String time_hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jam yang lalu',
      one: '1 jam yang lalu',
    );
    return '$_temp0';
  }

  @override
  String time_daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari yang lalu',
      one: '1 hari yang lalu',
    );
    return '$_temp0';
  }

  @override
  String stat_changeFromLastMonth(String change) {
    return '+$change dari bulan lalu';
  }

  @override
  String stat_changePercentFromLastMonth(String change) {
    return '+$change% dari bulan lalu';
  }

  @override
  String dashboard_recentActivitiesCount(int count) {
    return '$count aktivitas terbaru';
  }

  @override
  String get dashboard_recentActivitiesEmpty =>
      'Transaksi terbaru dan pembaruan anggota akan ditampilkan di sini.';
}
