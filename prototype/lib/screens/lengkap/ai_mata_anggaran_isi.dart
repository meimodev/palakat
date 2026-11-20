import 'package:flutter/material.dart';

import '../../mock/orang.dart' show plk;
import '../../motion/kerangka.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// Shared by AIMataAnggaran and WebAIMataAnggaran: the boards' identical
/// logic class (`DEF`, `U`, state `{ur, dasar, st, pilihan}`) and regions
/// 2a–2e of the spec.

const _def = {
  'Satu baris': 'Kertas HVS dan tinta printer',
  'Bagi ke dua baris': 'Kertas HVS Rp300.000 dan token listrik Rp180.000',
  'AI kurang yakin': 'Keperluan ibadah padang',
};

typedef _Baris = (String no, String n, String rp);

const Map<String, List<_Baris>> _u = {
  'Satu baris': [('5.02.01.00', 'Alat tulis dan fotokopi', 'Rp480.000')],
  'Bagi ke dua baris': [
    ('5.02.01.00', 'Alat tulis dan fotokopi', 'Rp300.000'),
    ('5.01.02.00', 'Listrik, air dan telepon', 'Rp180.000'),
  ],
  'AI kurang yakin': [
    ('5.04.01.00', 'Konsumsi rapat', ''),
    ('5.05.02.00', 'Sewa peralatan', ''),
  ],
};

/// The board state. Survives a tweak change, as on the canvas.
class KeadaanUsulanMA {
  String? ur, dasar;
  String st = 'ada';
  int? pilihan;
  final uraian = TextEditingController();
}

/// The regions of one render, built from [k] for [mode].
class IsiUsulanMA {
  IsiUsulanMA({
    required this.context,
    required this.k,
    required this.mode,
    required this.ubah,
    required this.keBagi,
  }) {
    // `ur === null` shows the mode's default; keep the field in step.
    if (k.uraian.text != ur) k.uraian.text = ur;
  }

  final BuildContext context;
  final KeadaanUsulanMA k;
  final String mode;
  final void Function(VoidCallback) ubah;

  /// "Pilih sendiri": Bagi / WebBagi.
  final Layar keBagi;

  List<_Baris> get _usul => _u[mode]!;
  String get ur => k.ur ?? _def[mode]!;
  bool get basi => k.st == 'ada' && ur != (k.dasar ?? _def[mode]!);
  bool get ragu => mode == 'AI kurang yakin';

  /// Board `jadi`. A sure-mode "Pakai" seen in the unsure mode has no
  /// `pilihan` (the canvas crashes on `U[null]`): show no row.
  List<_Baris> get _jadi => k.st != 'pakai'
      ? const []
      : !ragu
      ? _usul
      : k.pilihan == null || k.pilihan! >= _usul.length
      ? const []
      : [_usul[k.pilihan!]];

  void _terima() {
    if (!basi && !ragu) ubah(() => k.st = 'pakai');
  }

  void _abaikan() => ubah(() => k.st = 'abai');

  void _baru() {
    final u = ur;
    ubah(() {
      k.dasar = u;
      k.st = 'ada';
    });
  }

  void _ulang() {
    final u = ur;
    ubah(() {
      k.st = 'ada';
      k.pilihan = null;
      k.dasar = u;
    });
  }

  /// 2a: the draft card.
  Widget get draf {
    final c = context.warna;
    return Kartu(
      status: GarisStatus.draf,
      radius: 16,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LencanaStatus(
            'Draf · belum masuk saldo',
            bentuk: BentukLencana.draf,
          ),
          const SizedBox(height: 6),
          Text(
            '−Rp480.000',
            style: TextStyle(
              fontFamily: PalakatText.mono,
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: c.tinta2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belanja · Toko Sinar · Kas · diambil dari peruntukan Umum Jemaat · Lingkup Jemaat',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ),
    );
  }

  /// 2b: Uraian.
  Widget get uraian => IsianTeks(
    controller: k.uraian,
    label: 'Uraian',
    jarakLabel: 6,
    // TextField merges over the theme's bodyLarge (letter-spacing 0.5).
    gaya: const TextStyle(letterSpacing: 0),
    onChanged: (v) => ubah(() => k.ur = v),
  );

  /// 2c: the Mata Anggaran group.
  Widget mataAnggaran(bool jk) {
    final c = context.warna;
    final jadi = _jadi;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mata Anggaran', style: TextStyle(fontSize: 14, color: c.tinta2)),
        const SizedBox(height: 6),
        if (k.st != 'pakai')
          Kartu(
            status: GarisStatus.draf,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'Mata Anggaran belum dipilih',
              style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
            ),
          )
        else ...[
          Gerak(
            Kerangka.muncul,
            key: const ValueKey('pakai'),
            lama: const Duration(milliseconds: 300),
            child: Kartu(
              status: GarisStatus.terpilih,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Column(
                children: [
                  for (final (i, j) in jadi.indexed)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        border: i == 0
                            ? null
                            : Border(top: BorderSide(color: c.garis)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: Text(
                              'Belanja ${j.$1} ${j.$2}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            j.$3.isEmpty ? 'Rp480.000' : j.$3,
                            style: const TextStyle(
                              fontFamily: PalakatText.mono,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Board template: "{plk} Usulan…", no stop added after "Operator".
          Text(
            'Mata Anggaran sudah dipilih oleh ${plk(jk)} Usulan AI tidak tersimpan sebagai keputusan.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Tombol(
              'Ganti pilihan',
              onPressed: _ulang,
              jenis: JenisTombol.teks,
              lebarPenuh: false,
              paddingH: 0,
            ),
          ),
        ],
      ],
    );
  }

  /// 2d: the AI panel, only in state `ada`.
  Widget? get panel {
    if (k.st != 'ada') return null;
    final c = context.warna;
    final usul = _usul;
    final sah = !basi;
    final adaCek = usul.length > 1 && !ragu;
    final label = ragu
        ? 'Usulan AI · kurang yakin, mohon dicek'
        : usul.length > 1
        ? 'Usulan AI · bagi ke 2 Mata Anggaran'
        : 'Usulan AI · Mata Anggaran';

    Widget barisUsul(int i, _Baris u) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GarisLurus(warna: c.garisTegas, gaya: GayaGaris.titik),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belanja ${u.$1} ${u.$2}',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: c.lautTua,
                      ),
                    ),
                    if (u.$3.isNotEmpty)
                      Text(
                        u.$3,
                        style: TextStyle(
                          fontFamily: PalakatText.mono,
                          fontSize: 13,
                          color: c.tinta2,
                        ),
                      ),
                  ],
                ),
              ),
              if (ragu) ...[
                const SizedBox(width: 10),
                Tombol(
                  'Pilih ini',
                  onPressed: () {
                    if (!basi) {
                      ubah(() {
                        k.st = 'pakai';
                        k.pilihan = i;
                      });
                    }
                  },
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.mini,
                  lebarPenuh: false,
                  paddingH: 14,
                  ukuranTeks: 14,
                  // Board `disabled` while stale; its reason is the stale sentence.
                  nonaktif: basi,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    const jeda10 = SizedBox(height: 10);
    return Semantics(
      container: true,
      label: 'Usulan AI',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.lautLembut,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BANTUAN AI · PILIHAN',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c.lautTua,
                letterSpacing: 0.3,
              ),
            ),
            jeda10,
            Kartu(
              status: GarisStatus.usulanAI,
              radius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LencanaStatus(label, bentuk: BentukLencana.usulanAI),
                  ),
                  for (final (i, u) in usul.indexed) ...[
                    const SizedBox(height: 6),
                    barisUsul(i, u),
                  ],
                  if (adaCek) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Rp300.000 + Rp180.000 = Rp480.000, sama persis dengan jumlah pembayaran.',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ],
              ),
            ),
            jeda10,
            if (!sah) ...[
              Text(
                'Usulan lama — draf sudah berubah. Usulan ini tidak dapat dipakai.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.tinta,
                ),
              ),
              jeda10,
              Tombol(
                'Buat usulan baru',
                onPressed: _baru,
                jenis: JenisTombol.garisLaut,
                ukuran: UkuranTombol.kecil,
                warnaTeks: c.lautTua,
              ),
            ] else
              LayoutBuilder(
                builder: (_, kotak) {
                  // CSS flex 1 / 1.3 / 1 with basis 0: each item starts at its
                  // padding + border (button 12 + 0 or 15, link 3), the rest
                  // is shared by grow factor.
                  final aksi = [
                    if (!ragu)
                      (
                        12.0,
                        1.0,
                        Tombol(
                          'Pakai',
                          onPressed: _terima,
                          ukuran: UkuranTombol.ringkas,
                          paddingH: 6,
                        ),
                      ),
                    (
                      3.0,
                      1.3,
                      Tombol(
                        'Pilih sendiri',
                        onPressed: null,
                        ke: keBagi,
                        jenis: JenisTombol.kedua,
                        ukuran: UkuranTombol.ringkas,
                        paddingH: 0,
                        ukuranTeks: 15,
                      ),
                    ),
                    (
                      15.0,
                      1.0,
                      Tombol(
                        'Abaikan',
                        onPressed: _abaikan,
                        jenis: JenisTombol.kedua,
                        ukuran: UkuranTombol.ringkas,
                        paddingH: 6,
                      ),
                    ),
                  ];
                  final sisa =
                      kotak.maxWidth -
                      8 * (aksi.length - 1) -
                      aksi.fold(0.0, (j, a) => j + a.$1);
                  final tumbuh = aksi.fold(0.0, (j, a) => j + a.$2);
                  return Row(
                    children: [
                      for (final (i, a) in aksi.indexed) ...[
                        if (i > 0) const SizedBox(width: 8),
                        SizedBox(
                          width: a.$1 + sisa * a.$2 / tumbuh,
                          child: a.$3,
                        ),
                      ],
                    ],
                  );
                },
              ),
            jeda10,
            Text(
              'AI hanya memilih dari baris yang dapat dibukukan dan boleh untuk uang milik sendiri. Memakai, mengganti atau mengabaikan usulan tidak perlu alasan.',
              style: TextStyle(fontSize: 13, color: c.tinta2),
            ),
          ],
        ),
      ),
    );
  }

  /// 2e: the ignored sentence, only in state `abai`.
  Widget? get abai => k.st != 'abai'
      ? null
      : Gerak(
          Kerangka.muncul,
          key: const ValueKey('abai'),
          lama: const Duration(milliseconds: 300),
          child: Text(
            'Usulan diabaikan. Draf boleh disimpan tanpa Mata Anggaran, tetapi belum dapat dibukukan.',
            style: TextStyle(fontSize: 14, color: context.warna.tinta2),
          ),
        );
}
