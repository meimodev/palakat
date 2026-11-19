import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// One entry of the board's `D`: [judul, "jenis · tanggal · untuk", revisi].
typedef DokumenAlur = ({String judul, String ket, int revisi});

const _jenisPil = [
  'Keputusan dan surat edaran',
  'Notulen rapat',
  'Tata gereja dan liturgi',
];
const _untukPil = ['Semua anggota', 'Pelayan dan pengurus', 'Kolom 7'];

// This flow seeds the document at revision 1 (DokumenGereja shows Revisi 2).
final DokumenAlur _seed = (
  judul: semuaDokumenGereja[1].judul,
  ket: semuaDokumenGereja[1].jenisTanggalUntuk,
  revisi: 1,
);

/// The board's flow state `a`, shared by AlurDokumen and WebAlurDokumen.
/// The typed values live in the controllers (the board's `judul`, `tgl`,
/// `ralat`), raw: no mask, trimmed only when checked and published.
class AlurDokumenData extends ChangeNotifier {
  String pesan = '', jenis = '', untuk = '', file = '';
  List<String> riw = [];
  int sel = 0;

  /// `daftar`, `form` or `ralat`; on the phone the route decides instead.
  String v = 'daftar';
  List<DokumenAlur> dok = [_seed];
  final judul = TextEditingController(),
      tgl = TextEditingController(),
      ralat = TextEditingController();

  void _set(VoidCallback f) {
    f();
    notifyListeners();
  }

  /// Back to the initial state object.
  void ulang() => _set(() {
    pesan = jenis = untuk = file = '';
    riw = [];
    sel = 0;
    v = 'daftar';
    dok = [_seed];
    judul.clear();
    tgl.clear();
    ralat.clear();
  });

  /// `keForm`.
  void keForm() => _set(() {
    v = 'form';
    pesan = jenis = untuk = file = '';
    judul.clear();
    tgl.clear();
  });

  /// `ke('ralat', { sel: i, ralat: '', file: '' })`.
  void keRalat(int i) => _set(() {
    v = 'ralat';
    pesan = file = '';
    sel = i;
    ralat.clear();
  });

  /// `batal`.
  void batal() => _set(() {
    v = 'daftar';
    pesan = '';
  });

  /// `pil('jenis', …)` / `pil('untuk', …)`: a chip never deselects.
  void pilihJenis(String n) => _set(() {
    jenis = n;
    pesan = '';
  });
  void pilihUntuk(String n) => _set(() {
    untuk = n;
    pesan = '';
  });

  /// `ketik`: the controller already holds the text.
  void ketik(String _) => notifyListeners();

  /// `pilihFile` with `sekaliGagal`: the first attempt always fails.
  void pilihFile() => _set(() => file = file.isEmpty ? 'gagal' : 'ada');

  /// First unmet condition of "Terbitkan", '' when met.
  String get alasan {
    final t = bacaTgl(tgl.text);
    if (jenis.isEmpty) return 'jenis dokumen belum dipilih.';
    if (judul.text.trim().isEmpty) return 'judul belum diisi.';
    if (t == null) return 'tanggal dokumen tidak dikenali. Contoh: 16/11/2026.';
    if (t > hari) return 'tanggal dokumen belum tiba.';
    if (untuk.isEmpty) return 'penerima belum dipilih.';
    if (file != 'ada') return 'salinan bertanda tangan belum terlampir.';
    return '';
  }

  bool get sebabTampil =>
      jenis.isNotEmpty ||
      judul.text.isNotEmpty ||
      tgl.text.isNotEmpty ||
      untuk.isNotEmpty ||
      file.isNotEmpty;

  /// First unmet condition of "Terbitkan revisi", '' when met.
  String get alasan2 {
    if (ralat.text.trim().isEmpty) return 'yang diralat belum diisi.';
    if (file != 'ada') return 'salinan bertanda tangan revisi belum terlampir.';
    return '';
  }

  bool get sebab2Tampil => ralat.text.isNotEmpty || file.isNotEmpty;

  DokumenAlur get terpilih => sel < dok.length ? dok[sel] : dok[0];

  void terbit() {
    if (alasan.isNotEmpty) return;
    final j = judul.text.trim();
    final teks = '$j diterbitkan untuk $untuk.';
    _set(() {
      v = 'daftar';
      dok = [
        (judul: j, ket: '$jenis · ${tgl.text.trim()} · $untuk', revisi: 1),
        ...dok,
      ];
      pesan = teks;
      riw = catat(riw, '$teks Oleh Olvie Pangemanan, Sekretaris Jemaat.');
    });
  }

  void terbitRev() {
    if (alasan2.isNotEmpty) return;
    final d = terpilih;
    final n = d.revisi + 1;
    final teks =
        '${d.judul}: revisi $n diterbitkan. Yang diralat: ${ralat.text.trim()}';
    _set(() {
      dok = [
        for (final (i, x) in dok.indexed)
          i == sel ? (judul: x.judul, ket: x.ket, revisi: n) : x,
      ];
      v = 'daftar';
      pesan = teks;
      riw = catat(riw, teks);
    });
  }

  @override
  void dispose() {
    judul.dispose();
    tgl.dispose();
    ralat.dispose();
    super.dispose();
  }
}

/// A column with the boards' `gap`.
Widget kolomAlur(List<Widget> anak, double jarak) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  mainAxisSize: MainAxisSize.min,
  children: [
    for (final (i, w) in anak.indexed) ...[
      if (i > 0) SizedBox(height: jarak),
      w,
    ],
  ],
);

Widget _kiri(Widget w) =>
    Align(alignment: AlignmentDirectional.centerStart, child: w);

Text _catatan(BuildContext context, String t) =>
    Text(t, style: TextStyle(fontSize: 13, color: context.warna.tinta3));

/// View `daftar` (2a–2e): banner, document cards, "Terbitkan dokumen", the
/// note and Riwayat.
List<Widget> daftarAlurDokumen(
  BuildContext context,
  AlurDokumenData a, {
  required VoidCallback onBaru,
  required ValueChanged<int> onRalat,
}) => [
  if (a.pesan.isNotEmpty) Pesan(Text(a.pesan)),
  for (final (i, d) in a.dok.indexed)
    Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: kolomAlur([
        KepalaKartu(
          judul: d.judul,
          ujung: LencanaStatus(
            d.revisi > 1 ? 'Revisi ${d.revisi}' : 'Diterbitkan',
            bentuk: BentukLencana.tinta,
          ),
        ),
        _catatan(
          context,
          d.ket +
              (d.revisi > 1
                  ? ' · revisi ${d.revisi - 1} tetap dapat dibuka'
                  : ''),
        ),
        _kiri(
          Tombol(
            'Ralat',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            lebarPenuh: false,
            onPressed: () => onRalat(i),
          ),
        ),
      ], 6),
    ),
  BarisTombol(
    anak: [
      Tombol('Terbitkan dokumen', jenis: JenisTombol.tinta, onPressed: onBaru),
    ],
  ),
  _catatan(
    context,
    'Dokumen yang sudah diterbitkan tidak pernah diubah diam-diam; ralat '
    'selalu menjadi revisi baru.',
  ),
  if (a.riw.isNotEmpty) RiwayatAlur(baris: a.riw),
];

/// Chip group (K7): label, gap 6, chips with gap 8 both ways.
Widget _chip(
  String label,
  List<String> pil,
  String nilai,
  ValueChanged<String> pilih,
) =>
    // ChipPilihan pads 8 under its chips; the flow boards' wrap has none.
    MarginNegatif(
      bawah: 8,
      child: ChipPilihan<String>(
        label: label,
        jarakLabel: 6,
        pilihan: [for (final p in pil) (nilai: p, teks: p)],
        terpilih: nilai.isEmpty ? null : nilai,
        onPilih: pilih,
      ),
    );

/// View `form`, left part (3a–3d).
List<Widget> isianTerbit(AlurDokumenData a) => [
  _chip('Jenis dokumen', _jenisPil, a.jenis, a.pilihJenis),
  IsianAlur(
    label: 'Judul',
    controller: a.judul,
    onChanged: a.ketik,
    petunjuk: 'Judul dokumen',
  ),
  IsianAlur(
    label: 'Tanggal dokumen',
    controller: a.tgl,
    onChanged: a.ketik,
    petunjuk: 'hh/bb/tttt',
    keterangan: 'Tanggal yang tertulis di dokumennya.',
    keyboard: TextInputType.datetime,
  ),
  _chip('Ditujukan untuk', _untukPil, a.untuk, a.pilihUntuk),
];

/// File panel (3e): dashed card, badge by file state.
Widget panelFile(BuildContext context, AlurDokumenData a) {
  final c = context.warna;
  return Kartu(
    status: GarisStatus.draf,
    child: kolomAlur([
      KepalaKartu(
        judul: 'Salinan bertanda tangan',
        ujung: LencanaStatus(
          a.file == 'ada'
              ? 'Terlampir'
              : a.file == 'gagal'
              ? 'Gagal diunggah'
              : 'Wajib, belum ada',
          bentuk: a.file == 'ada' ? BentukLencana.garis : BentukLencana.bata,
        ),
      ),
      if (a.file == 'gagal') ...[
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Gagal diunggah.',
                style: TextStyle(fontWeight: FontWeight.w700, color: c.bata),
              ),
              const TextSpan(
                text:
                    ' Isian Anda masih ada di layar ini; file belum terlampir.',
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
        _kiri(
          Tombol(
            'Coba lagi',
            jenis: JenisTombol.tinta,
            lebarPenuh: false,
            onPressed: a.pilihFile,
          ),
        ),
      ],
      if (a.file.isEmpty) ...[
        _catatan(
          context,
          'Tanda tangan ada di dokumennya. Tidak ada persetujuan di aplikasi '
          'untuk dokumen gereja.',
        ),
        _kiri(
          Tombol(
            'Pilih file',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            lebarPenuh: false,
            onPressed: a.pilihFile,
          ),
        ),
      ],
      if (a.file == 'ada')
        _catatan(context, 'salinan-bertanda-tangan.pdf · 1 halaman'),
    ], 6),
  );
}

/// The refusal (3f / 4d) and the button row (3g / 4e).
List<Widget> _aksi({
  required String label,
  required String alasan,
  required bool tampil,
  required String Function() periksa,
  required VoidCallback onTerbit,
  required VoidCallback onBatal,
}) => [
  if (tampil && alasan.isNotEmpty)
    Penolakan(tindakan: label, sebab: alasan, jalan: const [], ukuranTeks: 14),
  BarisTombol(
    anak: [
      TombolBersyarat(
        label: label,
        tindakan: label,
        alasan: alasan,
        periksa: periksa,
        sudahMulai: false,
        onPressed: onTerbit,
      ),
      Tombol(
        'Batalkan',
        jenis: JenisTombol.teks,
        ukuran: UkuranTombol.kecil,
        onPressed: onBatal,
      ),
    ],
  ),
];

/// View `form`, right part (3e–3g).
List<Widget> aksiTerbit(
  BuildContext context,
  AlurDokumenData a, {
  required VoidCallback onTerbit,
  required VoidCallback onBatal,
}) => [
  panelFile(context, a),
  ..._aksi(
    label: 'Terbitkan',
    alasan: a.alasan,
    tampil: a.sebabTampil,
    periksa: () => a.alasan,
    onTerbit: onTerbit,
    onBatal: onBatal,
  ),
];

/// View `ralat`, left part (4a–4b).
List<Widget> isianRalat(BuildContext context, AlurDokumenData a) => [
  Kartu(
    child: kolomAlur([
      KepalaKartu(
        judul: a.terpilih.judul,
        ujung: const LencanaStatus('Diterbitkan', bentuk: BentukLencana.tinta),
      ),
      _catatan(
        context,
        'Revisi yang sekarang tetap dapat dibuka dan diberi tanda '
        '“Digantikan”.',
      ),
    ], 6),
  ),
  IsianAlur(
    label: 'Yang diralat · wajib',
    controller: a.ralat,
    onChanged: a.ketik,
    baris: 3,
  ),
];

/// View `ralat`, right part (4c–4e).
List<Widget> aksiRalat(
  BuildContext context,
  AlurDokumenData a, {
  required VoidCallback onTerbit,
  required VoidCallback onBatal,
}) => [
  panelFile(context, a),
  ..._aksi(
    label: 'Terbitkan revisi',
    alasan: a.alasan2,
    tampil: a.sebab2Tampil,
    periksa: () => a.alasan2,
    onTerbit: onTerbit,
    onBatal: onBatal,
  ),
];
