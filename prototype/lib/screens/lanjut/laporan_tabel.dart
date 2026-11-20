// The report pack forms as tables (Laporan.dc.html `F` and `LAP`), built
// from report datasets (README 7.1 rule 5): the phone's stacked cards, the
// web paper, the A4 views and the Excel sheets all print these.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/keuangan/laporan.dart';

/// One printed table: subtitle, columns, right-aligned column indices, rows
/// (a trailing `1` marks a bold total row) and the footnote.
typedef LaporanTabel = ({
  String sub,
  List<String> cols,
  List<int> kanan,
  List<List<Object>> rows,
  String kaki,
});

const laporanDaftar = [
  ('F01', 'Laporan Perbendaharaan Bulanan'),
  ('F02', 'Buku Kas Umum'),
  ('F03', 'Buku Kas Pembantu'),
  ('F04', 'Mata Anggaran Pendapatan'),
  ('F05', 'Realisasi Pendapatan Menurut Mata Anggaran'),
  ('F06', 'Mata Anggaran Belanja'),
  ('F07', 'Realisasi Belanja Menurut Mata Anggaran'),
  ('F08', 'Rekap Penerimaan'),
  ('F09', 'Rekap Pengeluaran'),
  ('F10', 'Posisi Kas & Bank'),
  ('F11', 'Rekonsiliasi'),
  ('F12', 'Daftar Bukti Kas'),
  ('F13', 'Sentralisasi / Penyaluran'),
  ('F14', 'Lampiran Laporan Bulanan'),
];

/// The F14 attachments, in order.
const lampiranF14 = [
  ('Uang Muka', 'kasus'),
  ('Rincian Pertanggungjawaban Uang Muka', 'transaksi'),
  ('Penghitungan Persembahan', 'ibadah'),
  ('Penggantian Biaya', 'transaksi'),
  ('Pengecualian Dokumen Pendukung', 'dokumen'),
  ('Pembalikan dan Koreksi', 'rangkaian'),
  ('Saldo Awal Pencatatan', 'transaksi'),
  ('Hasil Pengecekan Otomatis', 'syarat terpenuhi'),
];

ReportForm formLaporan(String id) =>
    ReportForm.values.firstWhere((f) => f.name == id.toLowerCase());

String _rp(Object? n) => n == null ? '' : rp(n as int);

/// The chain tags of an F02/F03 row (A4F02a, A4F02b, WebPaketLaporan):
/// "Dibalik oleh BKU-…" on the original, "Koreksi dari BKU-…" on the
/// correction.
List<String> tandaRantai(Map<String, Object?> r) => [
  if (r['reversedBy'] case final String v) 'Dibalik oleh $v',
  if (r['correctionOf'] case final String v) 'Koreksi dari $v',
];

/// The Uraian cell of an F02/F03 row with its chain tags.
String uraianBku(Map<String, Object?> r) =>
    ['${r['description']}', ...tandaRantai(r)].join(' · ');
String _neg(Object? n) => n == null || n == 0 ? 'Rp0' : rp(-(n as int));

const _efek = {
  'owned': 'Milik sendiri',
  'custody': 'Titipan',
  'both': 'Milik sendiri atau titipan',
};

const _bukti = {
  'notRequired': 'Tidak diperlukan',
  'requiredMissing': 'Belum ada',
  'uploaded': 'Diunggah, belum diverifikasi',
  'verified': 'Terverifikasi',
  'exceptionAccepted': 'Dikecualikan',
};

const _setuju = {
  'notRequired': 'Tidak diperlukan',
  'recorded': 'Sudah dicatat',
  'missing': 'Belum dicatat',
};

const _status = {
  'open': 'Sedang dikerjakan',
  'reviewed': 'Sudah diperiksa',
  'confirmed': 'Sudah dipastikan',
};

/// [form] of [l] as a table.
LaporanTabel tabelLaporan(
  LaporanBulan l,
  ReportForm form, {
  ReportDataset? data,
}) {
  final d = data ?? l.data(form);
  final p = l.periode;
  final bulan = namaBulan(p);
  final t = d.totals;
  switch (form) {
    case ReportForm.f01:
      return (
        sub: 'Ringkasan bulan',
        cols: ['Baris', bulan],
        kanan: [1],
        rows: [
          ['Saldo awal Kas/Bank', _rp(t['opening']), 1],
          ['Pendapatan ekonomi', _rp(t['income'])],
          ['Belanja ekonomi', _neg(t['expense'])],
          if (t['expenseFromAdvance'] != 0)
            [
              'Belanja dari pertanggungjawaban uang muka',
              _neg(t['expenseFromAdvance']),
            ],
          ['Dana Transit masuk', _rp(t['transitIn'])],
          ['Dana Transit keluar', _neg(t['transitOut'])],
          ['Uang Muka diberikan', _neg(t['advanceIssued'])],
          ['Pengembalian sisa uang muka', _rp(t['advanceReturned'])],
          ['Saldo akhir Kas/Bank', _rp(t['closing']), 1],
        ],
        kaki: l.format?.acceptedAt == null
            ? 'Format laporan bawaan aplikasi.'
            : 'Nama baris uang muka mengikuti format laporan yang disetujui '
                  '${tgl(l.format!.acceptedAt!)}.',
      );
    case ReportForm.f02:
      return (
        sub: 'Semua Kas/Bank',
        cols: [
          'Tanggal',
          'No. Bukti',
          'No. MA',
          'Uraian',
          'Kas/Bank',
          'Penerimaan',
          'Pengeluaran',
          'Saldo semua Kas/Bank',
        ],
        kanan: [5, 6, 7],
        rows: [
          ['', '', '', 'Saldo awal Kas/Bank', '', '', '', _rp(t['opening']), 1],
          for (final r in d.rows)
            [
              '${r['date']}',
              '${r['voucher'] ?? ''}',
              (r['codes'] as List).join('; '),
              uraianBku(r),
              (r['accountIds'] as List)
                  .map((a) => l.akun(a as String))
                  .join('; '),
              r['in'] == 0 ? '' : _rp(r['in']),
              r['out'] == 0 ? '' : _rp(r['out']),
              _rp(r['balance']),
            ],
          [
            '',
            '',
            '',
            'Saldo akhir Kas/Bank',
            '',
            _rp(t['in']),
            _rp(t['out']),
            _rp(t['closing']),
            1,
          ],
        ],
        kaki:
            '${d.rows.length} baris. Nomor yang tidak tampil bukan arus '
            'kas/bank $bulan; lihat F12.',
      );
    case ReportForm.f03:
      final akun = <String>[];
      for (final r in d.rows) {
        final a = r['accountId'] as String;
        if (!akun.contains(a)) akun.add(a);
      }
      for (final k in t.keys) {
        final a = k.split(':').last;
        if (k.startsWith('opening:') && !akun.contains(a)) akun.add(a);
      }
      return (
        sub: 'Buku per Kas/Bank',
        cols: [
          'Tanggal',
          'No. Bukti',
          'Uraian',
          'Penerimaan',
          'Pengeluaran',
          'Saldo',
        ],
        kanan: [3, 4, 5],
        rows: [
          for (final a in akun) ...[
            [
              '',
              '',
              'Saldo awal ${l.akun(a)}',
              '',
              '',
              _rp(t['opening:$a'] ?? 0),
              1,
            ],
            for (final r in d.rows)
              if (r['accountId'] == a)
                [
                  '${r['date']}',
                  '${r['voucher'] ?? ''}',
                  uraianBku(r),
                  r['in'] == 0 ? '' : _rp(r['in']),
                  r['out'] == 0 ? '' : _rp(r['out']),
                  _rp(r['balance']),
                ],
            [
              '',
              '',
              'Saldo akhir ${l.akun(a)}',
              '',
              '',
              _rp(t['closing:$a'] ?? 0),
              1,
            ],
          ],
        ],
        kaki:
            'Buku pembantu juga dibuat per peruntukan, per Lingkup, per Uang '
            'Muka dan per Titipan untuk.',
      );
    case ReportForm.f04 || ReportForm.f06:
      return (
        sub: 'Versi Mata Anggaran ${t['versionCode'] ?? ''}',
        cols: ['No. MA', 'Nama Mata Anggaran', 'Jenis baris', 'Boleh untuk'],
        kanan: [],
        rows: [
          for (final r in d.rows)
            [
              '${r['code']}',
              '${r['name']}',
              r['postable'] == true
                  ? 'Dapat dibukukan'
                  : 'Judul kelompok, tidak dapat dibukukan',
              r['postable'] == true ? _efek[r['allowedEffect']] ?? '' : '',
              if (r['postable'] != true) 1,
            ],
        ],
        kaki: '${d.rows.length} baris, sesuai urutan sumber.',
      );
    case ReportForm.f05 || ReportForm.f07:
      return (
        sub: form == ReportForm.f05
            ? 'Pendapatan menurut Mata Anggaran'
            : 'Belanja menurut Mata Anggaran',
        cols: ['No. MA', 'Nama Mata Anggaran', bulan],
        kanan: [2],
        rows: [
          for (final r in d.rows)
            [
              '${r['code']}',
              '${r['name']}',
              _rp(r['amount']),
              if (r['postable'] != true) 1,
            ],
          ['', 'Jumlah', _rp(t['total']), 1],
        ],
        kaki:
            'Baris tanpa transaksi tetap dicetak sebagai Rp0. Tidak ada kolom '
            'anggaran, selisih atau persentase.',
      );
    case ReportForm.f08 || ReportForm.f09:
      final masuk = form == ReportForm.f08;
      final kolom = masuk
          ? [
              ('income', 'Pendapatan'),
              ('transitIn', 'Titipan masuk'),
              ('advanceReturn', 'Pengembalian sisa uang muka'),
              ('transferIn', 'Pindah masuk'),
              ('other', 'Lainnya'),
              ('total', 'Jumlah penerimaan'),
            ]
          : [
              ('expense', 'Belanja'),
              ('transitOut', 'Titipan disalurkan'),
              ('advanceIssued', 'Uang Muka diberikan'),
              ('transferOut', 'Pindah keluar'),
              ('other', 'Lainnya'),
              ('total', 'Jumlah pengeluaran'),
            ];
      final pakai = [
        for (final k in kolom)
          if (k.$1 != 'other' || t['other'] != 0) k,
      ];
      return (
        sub: masuk
            ? 'Penerimaan buku per Kas/Bank'
            : 'Pengeluaran buku per Kas/Bank',
        cols: ['Kas/Bank', for (final k in pakai) k.$2],
        kanan: [for (var i = 1; i <= pakai.length; i++) i],
        rows: [
          for (final r in d.rows)
            [
              l.akun(r['accountId'] as String?),
              for (final k in pakai) _rp(r[k.$1]),
            ],
          ['Jumlah', for (final k in pakai) _rp(t[k.$1]), 1],
        ],
        kaki: masuk
            ? 'Penerimaan bukan Pendapatan: kolom Pindah masuk, Titipan masuk '
                  'dan Pengembalian sisa uang muka tidak pernah dijumlahkan ke '
                  'Pendapatan.'
            : 'Belanja dari pertanggungjawaban uang muka dicetak di baris '
                  'tersendiri dan tidak mengurangi Kas/Bank lagi.',
      );
    case ReportForm.f10:
      return (
        sub: 'Per ${p.end}',
        cols: [
          'Kas/Bank',
          'Saldo buku',
          'Hasil hitung kas',
          'Saldo rekening koran',
          'Selisih belum dijelaskan',
        ],
        kanan: [1, 2, 3, 4],
        rows: [
          for (final r in d.rows)
            [
              l.akun(r['accountId'] as String?),
              _rp(r['book']),
              _rp(r['cashCount']),
              _rp(r['statement']),
              _rp(r['difference']),
            ],
        ],
        kaki:
            'Hasil hitung kas dan saldo rekening koran berada di kolom '
            'terpisah dan tidak dijumlahkan. Item dalam perjalanan dijelaskan '
            'di F11.',
      );
    case ReportForm.f11:
      List<Object> baris(
        String judul,
        String Function(Map<String, Object?>) f, [
        bool tebal = false,
      ]) => [judul, for (final r in d.rows) f(r), if (tebal) 1];
      return (
        sub: 'Per Kas/Bank',
        cols: [
          'Baris',
          for (final r in d.rows) l.akun(r['accountId'] as String?),
        ],
        kanan: [for (var i = 1; i <= d.rows.length; i++) i],
        rows: [
          baris(
            'Hasil hitung kas / Saldo rekening koran',
            (r) => _rp(r['observed']),
          ),
          baris('Setoran dalam perjalanan', (r) => _rp(r['depositsInTransit'])),
          baris(
            'Pembayaran dalam perjalanan',
            (r) => _rp(r['paymentsInTransit']),
          ),
          baris('Saldo pembanding', (r) => _rp(r['comparison']), true),
          baris('Saldo buku', (r) => _rp(r['book']), true),
          baris('Selisih belum dijelaskan', (r) => _rp(r['difference']), true),
          baris(
            'Mutasi bank cocok / belum cocok',
            (r) => r['matched'] == 0 && r['unmatched'] == 0
                ? ''
                : '${r['matched']} / ${r['unmatched']}',
          ),
          baris('Status', (r) => _status[r['status']] ?? 'Belum dimulai'),
        ],
        kaki:
            'Item dalam perjalanan dibawa ke ${bulanSesudahnya(p)} dan dicetak '
            'lagi di laporan bulan itu sampai cocok.',
      );
    case ReportForm.f12:
      return (
        sub: 'No. Bukti $bulan',
        cols: [
          'No. Bukti',
          'Tanggal',
          'Uraian',
          'Jumlah (Rp)',
          'Persetujuan',
          'Dokumen pendukung saat tutup buku',
        ],
        kanan: [3],
        rows: [
          for (final r in d.rows)
            switch (r['kind']) {
              'posted' => [
                '${r['voucher']}',
                '${r['date']}',
                '${r['description']}',
                _rp(r['amount']),
                _setuju[r['approval']] ?? '',
                _bukti[r['evidence']] ?? '',
              ],
              'unfinished' => [
                '${r['voucher']}',
                '${r['date']}',
                'Nomor diberikan, pembukuannya tidak selesai'
                    '${r['note'] == null ? '' : ' · ${r['note']}'}',
                '',
                '',
                '',
              ],
              _ => [
                'Draf',
                '${r['date']}',
                '${r['description']}',
                _rp(r['amount']),
                '',
                '',
              ],
            },
        ],
        kaki:
            '${d.rows.length} baris. Kolom dokumen pendukung mencetak status '
            'saat tutup buku; dokumen susulan tidak mengubah halaman ini.',
      );
    case ReportForm.f13:
      return (
        sub: 'Titipan per pihak, lalu Sentralisasi dari uang milik sendiri',
        cols: [
          'Titipan untuk',
          'Sisa awal',
          'Terkumpul',
          'Disalurkan',
          'Sisa belum disalurkan',
        ],
        kanan: [1, 2, 3, 4],
        rows: [
          for (final r in d.rows)
            [
              '${r['title']}',
              _rp(r['opening']),
              _rp(r['collected']),
              _rp(r['remitted']),
              _rp(r['closing']),
            ],
          [
            'Jumlah titipan',
            _rp(t['opening'] ?? 0),
            _rp(t['collected'] ?? 0),
            _rp(t['remitted'] ?? 0),
            _rp(t['closing'] ?? 0),
            1,
          ],
          [
            'Sentralisasi dari uang milik sendiri (Belanja, bukan titipan)',
            '',
            '',
            _rp(t['ownCentralization'] ?? 0),
            '',
          ],
        ],
        kaki:
            'Judul “Sentralisasi / Penyaluran” menggantikan judul sumber '
            '“Sentralisasi / Settlement”.',
      );
    case ReportForm.f14:
      return (
        sub: 'Delapan lampiran',
        cols: ['', 'Lampiran', 'Isi pada $bulan'],
        kanan: [],
        rows: [
          for (final r in d.rows)
            () {
              final n = r['n'] as int, jml = r['count'] as int;
              final (judul, satuan) = lampiranF14[n - 1];
              return <Object>['$n', judul, jml == 0 ? 'Nihil' : '$jml $satuan'];
            }(),
        ],
        kaki:
            'Lampiran tanpa isi dicetak sebagai “Nihil”, bukan halaman kosong.',
      );
  }
}

const kolomMono = {'No. Bukti', 'No. MA', 'Tanggal'};

/// Grid widths for [t]: the widest text column flexes (null), figures get
/// 120 px, codes and dates their board widths.
List<double?> lebarKolom(LaporanTabel t) {
  final lebar = [for (final _ in t.cols) 0];
  for (final r in t.rows) {
    for (var i = 0; i < t.cols.length && i < r.length; i++) {
      if (r[i] is String && (r[i] as String).length > lebar[i]) {
        lebar[i] = (r[i] as String).length;
      }
    }
  }
  var lentur = -1;
  for (var i = 0; i < t.cols.length; i++) {
    if (!t.kanan.contains(i) &&
        !kolomMono.contains(t.cols[i]) &&
        (lentur < 0 || lebar[i] > lebar[lentur])) {
      lentur = i;
    }
  }
  return [
    for (var i = 0; i < t.cols.length; i++)
      i == lentur
          ? null
          : t.kanan.contains(i)
          ? 120
          : t.cols[i] == 'No. Bukti'
          ? 118
          : t.cols[i] == 'Tanggal'
          ? 84
          : 104,
  ];
}

/// [r]'s cells, without the bold marker.
List<String> selBaris(List<Object> r) => [
  for (final v in r)
    if (v is String) v,
];

/// '{Bulan} {tahun}' after [p].
String bulanSesudahnya(Period p) =>
    bulanTahun(p.month == 12 ? p.year + 1 : p.year, p.month % 12 + 1);

/// The report of the route's `:periode` (`laporanResmi`, `laporanTerbatas`),
/// else `laporanBulanProvider`'s.
LaporanBulan? laporanRute(BuildContext context, WidgetRef ref) {
  final id = GoRouterState.of(context).pathParameters['periode'];
  return (id == null ? null : ref.watch(laporanPeriodeProvider(id))) ??
      ref.watch(laporanBulanProvider);
}

/// '{Bulan} {tahun}' of [l].
String namaBulanLaporan(LaporanBulan l) => namaBulan(l.periode);

/// The TERBATAS sheets of [r] (F02, F03, F05, F07, F12): only the Fund's
/// rows; Mata Anggaran rows without an amount and allocated numbers are not
/// printed.
List<(String, String, LaporanTabel)> lembarTerbatas(
  LaporanBulan l,
  RestrictedReport r,
) => [
  for (final (kode, nama) in laporanDaftar)
    if (r.datasets[formLaporan(kode)] case final d?)
      (
        kode,
        nama,
        tabelLaporan(
          l,
          d.form,
          data: switch (d.form) {
            ReportForm.f05 || ReportForm.f07 => ReportDataset(
              form: d.form,
              rows: [
                for (final x in d.rows)
                  if (x['postable'] == true && x['amount'] != 0) x,
              ],
              totals: d.totals,
            ),
            ReportForm.f12 => ReportDataset(
              form: d.form,
              rows: [
                for (final x in d.rows)
                  if (x['kind'] == 'posted') x,
              ],
            ),
            _ => d,
          },
        ),
      ),
];
