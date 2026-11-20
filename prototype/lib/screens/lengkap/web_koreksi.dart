import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/koreksi.dart';
import '../../providers/keuangan/persetujuan.dart';
import '../../widgets/kartu_persetujuan.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/rangkaian_koreksi.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

const _mono = TextStyle(fontFamily: PalakatText.mono);

/// Web · Koreksi dengan pembalikan (docs/build/screens/02-awal.md): the
/// original (route `:id`) on the left, the reversal form, its result or the
/// closed-month refusal on the right.
class WebKoreksiScreen extends ConsumerStatefulWidget {
  const WebKoreksiScreen({super.key});

  @override
  ConsumerState<WebKoreksiScreen> createState() => _WebKoreksiScreenState();
}

class _WebKoreksiScreenState extends ConsumerState<WebKoreksiScreen> {
  // Board state { alasan, mode, ma }; the records come from koreksiProvider.
  final _alasan = TextEditingController();
  bool _koreksi = true; // mode 'koreksi' | 'balik'
  String? _ma;
  Refusal? _pesan;
  late DataKoreksi _d;

  bool get _jadi => _d.dibalik;
  String? get _maPilih =>
      _ma ??
      (_d.pilihanMa.length > 1
          ? _d.pilihanMa[1].$1
          : _d.pilihanMa.firstOrNull?.$1);

  bool get _ok => _d.menunggu || IsianAlasan.terisi(_alasan.text);

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  Future<void> _bukukan() async {
    if (!_ok) return;
    final r = _d.menunggu
        ? await bukukanRangkaian(ref, _d.asal.id)
        : await bukukanKoreksi(
            ref,
            _d,
            alasan: _alasan.text,
            ma: _koreksi ? _maPilih : null,
          );
    if (mounted) setState(() => _pesan = r);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final d = ref.watch(
      koreksiProvider(GoRouterState.of(context).pathParameters['id'] ?? ''),
    );
    if (d == null) {
      return Material(
        type: MaterialType.transparency,
        child: HalamanWeb(
          layarKeuangan: true,
          nav: const NavSamping(item: navKeuangan, aktif: 1),
          isi: [
            Text(
              'Transaksi tidak ditemukan.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ),
      );
    }
    _d = d;
    final tutup = d.tutup;
    final bulan = d.bulan;

    final judul = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TautanSebaris(
          ke: Layar.transaksi,
          // The 14 px <a> sits in a 15 px line: the body's strut sets its height.
          tinggiBaris: 15 * 1.45,
          child: TautanTeks('Transaksi', ukuran: 14),
        ),
        const SizedBox(height: 2),
        Semantics(
          header: true,
          child: Text(
            d.asal.voucher ?? '',
            style: _mono.copyWith(fontSize: 26, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    final kiri = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _kartuAsal(c, tutup),
        if (tutup) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: c.tinta,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$bulan sudah ditutup.',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        ' Transaksi ini final dan laporan resminya dibekukan.',
                  ),
                ],
              ),
              style: TextStyle(fontSize: 14, color: c.permukaan),
            ),
          ),
        ],
        const SizedBox(height: 14),
        if (d.asal.approvalMode == ApprovalMode.external) ...[
          _kartuPersetujuan(d.asal),
          const SizedBox(height: 14),
        ],
        if (d.dokumen case final dok?)
          Kartu(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dokumen pendukung',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
                Text(
                  dok.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );

    final kanan = tutup
        ? _ditutup(c, bulan)
        : _jadi
        ? _hasil(c)
        : _form(c);

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          judul,
          BarisLentur(
            jarak: 28,
            anak: [
              Lentur(dasar: 400, child: kiri),
              Lentur(dasar: 480, tumbuh: 999, child: kanan),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kartuAsal(PalakatWarna c, bool tutup) => Container(
    padding: const EdgeInsets.all(18),
    decoration: ShapeDecoration(
      color: c.permukaan,
      shape: GarisBorder.penuh(_jadi ? c.tinta3 : c.tinta, radius: 14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // space-between; when it does not fit, both shrink as CSS flex items
        // do, in proportion to their content width (badge ≈300 or ≈90,
        // number ≈101).
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: _jadi ? 300 : 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: ShapeDecoration(
                  color: _jadi ? c.permukaan : c.tinta,
                  shape: GarisBorder.penuh(
                    _jadi ? c.tinta3 : c.tinta,
                    radius: 6,
                  ),
                ),
                child: Text(
                  // U+200B: the browser may break after a hyphen; Flutter does not.
                  _jadi
                      ? 'Dibalik oleh No. Bukti '
                            '${_putus(_d.pembalikan?.voucher ?? '')}'
                      : 'Dibukukan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _jadi ? c.tinta2 : c.permukaan,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Flexible(
              flex: 101,
              child: Text(
                _putus(_d.asal.voucher ?? ''),
                semanticsLabel: _d.asal.voucher,
                style: _mono.copyWith(fontSize: 13, color: c.tinta2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // gap 4 + margin-top 4
        Text(
          rp(_d.rincian.baris.jumlah),
          style: _mono.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w500,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _d.asal.description,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(_d.keterangan, style: TextStyle(fontSize: 13, color: c.tinta3)),
        const SizedBox(height: 4),
        Text(_d.maAsal, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    ),
  );

  /// The external approval of [t], recorded on Persetujuan.
  Widget _kartuPersetujuan(Transaction t) {
    final r = ref.watch(persetujuanProvider(t.id))?.berlaku;
    void buka() => context.dorongKe(Layar.persetujuan, param: {'id': t.id});
    return r == null
        ? KartuPersetujuan.belum(
            kepala: 'Persetujuan di luar aplikasi',
            onCatat: buka,
          )
        : KartuPersetujuan.sudah(
            kepala: 'Persetujuan di luar aplikasi',
            pemberi: r.nama,
            jabatan: r.jabatan,
            tanggal: r.tanggal,
            cara: r.cara,
            dicatatOleh: r.oleh,
            dicatatPada: r.pada,
          );
  }

  Widget _ditutup(PalakatWarna c, String bulan) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Penolakan(
        tindakan: 'koreksi dengan pembalikan',
        sebab: '$bulan sudah ditutup. Yang masih dapat Anda lakukan:',
        jalan: const [],
      ),
      const SizedBox(height: 10),
      const Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          Tombol(
            'Catat kejadian',
            onPressed: null,
            ke: Layar.kejadian,
            jenis: JenisTombol.tinta,
            ukuran: UkuranTombol.ringkas,
            lebarPenuh: false,
          ),
          Tombol(
            'Lampirkan dokumen pendukung',
            onPressed: null,
            ke: Layar.dokumen,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.ringkas,
            lebarPenuh: false,
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        'Dokumen susulan hanya mengubah Status sekarang, bukan laporan resmi.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ],
  );

  Widget _form(PalakatWarna c) {
    final ok = _ok;
    final label = _d.menunggu
        ? 'Periksa dan bukukan'
        : _koreksi
        ? 'Bukukan pembalikan dan koreksi'
        : 'Bukukan pembalikan';
    final teks2 = TextStyle(fontSize: 14, color: c.tinta2);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Koreksi dengan pembalikan',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Transaksi asal tetap tercatat. Sebuah pembalikan meniadakan '
          'pengaruhnya, lalu transaksi koreksi mencatat yang benar.',
          style: teks2,
        ),
        const SizedBox(height: 16),
        IsianAlasan(
          controller: _alasan,
          onChanged: (_) => setState(() {}),
          contoh: 'Contoh: Mata Anggaran keliru',
        ),
        const SizedBox(height: 20), // gap 16 + the inline textarea's 4 px

        ChipPilihan<bool>(
          label: 'Yang dibuat',
          pilihan: const [
            (nilai: true, teks: 'Pembalikan dan transaksi koreksi'),
            (nilai: false, teks: 'Pembalikan saja'),
          ],
          terpilih: _koreksi,
          onPilih: (v) => setState(() => _koreksi = v),
        ),
        if (_koreksi) ...[
          const SizedBox(height: 16),
          Text('Mata Anggaran pada transaksi koreksi', style: teks2),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final (i, m) in _d.pilihanMa.indexed)
                  _ChipMA(
                    teks:
                        '${_d.maAsal.split(' ').first} ${m.$1} ${m.$2}'
                        '${i == 0 ? ' · asal' : ''}',
                    dipilih: _maPilih == m.$1,
                    onTap: () => setState(() => _ma = m.$1),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Yang ikut terdampak',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              for (final t in [
                'Bulan terdampak: ${_d.bulan} · Belum ditutup',
                'Persetujuan pada transaksi asal tidak ikut pindah ke '
                    'transaksi koreksi.',
                _d.asal.allocations.any((a) => a.caseId != null)
                    ? 'Kasus uang muka, titipan atau penggantian biaya yang '
                          'terkait ikut berubah.'
                    : 'Tidak ada uang muka, titipan atau pencocokan rekening '
                          'koran yang terkait.',
              ]) ...[const SizedBox(height: 4), Text(t, style: teks2)],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // The board's `disabled` button stays pressable and re-checks
            // (CONVENTIONS, TombolBersyarat).
            TekanAria(
              onTap: _bukukan,
              aktif: ok,
              petunjuk: ok ? null : 'Isi alasan untuk melanjutkan.',
              radius: 12,
              child: RupaTombol(
                label: label,
                isi: ok ? c.laut : c.garis,
                warnaTeks: ok ? c.diLaut : c.tinta3,
                radius: 12,
                tinggi: 46,
                paddingH: 20,
                lebarPenuh: false,
              ),
            ),
            if (!ok) Text('Isi alasan untuk melanjutkan.', style: teks2),
          ],
        ),
        if (_pesan case final r?) ...[
          const SizedBox(height: 16),
          Penolakan(
            tindakan: r.action,
            sebab:
                r.because +
                (r.whoCanAct == null
                    ? ''
                    : ' Yang perlu bertindak: ${r.whoCanAct}.'),
            jalan: const [],
          ),
        ],
      ],
    );
  }

  Widget _hasil(PalakatWarna c) {
    final asal = _d.asal.voucher ?? '';
    final balik = _d.pembalikan, ganti = _d.pengganti;
    final kor = ganti != null && ganti.isPosted;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: const Text(
            'Koreksi dibukukan',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          kor
              ? 'Dua No. Bukti baru dibukukan bersama sebagai satu rangkaian. '
                    'Transaksi asal tetap tampil di daftar dan laporan.'
              : 'Satu No. Bukti baru dibukukan. Transaksi asal tetap tampil di '
                    'daftar dan laporan.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        const SizedBox(height: 16),
        RangkaianKoreksi(
          web: true,
          kartu: [
            KartuRangkaian(
              noBukti: balik?.voucher ?? '',
              lencana: 'Dibukukan',
              judul: 'Pembalikan',
              jumlah: balik == null ? '' : rp(signedAmount(balik)),
              keterangan:
                  'Pembalikan dari No. Bukti $asal · tidak dapat diubah atau '
                  'dibalik',
              tundaMuncul: const Duration(milliseconds: 200),
            ),
            if (kor)
              KartuRangkaian(
                noBukti: ganti.voucher ?? '',
                lencana: 'Dibukukan',
                judul: 'Transaksi koreksi',
                jumlah: rp(signedAmount(ganti)),
                keterangan:
                    'Koreksi dari No. Bukti $asal · ${labelKoreksi(ref, ganti)}',
                tundaMuncul: const Duration(milliseconds: 600),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 400),
          tunda: const Duration(milliseconds: 1000),
          child: Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.tinta, width: 1.5)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    'Pengaruh pada Saldo buku ${_d.kasBank}',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  pengaruhTeks(_d.pengaruh),
                  style: _mono.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (ref.watch(alasanPembalikanProvider(_d.asal.id)) case final a
            when a.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text('Alasan: $a', style: TextStyle(fontSize: 13, color: c.tinta3)),
        ],
      ],
    );
  }
}

/// U+200B after each hyphen: the browser may break there; Flutter does not.
String _putus(String no) => no.replaceAll('-', '-\u200B');

/// A Mata Anggaran chip: [ChipSatu] with the board's later `border-radius:
/// 12px`.
class _ChipMA extends StatelessWidget {
  const _ChipMA({
    required this.teks,
    required this.dipilih,
    required this.onTap,
  });

  final String teks;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 12,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: 12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                teks,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: dipilih ? c.permukaan : c.tinta,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// An inline text link with a 44 × 44 target that keeps its line height.
class _TautanSebaris extends StatelessWidget {
  const _TautanSebaris({
    required this.ke,
    required this.tinggiBaris,
    required this.child,
  });

  final Layar ke;
  final double tinggiBaris;
  final Widget child;

  @override
  Widget build(BuildContext context) => MarginNegatif(
    atas: (44 - tinggiBaris) / 2,
    bawah: (44 - tinggiBaris) / 2,
    child: Tautan(
      ke: ke,
      cara: Cara.naik,
      child: Align(
        alignment: Alignment.centerLeft,
        widthFactor: 1,
        child: child,
      ),
    ),
  );
}
