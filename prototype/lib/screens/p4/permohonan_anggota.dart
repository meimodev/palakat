import 'package:flutter/widgets.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../shell/tautan.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';
import '../../app/belum_dipindah.dart';

const _mengisi = 'Mengisi';
const _izinBelum = 'Izin belum diberikan';
const _untukAnak = 'Untuk anak';
const _diajukan = 'Diajukan';
const _dikembalikan = 'Dikembalikan';
const _diverifikasi = 'Diverifikasi';
const _tidakDiterima = 'Tidak diterima';

/// 72 · Permohonan menjadi anggota (spec 19-alursurat.md): seven views under
/// one header, chosen by `k ?? keadaan`.
class PermohonanAnggotaScreen extends StatefulWidget {
  const PermohonanAnggotaScreen({super.key});

  @override
  State<PermohonanAnggotaScreen> createState() =>
      _PermohonanAnggotaScreenState();
}

class _PermohonanAnggotaScreenState extends State<PermohonanAnggotaScreen> {
  String? _k;
  String? _tweakLama;
  String? _tampil;

  /// The native checkbox's own tick; drives only the box (spec Notes).
  bool _izin = true;

  void _ke(String v) => setState(() => _k = v);

  @override
  Widget build(BuildContext context) {
    final tweak = belumDipindah<String>('Mengisi');
    if (tweak != _tweakLama) {
      _tweakLama = tweak;
      _k = null;
    }
    final v = _k ?? tweak;
    if (v != _tampil) {
      _tampil = v;
      _izin = v != _izinBelum;
    }
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Permohonan menjadi anggota',
            anakJudul: 'Diisi sendiri, lalu diverifikasi Penatua Kolom',
            kembaliKe: Layar.dataAnggota,
            labelKembali: 'Kembali ke Data jemaat',
          ),
          Expanded(
            child: SingleChildScrollView(
              key: ValueKey(v),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _sela(_isi(context, v), 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _isi(BuildContext context, String v) {
    final c = context.warna;
    final ajukan = BarisTombol(
      anak: [
        Tombol(
          'Ajukan permohonan',
          jenis: JenisTombol.tinta,
          onPressed: () => _ke(_diajukan),
        ),
      ],
    );
    Widget izin(String kalimat) => _KartuIzin(
      kalimat: kalimat,
      nilai: _izin,
      onUbah: (b) => setState(() => _izin = b),
    );
    const sendiri = 'Saya memberi izin penggunaan data pribadi saya.';
    return switch (v) {
      _izinBelum => [
        const _FormulirSaya(),
        izin(sendiri),
        // `<button disabled>`: not focusable, nothing happens.
        BarisTombol(
          anak: [
            Tekan(
              onTap: null,
              radius: 14,
              child: RupaTombol(
                label: 'Ajukan permohonan',
                isi: c.garis,
                warnaTeks: c.tinta2,
                radius: 14,
                tinggi: 52,
                paddingH: 16,
              ),
            ),
          ],
        ),
        Text(
          'Tidak dapat dilakukan: izin penggunaan data pribadi belum diberikan.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
      ],
      _untukAnak => [
        const _Kartu(
          jarak: 12,
          anak: [
            _Isian('Nama anak', 'Gabriel Wenas'),
            _Isian('Tanggal lahir', '02/09/2019'),
            _Isian('Orang tua atau wali', 'Novita Wenas'),
          ],
        ),
        izin(
          'Sebagai orang tua atau wali, saya memberi izin penggunaan data '
          'pribadi anak ini.',
        ),
        ajukan,
      ],
      _diajukan => [
        _KartuHasil(
          judul: 'Permohonan menjadi anggota',
          lencana: const LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
          isi: 'Diajukan 16/11/2026 10.12',
          ket:
              'Berikutnya: Pnt. Hendrik Rumagit, Penatua Kolom 7, memverifikasi '
              'data ini. Anda belum menjadi anggota sampai permohonan '
              'Diverifikasi.',
        ),
      ],
      _dikembalikan => [
        _KartuHasil(
          judul: 'Permohonan menjadi anggota',
          lencana: const LencanaStatus(
            'Dikembalikan',
            bentuk: BentukLencana.bata,
          ),
          isi:
              'Alasan: tanggal lahir berbeda dengan surat baptis. Mohon '
              'diperiksa lagi.',
          ket: 'Oleh Pnt. Hendrik Rumagit, 17/11/2026 08.40',
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Ubah dan ajukan lagi',
              jenis: JenisTombol.tinta,
              onPressed: () => _ke(_mengisi),
            ),
          ],
        ),
      ],
      _diverifikasi => [
        _KartuHasil(
          judul: 'Novita Wenas',
          lencana: const LencanaStatus(
            'Diverifikasi',
            bentuk: BentukLencana.laut,
          ),
          isi: 'Anggota jemaat · Keluarga Wenas-Lasut · Kolom 7',
          ket:
              'Diverifikasi oleh Pnt. Hendrik Rumagit, 17/11/2026 19.05. '
              'Verifikasi bukan persetujuan keuangan dan tidak dilakukan oleh '
              'pemohon sendiri.',
        ),
        // The board's `<a>` is content-box: max-width 340 + padding + line
        // is wider than the row, so it fills it; min height 48 + 2 × 1.5.
        Tautan(
          ke: Layar.tampilanNama,
          radius: 14,
          child: RupaTombol(
            label: 'Atur tampilan nama saya',
            isi: c.permukaan,
            garis: GarisBorder.penuh(c.tinta, radius: 14),
            warnaTeks: c.tinta,
            radius: 14,
            tinggi: 51,
            paddingH: 16,
          ),
        ),
      ],
      _tidakDiterima => [
        _KartuHasil(
          judul: 'Permohonan menjadi anggota',
          lencana: const LencanaStatus(
            'Tidak diterima',
            bentuk: BentukLencana.bata,
          ),
          isi:
              'Alasan: pemohon tercatat sebagai anggota aktif jemaat lain; '
              'perlu atestasi masuk.',
          ket:
              'Oleh Pnt. Hendrik Rumagit, 17/11/2026. Data yang diisi tidak '
              'menjadi data anggota.',
        ),
      ],
      _ => [const _FormulirSaya(), izin(sendiri), ajukan],
    };
  }
}

List<Widget> _sela(List<Widget> anak, double jarak) => [
  for (final (i, a) in anak.indexed) ...[if (i > 0) SizedBox(height: jarak), a],
];

/// Detail card: padding 14 16, a column with [jarak].
class _Kartu extends StatelessWidget {
  const _Kartu({required this.anak, required this.jarak});

  final List<Widget> anak;
  final double jarak;

  @override
  Widget build(BuildContext context) => Kartu(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _sela(anak, jarak),
    ),
  );
}

/// The applicant's own form (Mengisi, Izin belum diberikan).
class _FormulirSaya extends StatelessWidget {
  const _FormulirSaya();

  @override
  Widget build(BuildContext context) => const _Kartu(
    jarak: 12,
    anak: [
      _Isian('Nama lengkap', 'Novita Wenas'),
      KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          _Isian('Tanggal lahir', '14/03/1996'),
          _Isian('Jenis kelamin', 'Perempuan'),
        ],
      ),
      _Isian(
        'Status pernikahan',
        'Belum pernah menikah',
        ket: 'Bersama tanggal lahir menentukan Kategori BIPRA: Pemuda',
      ),
      _Isian(
        'Keluarga',
        'Wenas-Lasut',
        ket: 'Setiap orang tetap punya datanya sendiri, termasuk anak',
      ),
      _Isian('Kolom', 'Kolom 7'),
    ],
  );
}

/// A read-only field: label 14 `tinta2`, gap 6, input, optional 13 `tinta3`
/// helper.
class _Isian extends StatelessWidget {
  const _Isian(this.label, this.nilai, {this.ket});

  final String label, nilai;
  final String? ket;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isian = IsianTeks(
      nilaiAwal: nilai,
      label: label,
      jarakLabel: 6,
      hanyaBaca: true,
      gaya: TextStyle(fontSize: 14, color: c.tinta2),
    );
    if (ket == null) return isian;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        isian,
        const SizedBox(height: 6),
        Text(ket!, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    );
  }
}

/// Consent card (Q28): title, text version, text, checkbox row.
class _KartuIzin extends StatelessWidget {
  const _KartuIzin({
    required this.kalimat,
    required this.nilai,
    required this.onUbah,
  });

  final String kalimat;
  final bool nilai;
  final ValueChanged<bool> onUbah;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return _Kartu(
      jarak: 6,
      anak: [
        const Text(
          'Izin penggunaan data pribadi',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        Text(
          'Naskah versi 1 · 12/11/2026',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        Text(
          'Data ini dipakai Jemaat Karunia untuk pelayanan, surat dan Warta '
          'Jemaat. Nama saya di publikasi mengikuti Tampilan nama yang saya '
          'pilih. Saya dapat mencabut izin dan meminta data saya dihapus.',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        // KotakCentang has no `margin: 2px 0 0` for its box; the same look,
        // drawn here with it. The whole row is the target.
        Tekan(
          onTap: () => onUbah(!nilai),
          tercentang: nilai,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: SizedBox.square(
                  dimension: 24,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: nilai ? c.laut : c.permukaan,
                      shape: nilai
                          ? RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            )
                          : GarisBorder.penuh(c.garisTegas, radius: 4),
                    ),
                    child: nilai
                        ? Center(
                            child: PalakatIkon(
                              Ikon.centang,
                              ukuran: 16,
                              warna: c.diLaut,
                              tebal: 3,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(kalimat, style: const TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Outcome card: title row with badge, 14 `tinta2` line, 13 `tinta3` note.
class _KartuHasil extends StatelessWidget {
  const _KartuHasil({
    required this.judul,
    required this.lencana,
    required this.isi,
    required this.ket,
  });

  final String judul, isi, ket;
  final Widget lencana;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return _Kartu(
      jarak: 6,
      anak: [
        KepalaKartu(judul: judul, ujung: lencana),
        Text(isi, style: TextStyle(fontSize: 14, color: c.tinta2)),
        Text(ket, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    );
  }
}
