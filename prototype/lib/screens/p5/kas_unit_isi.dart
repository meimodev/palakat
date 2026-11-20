import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/pengaturan.dart';
import '../../providers/repositories_keuangan.dart';

import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';

/// The body of KasUnit (phone) and WebKasUnit (web): the boards share one
/// logic class, handler for handler. [web] puts the `tambah` form in the
/// two-column form row. A new Kas/Bank operated by a unit is added through
/// `AccountRepository.add` from the 1st of M+1 (DL32).
class KasUnitIsi extends ConsumerStatefulWidget {
  const KasUnitIsi({super.key, this.web = false});

  final bool web;

  @override
  ConsumerState<KasUnitIsi> createState() => _KasUnitIsiState();
}

class _KasUnitIsiState extends ConsumerState<KasUnitIsi> {
  String _v = 'daftar';
  final _nama = TextEditingController();
  String? _unit;
  String _pesan = '';
  Refusal? _tolak;

  @override
  void dispose() {
    _nama.dispose();
    super.dispose();
  }

  /// The unit's treasurer in force today, or null.
  String? _bendahara(String scopeId) {
    for (final p in ref.read(roleRepositoryProvider).posts(scopeId: scopeId)) {
      if (p.post.role == Role.bendaharaUnit && p.holder != null) {
        return ref
            .read(peopleRepositoryProvider)
            .person(p.holder!.personId)
            ?.name;
      }
    }
    return null;
  }

  String _alasan() {
    if (_nama.text.trim().isEmpty) return 'nama Kas/Bank belum diisi.';
    if (_unit == null) return 'unit belum dipilih.';
    if (_bendahara(_unit!) == null) {
      final n = ref.read(orgRepositoryProvider).scope(_unit!)?.name ?? '';
      return '$n belum punya bendahara unit.';
    }
    return '';
  }

  /// The board's `ke(v, o)`: a view change clears `pesan`; the body jumps to top.
  void _ke(String v, [VoidCallback? lagi]) {
    setState(() {
      _v = v;
      _pesan = '';
      _tolak = null;
      lagi?.call();
    });
    final p = Scrollable.maybeOf(context)?.position;
    if (p != null && p.hasPixels) p.jumpTo(0);
  }

  void _keTambah() => _ke('tambah', () {
    _nama.clear();
    _unit = null;
  });

  Future<void> _simpan() async {
    final n = _nama.text.trim();
    final unit = _unit!;
    final mulai = ref.read(pengaturanProvider).bulanBerlaku.first;
    final r = await jalankanPengaturan(
      ref,
      (a, k) => ref
          .read(accountRepositoryProvider)
          .add(
            a,
            AccountDraft(
              name: n,
              shortName: n,
              type: n.toLowerCase().startsWith('bank')
                  ? AccountType.bank
                  : AccountType.cash,
              operatedByScopeId: unit,
            ),
            mulai,
            idempotencyKey: k,
          ),
    );
    if (!mounted) return;
    if (r != null) {
      setState(() => _tolak = r);
      return;
    }
    final namaUnit = ref.read(orgRepositoryProvider).scope(unit)?.name ?? '';
    _ke(
      'daftar',
      () => _pesan =
          '$n dikelola oleh $namaUnit, berlaku mulai '
          '${bulanDari(mulai)}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final anak = _v == 'daftar' ? _daftar(c) : _tambah(c);
    return CssLeading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < anak.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            anak[i],
          ],
        ],
      ),
    );
  }

  List<Widget> _daftar(PalakatWarna c) {
    final p = ref.watch(pengaturanProvider);
    // A unit's Kas/Bank: added for a unit, or handed to one.
    final riwayat = [
      for (final r in p.riwayat)
        if ((r.action == 'finance.account.add' && r.after != null) ||
            r.action == 'finance.account.assign_unit')
          '${tgl(r.at)} · ${r.summary}. Oleh ${r.actorLine}.',
    ];
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      for (final k in p.kas)
        if (!k.mati)
          if (k.akun.activeFrom > p.hariIni)
            _kartu(
              c,
              k.akun.name,
              k.akun.operatedByScopeId == null
                  ? 'Dikelola Jemaat'
                  : 'Dikelola oleh ${k.unit ?? ''}',
              'Berlaku mulai ${bulanDari(k.akun.activeFrom)}',
              BentukLencana.draf,
            )
          else
            _kartu(
              c,
              k.akun.name,
              [
                if (k.akun.operatedByScopeId == null)
                  'Dikelola Jemaat'
                else ...[
                  'Dikelola oleh ${k.unit ?? ''}',
                  if (_bendahara(k.akun.operatedByScopeId!) case final b?)
                    'Bendahara: $b',
                ],
              ].join(' · '),
              'Aktif',
              BentukLencana.laut,
            ),
      BarisTombol(
        anak: [
          Tombol(
            'Tambah Kas/Bank unit',
            jenis: JenisTombol.tinta,
            onPressed: _keTambah,
          ),
        ],
      ),
      Text(
        'Bendahara unit membukukan hanya pada Kas/Bank yang dikelola unitnya. '
        'Kas/Bank lain tetap pada Bendahara Jemaat.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
      if (riwayat.isNotEmpty) RiwayatAlur(baris: riwayat),
    ];
  }

  Widget _kartu(
    PalakatWarna c,
    String j,
    String s,
    String l,
    BentukLencana b,
  ) => Kartu(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // KepalaKartu's row, wrapping: a long draf badge ("Berlaku mulai
        // {bulan}") moves under the name instead of overflowing.
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 6,
          children: [
            Text(j, style: const TextStyle(fontWeight: FontWeight.w700)),
            LencanaStatus(l, bentuk: b),
          ],
        ),
        const SizedBox(height: 6),
        Text(s, style: TextStyle(fontSize: 13, color: c.tinta3)),
      ],
    ),
  );

  List<Widget> _tambah(PalakatWarna c) {
    final alasan = _alasan();
    final p = ref.watch(pengaturanProvider);
    final unit = [
      for (final s in ref.watch(orgRepositoryProvider).scopes())
        if (s.active &&
            (s.type == ScopeType.panitia ||
                s.type == ScopeType.komisi ||
                s.type == ScopeType.kolom))
          s,
    ];
    final kiri = [
      _TanpaJarakHuruf(
        child: IsianAlur(
          label: 'Nama Kas/Bank',
          controller: _nama,
          petunjuk: 'Contoh: Kas Panitia Natal',
          onChanged: (_) => setState(() {}),
        ),
      ),
      ChipPilihan<String>(
        label: 'Dikelola oleh',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [for (final u in unit) (nilai: u.id, teks: u.name)],
        terpilih: _unit,
        onPilih: (u) => setState(() {
          _unit = u;
          _pesan = '';
        }),
      ),
      BarisInfo('Berlaku mulai', bulanDari(p.bulanBerlaku.first)),
      Text(
        'Perubahan pengaturan berlaku mulai bulan berikutnya.',
        style: TextStyle(fontSize: 13, color: c.tinta3),
      ),
    ];
    final kanan = [
      if (_tolak != null)
        Penolakan(
          tindakan: _tolak!.action,
          sebab: _tolak!.because,
          jalan: const [],
          ukuranTeks: 14,
        )
      else if ((_nama.text.isNotEmpty || _unit != null) && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Simpan',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Simpan',
            tindakan: 'Simpan',
            alasan: alasan,
            periksa: _alasan,
            sudahMulai: false,
            onPressed: _simpan,
          ),
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _ke('daftar'),
          ),
        ],
      ),
    ];
    if (!widget.web) return [...kiri, ...kanan];
    Widget kolom(List<Widget> a) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < a.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          a[i],
        ],
      ],
    );
    return [
      BarisLentur(
        jarak: 28,
        jarakBaris: 20,
        anak: [
          Lentur(dasar: 420, tumbuh: 1.3, child: kolom(kiri)),
          Lentur(dasar: 340, child: kolom(kanan)),
        ],
      ),
    ];
  }
}

/// CSS half-leading: the boards split a line's extra height evenly above and
/// below the glyphs; Flutter's default puts more above (text 1–2 px low).
class CssLeading extends StatelessWidget {
  const CssLeading({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(leadingDistribution: TextLeadingDistribution.even),
    child: child,
  );
}

/// The M3 TextField takes `bodyLarge` (letter-spacing 0.5) under its text and
/// placeholder; the board's input has none.
class _TanpaJarakHuruf extends StatelessWidget {
  const _TanpaJarakHuruf({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Theme(
      data: t.copyWith(
        textTheme: t.textTheme.copyWith(
          bodyLarge: t.textTheme.bodyLarge?.copyWith(letterSpacing: 0),
        ),
      ),
      child: child,
    );
  }
}
