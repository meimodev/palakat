import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kartu_persetujuan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/persetujuan.dart';
import '../../widgets/penolakan.dart';

/// Web · Persetujuan: ganti catatan dan perubahan (spec 08, WebPersetujuan).
/// Transaction `:id`, records from ApprovalRepository.
class WebPersetujuanScreen extends ConsumerStatefulWidget {
  const WebPersetujuanScreen({super.key});

  @override
  ConsumerState<WebPersetujuanScreen> createState() =>
      _WebPersetujuanScreenState();
}

class _WebPersetujuanScreenState extends ConsumerState<WebPersetujuanScreen> {
  String? _form; // null, 'ganti' or 'catat'
  bool _peringatan = false;
  Refusal? _tolak;
  final _nama = TextEditingController();
  final _jab = TextEditingController(text: 'Ketua BPMJ');
  final _alasan = TextEditingController();

  @override
  void dispose() {
    _nama.dispose();
    _jab.dispose();
    _alasan.dispose();
    super.dispose();
  }

  bool get _ganti => _form == 'ganti';

  /// The first unmet condition, '' when the submit may run.
  String get _alasanTolak => _nama.text.trim().isEmpty
      ? 'Pemberi persetujuan belum diisi'
      : _ganti && _alasan.text.trim().isEmpty
      ? 'Alasan mengganti belum diisi'
      : '';

  void _buka(String form) => setState(() {
    _form = form;
    _tolak = null;
    _nama.clear();
    _alasan.clear();
  });

  void _batal() => setState(() {
    _form = null;
    _peringatan = false;
  });

  Future<void> _simpan(DataPersetujuan d) async {
    if (_alasanTolak.isNotEmpty) return;
    final r = await simpanPersetujuan(
      ref,
      d,
      nama: _nama.text,
      jabatan: _jab.text,
      alasan: _ganti ? _alasan.text.trim() : null,
    );
    if (!mounted) return;
    setState(() {
      _tolak = r;
      if (r == null) _form = null;
    });
  }

  Future<void> _ubah(DataPersetujuan d) async {
    final r = await ubahJumlahDraf(ref, d.transaksi, jumlahUbahan(d.jumlah));
    if (!mounted) return;
    setState(() {
      _tolak = r;
      _peringatan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final d = ref.watch(persetujuanProvider(id));
    final cur = d?.berlaku;
    final lama = d?.lama ?? const <CatatanPersetujuan>[];
    final t = d?.transaksi;
    final bisaUbah = t != null && t.isDraft && t.allocations.isNotEmpty;

    Widget muncul(Key key, Widget child) => Gerak(
      Kerangka.muncul,
      key: key,
      lama: const Duration(milliseconds: 300),
      child: child,
    );

    Widget tombol(String label, VoidCallback onTap, JenisTombol jenis) =>
        Tombol(
          label,
          onPressed: onTap,
          jenis: jenis,
          ukuran: UkuranTombol.ringkas,
          lebarPenuh: false,
        );

    Widget kolom(double jarak, List<Widget> anak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: jarak,
      children: anak,
    );

    Widget label(String teks, {bool wajib = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: teks),
            if (wajib)
              TextSpan(
                text: ' · wajib',
                style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
    );

    final tolak = _alasanTolak;
    final ok = tolak.isEmpty;
    final judulForm = _ganti
        ? 'Ganti catatan persetujuan'
        : 'Catat persetujuan';

    final draf = d == null || t == null
        ? Text(
            'Transaksi tidak ditemukan.',
            style: TextStyle(fontSize: 14, color: c.tinta2),
          )
        : Kartu(
            status: GarisStatus.draf,
            radius: 16,
            padding: const EdgeInsets.all(18),
            child: kolom(6, [
              Align(
                alignment: Alignment.centerLeft,
                child: t.isDraft
                    ? const LencanaStatus(
                        'Draf · belum masuk saldo',
                        bentuk: BentukLencana.draf,
                      )
                    : LencanaStatus(
                        '${d.rincian.baris.status} · ${d.rincian.baris.nomor}',
                        bentuk: BentukLencana.garis,
                      ),
              ),
              Text(
                rp(d.rincian.baris.jumlah),
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: c.tinta2,
                ),
              ),
              Text(
                t.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                d.keterangan,
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
              if (t.approvalRule != null)
                Text(
                  'Aturan: persetujuan wajib untuk ${t.approvalRule}',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
            ]),
          );

    final kanan = kolom(14, [
      if (cur != null)
        KartuPersetujuan.sudah(
          kepala: 'Persetujuan di luar aplikasi',
          pemberi: cur.nama,
          jabatan: cur.jabatan,
          tanggal: cur.tanggal,
          cara: cur.cara,
          dicatatOleh: cur.oleh,
          dicatatPada: cur.pada,
        )
      else if (d != null)
        muncul(
          const ValueKey('belum'),
          Kartu(
            status: GarisStatus.draf,
            child: kolom(0, [
              Text(
                'Persetujuan di luar aplikasi',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Text(
                'Persetujuan belum dicatat',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
              ),
              Text(
                'Draf ini belum dapat dibukukan sampai persetujuan untuk '
                'jumlah yang baru dicatat.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ]),
          ),
        ),
      if (_tolak case final r?)
        Penolakan(
          tindakan: r.action,
          sebab:
              r.because +
              (r.whoCanAct == null
                  ? ''
                  : ' Yang perlu bertindak: ${r.whoCanAct}.'),
          jalan: const [],
        ),
      if (_peringatan && d != null)
        muncul(
          const ValueKey('peringatan'),
          Kartu(
            status: GarisStatus.terpilih,
            padding: const EdgeInsets.all(16),
            child: kolom(10, [
              const Text(
                'Mengubah jumlah membuat persetujuan tidak berlaku',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              Text(
                'Persetujuan dicatat untuk ${rp(d.jumlah)}. Perubahan pada '
                'jumlah, '
                // Word joiner: Chrome does not break after this slash.
                'pihak yang dibayar, Kas/⁠Bank, peruntukan, Mata Anggaran, '
                'tanggal atau uraian mengembalikannya ke belum dicatat.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  tombol(
                    'Ubah menjadi ${rp(jumlahUbahan(d.jumlah))}',
                    () => _ubah(d),
                    JenisTombol.tinta,
                  ),
                  tombol('Kembali', _batal, JenisTombol.kedua),
                ],
              ),
            ]),
          ),
        ),
      if (_form != null && d != null)
        muncul(
          ValueKey('form-$_form'),
          // TextField would otherwise add Material's 0.5 letter spacing to
          // the typed text and the hint; the board's inputs inherit none.
          DefaultTextStyle.merge(
            style: const TextStyle(letterSpacing: 0),
            child: Kartu(
              padding: const EdgeInsets.all(16),
              child: kolom(10, [
                kolom(0, [
                  Text(
                    judulForm,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _ganti
                        ? 'Catatan lama tidak diubah. Ia tetap ada di Riwayat '
                              'dengan tanda digantikan.'
                        : 'Anda mencatat persetujuan yang diberikan di luar '
                              'aplikasi.',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                ]),
                kolom(0, [
                  label('Pemberi persetujuan', wajib: true),
                  IsianTeks(
                    controller: _nama,
                    labelSemantik: 'Pemberi persetujuan',
                    onChanged: (_) => setState(() {}),
                  ),
                ]),
                kolom(0, [
                  label('Jabatan'),
                  IsianTeks(
                    controller: _jab,
                    labelSemantik: 'Jabatan',
                    onChanged: (_) => setState(() {}),
                  ),
                ]),
                if (_ganti)
                  // The inline-block textarea leaves the line box's descender gap
                  // (4.75 px) below it in its div, as on the board.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.75),
                    child: IsianAlasan(
                      controller: _alasan,
                      onChanged: (_) => setState(() {}),
                      label: 'Alasan mengganti',
                      contoh: 'Contoh: nama pemberi persetujuan keliru',
                    ),
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Board: no refusal sentence, the "· wajib" labels are the
                    // cue; the reason is the Semantics hint (spec Notes).
                    TekanAria(
                      onTap: () => _simpan(d),
                      aktif: ok,
                      petunjuk: ok ? null : tolak,
                      radius: 12,
                      child: RupaTombol(
                        label: judulForm,
                        isi: ok ? c.laut : c.garis,
                        warnaTeks: ok ? c.diLaut : c.tinta3,
                        radius: 12,
                        tinggi: 46,
                        paddingH: 20,
                        lebarPenuh: false,
                      ),
                    ),
                    tombol('Kembali', _batal, JenisTombol.kedua),
                  ],
                ),
              ]),
            ),
          ),
        ),
      if (_form == null && !_peringatan && d != null)
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (cur != null)
              tombol(
                'Ganti catatan persetujuan',
                () => _buka('ganti'),
                JenisTombol.kedua,
              ),
            if (cur == null)
              tombol(
                'Catat persetujuan',
                () => _buka('catat'),
                JenisTombol.utama,
              ),
            if (bisaUbah && cur != null)
              tombol(
                'Ubah jumlah',
                () => setState(() {
                  _peringatan = true;
                  _form = null;
                }),
                JenisTombol.kedua,
              ),
          ],
        ),
      if (lama.isNotEmpty)
        kolom(8, [
          const Text(
            'Riwayat persetujuan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          for (final r in lama)
            muncul(
              ValueKey('lama-${r.rekam.id}'),
              Kartu(
                status: GarisStatus.draf,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: kolom(0, [
                  Text(
                    '${r.nama}, ${r.jabatan} · ${r.tanggal} · dicatat '
                    '${r.pada}',
                    style: TextStyle(fontSize: 14, color: c.tinta2),
                  ),
                  Text(
                    r.cat,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ]),
              ),
            ),
        ]),
    ]);

    // CSS puts half the leading above and half below each line; Flutter's
    // default (proportional) sets glyphs lower than the board does.
    return DefaultTextHeightBehavior(
      textHeightBehavior: const TextHeightBehavior(
        leadingDistribution: TextLeadingDistribution.even,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: HalamanWeb(
          layarKeuangan: true,
          nav: NavSamping(item: navKeuangan, aktif: 1),
          isi: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The 44 px target hangs below the line; the inline link sits in
                // the 15 / 1.45 line box of its div, as on the board.
                MarginNegatif(
                  bawah: 44 - 15 * 1.45,
                  child: Tautan(
                    ke: Layar.transaksi,
                    cara: Cara.naik,
                    child: const TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Semantics(
                    header: true,
                    child: const Text(
                      'Persetujuan di luar aplikasi',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Text(
                  'Catatan yang keliru digantikan catatan baru, tidak diubah. '
                  'Perubahan pada transaksi membuat persetujuan perlu dicatat '
                  'lagi.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
            BarisLentur(
              jarak: 24,
              anak: [
                Lentur(dasar: 360, child: draf),
                Lentur(dasar: 440, tumbuh: 999, child: kanan),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
