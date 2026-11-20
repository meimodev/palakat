import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../motion/kerangka.dart';
import '../../motion/urutan.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tahapan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../providers/keuangan/isian.dart';
import '../../providers/keuangan/pemeriksa.dart';
import 'pemeriksa_baris.dart';

enum _Gaya { utama, kedua, mati }

/// 13 · Wajib pemeriksa kedua (phone). The drafts awaiting the second check
/// (DP33: the real queue); the selected one goes Draf → Sudah diperiksa
/// (the Pemeriksa kedua) → Dibukukan (the Bendahara). Its maker and a
/// covering Operator cannot mark it.
class PemeriksaScreen extends ConsumerStatefulWidget {
  const PemeriksaScreen({super.key});
  @override
  ConsumerState<PemeriksaScreen> createState() => _PemeriksaScreenState();
}

class _PemeriksaScreenState extends ConsumerState<PemeriksaScreen>
    with LogikaPemeriksa {
  bool _sheet = false;

  /// No draft awaits a check.
  Widget _kosong(PalakatWarna c, ({String siapa, String aturan}) masuk) =>
      Material(
        type: MaterialType.transparency,
        child: LayarPonsel(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masuk sebagai ${masuk.siapa} · Wajib pemeriksa kedua: '
                  '${masuk.aturan}',
                  style: TextStyle(fontSize: 13, color: c.tinta2),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada draf yang menunggu diperiksa.',
                  style: TextStyle(fontSize: 14, color: c.tinta2),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final masuk = masukSebagaiPemeriksa(ref);
    final ids = daftarId(ref.watch(antreanPemeriksaProvider));
    final id = terpilih(ids);
    final v = id == null ? null : tampilPemeriksa(ref, id);
    if (v == null) return _kosong(c, masuk);
    final t = v.t;
    final draf = v.draf, periksa = v.diperiksa, buku = v.dibukukan;
    final bend = v.bendahara;

    var aksi = <(String, _Gaya, VoidCallback?)>[];
    var tolak = '', penjelasan = '';
    if (draf && v.tolakTandai != null) {
      tolak = v.tolakTandai!;
      aksi = [
        ('Tandai sudah diperiksa', _Gaya.mati, null),
        if (bend) ('Ubah', _Gaya.kedua, null), // no handler on the board
      ];
      penjelasan =
          'Draf belum masuk saldo. Sampai diperiksa dan dibukukan, transaksi '
          'ini menjadi hambatan tutup buku '
          '${bulanTahun(t.effectiveDate.tahun, t.effectiveDate.bulan)}.';
    } else if (draf) {
      aksi = [('Tandai sudah diperiksa', _Gaya.utama, () => tandai(t))];
      penjelasan = 'Menandai sudah diperiksa bukan persetujuan dan belum memasukkan transaksi ke saldo. Bendahara yang membukukan.';
    } else if (periksa && bend) {
      aksi = [
        ('Bukukan', _Gaya.utama, () => bukukan(t)),
        ('Ubah', _Gaya.kedua, () => setState(() => _sheet = true)),
      ];
      penjelasan = 'Sudah diperiksa, belum masuk saldo. Pindah tanggal dan Batalkan tetap tersedia dengan alasan.';
    } else if (periksa) {
      penjelasan = 'Anda sudah menandai transaksi ini. Menunggu Bendahara membukukan; tidak ada yang perlu Anda lakukan.';
    } else {
      penjelasan = 'Sudah masuk saldo. Jumlah, tanggal, Kas/Bank, peruntukan, Lingkup dan Mata Anggaran tidak dapat diubah lagi.';
    }
    // A command's own refusal (e.g. an incomplete draft) replaces the line.
    if (tolakUntuk == t.id && this.tolak != null) {
      final r = this.tolak!;
      tolak =
          '${r.action}. ${r.because}'
          '${r.whoCanAct == null ? '' : ' Yang perlu bertindak: ${r.whoCanAct}.'}';
    }

    final t14 = TextStyle(fontSize: 14, color: c.tinta2);

    final kartu = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Only the background has the 300 ms transition; the edge switches at once.
          TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: draf ? c.permukaan.withValues(alpha: 0) : c.permukaan,
            ),
            duration: gerakMati(context)
                ? Duration.zero
                : const Duration(milliseconds: 300),
            builder: (context, isi, child) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: ShapeDecoration(
                color: isi,
                shape: buku
                    ? GarisBorder.penuh(c.tinta, radius: 16)
                    : periksa
                    ? GarisBorder.penuh(c.laut, radius: 16)
                    : GarisBorder.putus(c.putus, radius: 16),
              ),
              child: child,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      // Never shrinks on the board; only guards narrow text.
                      fit: FlexFit.loose,
                      flex: buku ? 0 : 1,
                      child: LencanaStatus(
                        buku
                            ? 'Dibukukan'
                            : periksa
                            ? 'Sudah diperiksa · belum masuk saldo'
                            : 'Draf · belum masuk saldo',
                        bentuk: buku
                            ? BentukLencana.tinta
                            : periksa
                            ? BentukLencana.lautGaris
                            : BentukLencana.draf,
                      ),
                    ),
                    if (buku) ...[
                      const SizedBox(width: 8),
                      // CSS shrinks the stamp, not the one-word badge: it wraps.
                      Expanded(
                        child: Gerak(
                          Kerangka.cap,
                          key: const ValueKey('cap'),
                          lama: const Duration(milliseconds: 550),
                          tunda: const Duration(milliseconds: 350),
                          kurva: PalakatMotion.keluar,
                          child: _Cap(t.voucher ?? ''),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  rp(v.jumlah),
                  style: TextStyle(
                    fontFamily: PalakatText.mono,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    color: buku ? c.tinta : c.tinta2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  [
                    if (v.kasBank.isNotEmpty) v.kasBank,
                    if (v.peruntukan.isNotEmpty)
                      'diambil dari peruntukan ${v.peruntukan}',
                    if (v.lingkup.isNotEmpty) 'Lingkup ${v.lingkup}',
                  ].join(' · '),
                  style: t14,
                ),
                const SizedBox(height: 6),
                Text(
                  '${v.mataAnggaran} · ${tglPanjang(t.effectiveDate.awal)}',
                  style: t14,
                ),
              ],
            ),
          ),
          if (buku) const SapuTinta(key: ValueKey('sapu')),
        ],
      ),
    );

    Widget tombol((String, _Gaya, VoidCallback?) a) {
      final (n, g, on) = a;
      final rupa = RupaTombol(
        label: n,
        isi: switch (g) {
          _Gaya.utama => c.laut,
          _Gaya.kedua => c.permukaan,
          _Gaya.mati => c.garis,
        },
        garis: g == _Gaya.kedua ? GarisBorder.penuh(c.tinta, radius: 14) : null,
        warnaTeks: switch (g) {
          _Gaya.utama => c.diLaut,
          _Gaya.kedua => c.tinta,
          _Gaya.mati => c.tinta3,
        },
        radius: 14,
        tinggi: 50,
        paddingH: 6,
      );
      if (g == _Gaya.mati) {
        return TekanAria(
          onTap: () {},
          aktif: false,
          petunjuk: tolak,
          radius: 14,
          child: rupa,
        );
      }
      return Tekan(onTap: on ?? () {}, radius: 14, child: rupa);
    }

    final isi = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Masuk sebagai '),
                    TextSpan(
                      text: masuk.siapa,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: c.tinta,
                      ),
                    ),
                    TextSpan(text: ' · Wajib pemeriksa kedua: ${masuk.aturan}'),
                  ],
                ),
                style: TextStyle(fontSize: 13, color: c.tinta2),
              ),
              const SizedBox(height: 4),
              Semantics(
                header: true,
                child: Text(
                  '${namaJenis(t.type)} · ${t.description}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ...[
                  _Antrean(ids: ids, pilih: id, onPilih: pilihBaris),
                  const SizedBox(height: 16),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: Tahapan(
                    langkah: const ['Draf', 'Sudah diperiksa', 'Dibukukan'],
                    selesai: draf ? 1 : (periksa ? 2 : 3),
                  ),
                ),
                const SizedBox(height: 16),
                kartu,
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.permukaan,
                    border: Border.all(color: c.garis),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      BarisRincian(
                        'Dicatat oleh',
                        '${v.pencatat} · ${tglJam(t.createdAt)}',
                        atas: false,
                      ),
                      BarisRincian(
                        'Diperiksa oleh',
                        v.pemeriksa == null
                            ? 'Belum diperiksa'
                            : '${v.pemeriksa} · '
                                  '${t.reviewedAt == null ? '' : tglJam(t.reviewedAt!)}',
                        warna: v.pemeriksa == null ? c.bata : c.tinta,
                        kanan: true,
                      ),
                      BarisRincian('Dokumen pendukung', v.dokumen),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(penjelasan, style: t14),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
          decoration: BoxDecoration(
            color: c.permukaan,
            border: Border(top: BorderSide(color: c.garis)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final w in [
                if (tolak.isNotEmpty)
                  Semantics(
                    container: true,
                    liveRegion: true,
                    child: Text(
                      'Tidak dapat dilakukan: $tolak',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.bata,
                      ),
                    ),
                  ),
                for (final a in aksi) tombol(a),
              ].indexed) ...[if (w.$1 > 0) const SizedBox(height: 8), w.$2],
            ],
          ),
        ),
      ],
    );

    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        overlay: [
          if (_sheet)
            Positioned.fill(
              child: LembarBawah(
                judul: 'Ubah transaksi yang sudah diperiksa?',
                ukuranJudul: 19,
                labelTirai: 'Kembali ke transaksi',
                onTutup: () => setState(() => _sheet = false),
                isi: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Transaksi kembali menjadi '),
                        const TextSpan(
                          text: 'Draf',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text:
                              '. Tanda sudah diperiksa dari ${v.pemeriksa ?? 'pemeriksa kedua'} dan persetujuan yang sudah dicatat akan hilang, lalu perlu diberikan lagi.',
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 15, color: c.tinta),
                  ),
                  Tombol(
                    'Ubah dan kembalikan ke Draf',
                    jenis: JenisTombol.tinta,
                    onPressed: () {
                      setState(() => _sheet = false);
                      kembalikan(t);
                    },
                  ),
                  Tombol(
                    'Kembali',
                    jenis: JenisTombol.teks,
                    warnaTeks: c.tinta,
                    onPressed: () => setState(() => _sheet = false),
                  ),
                ],
              ),
            ),
        ],
        child: isi,
      ),
    );
  }
}

/// The No. Bukti stamp: mono 14/600 `laut`, 2 px `laut` line, radius 8.
class _Cap extends StatelessWidget {
  const _Cap(this.nomor);
  final String nomor;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: c.laut, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        // U+200B: Chrome breaks after the hyphen when the stamp shrinks; ICU does not.
        'No. Bukti ${nomor.replaceFirst(RegExp(r'-(?=\d+$)'), '-\u200B')}',
        semanticsLabel: 'No. Bukti $nomor',
        style: TextStyle(
          fontFamily: PalakatText.mono,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: c.laut,
        ),
      ),
    );
  }
}

/// The queue (real data has more than the board's one draft): each draft by
/// its description, the selected one marked as WebPemeriksa marks its row
/// (`lautLembut`, 3 px `laut` left line).
class _Antrean extends ConsumerWidget {
  const _Antrean({
    required this.ids,
    required this.pilih,
    required this.onPilih,
  });

  final List<String> ids;
  final String? pilih;
  final void Function(String) onPilih;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    return Container(
      decoration: BoxDecoration(
        color: c.permukaan,
        border: Border.all(color: c.garis),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, id) in ids.indexed)
            if (tampilPemeriksa(ref, id) case final v?)
              Tekan(
                onTap: () => onPilih(id),
                dipilih: id == pilih,
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: id == pilih ? c.lautLembut : null,
                    border: i == 0
                        ? null
                        : Border(top: BorderSide(color: c.garis)),
                  ),
                  foregroundDecoration: id == pilih
                      ? BoxDecoration(
                          border: Border(
                            left: BorderSide(color: c.laut, width: 3),
                          ),
                        )
                      : null,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              v.t.description,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${v.t.effectiveDate} · ${v.pencatat}',
                              style: TextStyle(fontSize: 13, color: c.tinta2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        rp(v.jumlah),
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: v.dibukukan ? c.tinta : c.tinta3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
