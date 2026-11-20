import 'package:flutter/material.dart';

import '../shell/tautan.dart';
import '../theme/palakat_tema.dart';
import 'garis.dart';
import 'ikon.dart';
import 'kecil.dart';
import 'lencana_status.dart';
import 'tekan.dart';
import 'tombol.dart';
import '../app/layar.dart';

const _kode = TextStyle(
  fontFamily: PalakatText.mono,
  fontFeatures: [FontFeature.tabularFigures()],
  fontSize: 13,
);

/// One row of the published Mata Anggaran version. [grup] rows are headings
/// that cannot be posted to.
class BarisMataAnggaran {
  const BarisMataAnggaran(this.kode, this.nama, {this.grup = false});
  final String kode, nama;
  final bool grup;
}

/// Main's "Pilih Mata Anggaran" view (`/Main/mata-anggaran`): a full view on
/// `permukaan` with header, search, the list and the footer. The `naik`
/// entrance belongs to the route. Fill a bounded height (it scrolls inside).
class PemilihMataAnggaran extends StatefulWidget {
  const PemilihMataAnggaran({
    super.key,
    required this.pohon,
    required this.baris,
    required this.onPilih,
    required this.onTanpa,
    required this.keBagi,
    required this.versi,
    this.onKembali,
  });

  /// 'Belanja' | 'Pendapatan'.
  final String pohon;

  /// Published version, in order.
  final List<BarisMataAnggaran> baris;
  final ValueChanged<BarisMataAnggaran> onPilih;

  /// 'Simpan tanpa Mata Anggaran'.
  final VoidCallback onTanpa;

  /// Board stem of "Bagi ke beberapa Mata Anggaran" (Main: 'Bagi'); null hides it.
  final Layar? keBagi;

  /// The published version, '{tahun}.N'.
  final String versi;

  /// The header back button (board `keForm`); default pops the route.
  final VoidCallback? onKembali;

  /// Groups always stay; items match "kode nama" case-insensitively.
  static List<BarisMataAnggaran> saring(
    List<BarisMataAnggaran> baris,
    String q,
  ) {
    final kecil = q.toLowerCase();
    return [
      for (final r in baris)
        if (r.grup || '${r.kode} ${r.nama}'.toLowerCase().contains(kecil)) r,
    ];
  }

  @override
  State<PemilihMataAnggaran> createState() => _PemilihMataAnggaranState();
}

class _PemilihMataAnggaranState extends State<PemilihMataAnggaran> {
  String _cari = '';

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final w = widget;
    final baris = PemilihMataAnggaran.saring(w.baris, _cari);
    return ColoredBox(
      color: c.permukaan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
            child: Row(
              children: [
                Tekan(
                  onTap: w.onKembali ?? () => Navigator.of(context).maybePop(),
                  label: 'Kembali',
                  child: SizedBox.square(
                    dimension: 44,
                    child: Center(child: PalakatIkon(Ikon.kembali, ukuran: 22)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: const Text(
                      'Pilih Mata Anggaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                LencanaStatus(
                  w.pohon,
                  bentuk: BentukLencana.tinta,
                  kepala: true,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: IsianTeks(
              latar: c.kertas,
              petunjuk: 'Cari nomor atau nama',
              labelSemantik: 'Cari Mata Anggaran',
              onChanged: (q) => setState(() => _cari = q),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                for (final r in baris)
                  r.grup
                      ? _Grup(r)
                      : _Item(r, pohon: w.pohon, onTap: () => w.onPilih(r)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.garis)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (w.keBagi != null) ...[
                  Tautan(
                    ke: w.keBagi!,
                    radius: 14,
                    child: RupaTombol(
                      label: 'Bagi ke beberapa Mata Anggaran',
                      isi: null,
                      garis: GarisBorder.penuh(c.tinta, radius: 14),
                      warnaTeks: c.tinta,
                      radius: 14,
                      // An <a> is content-box: min-height 48 + the 1.5 lines.
                      tinggi: 51,
                      paddingH: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Tombol(
                  'Simpan tanpa Mata Anggaran',
                  onPressed: w.onTanpa,
                  jenis: JenisTombol.putus,
                  ukuran: UkuranTombol.sedang,
                  paddingH: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Group heading, not pressable: padding 14 0 6; code mono 13 `tinta3`,
/// name 14/700 `tinta2`, "Judul kelompok, tidak dapat dibukukan" 13 `tinta3`.
class _Grup extends StatelessWidget {
  const _Grup(this.r);
  final BarisMataAnggaran r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(r.kode, style: _kode.copyWith(color: c.tinta3)),
          Text(
            r.nama,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.tinta2,
            ),
          ),
          Text(
            'Judul kelompok, tidak dapat dibukukan',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }
}

/// Postable row (a `<button>`, border-box): min height 60 with the 1 px
/// `garis` top rule, padding 6 0 6 14; "{pohon} {kode}" mono 13 `tinta2`,
/// name 15/600.
class _Item extends StatelessWidget {
  const _Item(this.r, {required this.pohon, required this.onTap});
  final BarisMataAnggaran r;
  final String pohon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 60),
        padding: const EdgeInsets.fromLTRB(14, 6, 0, 6),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.garis)),
        ),
        alignment: Alignment.centerLeft,
        child: _KodeNama(kode: '$pohon ${r.kode}', nama: r.nama),
      ),
    );
  }
}

class _KodeNama extends StatelessWidget {
  const _KodeNama({required this.kode, required this.nama});
  final String kode, nama;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(kode, style: _kode.copyWith(color: context.warna.tinta2)),
      Text(
        nama,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ],
  );
}

/// The Mata Anggaran field of Main's Catat form: a 56-high button, padding
/// 10 14, radius 12, trailing `Ikon.lanjut` 18 `tinta3`, gap 12. Chosen:
/// `permukaan`, 1 px `garisTegas`, "{pohon} {kode}" over the name. Not
/// chosen: no fill, 1.5 dashed `putus`, the two "belum" lines.
class IsianMataAnggaran extends StatelessWidget {
  const IsianMataAnggaran({
    super.key,
    required this.pohon,
    required this.terpilih,
    required this.onTap,
  });

  final String pohon;
  final BarisMataAnggaran? terpilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final r = terpilih;
    return Tekan(
      onTap: onTap,
      radius: 12,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: ShapeDecoration(
          color: r == null ? null : c.permukaan,
          shape: r == null
              ? GarisBorder.putus(c.putus, radius: 12)
              : GarisBorder.penuh(c.garisTegas, tebal: 1, radius: 12),
        ),
        child: Row(
          children: [
            Expanded(
              child: _KodeNama(
                kode: r == null
                    ? 'Draf boleh disimpan tanpa Mata Anggaran'
                    : '$pohon ${r.kode}',
                nama: r == null ? 'Mata Anggaran belum dipilih' : r.nama,
              ),
            ),
            const SizedBox(width: 12),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}
