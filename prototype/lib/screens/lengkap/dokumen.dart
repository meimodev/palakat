import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/keuangan/dokumen.dart';
import '../../providers/repositories_keuangan.dart';
import '../../widgets/penolakan.dart';

/// The board's UI state shared by `/dokumen` and `/dokumen/rinci`: the open
/// reason form, its text and the last refusal. The rows and the chosen
/// transaction are read from providers (pilihanDokumenProvider).
class _Dokumen extends ChangeNotifier {
  String? form;
  Refusal? pesan;
  final alasan = TextEditingController();

  /// The textarea's focus: tapping its label focuses it (board `label for`).
  final fokus = FocusNode();

  void tutupRinci() {
    if (form == null && pesan == null) return;
    form = null;
    pesan = null;
    notifyListeners();
  }

  void bukaForm(String f) {
    form = f;
    pesan = null;
    alasan.clear();
    notifyListeners();
  }

  void batalForm() {
    form = null;
    notifyListeners();
  }

  void selesai(Refusal? r) {
    pesan = r;
    if (r == null) {
      form = null;
      alasan.clear();
    }
    notifyListeners();
  }

  void ubahAlasan() => notifyListeners();

  @override
  void dispose() {
    alasan.dispose();
    fokus.dispose();
    super.dispose();
  }
}

/// Runs an EvidenceRepository decision on [b] ('verif', 'tolak', 'lepas',
/// 'kecuali'); returns the refusal or null. Shared with WebDokumen.
Future<Refusal?> putuskanDokumen(
  WidgetRef ref,
  BarisDokumen b,
  String aksi, [
  String alasan = '',
]) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final ev = ref.read(evidenceRepositoryProvider);
  final kunci = kunciBaru(a.personId, ref.read(clockProvider));
  final e =
      b.menunggu ??
      ev
          .forTransaction(b.id)
          .where(
            (x) =>
                x.state == EvidenceItemState.verified ||
                x.state == EvidenceItemState.exception,
          )
          .lastOrNull;
  final r = switch (aksi) {
    'kecuali' => await ev.acceptException(
      a,
      b.id,
      reason: alasan,
      expectedRevision: b.transaksi.revision,
      idempotencyKey: kunci,
    ),
    _ when e == null => null,
    'verif' => await ev.verify(
      a,
      e.id,
      expectedRevision: e.revision,
      idempotencyKey: kunci,
    ),
    'tolak' => await ev.reject(
      a,
      e.id,
      reason: alasan,
      expectedRevision: e.revision,
      idempotencyKey: kunci,
    ),
    _ => await ev.release(
      a,
      e.id,
      reason: alasan.isEmpty ? 'File dilepas' : alasan,
      expectedRevision: e.revision,
      idempotencyKey: kunci,
    ),
  };
  return r?.refusal;
}

class _Lingkup extends InheritedNotifier<_Dokumen> {
  const _Lingkup({required _Dokumen k, required super.child})
    : super(notifier: k);

  static _Dokumen of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Lingkup>()!.notifier!;
}

/// Owns the board state, the phone screen and the strip (navigation.md 2.1).
class DokumenKendali extends StatefulWidget {
  const DokumenKendali({super.key, required this.child});
  final Widget child;
  @override
  State<DokumenKendali> createState() => _DokumenKendaliState();
}

class _DokumenKendaliState extends State<DokumenKendali> {
  final _k = _Dokumen();

  @override
  void dispose() {
    _k.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Lingkup(
    k: _k,
    child: LayarPonsel(layarKeuangan: true, child: widget.child),
  );
}

/// 19 · Dokumen pendukung (06-bukti.md, Dokumen): the list at `/Dokumen`,
/// the chosen transaction at `/Dokumen/rinci`.
class DokumenScreen extends StatelessWidget {
  const DokumenScreen({super.key, this.anak, this.param = const {}});
  final String? anak;
  final Map<String, String> param;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.warna.kertas,
    child: anak == 'rinci' ? const _Rinci() : const _Daftar(),
  );
}

class _Daftar extends ConsumerWidget {
  const _Daftar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final daftar = ref.watch(daftarDokumenProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Dokumen pendukung',
          anakJudul: 'Yang perlu diputuskan',
          kembaliKe: Layar.pengaturan,
          labelKembali: 'Kembali ke Lainnya',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final d in daftar) ...[
                  _baris(context, ref, d),
                  const SizedBox(height: 10),
                ],
                Text(
                  'Diunggah bukan terverifikasi. Tutup buku hanya menerima Terverifikasi atau Dikecualikan.',
                  style: TextStyle(fontSize: 13, color: c.tinta3),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _baris(BuildContext context, WidgetRef ref, BarisDokumen d) {
    final c = context.warna;
    final b = d.beres;
    return Tekan(
      radius: 14,
      onTap: () {
        ref.read(pilihanDokumenProvider.notifier).pilih(d.id);
        context.dorongKe(Layar.dokumen, anak: 'rinci');
      },
      child: Kartu(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kodeJumlah(c, d),
            const SizedBox(height: 3),
            Text(
              d.transaksi.description,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 3),
            Text(
              d.label,
              style: TextStyle(
                fontSize: 14,
                color: b ? c.tinta : c.bata,
                fontWeight: b ? FontWeight.w500 : FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(d.bulan, style: TextStyle(fontSize: 13, color: c.tinta3)),
          ],
        ),
      ),
    );
  }
}

/// No. Bukti and amount: space-between, baseline, gap 16.
Widget _kodeJumlah(PalakatWarna c, BarisDokumen d) => Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.baseline,
  textBaseline: TextBaseline.alphabetic,
  children: [
    Flexible(
      child: Text(
        d.no,
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontSize: 13,
          color: c.tinta2,
        ),
      ),
    ),
    const SizedBox(width: 16),
    Text(
      d.jumlah,
      style: const TextStyle(
        fontFamily: PalakatText.mono,
        fontWeight: FontWeight.w500,
      ),
    ),
  ],
);

class _Rinci extends ConsumerWidget {
  const _Rinci();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final k = _Lingkup.of(context);
    final cur = ref.watch(dokumenTerpilihProvider);
    if (cur == null) return const SizedBox.shrink();
    final beres = cur.beres;
    final bulan = cur.bulan.split(' · ').first;
    final catatan = cur.tutup
        ? 'Dokumen susulan disimpan dan mengubah Status sekarang. Laporan resmi $bulan tidak berubah.'
        : cur.status == EvidenceStatus.notRequired
        ? 'Aturan Jemaat tidak mewajibkan dokumen untuk transaksi ini.'
        : beres
        ? 'Memenuhi syarat tutup buku $bulan.'
        : 'Menjadi hambatan tutup buku $bulan sampai terverifikasi atau dikecualikan.';

    Future<void> putuskan(String aksi) async =>
        k.selesai(await putuskanDokumen(ref, cur, aksi));
    void lampirkan() {
      ref.read(pilihanDokumenProvider.notifier).pilih(cur.id);
      context.dorongKe(Layar.fotoDokumen);
    }

    // Action buttons: U (laut) and O (outline), min 48, padding 0 18, radius 12.
    Widget aksi(String n, VoidCallback on, {bool u = false}) => Tekan(
      onTap: on,
      radius: 12,
      child: RupaTombol(
        label: n,
        isi: u ? c.laut : c.permukaan,
        garis: u ? null : GarisBorder.penuh(c.tinta, radius: 12),
        warnaTeks: u ? c.diLaut : c.tinta,
        radius: 12,
        tinggi: 48,
        paddingH: 18,
        lebarPenuh: false,
      ),
    );
    final daftarAksi = <Widget>[
      if (k.form == null)
        ...switch (cur.status) {
          EvidenceStatus.requiredMissing => [
            aksi('Lampirkan dokumen pendukung', lampirkan, u: true),
            aksi('Catat pengecualian', () => k.bukaForm('kecuali')),
          ],
          EvidenceStatus.uploaded => [
            aksi('Verifikasi', () => putuskan('verif'), u: true),
            aksi('Tolak dengan alasan', () => k.bukaForm('tolak')),
            aksi('Lepaskan file', () => putuskan('lepas')),
            if (!cur.tutup)
              aksi('Catat pengecualian', () => k.bukaForm('kecuali')),
          ],
          EvidenceStatus.exceptionAccepted => [
            aksi(
              cur.tutup
                  ? 'Lampirkan dokumen susulan'
                  : 'Lampirkan dokumen pendukung',
              lampirkan,
            ),
          ],
          _ => const <Widget>[],
        },
    ];

    final tautan = TextStyle(fontSize: 14, fontWeight: FontWeight.w700);
    Widget link(String teks) => Center(
      widthFactor: 1,
      heightFactor: 1,
      child: TautanTeks(teks, berat: FontWeight.w700, ukuran: 14),
    );

    final isi = <Widget>[
      Kartu(
        status: GarisStatus.terpilih,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _kodeJumlah(c, cur),
            const SizedBox(height: 4),
            Text(
              cur.transaksi.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(cur.bulan, style: TextStyle(fontSize: 13, color: c.tinta3)),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, w) in [
            Text(
              'Dokumen pendukung',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
            Text(
              cur.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: beres ? c.tinta : c.bata,
              ),
            ),
            Text(catatan, style: TextStyle(fontSize: 14, color: c.tinta2)),
          ].indexed) ...[if (i > 0) const SizedBox(height: 4), w],
        ],
      ),
      if (k.form != null) _Form(key: ValueKey(k.form), k: k, cur: cur),
      if (k.pesan case final r?)
        Penolakan(
          tindakan: r.action,
          sebab:
              r.because +
              (r.whoCanAct == null
                  ? ''
                  : ' Yang perlu bertindak: ${r.whoCanAct}.'),
          jalan: const [],
          ukuranTeks: 14,
        ),
      // Always present: the empty row still takes its 16 px column gap.
      Wrap(spacing: 8, runSpacing: 8, children: daftarAksi),
      DefaultTextStyle.merge(
        style: tautan,
        child: Wrap(
          spacing: 22,
          children: [
            if (cur.menunggu != null || cur.status == EvidenceStatus.verified)
              Tautan(
                ke: Layar.lihatDokumen,
                param: {'id': cur.id},
                child: link('Lihat file'),
              ),
            Tekan(onTap: lampirkan, child: link('Foto dengan kamera')),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Riwayat keputusan',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          for (final (i, h) in cur.riwayat.indexed) ...[
            const SizedBox(height: 6),
            // Keyed from the oldest line, so only a new top line enters.
            Gerak(
              Kerangka.muncul,
              key: ValueKey('${cur.id}-${cur.riwayat.length - i}'),
              lama: const Duration(milliseconds: 300),
              child: Text(h, style: TextStyle(fontSize: 14, color: c.tinta2)),
            ),
          ],
          if (cur.riwayat.isEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Belum ada file dan belum ada keputusan.',
              style: TextStyle(fontSize: 14, color: c.tinta2),
            ),
          ],
        ],
      ),
    ];

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) k.tutupRinci();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KepalaPonsel(
            judul: 'Dokumen pendukung',
            labelKembali: 'Kembali',
            onKembali: () {
              k.tutupRinci();
              context.naikKe(Layar.dokumen);
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (i, w) in isi.indexed) ...[
                    if (i > 0) const SizedBox(height: 16),
                    w,
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

/// The reason form (exception or rejection), entering with `muncul` 300 ms.
class _Form extends ConsumerWidget {
  const _Form({super.key, required this.k, required this.cur});
  final _Dokumen k;
  final BarisDokumen cur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final kec = k.form == 'kecuali';
    final ok = k.alasan.text.trim().isNotEmpty;
    Future<void> simpan() async {
      // Re-read the latest text at press time.
      final a = k.alasan.text.trim();
      if (a.isEmpty) return;
      k.selesai(await putuskanDokumen(ref, cur, kec ? 'kecuali' : 'tolak', a));
    }

    final isi = <Widget>[
      Text(
        kec ? 'Catat pengecualian' : 'Tolak dengan alasan',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      Text(
        kec
            ? 'Pemberi pengecualian: Ketua BPMJ, sesuai pengaturan Jemaat. Anda mencatat keputusannya.'
            : 'Sementara (draf EC07). File yang ditolak tetap ada di Riwayat, dan statusnya dihitung lagi.',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
      GestureDetector(
        onTap: k.fokus.requestFocus,
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Alasan '),
              TextSpan(
                text: '· wajib',
                style: TextStyle(color: c.tinta, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
      ),
      IsianTeks(
        controller: k.alasan,
        focusNode: k.fokus,
        labelSemantik: 'Alasan · wajib',
        onChanged: (_) => k.ubahAlasan(),
        baris: 2,
        minTinggi: 0,
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          TekanAria(
            onTap: simpan,
            aktif: ok,
            petunjuk: ok ? null : 'Alasan wajib diisi',
            radius: 12,
            child: RupaTombol(
              label: kec ? 'Simpan pengecualian' : 'Tolak file ini',
              isi: ok ? c.tinta : c.garis,
              warnaTeks: ok ? c.permukaan : c.tinta3,
              radius: 12,
              tinggi: 46,
              paddingH: 20,
              lebarPenuh: false,
            ),
          ),
          Tombol(
            'Kembali',
            onPressed: k.batalForm,
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.ringkas,
            lebarPenuh: false,
          ),
        ],
      ),
    ];
    return Gerak(
      Kerangka.muncul,
      lama: const Duration(milliseconds: 300),
      child: Kartu(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, w) in isi.indexed) ...[
              if (i > 0) const SizedBox(height: 10),
              w,
            ],
          ],
        ),
      ),
    );
  }
}
