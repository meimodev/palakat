import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

/// 51 · Pemberitahuan (spec 14-berandajabatan.md, KotakMasuk): the one
/// notification box for all active modules. The view is the `keadaan` tweak;
/// the board has no control that changes it.
class KotakMasukScreen extends StatelessWidget {
  const KotakMasukScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final keadaan = belumDipindah<String>('Ada pemberitahuan');
    const a = kotakMasukAda, k1 = kotakMasukKeuangan;
    // Row targets are the logic class's hal(n), written out per row.
    final (tindak, tahu) = switch (keadaan) {
      'Semua sudah selesai' => (const <_Kartu>[], const <_Kartu>[]),
      'Hanya modul Keuangan' => (
        [_Kartu(k1.tindak[0]), _Kartu(k1.tindak[1])],
        [_Kartu(k1.tahu[0])],
      ),
      _ => (
        [_Kartu(a.tindak[0]), _Kartu(a.tindak[1])],
        [_Kartu(a.tahu[0]), _Kartu(a.tahu[1])],
      ),
    };
    final ada = keadaan != 'Semua sudah selesai';

    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pemberitahuan',
            anakJudul: 'Satu kotak untuk semua modul yang aktif',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              // A new view starts at the top.
              key: ValueKey(keadaan),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 16,
                children: [
                  if (ada) ...[
                    const JudulKotak('Perlu tindakan'),
                    ...tindak,
                    const JudulKotak('Untuk diketahui'),
                    ...tahu,
                  ] else
                    const KotakKosong(),
                  const CatatanKotakMasuk(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Row card: `permukaan`, 1 px `garis`, radius 14, padding 12 16, min height
/// 44 (content box), gap 12; title 600, subtitle 13 `tinta3`, badge, chevron.
class _Kartu extends StatelessWidget {
  const _Kartu(this.r);

  final ItemKotak r;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: r.ke,
      param: r.param,
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2,
                  children: [
                    Text(
                      r.judul,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      r.sub,
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
              if (r.label != null)
                LencanaStatus(
                  r.label!,
                  bentuk: (r.gaya ?? GayaLabel.garis).bentuk,
                ),
              PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
            ],
          ),
        ),
      ),
    );
  }
}

/// h2 16/700 ("Perlu tindakan", "Untuk diketahui"); shared with WebKotakMasuk.
class JudulKotak extends StatelessWidget {
  const JudulKotak(this.teks, {super.key});
  final String teks;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      teks,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );
}

/// "Semua sudah selesai": the dashed (draf) box, padding 14 16, gap 6. The
/// title takes the page's body size (16 phone, 15 web).
class KotakKosong extends StatelessWidget {
  const KotakKosong({super.key});

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        const Text(
          'Tidak ada yang perlu tindakan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          'Pemberitahuan selesai sendiri ketika pekerjaannya selesai.',
          style: TextStyle(fontSize: 14, color: context.warna.tinta2),
        ),
      ],
    ),
  );
}

/// The closing caption, 13 `tinta3`, on every view.
class CatatanKotakMasuk extends StatelessWidget {
  const CatatanKotakMasuk({super.key});

  @override
  Widget build(BuildContext context) => Text(
    'Pemberitahuan bukan persetujuan dan bukan dokumen pendukung. Bila '
    'pemberitahuan dorong gagal terkirim, pekerjaan di aplikasi tetap berjalan.',
    style: TextStyle(fontSize: 13, color: context.warna.tinta3),
  );
}
