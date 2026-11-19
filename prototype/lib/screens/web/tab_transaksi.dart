import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tablet.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'tab_beranda_kit.dart';

/// Tablet · Transaksi (spec 13): WebTransaksi at 834 wide, no vacancy tweak.
/// State `{filter, pilih, buku}` as the board's logic class.
class TabTransaksiScreen extends StatefulWidget {
  const TabTransaksiScreen({super.key});

  @override
  State<TabTransaksiScreen> createState() => _TabTransaksiScreenState();
}

/// One transaction of the board's `data` list.
typedef _Baris = ({
  String st,
  String no,
  String tgl,
  String ur,
  String ak,
  int jm,
  String cat,
  List<(String, String, bool)> rinci,
  List<String> aksi,
  int? utama,
  String catatan,
});

/// The board's `TUJU`: action label → board (push). Other labels → WebKoreksi.
const _tuju = [
  (n: 'Verifikasi', ke: 'WebLihatDokumen'),
  (n: 'Lampirkan dokumen pendukung', ke: 'WebUnggah'),
  (n: 'Catat pengecualian', ke: 'WebDokumen'),
  (n: 'Koreksi dengan pembalikan', ke: 'WebKoreksi'),
  (n: 'Pilih Mata Anggaran', ke: 'WebCatat'),
  (n: 'Ubah', ke: 'WebCatat'),
  (n: 'Catat persetujuan', ke: 'WebPersetujuan'),
  (n: 'Batalkan', ke: 'WebDraf'),
  (n: 'Pindah tanggal', ke: 'WebDraf'),
];

const _filter = ['Semua', 'Draf', 'Dibukukan', 'Dibalik', 'Dibatalkan'];
const _bukukan = 'Periksa dan bukukan';

class _TabTransaksiScreenState extends State<TabTransaksiScreen> {
  String _filterAktif = 'Semua';
  int _pilih = 0;
  bool _buku = false;

  List<_Baris> get _data {
    final b = _buku;
    return [
      (
        st: b ? 'Dibukukan' : 'Draf',
        no: b ? 'BKU-2026-0147' : '',
        tgl: '16/11/2026',
        ur: 'Fotokopi warta jemaat',
        ak: 'Kas',
        jm: -150000,
        cat: b ? '' : 'Belum masuk saldo',
        rinci: [
          ('Diambil dari peruntukan', 'Umum Jemaat', false),
          ('Lingkup', 'Jemaat', false),
          (
            'Mata Anggaran',
            'Belanja 5.02.01.00 Alat tulis dan fotokopi',
            false,
          ),
          ('Persetujuan', 'Tidak diperlukan (aturan: transaksi rutin)', false),
          ('Dokumen pendukung', 'Diunggah, belum diverifikasi', false),
          if (b) ('Dibukukan pada', '16/11/2026 10.42', false),
        ],
        aksi: b
            ? [
                'Verifikasi',
                'Lampirkan dokumen pendukung',
                'Koreksi dengan pembalikan',
              ]
            : [_bukukan, 'Ubah', 'Pindah tanggal', 'Batalkan'],
        utama: 0,
        catatan: b
            ? 'Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata '
                  'Anggaran tidak dapat diubah lagi.'
            : 'Semua syarat terpenuhi. Pindah tanggal dan Batalkan memerlukan '
                  'alasan.',
      ),
      (
        st: 'Draf',
        no: '',
        tgl: '08/11/2026',
        ur: 'Honor pemusik',
        ak: 'Bank BNI ··4821',
        jm: -650000,
        cat: 'Belum masuk saldo · Mata Anggaran belum dipilih',
        rinci: [
          ('Diambil dari peruntukan', 'Umum Jemaat', false),
          ('Lingkup', 'Jemaat', false),
          ('Mata Anggaran', 'Mata Anggaran belum dipilih', true),
          ('Persetujuan', 'Persetujuan belum dicatat', true),
          ('Dokumen pendukung', 'Wajib, belum ada', true),
        ],
        aksi: [
          'Pilih Mata Anggaran',
          'Catat persetujuan',
          'Lampirkan dokumen pendukung',
          'Ubah',
          'Batalkan',
        ],
        utama: 0,
        catatan:
            'Tidak dapat dilakukan: Bukukan. Mata Anggaran belum dipilih dan '
            'persetujuan belum dicatat.',
      ),
      (
        st: 'Dibukukan',
        no: 'BKU-2026-0146',
        tgl: '15/11/2026',
        ur: 'Persembahan Ibadah Minggu',
        ak: 'Kas',
        jm: 3450000,
        cat: '',
        rinci: [
          ('Masuk ke peruntukan', 'Umum Jemaat', false),
          ('Lingkup', 'Jemaat', false),
          (
            'Mata Anggaran',
            'Pendapatan 1.3.53.07.00 Persembahan Ibadah Minggu',
            false,
          ),
          ('Versi Mata Anggaran', '2026.1', false),
          ('Dokumen pendukung', 'Terverifikasi (oleh Meiske L.)', false),
          ('Dibukukan pada', '15/11/2026 12.20', false),
        ],
        aksi: ['Lampirkan dokumen pendukung', 'Koreksi dengan pembalikan'],
        utama: null,
        catatan:
            'Koreksi hanya lewat pembalikan, selama November 2026 belum '
            'ditutup.',
      ),
      (
        st: 'Dibukukan',
        no: 'BKU-2026-0143',
        tgl: '11/11/2026',
        ur: 'Sewa sound system',
        ak: 'Kas',
        jm: -600000,
        cat: 'Dokumen pendukung wajib, belum ada',
        rinci: [
          ('Diambil dari peruntukan', 'Umum Jemaat', false),
          ('Lingkup', 'Panitia Natal', false),
          ('Mata Anggaran', 'Belanja 5.05.02.00 Sewa peralatan', false),
          ('Dokumen pendukung', 'Wajib, belum ada', true),
          ('Dibukukan pada', '11/11/2026 16.05', false),
        ],
        aksi: [
          'Lampirkan dokumen pendukung',
          'Catat pengecualian',
          'Koreksi dengan pembalikan',
        ],
        utama: 0,
        catatan:
            'Menjadi hambatan tutup buku sampai dokumen terverifikasi atau '
            'dikecualikan dengan alasan.',
      ),
      (
        st: 'Dibukukan',
        no: 'BKU-2026-0144',
        tgl: '12/11/2026',
        ur: 'Pembalikan BKU-2026-0139',
        ak: 'Kas',
        jm: 750000,
        cat: 'Pembalikan',
        rinci: [
          ('Pembalikan dari', 'No. Bukti BKU-2026-0139', false),
          ('Alasan', 'Mata Anggaran keliru', false),
          ('Dibukukan pada', '12/11/2026 09.31', false),
        ],
        aksi: ['Lihat transaksi asal'],
        utama: null,
        catatan: 'Pembalikan tidak dapat diubah atau dibalik.',
      ),
      (
        st: 'Dibalik',
        no: 'BKU-2026-0139',
        tgl: '09/11/2026',
        ur: 'Konsumsi rapat majelis',
        ak: 'Kas',
        jm: -750000,
        cat: 'Dibalik oleh No. Bukti BKU-2026-0144',
        rinci: [
          ('Dibalik oleh', 'No. Bukti BKU-2026-0144', false),
          ('Transaksi koreksi', 'No. Bukti BKU-2026-0145', false),
          (
            'Mata Anggaran',
            'Belanja 5.02.01.00 Alat tulis dan fotokopi',
            false,
          ),
          ('Dibukukan pada', '09/11/2026 14.12', false),
        ],
        aksi: ['Lihat pembalikan', 'Lihat transaksi koreksi'],
        utama: null,
        catatan: 'Transaksi asal tetap tampil di daftar dan laporan.',
      ),
      (
        st: 'Dibatalkan',
        no: '',
        tgl: '05/11/2026',
        ur: 'Pembelian bunga altar',
        ak: 'Kas',
        jm: -200000,
        cat: 'Tidak pernah dibukukan',
        rinci: [
          ('Alasan', 'Tercatat dua kali', false),
          ('Dibatalkan oleh', 'Meiske L.', false),
          ('Dibatalkan pada', '06/11/2026 08.02', false),
        ],
        aksi: [],
        utama: null,
        catatan:
            'Hanya dapat dilihat. Transaksi ini tidak pernah punya No. Bukti.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final data = _data;
    return HalamanTablet(
      nav: const NavSamping(
        item: navKeuangan,
        aktif: 1,
        pengguna: PenggunaKeuangan(ikutJabatanKosong: false),
      ),
      isi: [
        KepalaTab(
          'Transaksi',
          ujung: [
            const Tautan(ke: 'WebPilihBulan', radius: 999, child: PilBulan()),
            const Tombol(
              'Impor',
              onPressed: null,
              ke: 'WebImpor',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.kecil,
              lebarPenuh: false,
            ),
            const Tombol(
              '+ Catat transaksi',
              onPressed: null,
              ke: 'WebCatat',
              ukuran: UkuranTombol.kecil,
              paddingH: 18,
              lebarPenuh: false,
            ),
          ],
        ),
        const DeretTautan(
          web: true,
          anak: [
            TautanTab('Daftar Bukti Kas', ke: 'WebBukti'),
            TautanTab('Koreksi dengan pembalikan', ke: 'WebKoreksi'),
            TautanTab('Draf di bulan yang sudah ditutup', ke: 'WebDraf'),
            TautanTab('Pengembalian', ke: 'WebPengembalian'),
            TautanTab('Cari', ke: 'WebCari'),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in _filter)
              ChipSatu(
                teks: f,
                dipilih: _filterAktif == f,
                padding: 16,
                onTap: () => setState(() => _filterAktif = f),
              ),
          ],
        ),
        BarisLentur(
          anak: [
            Lentur(dasar: 520, tumbuh: 999, child: _tabel(c, data)),
            Lentur(dasar: 360, child: _panel(c, data[_pilih])),
          ],
        ),
      ],
    );
  }

  Widget _tabel(PalakatWarna c, List<_Baris> data) {
    Widget kisi(List<Widget> sel) => Row(
      children: [
        SizedBox(width: 104, child: sel[0]),
        const SizedBox(width: 12),
        SizedBox(width: 88, child: sel[1]),
        const SizedBox(width: 12),
        Expanded(child: sel[2]),
        const SizedBox(width: 12),
        SizedBox(width: 124, child: sel[3]),
      ],
    );

    final baris = <Widget>[];
    for (var i = 0; i < data.length; i++) {
      final r = data[i];
      if (_filterAktif != 'Semua' && r.st != _filterAktif) continue;
      final on = _pilih == i;
      final draf = r.st == 'Draf', batal = r.st == 'Dibatalkan';
      baris.add(
        Tekan(
          onTap: () => setState(() => _pilih = i),
          dipilih: on,
          child: Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: on ? c.lautLembut : (draf ? c.kertas : c.permukaan),
              border: Border(top: BorderSide(color: c.garis)),
            ),
            // box-shadow: inset 3px 0 0 laut, under the top rule.
            foregroundDecoration: on
                ? BoxDecoration(
                    border: Border(left: BorderSide(color: c.laut, width: 3)),
                  )
                : null,
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 14),
              child: kisi([
                Align(
                  alignment: Alignment.centerLeft,
                  child: _lencana(c, r.st),
                ),
                Text(r.tgl, style: TextStyle(color: c.tinta2)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.ur,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: r.no.isEmpty ? '—' : r.no,
                            style: const TextStyle(
                              fontFamily: PalakatText.mono,
                            ),
                          ),
                          TextSpan(text: ' · ${r.ak}'),
                        ],
                      ),
                      style: TextStyle(fontSize: 13, color: c.tinta2),
                    ),
                    if (r.cat.isNotEmpty)
                      Text(
                        r.cat,
                        style: TextStyle(fontSize: 13, color: c.tinta3),
                      ),
                  ],
                ),
                Text(
                  rp(r.jm),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontWeight: FontWeight.w500,
                    color: draf || batal ? c.tinta3 : c.tinta,
                    decoration: batal ? TextDecoration.lineThrough : null,
                    decorationColor: c.tinta3,
                  ),
                ),
              ]),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: LayoutBuilder(
          builder: (context, k) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: k.maxWidth < 470 ? 470 : k.maxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: DefaultTextStyle.merge(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: c.tinta2,
                      ),
                      child: kisi(const [
                        Text('Status'),
                        Text('Tanggal'),
                        Text('Uraian · No. Bukti · Kas/Bank'),
                        Text('Jumlah (Rp)', textAlign: TextAlign.right),
                      ]),
                    ),
                  ),
                  ...baris,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panel(PalakatWarna c, _Baris p) {
    final draf = p.st == 'Draf';
    final baruBuku = _pilih == 0 && _buku;
    final bk = [
      for (final r in p.rinci)
        if (r.$1 == 'Dibukukan pada') r.$2,
    ].firstOrNull;
    final riwayat = draf
        ? ['${p.tgl} · Draf dicatat oleh Meiske L.']
        : [
            '${bk != null ? '$bk · ' : ''}Dibukukan oleh Meiske L.',
            '${p.tgl} · Draf dicatat oleh Meiske L.',
          ];
    const mono14 = TextStyle(fontFamily: PalakatText.mono, fontSize: 14);
    const h2 = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

    final kartu = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: ShapeDecoration(
              color: draf ? null : c.permukaan,
              shape: draf
                  ? GarisBorder.putus(c.putus, radius: 16)
                  : GarisBorder.penuh(c.tinta, radius: 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: _lencana(
                        c,
                        p.st,
                        draf ? 'Draf · belum masuk saldo' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: baruBuku
                          ? Gerak(
                              Kerangka.cap,
                              lama: const Duration(milliseconds: 550),
                              tunda: const Duration(milliseconds: 350),
                              kurva: PalakatMotion.keluar,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(color: c.laut, width: 2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'No. Bukti ${p.no}',
                                  style: mono14.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: c.laut,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              p.no.isEmpty ? 'Belum ada No. Bukti' : p.no,
                              textAlign: TextAlign.right,
                              style: mono14.copyWith(color: c.tinta2),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rp(p.jm),
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                    color: draf || p.st == 'Dibatalkan' ? c.tinta2 : c.tinta,
                  ),
                ),
                const SizedBox(height: 6),
                Text(p.ur, style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  '${p.ak} · tanggal transaksi ${p.tgl}',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
          if (baruBuku) const SapuTinta(),
        ],
      ),
    );

    final rinci = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (var i = 0; i < p.rinci.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: i == 0
                  ? null
                  : BoxDecoration(
                      border: Border(top: BorderSide(color: c.garis)),
                    ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Text(
                      p.rinci[i].$1,
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    flex: 3,
                    child: Text(
                      p.rinci[i].$2,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: p.rinci[i].$3 ? c.bata : c.tinta,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    Widget aksi(int i) {
      final n = p.aksi[i];
      final utama = i == p.utama;
      final jenis = utama ? JenisTombol.utama : JenisTombol.kedua;
      if (n == _bukukan) {
        return Tombol(
          n,
          onPressed: () => setState(() => _buku = true),
          jenis: jenis,
          ukuran: UkuranTombol.kecil,
          ukuranTeks: 14,
          lebarPenuh: false,
        );
      }
      return Tombol(
        n,
        onPressed: null,
        ke: _tuju.where((t) => t.n == n).firstOrNull?.ke ?? 'WebKoreksi',
        jenis: jenis,
        ukuran: UkuranTombol.kecil,
        ukuranTeks: 14,
        lebarPenuh: false,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        kartu,
        const SizedBox(height: 14),
        rinci,
        const SizedBox(height: 14),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Yang dapat dilakukan', style: h2),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (var i = 0; i < p.aksi.length; i++) aksi(i)],
        ),
        const SizedBox(height: 8),
        Text(p.catatan, style: TextStyle(fontSize: 13, color: c.tinta3)),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Riwayat', style: h2),
        ),
        for (final t in riwayat) ...[
          const SizedBox(height: 4),
          Text(t, style: TextStyle(fontSize: 14, color: c.tinta2)),
        ],
      ],
    );
  }
}

/// The board's `B` badge map (13/700, padding 3 9, radius 6). Dibatalkan is a
/// `kertas` field with a `kertas` edge here, not LencanaStatus's `garis`
/// (spec note); the text wraps, as the panel's flex item does when narrow.
Widget _lencana(PalakatWarna c, String st, [String? label]) {
  final (GarisBorder garis, Color? isi, Color teks) = switch (st) {
    'Draf' => (GarisBorder.putus(c.putus, radius: 6), null, c.tinta2),
    'Dibukukan' => (
      GarisBorder.penuh(c.tinta, radius: 6),
      c.tinta,
      c.permukaan,
    ),
    'Dibalik' => (
      GarisBorder.penuh(c.tinta3, radius: 6),
      c.permukaan,
      c.tinta2,
    ),
    _ => (GarisBorder.penuh(c.kertas, radius: 6), c.kertas, c.tinta2),
  };
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: ShapeDecoration(color: isi, shape: garis),
    child: Text(
      label ?? st,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: teks),
    ),
  );
}
