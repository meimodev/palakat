import 'package:flutter/widgets.dart';

import '../../mock/mock.dart';
import '../../shell/prototipe_state.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';

/// Shared by Pengumuman and WebPengumuman (17-keadaanumum.md): the five
/// views of the `keadaan` tweak and the board state `{ k: null }`.
const opsiPengumuman = [
  'Daftar',
  'Draf',
  'Diterbitkan',
  'Diarsipkan sendiri',
  'Ralat sebagai revisi',
];

const _isiRalat =
    'Sabtu, 21 November 2026 pukul 06.30. Membawa alat kebersihan masing-masing.';

/// The board's `k`: view = `k ?? keadaan`; a tweak change resets `k`, and
/// every view change jumps the scroll area to the top.
mixin KeadaanPengumuman<W extends StatefulWidget> on State<W> {
  String get stem;

  /// On a widget inside the scroll view.
  final kunciAtas = GlobalKey();
  String? _k, _tweak;

  String keadaan(BuildContext context) {
    final t = context.tweak<String>(stem, 'keadaan');
    if (_tweak != null && t != _tweak) {
      _k = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _keAtas());
    }
    _tweak = t;
    final k = _k ?? t;
    return opsiPengumuman.contains(k) ? k : opsiPengumuman.first;
  }

  void pilih(String k) {
    _keAtas();
    setState(() => _k = k);
  }

  void _keAtas() {
    final c = kunciAtas.currentContext;
    if (!mounted || c == null) return;
    Scrollable.maybeOf(c)?.position.jumpTo(0);
  }
}

/// A flex column with a fixed gap.
class KolomJarak extends StatelessWidget {
  const KolomJarak({super.key, required this.jarak, required this.anak});
  final double jarak;
  final List<Widget> anak;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < anak.length; i++) ...[
        if (i > 0) SizedBox(height: jarak),
        anak[i],
      ],
    ],
  );
}

LencanaStatus lencanaPengumuman(Pengumuman p) =>
    LencanaStatus(p.status, bentuk: p.gaya.bentuk);

/// Phone row (DokumenGereja 2b): a self link to the board.
class BarisPengumuman extends StatelessWidget {
  const BarisPengumuman(this.p, {super.key});
  final Pengumuman p;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: 'Pengumuman',
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    p.judul,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.untuk,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            lencanaPengumuman(p),
            const SizedBox(width: 12),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}

/// Web table (WebDokumenGereja 2b): rows with a 1 px rule between them.
class TabelPengumuman extends StatelessWidget {
  const TabelPengumuman({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, p) in semuaPengumuman.indexed) ...[
            if (i > 0) GarisLurus(warna: c.garis),
            Tautan(
              ke: 'WebPengumuman',
              child: Container(
                // min-height 52 on a content-box <a>, plus padding 8 + 8.
                constraints: const BoxConstraints(minHeight: 68),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(child: _SelJudul(p)),
                    const SizedBox(width: 16),
                    lencanaPengumuman(p),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 20,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: PalakatIkon(
                          Ikon.lanjut,
                          ukuran: 18,
                          warna: c.tinta3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// `flex-wrap: wrap; align-items: baseline; gap: 2px 20px`: title
/// `flex: 1 1 260px`, caption `flex: 1.4 1 300px`.
class _SelJudul extends StatelessWidget {
  const _SelJudul(this.p);
  final Pengumuman p;

  @override
  Widget build(BuildContext context) {
    final judul = Text(
      p.judul,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
    final ket = Text(
      p.untuk,
      style: TextStyle(fontSize: 13, color: context.warna.tinta3),
    );
    return LayoutBuilder(
      builder: (context, k) {
        final l = BarisLentur.lebar(
          [
            Lentur(dasar: 260, child: judul),
            Lentur(dasar: 300, tumbuh: 1.4, child: ket),
          ],
          20,
          k.maxWidth,
        );
        if (l.length > 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [judul, const SizedBox(height: 2), ket],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            SizedBox(width: l[0][0], child: judul),
            const SizedBox(width: 20),
            SizedBox(width: l[0][1], child: ket),
          ],
        );
      },
    );
  }
}

/// A read-only field: label 14 `tinta2` above (gap 6), value inherits 14
/// `tinta2` (`input{font:inherit}`).
Widget _isian(
  BuildContext context,
  String label,
  String nilai, {
  int baris = 1,
}) => IsianTeks(
  label: label,
  nilaiAwal: nilai,
  hanyaBaca: true,
  jarakLabel: 6,
  baris: baris,
  gaya: TextStyle(fontSize: 14, color: context.warna.tinta2),
);

/// The draft form card (Draf view).
class FormDrafPengumuman extends StatelessWidget {
  const FormDrafPengumuman({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      child: KolomJarak(
        jarak: 12,
        anak: [
          _isian(context, 'Judul', semuaPengumuman[0].judul),
          _isian(context, 'Isi', pengumumanKerjaBaktiIsi, baris: 3),
          KisiOtomatis(
            minLebar: 300,
            jarak: 16,
            anak: [
              _isian(context, 'Ditujukan untuk', 'Semua anggota'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isian(context, 'Berakhir pada', '20/11/2026'),
                  const SizedBox(height: 6),
                  Text(
                    'Boleh kosong. Setelah tanggal ini pengumuman diarsipkan sendiri.',
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Text _keterangan(BuildContext context, String s) =>
    Text(s, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

/// The draft form, its caption and its buttons (Draf view, phone and the
/// web's left column).
List<Widget> drafPengumuman(
  BuildContext context,
  ValueChanged<String> pilih,
) => [
  const FormDrafPengumuman(),
  _keterangan(
    context,
    'Draf oleh $pengumumanDrafOleh. Hanya Sekretaris Jemaat yang menerbitkan.',
  ),
  BarisTombol(
    anak: [
      Tombol(
        'Terbitkan',
        jenis: JenisTombol.tinta,
        onPressed: () => pilih('Diterbitkan'),
      ),
      Tombol(
        'Simpan sebagai draf',
        jenis: JenisTombol.kedua,
        ukuran: UkuranTombol.sedang,
        onPressed: () => pilih('Daftar'),
      ),
    ],
  ),
];

/// Member preview of the draft (web Draf view, right column).
List<Widget> pratinjauPengumuman(BuildContext context) {
  final c = context.warna;
  return [
    const JudulBagian('Yang dilihat anggota'),
    Kartu(
      child: KolomJarak(
        jarak: 6,
        anak: [
          KepalaKartu(
            judul: semuaPengumuman[0].judul,
            ujung: const LencanaStatus(
              'Belum diterbitkan',
              bentuk: BentukLencana.draf,
            ),
          ),
          Text(
            pengumumanKerjaBaktiIsi,
            style: TextStyle(fontSize: 14, color: c.tinta2),
          ),
          _keterangan(
            context,
            'Ditujukan untuk: Semua anggota · tampil sampai 20/11/2026',
          ),
        ],
      ),
    ),
    _keterangan(
      context,
      'Sama seperti yang masuk ke Warta Jemaat. Draf tidak pernah terlihat anggota.',
    ),
  ];
}

/// The views other than Daftar and Draf, identical on phone and web.
List<Widget> viewPengumuman(
  BuildContext context,
  String keadaan,
  ValueChanged<String> pilih,
) {
  final c = context.warna;
  switch (keadaan) {
    case 'Diterbitkan':
      return [
        Kartu(
          child: KolomJarak(
            jarak: 6,
            anak: [
              KepalaKartu(
                judul: semuaPengumuman[0].judul,
                ujung: lencanaPengumuman(semuaPengumuman[0]),
              ),
              Text(
                'Ditujukan untuk: Semua anggota · Berakhir pada 20/11/2026',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              _keterangan(
                context,
                '$pengumumanKerjaBaktiOleh. Masuk ke Warta edisi 22/11/2026.',
              ),
            ],
          ),
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Ralat',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: () => pilih('Ralat sebagai revisi'),
            ),
          ],
        ),
      ];
    case 'Diarsipkan sendiri':
      return [
        Kartu(
          status: GarisStatus.draf,
          child: KolomJarak(
            jarak: 6,
            anak: [
              KepalaKartu(
                judul: semuaPengumuman[3].judul,
                ujung: lencanaPengumuman(semuaPengumuman[3]),
              ),
              Text(
                'Berakhir pada 15/11/2026',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              _keterangan(
                context,
                'Diarsipkan sendiri pada tanggal berakhirnya. Tetap dapat dibaca di arsip.',
              ),
            ],
          ),
        ),
      ];
    case 'Ralat sebagai revisi':
      return [
        Kartu(
          status: GarisStatus.draf,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Ralat menjadi Revisi 2.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(text: ' '),
                TextSpan(
                  text: 'Revisi 1 tetap tampil sebagai “Digantikan oleh revisi 2”.',
                  style: TextStyle(color: c.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Kartu(child: _isian(context, 'Isi', _isiRalat, baris: 3)),
        BarisTombol(
          anak: [
            Tombol(
              'Terbitkan revisi 2',
              jenis: JenisTombol.tinta,
              onPressed: () => pilih('Diterbitkan'),
            ),
            Tombol(
              'Batalkan',
              jenis: JenisTombol.teks,
              onPressed: () => pilih('Diterbitkan'),
            ),
          ],
        ),
      ];
  }
  return const [];
}

/// "Tulis pengumuman" under the list.
Widget tulisPengumuman(ValueChanged<String> pilih) => BarisTombol(
  anak: [
    Tombol(
      'Tulis pengumuman',
      jenis: JenisTombol.tinta,
      onPressed: () => pilih('Draf'),
    ),
  ],
);
