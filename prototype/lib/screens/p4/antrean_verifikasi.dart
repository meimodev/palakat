import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'jemaat_bagian.dart';

/// 75 · Verifikasi data (spec 20): the actor's queue
/// (`VerificationRepository.queue`), routed by the posts, delegations and
/// covers in force. Applications, life events and family confirmations open
/// their own screen; a data change is decided here.
class AntreanVerifikasiScreen extends ConsumerStatefulWidget {
  const AntreanVerifikasiScreen({super.key});

  @override
  ConsumerState<AntreanVerifikasiScreen> createState() => _State();
}

enum _Mode { lihat, kembali, tolak }

class _State extends ConsumerState<AntreanVerifikasiScreen> {
  final _alasan = TextEditingController();
  String? _dipilih;
  _Mode _mode = _Mode.lihat;
  String _pesan = '';
  Refusal? _tolakan;

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  void _ke(String? id, [_Mode mode = _Mode.lihat]) => setState(() {
    _dipilih = id;
    _mode = mode;
    _tolakan = null;
    _alasan.clear();
    if (id != null) _pesan = '';
  });

  Future<void> _putuskan(VerificationItem i, _Mode mode) async {
    final repo = ref.read(verificationRepositoryProvider);
    final judul = ref.read(namaJemaatProvider).judul(i);
    final r = await jalankanJemaat(
      ref,
      (a, k) => switch (mode) {
        _Mode.kembali => repo.returnForChanges(
          a,
          i.id,
          reason: _alasan.text,
          expectedRevision: i.revision,
          idempotencyKey: k,
        ),
        _Mode.tolak => repo.decline(
          a,
          i.id,
          reason: _alasan.text,
          expectedRevision: i.revision,
          idempotencyKey: k,
        ),
        _Mode.lihat => repo.verify(
          a,
          i.id,
          expectedRevision: i.revision,
          idempotencyKey: k,
        ),
      },
    );
    if (!mounted || r == null) return;
    if (r.refusal != null) {
      setState(() => _tolakan = r.refusal);
      return;
    }
    _ke(null);
    setState(
      () => _pesan = switch (mode) {
        _Mode.kembali => '$judul dikembalikan.',
        _Mode.tolak => '$judul tidak diterima.',
        _Mode.lihat => '$judul diverifikasi.',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(actorProvider);
    final nama = ref.watch(namaJemaatProvider);
    final hari = ref.watch(hariIniProvider);
    final can = ref.watch(canProvider);
    if (a == null) return const SizedBox.shrink();
    final antre = ref.watch(verificationRepositoryProvider).queue(a);
    // The Kolom the actor verifies (an Operator's Jemaat-wide fallback is
    // not one).
    final hak = can
        .grantsFor(
          a.personId,
          Capability.membershipVerify,
          ScopeRef.anywhere,
          at: hari,
        )
        .where((g) => g.scopeId != ScopeRef.jemaatId)
        .toList();
    final kolom = {for (final g in hak) nama.kolom(g.scopeId)}.join(', ');
    final terpilih = antre.where((e) => e.item.id == _dipilih).firstOrNull;
    return KerangkaJemaat(
      judul: 'Verifikasi data',
      anakJudul: 'Hanya data $kolom; milik keluarga sendiri pergi ke Syamas',
      tampilan: (_dipilih, _mode),
      blok: terpilih == null
          ? _antrean(antre, hak, kolom, nama)
          : _rinci(terpilih, nama),
    );
  }

  List<Widget> _antrean(
    List<QueueEntry> antre,
    List<Grant> hak,
    String kolom,
    NamaJemaat nama,
  ) {
    final c = context.warna;
    final keterangan = TextStyle(fontSize: 13, color: c.tinta3);
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      for (final g in hak.where((g) => g.kind == GrantKind.cover))
        _PitaKosong(
          judul: '${g.title}: jabatan kosong.',
          isi:
              ' Verifikasi ${nama.kolom(g.scopeId)} dijalankan Operator '
              '${nama.orang(g.personId)} sampai ada pemegang jabatan.',
        ),
      if (antre.isEmpty)
        kotakKosong(
          context,
          'Permohonan, perubahan data dan peristiwa dari $kolom akan muncul '
          'di sini.',
        ),
      for (final e in antre) _baris(e, nama),
      if (hak.any((g) => g.kind == GrantKind.assignment))
        Text(
          'Anda melihat data lengkap hanya untuk anggota dan keluarga '
          '$kolom, serta permohonan pindah ke $kolom.',
          style: keterangan,
        ),
    ];
  }

  Widget _baris(QueueEntry e, NamaJemaat nama) {
    final i = e.item;
    final diajukan = tgl(i.submittedAt);
    final kolom = nama.kolom(i.scopeId);
    const lencana = LencanaStatus('Diajukan', bentuk: BentukLencana.garis);
    final judul = nama.judul(i);
    if (e.blocked != null) {
      final syamas = e.forwardedTo == null
          ? null
          : ref
                .read(canProvider)
                .grantsOf(e.forwardedTo!, at: ref.read(hariIniProvider))
                .where((g) => g.kind == GrantKind.assignment)
                .map((g) => g.title)
                .firstOrNull;
      return _Baris(
        judul,
        syamas == null
            ? 'Milik keluarga Anda sendiri'
            : 'Milik keluarga Anda sendiri · diteruskan ke $syamas',
        LencanaStatus(
          syamas == null ? 'Keluarga sendiri' : 'Ke Syamas',
          bentuk: BentukLencana.abu,
        ),
        onTap: () => _ke(i.id),
      );
    }
    final ev = i.event;
    final ket = switch (i.kind) {
      ItemKind.application =>
        '$kolom · diajukan $diajukan · izin data pribadi diberikan',
      ItemKind.household =>
        '${ref.read(memberRepositoryProvider).household(i.householdId!)?.memberIds.length ?? 0} '
            'orang dari buku anggota',
      ItemKind.lifeEvent when ev!.kind == LifeEventKind.kolomMove =>
        'Dari ${nama.kolom(ev.fromKolomId!)} ke ${nama.kolom(ev.toKolomId!)} '
            '· berlaku ${tgl(ev.effective!.awal)}',
      ItemKind.lifeEvent when ev!.kind == LifeEventKind.death =>
        '$kolom · diajukan keluarga $diajukan',
      _ => 'Diajukan $diajukan',
    };
    return _Baris(
      judul,
      ket,
      lencana,
      onTap: () {
        switch (i.kind) {
          case ItemKind.application:
            context.dorongKe(Layar.permohonanAnggota, param: {'id': i.id});
          case ItemKind.lifeEvent:
            ref.read(peristiwaDipilihProvider.notifier).pilih(i.id);
            context.dorongKe(Layar.peristiwa);
          case ItemKind.household
              when ref.read(penjagaProvider(Layar.konfirmasiKeluarga)) == null:
            ref.read(keluargaDipilihProvider.notifier).pilih(i.householdId);
            context.dorongKe(Layar.konfirmasiKeluarga);
          // A verifier by delegation does not confirm families: decided here.
          case ItemKind.household:
            _ke(i.id);
          case ItemKind.dataChange:
            _ke(i.id);
        }
      },
    );
  }

  /// "Kolom 7 · 4 orang: Ferry, Agustina, Novita, Gabriel".
  String _anggotaKeluarga(VerificationItem i, NamaJemaat nama) {
    final h = ref.read(memberRepositoryProvider).household(i.householdId!);
    final orang = h?.memberIds ?? const <String>[];
    return '${nama.kolom(i.scopeId)} · ${orang.length} orang: '
        '${orang.map((p) => nama.orang(p).split(' ').first).join(', ')}';
  }

  /// A data change, decided here (the board's k1 and k2 views); a family
  /// confirmation too for a verifier who may not open KonfirmasiKeluarga.
  List<Widget> _rinci(QueueEntry e, NamaJemaat nama) {
    final c = context.warna;
    final i = e.item;
    final judul = nama.judul(i);
    final kepala = kartuAlur([
      KepalaKartu(judul: judul, ujung: lencanaSt('Diajukan')),
      Text(
        'Diajukan ${nama.orang(i.submittedBy)}, ${tgl(i.submittedAt)}',
        style: TextStyle(fontSize: 14, color: c.tinta2),
      ),
      if (i.change != null) BarisInfo('Perubahan', i.change!),
      if (i.kind == ItemKind.household) ...[
        BarisInfo('Keluarga', _anggotaKeluarga(i, nama)),
        if (i.paperForm != null) BarisInfo('Formulir', i.paperForm!),
      ],
    ]);
    final kembali = Align(
      alignment: Alignment.centerLeft,
      child: Tombol(
        'Kembali ke antrean',
        onPressed: () => _ke(null),
        jenis: JenisTombol.teks,
        ukuran: UkuranTombol.kecil,
        lebarPenuh: false,
      ),
    );
    if (e.blocked != null) {
      final ke = e.forwardedTo;
      final jabatan = ke == null
          ? null
          : ref
                .read(canProvider)
                .grantsOf(ke, at: ref.read(hariIniProvider))
                .where((g) => g.kind == GrantKind.assignment)
                .map((g) => g.title)
                .firstOrNull;
      return [
        kepala,
        Penolakan(tindakan: 'Verifikasi data', sebab: e.blocked!, jalan: []),
        Text(
          '${ke == null ? '' : 'Diteruskan kepada ${nama.orang(ke)}'
                    '${jabatan == null ? '' : ', $jabatan'}. '}'
          'Mengisi sendiri bukan berarti memverifikasi sendiri.',
          style: TextStyle(fontSize: 13, color: c.tinta3),
        ),
        kembali,
      ];
    }
    if (_mode != _Mode.lihat) {
      final tindakan = _mode == _Mode.kembali ? 'Kembalikan' : 'Tidak diterima';
      return [
        ...formAlasan(
          judul: judul,
          tindakan: tindakan,
          alasan: _alasan,
          onUbah: () => setState(() {}),
          kirim: () => _putuskan(i, _mode),
          batal: () => _ke(i.id),
        ),
        ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
      ];
    }
    return [
      kepala,
      keteranganAlur(context, hanyaKolom(nama.kolom(i.scopeId))),
      ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
      tombolPenatua(
        verif: () => _putuskan(i, _Mode.lihat),
        keKembali: () => _ke(i.id, _Mode.kembali),
        keTolak: () => _ke(i.id, _Mode.tolak),
      ),
      kembali,
    ];
  }
}

/// The dark vacancy band of a covered Penatua post.
class _PitaKosong extends StatelessWidget {
  const _PitaKosong({required this.judul, required this.isi});
  final String judul, isi;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: c.tinta,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: judul,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(
              text: isi,
              style: TextStyle(color: c.diTinta2),
            ),
          ],
        ),
        style: TextStyle(fontSize: 14, color: c.permukaan),
      ),
    );
  }
}

/// Row card: a full-width target, title 16/600, caption 13 `tinta3`, badge,
/// chevron 18.
class _Baris extends StatelessWidget {
  const _Baris(
    this.judul,
    this.keterangan,
    this.lencana, {
    required this.onTap,
  });

  final String judul, keterangan;
  final Widget lencana;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onTap,
      radius: 14,
      peran: PeranTekan.tautan,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.permukaan,
          border: Border.all(color: c.garis),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    keterangan,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
            lencana,
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}
