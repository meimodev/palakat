import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../motion/kerangka.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import '../../app/layar.dart';

/// The form state (shared with WebUbahPengaturan; each screen owns its own
/// instance). The board's "Seri No. Bukti" and "Aturan persetujuan" tabs
/// have no repository command (README 4.2), so the tabs add what F19 adds:
/// a Kas/Bank, a peruntukan or a Lingkup, each from a month not yet running.
class DataUbahPengaturan {
  String tab = 'kas', jenis = 'Bank', nama = '', akhir = '';
  Tanggal? mulai;
  String? pemilik, lingkup;

  bool get ok => switch (tab) {
    'kas' => nama.trim().isNotEmpty && (jenis == 'Kas' || akhir.length == 4),
    'dana' => nama.trim().isNotEmpty && pemilik != null,
    _ => lingkup != null,
  };

  /// Rule A02: a field of the open tab differs from its start value.
  bool get sudahMulai => switch (tab) {
    'kas' => nama.isNotEmpty || akhir.isNotEmpty,
    'dana' => nama.isNotEmpty || pemilik != null,
    _ => lingkup != null,
  };

  /// The first unmet field of the open tab, as named on the board.
  String get alasan => ok
      ? ''
      : '${switch (tab) {
          'kas' when nama.trim().isEmpty => jenis == 'Kas' ? 'Tempat atau pemegang' : 'Nama bank',
          'kas' => 'Empat angka akhir No. rekening',
          'dana' when nama.trim().isEmpty => 'Nama peruntukan',
          'dana' => 'Pemilik peruntukan',
          _ => 'Lingkup',
        }} belum diisi.';

  void kosongkan() {
    nama = '';
    akhir = '';
    pemilik = null;
    lingkup = null;
  }
}

const _tabs = [
  (nilai: 'kas', teks: 'Tambah Kas/Bank'),
  (nilai: 'dana', teks: 'Tambah peruntukan'),
  (nilai: 'lingkup', teks: 'Tambah Lingkup'),
];

/// The parts both boards place in their own layout.
typedef BagianUbahPengaturan = ({
  Widget tab,
  Widget isi,
  Widget tombol,
  Widget judul,
  List<Widget> jadi,
  Widget catatan,
});

/// The changes that wait for their month (computed from the repositories).
List<String> perubahanMenunggu(WidgetRef ref) {
  ref.watch(revisionProvider);
  final p = ref.watch(pengaturanProvider);
  final hari = p.hariIni;
  final org = ref.watch(orgRepositoryProvider);
  String dari(Tanggal d) => 'berlaku mulai ${bulanDari(d)}';
  return [
    for (final k in p.kas)
      if (k.akun.activeFrom > hari)
        '${k.akun.name} · ${dari(k.akun.activeFrom)} · belum dapat dipakai '
            'untuk transaksi sebelum itu'
      else if (k.akanMati)
        '${k.akun.name} nonaktif · ${dari(k.akun.activeTo!.tambahHari(1))}',
    for (final f in ref.watch(fundRepositoryProvider).funds())
      if (f.activeFrom > hari) 'Peruntukan ${f.name} · ${dari(f.activeFrom)}',
    for (final l
        in ref
            .watch(settingsRepositoryProvider)
            .lingkup(at: awalBulanKe(hari, 24)))
      if (l.activeFrom > hari)
        'Lingkup ${org.scope(l.scopeId)?.name ?? l.scopeId} · '
            '${dari(l.activeFrom)}',
    for (final v in ref.watch(settingsRepositoryProvider).scheduled())
      'Wajib pemeriksa kedua ${v.on ? 'hidup' : 'mati'} · '
          '${dari(v.effectiveFrom)}',
  ];
}

/// Holds the state and the fields; [tata] lays the parts out per board.
class IsiUbahPengaturan extends ConsumerStatefulWidget {
  const IsiUbahPengaturan({super.key, required this.web, required this.tata});

  final bool web;
  final Widget Function(BagianUbahPengaturan b) tata;

  @override
  ConsumerState<IsiUbahPengaturan> createState() => _IsiUbahPengaturanState();
}

class _IsiUbahPengaturanState extends ConsumerState<IsiUbahPengaturan> {
  final d = DataUbahPengaturan();
  late final _nama = TextEditingController(text: d.nama);
  late final _akhir = TextEditingController(text: d.akhir);
  final _fokusAkhir = FocusNode();
  Refusal? _tolak;

  @override
  void dispose() {
    for (final k in [_nama, _akhir]) {
      k.dispose();
    }
    _fokusAkhir.dispose();
    super.dispose();
  }

  void _ubah(VoidCallback f) => setState(f);

  Future<void> _simpan(Tanggal mulai) async {
    if (!d.ok) return;
    final nama = d.nama.trim();
    final r = await jalankanPengaturan(ref, (a, kunci) {
      switch (d.tab) {
        case 'kas':
          final kas = d.jenis == 'Kas';
          return ref
              .read(accountRepositoryProvider)
              .add(
                a,
                AccountDraft(
                  name: kas ? 'Kas $nama' : 'Bank $nama ··${d.akhir}',
                  shortName: kas ? 'Kas $nama' : 'Bank $nama',
                  type: kas ? AccountType.cash : AccountType.bank,
                  institution: kas ? null : nama,
                ),
                mulai,
                idempotencyKey: kunci,
              );
        case 'dana':
          return ref
              .read(fundRepositoryProvider)
              .add(
                a,
                FundDraft(name: nama, ownerScopeId: d.pemilik!),
                mulai,
                idempotencyKey: kunci,
              );
        default:
          return ref
              .read(settingsRepositoryProvider)
              .addLingkup(a, d.lingkup!, mulai, idempotencyKey: kunci);
      }
    });
    if (!mounted) return;
    setState(() {
      _tolak = r;
      if (r == null) {
        d.kosongkan();
        _nama.clear();
        _akhir.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final label = TextStyle(fontSize: 14, color: c.tinta2);
    const mono = TextStyle(fontFamily: PalakatText.mono);
    final p = ref.watch(pengaturanProvider);
    final org = ref.watch(orgRepositoryProvider);
    final bulan = d.mulai ?? p.bulanBerlaku.first;
    final lingkupAda = {
      for (final l
          in ref
              .watch(settingsRepositoryProvider)
              .lingkup(at: awalBulanKe(p.hariIni, 24)))
        l.scopeId,
    };
    String namaScope(Scope s) => s.id == ScopeRef.jemaatId ? 'Jemaat' : s.name;

    Widget pilih<T>(
      String judul,
      List<({T nilai, String teks})> pilihan,
      T? nilai,
      ValueChanged<T> f,
    ) => ChipPilihan<T>(
      label: judul,
      pilihan: pilihan,
      terpilih: nilai,
      onPilih: (v) => _ubah(() => f(v)),
    );

    final mulai = pilih<Tanggal>(
      'Berlaku mulai',
      [for (final b in p.bulanBerlaku) (nilai: b, teks: bulanDari(b))],
      bulan,
      (v) => d.mulai = v,
    );

    // `<label for>`: tapping the label focuses its field.
    Widget sempit(String judul, FocusNode fokus, Widget isian) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: fokus.requestFocus,
          // The field carries the label; no separate small tap node.
          excludeFromSemantics: true,
          child: Text(judul, style: label),
        ),
        const SizedBox(height: 6),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: isian,
        ),
      ],
    );

    Widget kini(String judul, String nilai) => Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: label),
          Text(nilai, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );

    final isi = switch (d.tab) {
      'kas' => [
        pilih(
          'Jenis',
          const [(nilai: 'Kas', teks: 'Kas'), (nilai: 'Bank', teks: 'Bank')],
          d.jenis,
          (v) => d.jenis = v,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IsianTeks(
              controller: _nama,
              label: d.jenis == 'Kas' ? 'Tempat atau pemegang' : 'Nama bank',
              jarakLabel: 6,
              petunjuk: d.jenis == 'Kas'
                  ? 'Misalnya: Panitia Natal'
                  : 'Misalnya: Mandiri',
              onChanged: (v) => _ubah(() => d.nama = v),
            ),
            const SizedBox(height: 4),
            Text(
              'Jangan memakai nama peruntukan atau Lingkup.',
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
        if (d.jenis == 'Bank')
          sempit(
            'Empat angka akhir No. rekening',
            _fokusAkhir,
            IsianTeks(
              controller: _akhir,
              focusNode: _fokusAkhir,
              labelSemantik: 'Empat angka akhir No. rekening',
              gaya: mono,
              keyboardType: TextInputType.number,
              formatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              onChanged: (v) => _ubah(() => d.akhir = v),
            ),
          ),
        mulai,
      ],
      'dana' => [
        kini('Sekarang', p.peruntukan.join(' · ')),
        IsianTeks(
          controller: _nama,
          label: 'Nama peruntukan',
          jarakLabel: 6,
          petunjuk: 'Misalnya: Beasiswa',
          onChanged: (v) => _ubah(() => d.nama = v),
        ),
        pilih<String>(
          'Pemilik',
          [
            for (final s in org.scopes())
              if (s.id == ScopeRef.jemaatId || lingkupAda.contains(s.id))
                (nilai: s.id, teks: namaScope(s)),
          ],
          d.pemilik,
          (v) => d.pemilik = v,
        ),
        mulai,
      ],
      _ => [
        kini('Sekarang', p.lingkup.join(' · ')),
        pilih<String>(
          'Lingkup baru',
          [
            for (final s in org.scopes())
              if (!lingkupAda.contains(s.id) && s.active)
                (nilai: s.id, teks: namaScope(s)),
          ],
          d.lingkup,
          (v) => d.lingkup = v,
        ),
        mulai,
      ],
    };

    final tab = widget.web
        ? Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _tabs)
                ChipSatu(
                  teks: t.teks,
                  dipilih: d.tab == t.nilai,
                  onTap: () => _ubah(() => d.tab = t.nilai),
                ),
            ],
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in _tabs)
                  _ChipTab(
                    teks: t.teks,
                    dipilih: d.tab == t.nilai,
                    onTap: () => _ubah(() => d.tab = t.nilai),
                  ),
              ],
            ),
          );

    return widget.tata((
      tab: tab,
      isi: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < isi.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            isi[i],
          ],
        ],
      ),
      tombol: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          if (_tolak != null)
            Penolakan(
              tindakan: _tolak!.action,
              sebab: _tolak!.because,
              jalan: const [],
            ),
          TombolBersyarat(
            label: 'Simpan sebagai versi baru',
            tindakan: 'Simpan sebagai versi baru',
            alasan: d.alasan,
            periksa: () => d.alasan,
            onPressed: () => _simpan(bulan),
            sudahMulai: d.sudahMulai,
            warnaSiap: JenisTombol.utama,
            teksBelumRedup: true,
            paddingH: 20,
          ),
        ],
      ),
      judul: const JudulBagian('Perubahan yang menunggu berlaku'),
      jadi: [
        for (final e in perubahanMenunggu(ref))
          Gerak(
            Kerangka.muncul,
            key: ValueKey(e),
            lama: const Duration(milliseconds: 300),
            child: Kartu(
              status: GarisStatus.draf,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                e,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
      catatan: Text(
        'Pengaturan tidak diubah di tempat. Versi lama tetap berlaku untuk bulan-bulan sebelumnya dan tidak mengubah transaksi yang sudah dibukukan. Yang sudah dipakai hanya dapat dinonaktifkan.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ));
  }
}

/// The phone's smaller tab chip: 13/600, padding 0 12 (ChipSatu is fixed
/// at 14 / 0 14).
class _ChipTab extends StatelessWidget {
  const _ChipTab({
    required this.teks,
    required this.dipilih,
    required this.onTap,
  });

  final String teks;
  final bool dipilih;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      dipilih: dipilih,
      radius: 22,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: ShapeDecoration(
          color: dipilih ? c.tinta : c.permukaan,
          shape: GarisBorder.penuh(
            dipilih ? c.tinta : c.garisTegas,
            radius: PalakatRadius.chip,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              teks,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: dipilih ? c.permukaan : c.tinta,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UbahPengaturanScreen extends StatelessWidget {
  const UbahPengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: IsiUbahPengaturan(
      web: false,
      tata: (b) {
        final isi = [b.isi, b.tombol, b.judul, ...b.jadi, b.catatan];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Ubah pengaturan',
              anakJudul: 'Selalu sebagai versi baru',
              kembaliKe: Layar.pengaturan,
              labelKembali: 'Kembali ke Lainnya',
            ),
            b.tab,
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
        );
      },
    ),
  );
}
