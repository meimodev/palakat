import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_modul.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'inti_bagian.dart';

/// The tasks a post holder may delegate, by the capability their post gives
/// (PMP 5): the label is followed by the unit's name.
const _tugas = {
  Capability.membershipVerify: 'Verifikasi data',
  Capability.servicesApprove: 'Menyetujui jadwal ibadah',
};

/// 50 · Pelimpahan tugas + 55 · Alur (screens/14, screens/15; phone only):
/// the delegations from and to the signed-in person (RoleRepository), and a
/// new one through `delegate`: one task, one unit, an end date after today;
/// it ends by itself on that date.
class PelimpahanScreen extends ConsumerStatefulWidget {
  const PelimpahanScreen({super.key});

  @override
  ConsumerState<PelimpahanScreen> createState() => _PelimpahanScreenState();
}

class _PelimpahanScreenState extends ConsumerState<PelimpahanScreen> {
  final _sampai = TextEditingController();
  var _form = false;
  String? _kepada;
  DelegatedTask? _tugasDipilih;
  String _pesan = '';
  Refusal? _tolak;

  @override
  void dispose() {
    _sampai.dispose();
    super.dispose();
  }

  Tanggal get _hari => ref.read(hariIniProvider);

  void _lihat(bool form, [VoidCallback? ubah]) {
    setState(() {
      ubah?.call();
      _form = form;
      _tolak = null;
    });
    keAtas(context);
  }

  String _nama(String id) =>
      ref.read(peopleRepositoryProvider).person(id)?.name ?? '—';

  String _syarat() {
    final actor = ref.read(actorProvider);
    if (_kepada == null) return 'penerima belum dipilih.';
    if (_kepada == actor?.personId) {
      return 'tugas tidak dapat dilimpahkan kepada diri sendiri.';
    }
    if (_tugasDipilih == null) return 'tugas belum dipilih.';
    if (_sampai.text.trim().isEmpty) return 'tanggal berakhir belum diisi.';
    final t = tanggalKetik(_sampai.text);
    if (t == null) {
      return 'tanggal berakhir tidak dikenali. Contoh: ${_hari.tambahHari(14)}.';
    }
    if (t <= _hari) return 'tanggal berakhir harus setelah hari ini ($_hari).';
    return '';
  }

  Future<void> _buat() async {
    final actor = ref.read(actorProvider);
    if (actor == null) return;
    final r = await ref
        .read(roleRepositoryProvider)
        .delegate(
          actor,
          _tugasDipilih!,
          _kepada!,
          _hari,
          tanggalKetik(_sampai.text)!,
          idempotencyKey: kunciInti(ref),
        );
    if (!mounted) return;
    if (r.refusal case final t?) return setState(() => _tolak = t);
    _lihat(false, () {
      _pesan = '${_nama(_kepada!)} diberi tahu lewat Pemberitahuan.';
    });
  }

  Future<void> _akhiri(Delegation d) async {
    final actor = ref.read(actorProvider);
    if (actor == null) return;
    final r = await ref
        .read(roleRepositoryProvider)
        .endDelegation(
          actor,
          d.id,
          expectedRevision: d.revision,
          idempotencyKey: kunciInti(ref),
        );
    if (!mounted) return;
    setState(() {
      _pesan = r.refusal == null
          ? '${d.task.label} kembali hanya kepada ${_nama(actor.personId)}.'
          : '${r.refusal!.action}: ${r.refusal!.because}';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final actor = ref.watch(actorProvider);
    final isi = actor == null
        ? const <Widget>[]
        : _form
        ? _isiForm(actor)
        : _daftar(actor);
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pelimpahan tugas',
            anakJudul: 'Bertanggal, terbatas pada satu unit, berakhir sendiri',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: susun(isi),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _daftar(Actor actor) {
    final hari = ref.watch(hariIniProvider);
    final role = ref.watch(roleRepositoryProvider);
    final semua = role.delegations(personId: actor.personId).reversed.toList();
    final riwayat = [
      for (final a
          in ref
              .watch(auditRepositoryProvider)
              .list(const AuditFilter(actionPrefix: 'role.delegate')))
        if (a.personId == actor.personId)
          '${tgl(a.at)} · ${a.summary} · ${a.actorLine}',
    ];
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (semua.isEmpty)
        const KotakKosong(
          'Belum ada pelimpahan',
          teks:
              'Limpahkan satu tugas kepada pelayan lain bila Anda berhalangan. '
              'Pelimpahan selalu punya tanggal berakhir.',
        ),
      for (final d in semua) _kartu(d, actor, hari),
      BarisTombol(
        anak: [
          Tombol(
            'Buat pelimpahan',
            jenis: JenisTombol.tinta,
            onPressed: () => _lihat(true, () {
              _pesan = '';
              _kepada = null;
              _tugasDipilih = null;
              _sampai.clear();
            }),
          ),
        ],
      ),
      const Catatan(
        'Pelimpahan tugas administrasi tidak memindahkan wewenang. Setiap '
        'tindakan mencatat pelaku, jabatan yang dijalankan, unit, atas nama '
        'siapa dan waktunya.',
      ),
      RiwayatAlur(baris: riwayat),
    ];
  }

  Widget _kartu(Delegation d, Actor actor, Tanggal hari) {
    final dari = d.fromAssignmentId == null
        ? null
        : ref
              .read(roleRepositoryProvider)
              .assignmentsOf(d.fromPersonId)
              .where((a) => a.id == d.fromAssignmentId)
              .firstOrNull;
    final pos = dari == null
        ? _nama(d.fromPersonId)
        : ref
                  .read(roleRepositoryProvider)
                  .posts()
                  .where((p) => p.post.id == dari.postId)
                  .firstOrNull
                  ?.post
                  .title ??
              _nama(d.fromPersonId);
    final aktif = d.inForce(hari);
    final belum = hari < d.start;
    final Widget lencana = aktif
        ? const LencanaModul.jabatan(KeadaanJabatan.aktif)
        : belum
        ? const LencanaStatus('Terjadwal', bentuk: BentukLencana.garis)
        : const LencanaModul.jabatan(KeadaanJabatan.berakhir);
    final catatan = d.endedAt != null && !aktif
        ? 'Diakhiri ${d.end} oleh ${_nama(d.fromPersonId)}'
        : !aktif && !belum
        ? 'Berakhir sendiri pada tanggalnya.'
        : d.fromPersonId == actor.personId
        ? 'Dilimpahkan oleh ${_nama(d.fromPersonId)}. Berlaku sampai ${d.end} '
              '· berakhir sendiri pada tanggalnya.'
        : 'Dari ${_nama(d.fromPersonId)}. Anda dapat menjalankan tugas ini '
              'sampai ${d.end}.';
    return Kartu(
      child: susun([
        KepalaKartu(judul: '$pos → ${_nama(d.toPersonId)}', ujung: lencana),
        Baris2('${d.task.label} · ${d.start} sampai ${d.end}'),
        Catatan(catatan),
        if (aktif && d.fromPersonId == actor.personId)
          BarisTombol(
            anak: [
              Tombol(
                'Akhiri sekarang',
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.kecil,
                onPressed: () => _akhiri(d),
              ),
            ],
          ),
      ], jarak: 6),
    );
  }

  List<Widget> _isiForm(Actor actor) {
    final hari = ref.watch(hariIniProvider);
    final can = ref.watch(canProvider);
    final role = ref.watch(roleRepositoryProvider);
    final org = ref.watch(orgRepositoryProvider);
    final milik = [
      for (final g in can.grantsOf(actor.personId, at: hari))
        if (g.kind == GrantKind.assignment) g,
    ];
    final lingkup = {for (final g in milik) g.scopeId};
    final kepada = <String>{
      for (final p in role.posts())
        if (lingkup.contains(p.post.scopeId))
          if (p.holder case final h?)
            if (h.personId != actor.personId) h.personId,
      actor.personId,
    }.toList();
    final tugas = [
      for (final g in milik)
        for (final e in _tugas.entries)
          if (g.capabilities.contains(e.key))
            DelegatedTask(
              capability: e.key,
              scopeId: g.scopeId,
              label: '${e.value} ${org.scope(g.scopeId)?.name ?? ''}',
            ),
    ];
    final alasan = _syarat();
    return [
      GrupChip(
        label: 'Dilimpahkan kepada',
        pilihan: [for (final id in kepada) _nama(id)],
        terpilih: _kepada == null ? null : kepada.indexOf(_kepada!),
        onPilih: (i) => setState(() {
          _kepada = kepada[i];
          _pesan = '';
          _tolak = null;
        }),
      ),
      GrupChip(
        label: 'Tugas',
        pilihan: [for (final t in tugas) t.label],
        terpilih: _tugasDipilih == null
            ? null
            : tugas.indexWhere((t) => t.label == _tugasDipilih!.label),
        onPilih: (i) => setState(() {
          _tugasDipilih = tugas[i];
          _pesan = '';
          _tolak = null;
        }),
      ),
      IsianAlur(
        label: 'Berlaku sampai',
        controller: _sampai,
        onChanged: (_) => setState(() => _tolak = null),
        petunjuk: 'hh/bb/tttt',
        keterangan: 'Wajib. Pelimpahan berakhir sendiri pada tanggal ini.',
        keyboard: TextInputType.datetime,
      ),
      if (_tolak case final t?)
        Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
      TombolBersyarat(
        label: 'Buat pelimpahan',
        tindakan: 'Buat pelimpahan',
        alasan: alasan,
        periksa: _syarat,
        sudahMulai:
            _kepada != null || _tugasDipilih != null || _sampai.text.isNotEmpty,
        onPressed: _buat,
        baris: [
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _lihat(false, () => _pesan = ''),
          ),
        ],
      ),
    ];
  }
}
