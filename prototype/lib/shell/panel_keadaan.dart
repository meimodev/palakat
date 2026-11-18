import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../boards.dart';
import '../theme/palakat_tema.dart';
import '../widgets/chip_pilihan.dart';
import '../widgets/kecil.dart';
import '../widgets/sakelar.dart';
import '../widgets/tekan.dart';
import 'prototipe_state.dart';
import 'tautan.dart';

/// The top page of the router: its location, its board stem (null for the
/// launcher, `/_komponen` and unknown routes) and whether it is the error page.
typedef LokasiAtas = ({String jalur, String? stem, bool galat});

/// Reads the top page from `currentConfiguration` (navigation.md 5.2): the last
/// match, through pushed and shell matches.
LokasiAtas lokasiAtas(GoRouter router) {
  final cfg = router.routerDelegate.currentConfiguration;
  if (cfg.isError) return (jalur: cfg.uri.toString(), stem: null, galat: true);
  if (cfg.isEmpty) return (jalur: '/', stem: null, galat: false);
  final jalur = cfg.last.matchedLocation;
  final ruas = Uri.parse(jalur).pathSegments.firstOrNull;
  return (
    jalur: jalur,
    stem: papanMenurutStem.containsKey(ruas) ? ruas : null,
    galat: false,
  );
}

/// Keadaan panel (components.md 4.9): prototype chrome, never app UI.
/// [BingkaiPerangkat] places it; [onTutup] is set when it floats over the page.
class PanelKeadaan extends StatelessWidget {
  const PanelKeadaan({
    super.key,
    required this.router,
    required this.lokasi,
    this.onTutup,
  });
  final GoRouter router;
  final LokasiAtas lokasi;
  final VoidCallback? onTutup;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final k = PrototypeState.of(context);
    final stem = lokasi.stem;
    final p = stem == null ? null : papanMenurutStem[stem]!;
    final tweaks = [...?p?.tweaks.where((t) => t.nama != 'jabatanKosong')];
    final adaJk = p?.tweaks.any((t) => t.nama == 'jabatanKosong') ?? false;
    final kecil = TextStyle(fontSize: 13, color: c.tinta3);
    final kode = PalakatText.kode.copyWith(color: c.tinta3);

    Widget sakelar(
      String teks,
      bool nilai,
      ValueChanged<bool> ubah, {
      String? label,
    }) => Row(
      children: [
        Expanded(child: Text(teks)),
        const SizedBox(width: 12),
        Sakelar(nilai: nilai, onUbah: ubah, label: label ?? teks),
      ],
    );

    return Material(
      color: c.permukaan,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: c.garis),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: DefaultTextStyle(
        style: PalakatText.isiWeb.copyWith(color: c.tinta),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              // 1. Title, stem, Semua layar, Kembali.
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (onTutup != null)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Keadaan',
                            style: kecil.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        Tekan(
                          onTap: onTutup,
                          child: const Center(child: TautanTeks('Tutup')),
                        ),
                      ],
                    ),
                  if (p != null) ...[
                    Text(
                      p.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(p.stem, style: kode),
                  ] else
                    Text(lokasi.jalur, style: kode),
                  Wrap(
                    spacing: 22,
                    children: [
                      Tekan(
                        onTap: () => router.go('/'),
                        peran: PeranTekan.tautan,
                        child: const Center(
                          widthFactor: 1,
                          child: TautanTeks('Semua layar'),
                        ),
                      ),
                      if (lokasi.jalur != '/' && !lokasi.galat)
                        Tekan(
                          onTap: () => router.routerDelegate.popRoute(),
                          peran: PeranTekan.tautan,
                          child: const Center(
                            widthFactor: 1,
                            child: TautanTeks('Kembali'),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              // 2. The board's tweaks (jabatanKosong is global, below).
              if (tweaks.isNotEmpty)
                _Bagian('Tweak', [
                  for (final t in tweaks)
                    if (t.editor == 'boolean')
                      sakelar(
                        t.nama,
                        k.tweak(stem!, t.nama) as bool,
                        (v) => k.setTweak(stem, t.nama, v),
                      )
                    else
                      ChipPilihan<String>(
                        label: t.nama,
                        pilihan: [
                          for (final o in t.pilihan!) (nilai: o, teks: o),
                        ],
                        terpilih: k.tweak(stem!, t.nama) as String,
                        onPilih: (v) => k.setTweak(stem, t.nama, v),
                      ),
                ]),
              // 3. Global switches.
              _Bagian('Semua layar', [
                if (adaJk)
                  sakelar(
                    'Jabatan kosong · Operator Yanti Sumual menjalankan Bendahara Jemaat',
                    k.jabatanKosong,
                    (v) => k.jabatanKosong = v,
                    label: 'jabatanKosong',
                  ),
                ChipPilihan<bool>(
                  label: 'Tema',
                  pilihan: const [
                    (nilai: false, teks: 'Terang'),
                    (nilai: true, teks: 'Gelap'),
                  ],
                  terpilih: k.gelap,
                  onPilih: (v) => k.gelap = v,
                ),
                sakelar(
                  'Kurangi gerak',
                  k.kurangiGerak,
                  (v) => k.kurangiGerak = v,
                ),
                sakelar(
                  'Bingkai ponsel',
                  k.bingkaiPonsel,
                  (v) => k.bingkaiPonsel = v,
                ),
              ]),
              // 4. Devices the top board registered with AlatPrototipe.
              if (stem != null)
                ValueListenableBuilder(
                  valueListenable: k.perangkat,
                  builder: (context, semua, _) {
                    final alat = semua[stem] ?? const <Widget>[];
                    if (alat.isEmpty) return const SizedBox.shrink();
                    return _Bagian('Alat prototipe', [
                      for (final a in alat)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Text('Hanya di prototipe', style: kecil),
                            a,
                          ],
                        ),
                    ]);
                  },
                ),
              // 5. Every board that links here.
              if (p != null && p.masuk.isNotEmpty)
                _Bagian('Tautan masuk', [
                  for (final s in p.masuk)
                    Tautan(
                      ke: s,
                      cara: Cara.ganti,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: papanMenurutStem[s]!.judul,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: c.laut,
                                ),
                              ),
                              TextSpan(text: '  $s', style: kode),
                            ],
                          ),
                        ),
                      ),
                    ),
                ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bagian extends StatelessWidget {
  const _Bagian(this.judul, this.isi);
  final String judul;
  final List<Widget> isi;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: 8,
    children: [
      Semantics(
        header: true,
        child: Text(
          judul,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: context.warna.tinta2,
          ),
        ),
      ),
      ...isi,
    ],
  );
}
