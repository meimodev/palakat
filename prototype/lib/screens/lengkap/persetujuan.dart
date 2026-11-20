import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kartu_persetujuan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../providers/keuangan/persetujuan.dart';
import '../../widgets/penolakan.dart';

/// 29 · Persetujuan: ganti catatan, gugur karena perubahan (spec 08-cari.md,
/// Persetujuan). A wrong record is replaced, never edited; changing the
/// amount voids the approval. Transaction `:id`, records from
/// ApprovalRepository.
class PersetujuanScreen extends ConsumerStatefulWidget {
  const PersetujuanScreen({super.key});

  @override
  ConsumerState<PersetujuanScreen> createState() => _PersetujuanScreenState();
}

class _PersetujuanScreenState extends ConsumerState<PersetujuanScreen> {
  String? _form; // null, 'ganti', 'catat'
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
  bool get _okNama => _nama.text.trim().isNotEmpty;
  bool get _ok => _okNama && (!_ganti || _alasan.text.trim().isNotEmpty);

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
    if (!_ok) return;
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
    final tanpaForm = _form == null && !_peringatan;
    final s14 = TextStyle(fontSize: 14, color: c.tinta2);

    Widget muncul(Key key, Widget child) => Gerak(
      Kerangka.muncul,
      key: key,
      lama: const Duration(milliseconds: 300),
      child: child,
    );

    Widget tombol(
      String label,
      VoidCallback onPressed, {
      JenisTombol jenis = JenisTombol.kedua,
    }) => Tombol(
      label,
      onPressed: onPressed,
      jenis: jenis,
      ukuran: UkuranTombol.ringkas,
      lebarPenuh: false,
    );

    Widget deret(List<Widget> anak, {Key? key}) =>
        Wrap(key: key, spacing: 8, runSpacing: 8, children: anak);

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
        style: s14,
      ),
    );

    final isi = <Widget>[
      if (d == null)
        Text('Transaksi tidak ditemukan.', style: s14)
      else
        Kartu(
          key: const ValueKey('draf'),
          status: GarisStatus.draf,
          radius: 16,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              t!.isDraft
                  ? const LencanaStatus(
                      'Draf · belum masuk saldo',
                      bentuk: BentukLencana.draf,
                    )
                  : LencanaStatus(
                      '${d.rincian.baris.status} · ${d.rincian.baris.nomor}',
                      bentuk: BentukLencana.garis,
                    ),
              const SizedBox(height: 6),
              Text(
                rp(d.rincian.baris.jumlah),
                style: TextStyle(
                  fontFamily: PalakatText.mono,
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                  color: c.tinta2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                t.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                d.keterangan,
                style: TextStyle(fontSize: 13, color: c.tinta3),
              ),
              if (t.approvalRule != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Aturan: persetujuan wajib untuk ${t.approvalRule}',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ],
          ),
        ),
      if (cur != null)
        KartuPersetujuan.sudah(
          key: const ValueKey('ada'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Persetujuan di luar aplikasi', style: s14),
                Text(
                  'Persetujuan belum dicatat',
                  style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
                ),
                Text(
                  'Draf ini belum dapat dibukukan sampai persetujuan untuk '
                  'jumlah yang baru dicatat.',
                  style: s14,
                ),
              ],
            ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Mengubah jumlah membuat persetujuan tidak berlaku',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  'Persetujuan dicatat untuk ${rp(d.jumlah)}. Perubahan pada '
                  'jumlah, pihak yang dibayar, Kas/Bank, peruntukan, Mata '
                  'Anggaran, tanggal atau uraian mengembalikannya ke belum '
                  'dicatat.',
                  style: s14,
                ),
                const SizedBox(height: 10),
                deret([
                  tombol(
                    'Ubah menjadi ${rp(jumlahUbahan(d.jumlah))}',
                    () => _ubah(d),
                    jenis: JenisTombol.tinta,
                  ),
                  tombol('Kembali', _batal),
                ]),
              ],
            ),
          ),
        ),
      if (_form != null && d != null)
        muncul(
          ValueKey('form-$_form'),
          Kartu(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _ganti ? 'Ganti catatan persetujuan' : 'Catat persetujuan',
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
                  style: s14,
                ),
                const SizedBox(height: 10),
                label('Pemberi persetujuan', wajib: true),
                IsianTeks(
                  controller: _nama,
                  labelSemantik: 'Pemberi persetujuan · wajib',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                label('Jabatan'),
                IsianTeks(
                  controller: _jab,
                  labelSemantik: 'Jabatan',
                  onChanged: (_) => setState(() {}),
                ),
                if (_ganti) ...[
                  const SizedBox(height: 10),
                  // The board's textarea is inline-block inside a div: the
                  // line's half-leading and descent (Plus Jakarta Sans
                  // descent 0.222 em, content 1.26 em) sit under it.
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 16 * (1.4 - 1.26) / 2 + 16 * 0.222,
                    ),
                    child: IsianAlasan(
                      controller: _alasan,
                      onChanged: (_) => setState(() {}),
                      label: 'Alasan mengganti',
                      contoh: 'Contoh: nama pemberi persetujuan keliru',
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                deret([
                  // No refusal sentence on the board; the hint names it.
                  Semantics(
                    hint: _ok
                        ? null
                        : !_okNama
                        ? 'Pemberi persetujuan belum diisi'
                        : 'Alasan mengganti belum diisi',
                    child: Tombol(
                      _ganti
                          ? 'Ganti catatan persetujuan'
                          : 'Catat persetujuan',
                      onPressed: () => _simpan(d),
                      nonaktif: !_ok,
                      ukuran: UkuranTombol.ringkas,
                      lebarPenuh: false,
                    ),
                  ),
                  tombol('Kembali', _batal),
                ]),
              ],
            ),
          ),
        ),
      if (tanpaForm && d != null)
        deret(key: const ValueKey('aksi'), [
          if (cur != null)
            tombol('Ganti catatan persetujuan', () => _buka('ganti'))
          else
            tombol(
              'Catat persetujuan',
              () => _buka('catat'),
              jenis: JenisTombol.utama,
            ),
          if (bisaUbah && cur != null)
            tombol(
              'Ubah jumlah',
              () => setState(() {
                _peringatan = true;
                _form = null;
              }),
            ),
        ]),
      if (lama.isNotEmpty)
        Column(
          key: const ValueKey('riwayat'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: const Text(
                'Riwayat persetujuan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
            for (final r in lama) ...[
              const SizedBox(height: 8),
              muncul(
                ValueKey(r.rekam.id),
                Kartu(
                  status: GarisStatus.draf,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${r.nama}, ${r.jabatan} · ${r.tanggal} · dicatat '
                        '${r.pada}',
                        style: s14,
                      ),
                      Text(
                        r.cat,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
    ];

    return LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Persetujuan',
            anakJudul: 'Catatan yang keliru digantikan, tidak diubah',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < isi.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    isi[i],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
