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
  String lbl_selectAccount(String type) {
    return 'Pilih Akun $type';
  }

  @override
  String get lbl_searchAccountNumber => 'Cari nomor akun atau deskripsi...';

  @override
  String lbl_noResultsFor(String query) {
    return 'Tidak ada hasil untuk \"$query\"';
  }

  @override
  String get lbl_noAccountNumbers => 'Tidak ada nomor akun tersedia';

  @override
  String get lbl_churchNotAvailable => 'Informasi gereja tidak tersedia';

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
  String err_statusWithCode(int code, String label) {
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
  String auth_resendIn(int seconds) {
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
  String memberCount(int count) {
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
}
