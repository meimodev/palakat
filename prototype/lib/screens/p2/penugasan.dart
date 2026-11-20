import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_modul.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'inti_bagian.dart';

/// 48 · Penugasan jabatan + 53 · Alur · Penugasan jabatan (screens/14,
/// screens/15): the posts from RoleRepository, "Tugaskan" and "Catat
/// berakhir" run `assign` and `endTerm`. The authorized church officer
/// records every assignment (DL21); the Bendahara and Sekretaris wait for the
/// Petugas verifikasi (DP39).
class PenugasanScreen extends StatelessWidget {
  const PenugasanScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Penugasan jabatan',
          anakJudul: 'Siapa memegang jabatan apa, di unit mana, sejak kapan',
          kembaliKe: Layar.beranda,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: const IsiPenugasan(),
          ),
        ),
      ],
    ),
  );
}

enum _Tampil { daftar, tugaskan, akhiri }

const _belumAdaDokumen = 'Belum ada dokumen';

const _catatanVerifikasi =
    'Penunjukan Bendahara Jemaat dan Sekretaris Jemaat diperiksa Petugas '
    'verifikasi terhadap keputusan tertulis gereja sebelum wewenangnya aktif. '
    'Akses teknis saja tidak memberi wewenang.';

/// The body shared by PenugasanScreen and WebPenugasanScreen.
class IsiPenugasan extends ConsumerStatefulWidget {
  const IsiPenugasan({super.key, this.web = false});
  final bool web;

  @override
  ConsumerState<IsiPenugasan> createState() => _IsiPenugasanState();
}

class _IsiPenugasanState extends ConsumerState<IsiPenugasan> {
  final _orang = TextEditingController();
  final _mulai = TextEditingController();
  final _akhir = TextEditingController();
  final _alasan = TextEditingController();
  var _tampil = _Tampil.daftar;
  String? _postId, _orangId;
  String _pesan = '';
  String _dok = '';
  Refusal? _tolak;

  @override
  void dispose() {
    for (final c in [_orang, _mulai, _akhir, _alasan]) {
      c.dispose();
    }
    super.dispose();
  }

  Tanggal get _hari => ref.read(hariIniProvider);

  void _ke(_Tampil t, [VoidCallback? ubah]) {
    setState(() {
      ubah?.call();
      _tampil = t;
      _tolak = null;
    });
    keAtas(context);
  }

  void _bukaTugaskan(PostView p) => _ke(_Tampil.tugaskan, () {
    _postId = p.post.id;
    _pesan = '';
    final h = p.handover;
    final orang = h == null
        ? null
        : ref.read(peopleRepositoryProvider).person(h.toPersonId);
    _orangId = orang?.id;
    _orang.text = orang?.name ?? '';
    _dok = h?.documentRef ?? '';
    _mulai.text = '$_hari';
  });

  void _bukaAkhiri(PostView p) => _ke(_Tampil.akhiri, () {
    _postId = p.post.id;
    _pesan = '';
    _akhir.text = '$_hari';
    _alasan.clear();
  });

  void _keDaftar(String pesan) => _ke(_Tampil.daftar, () {
    _pesan = pesan;
    _orang.clear();
    _dok = '';
    _orangId = null;
  });

  // ---------- Tugaskan ----------

  String _alasanTugas() {
    final o = _orang.text.trim();
    if (o.isEmpty) return 'orang belum diisi.';
    if (_orangId == null) return 'pilih orangnya dari Data jemaat.';
    if (_orangId == ref.read(actorProvider)?.personId) {
      return 'Anda tidak dapat menugaskan jabatan kepada diri sendiri.';
    }
    final t = tanggalKetik(_mulai.text);
    if (t == null) return 'tanggal mulai tidak dikenali. Contoh: $_hari.';
    if (_hari < t) {
      return 'tanggal mulai belum tiba. Penugasan dicatat pada atau setelah '
          'tanggal mulainya.';
    }
    if (_dok.isEmpty) return 'keputusan gereja belum dipilih.';
    if (_dok == _belumAdaDokumen) {
      return 'penugasan memerlukan keputusan tertulis gereja di Dokumen '
          'gereja.';
    }
    return '';
  }

  Future<void> _tugaskan(PostView p) async {
    final actor = ref.read(actorProvider);
    final orang = ref.read(peopleRepositoryProvider).person(_orangId!);
    if (actor == null || orang == null) return;
    final mulai = tanggalKetik(_mulai.text)!;
    final dok = _dok;
    final r = await ref
        .read(roleRepositoryProvider)
        .assign(
          actor,
          p.post.id,
          orang.id,
          mulai,
          documentRef: dok,
          expectedRevision: p.post.revision,
          idempotencyKey: kunciInti(ref),
        );
    if (!mounted) return;
    if (r.refusal case final t?) return setState(() => _tolak = t);
    _keDaftar(
      p.post.role.needsAuthority
          ? '${p.post.title}: penugasan ${orang.name} dicatat. Menunggu '
                'verifikasi wewenang.'
          : '${p.post.title} dipegang ${orang.name} sejak $mulai. '
                'Keputusan: $dok.',
    );
  }

  // ---------- Catat berakhir ----------

  String _alasanAkhir(Assignment a) {
    if (_alasan.text.trim().isEmpty) return 'alasan belum diisi.';
    final t = tanggalKetik(_akhir.text);
    if (t == null) return 'tanggal berakhir tidak dikenali. Contoh: $_hari.';
    if (t < a.start) return 'tanggal berakhir sebelum tanggal mulai.';
    return '';
  }

  Future<void> _akhiri(PostView p) async {
    final actor = ref.read(actorProvider);
    final a = p.holder;
    if (actor == null || a == null) return;
    final akhir = tanggalKetik(_akhir.text)!;
    final r = await ref
        .read(roleRepositoryProvider)
        .endTerm(
          actor,
          a.id,
          akhir,
          reason: _alasan.text.trim(),
          expectedRevision: a.revision,
          idempotencyKey: kunciInti(ref),
        );
    if (!mounted) return;
    if (r.refusal case final t?) return setState(() => _tolak = t);
    final nama = ref.read(peopleRepositoryProvider).person(a.personId)?.name;
    _keDaftar(
      akhir <= _hari
          ? '${p.post.title}: penugasan $nama berakhir $akhir. Jabatan ini '
                'menjadi Jabatan kosong.'
          : '${p.post.title}: penugasan $nama berakhir $akhir.',
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final posts = ref.watch(roleRepositoryProvider).posts();
    final p = posts.where((x) => x.post.id == _postId).firstOrNull;
    final isi = switch (_tampil) {
      _Tampil.tugaskan when p != null => _formTugaskan(p),
      _Tampil.akhiri when p?.holder != null => _formAkhiri(p!),
      _ => _daftar(posts),
    };
    return susun(isi);
  }

  String _nama(String id) =>
      ref.read(peopleRepositoryProvider).person(id)?.name ?? '—';

  String _unit(String scopeId) =>
      ref.read(orgRepositoryProvider).scope(scopeId)?.name ?? '';

  List<Widget> _daftar(List<PostView> posts) {
    final actor = ref.watch(actorProvider);
    final riwayat = [
      for (final a
          in ref
              .watch(auditRepositoryProvider)
              .list(const AuditFilter(actionPrefix: 'role.')))
        '${tgl(a.at)} · ${a.summary} · ${a.actorLine}',
    ];
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          for (final p in posts) _kartu(p, actor),
          for (final p in posts)
            if (p.lastHolder case final a?) _kartuBerakhir(p, a),
        ],
      ),
      const Catatan(
        'Penugasan mencatat keputusan gereja; keputusannya sendiri ada di '
        'Dokumen gereja, bukan persetujuan di aplikasi.',
      ),
      RiwayatAlur(baris: riwayat),
    ];
  }

  Widget _kartu(PostView p, Actor? actor) {
    final h = p.holder, w = p.pending, cover = p.cover, serah = p.handover;
    final kosong = h == null;
    final lencana = LencanaModul.jabatan(
      kosong ? KeadaanJabatan.jabatanKosong : KeadaanJabatan.aktif,
    );
    final catatan = [
      if (h != null)
        p.post.role.needsAuthority
            ? 'Aktif sejak ${h.start} · wewenang sudah diverifikasi'
            : 'Sejak ${h.start}'
      else if (cover != null)
        'Dijalankan Operator ${_nama(cover.personId)} sejak ${cover.start}'
      else
        'Belum ada yang menjalankan',
      if (serah != null && w == null)
        'Serah terima kepada ${_nama(serah.toPersonId)} disiapkan '
            '${tgl(serah.createdAt)} · ${serah.documentRef}',
      if (w != null) ...[
        '${_nama(w.personId)} · dicatat ${tgl(w.recordedAt!)}',
        _catatanVerifikasi,
      ],
    ];
    final tugaskan = w == null && (kosong || serah != null);
    final akhiri = w == null && h != null && h.personId != actor?.personId;
    return Kartu(
      status: kosong ? GarisStatus.draf : GarisStatus.dibukukan,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: susun([
        // The long badge takes its own line: at phone width it does not fit
        // beside the title (screens/14 Notes).
        KepalaKartu(judul: p.post.title, ujung: w == null ? lencana : null),
        if (w != null)
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: LencanaStatus(
              'Menunggu verifikasi wewenang',
              bentuk: BentukLencana.draf,
            ),
          ),
        Text(h == null ? '—' : _nama(h.personId)),
        for (final c in catatan) Catatan(c),
        if (tugaskan)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tombol(
              'Tugaskan',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              lebarPenuh: false,
              onPressed: () => _bukaTugaskan(p),
            ),
          ),
        if (akhiri)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tombol(
              'Catat berakhir',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              lebarPenuh: false,
              onPressed: () => _bukaAkhiri(p),
            ),
          ),
      ], jarak: 4),
    );
  }

  Widget _kartuBerakhir(PostView p, Assignment a) => Kartu(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: susun([
      KepalaKartu(
        judul: p.post.title,
        ujung: const LencanaModul.jabatan(KeadaanJabatan.berakhir),
      ),
      Text(_nama(a.personId)),
      Catatan('${a.start} – ${a.end ?? _hari}'),
    ], jarak: 4),
  );

  Widget _ringkas(PostView p, List<(String, String)> lain) => Kartu(
    child: susun([
      BarisInfo('Jabatan', p.post.title),
      BarisInfo('Unit', _unit(p.post.scopeId)),
      for (final (k, v) in lain) BarisInfo(k, v),
    ], jarak: 6),
  );

  Widget _baris(List<Widget> anak) => widget.web
      ? BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(dasar: 420, tumbuh: 1.3, child: susun(anak.sublist(0, 1))),
            Lentur(dasar: 340, child: susun(anak.sublist(1), jarak: 12)),
          ],
        )
      : susun(anak);

  List<Widget> _formTugaskan(PostView p) {
    final actor = ref.watch(actorProvider);
    final kata = _orang.text.trim();
    final saran = kata.isEmpty
        ? [
            if (p.handover case final h?)
              ?ref.read(peopleRepositoryProvider).person(h.toPersonId),
          ]
        : ref.read(peopleRepositoryProvider).search(kata).take(4).toList();
    // The handover's document, else the published assignment decisions
    // of Dokumen gereja (M6-R7).
    // ponytail: a document has no subject field, so "Penugasan" in the
    // title marks an assignment decision; add one when documents get it.
    final dokumen = [
      if (p.handover case final h?)
        h.documentRef
      else
        for (final d in ref.watch(documentRepositoryProvider).list())
          if (d.kind == DocumentKind.decision && d.title.contains('Penugasan'))
            d.title,
      _belumAdaDokumen,
    ];
    final alasan = _alasanTugas();
    final mulai = _orang.text.isNotEmpty || _dok.isNotEmpty;
    final nama = actor == null ? '' : _nama(actor.personId);
    return [
      _baris([
        susun([
          _ringkas(p, [
            if (p.holder case final h?) ('Pemegang', _nama(h.personId)),
          ]),
          IsianAlur(
            label: 'Orang',
            controller: _orang,
            onChanged: (v) => setState(() {
              final cocok = ref
                  .read(peopleRepositoryProvider)
                  .search(v.trim())
                  .where((o) => o.name == v.trim())
                  .firstOrNull;
              _orangId = cocok?.id;
              _tolak = null;
            }),
            petunjuk: 'Nama orang',
            keterangan: 'Ketik nama, atau pilih di bawah.',
          ),
          if (saran.isNotEmpty)
            GrupChip(
              label: 'Dari Data jemaat',
              pilihan: [for (final o in saran) o.name],
              terpilih: saran.indexWhere((o) => o.id == _orangId),
              onPilih: (i) => setState(() {
                _orang.text = saran[i].name;
                _orangId = saran[i].id;
                _tolak = null;
              }),
            ),
          IsianAlur(
            label: 'Mulai',
            controller: _mulai,
            onChanged: (_) => setState(() => _tolak = null),
            petunjuk: 'hh/bb/tttt',
            keterangan: 'Tanggal, bulan, tahun. Contoh: $_hari.',
            keyboard: TextInputType.datetime,
          ),
          GrupChip(
            label: 'Keputusan gereja',
            pilihan: dokumen,
            terpilih: dokumen.indexOf(_dok),
            onPilih: (i) => setState(() {
              _dok = dokumen[i];
              _tolak = null;
            }),
          ),
        ], jarak: 12),
        Catatan(
          'Dicatat oleh $nama, Pimpinan Jemaat yang berwenang. Penugasan '
          'bukan persetujuan di aplikasi; keputusannya ada di dokumen.',
        ),
        if (p.post.role.needsAuthority) const Catatan(_catatanVerifikasi),
        if (_tolak case final t?)
          Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
        TombolBersyarat(
          label: 'Catat penugasan',
          tindakan: 'Catat penugasan',
          alasan: alasan,
          periksa: _alasanTugas,
          sudahMulai: mulai,
          onPressed: () => _tugaskan(p),
          baris: [
            Tombol(
              'Batalkan',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              onPressed: () => _keDaftar(''),
            ),
          ],
        ),
      ]),
    ];
  }

  List<Widget> _formAkhiri(PostView p) {
    final a = p.holder!;
    final alasan = _alasanAkhir(a);
    return [
      _baris([
        susun([
          _ringkas(p, [
            ('Pemegang', _nama(a.personId)),
            ('Sejak', '${a.start}'),
          ]),
          IsianAlur(
            label: 'Berakhir',
            controller: _akhir,
            onChanged: (_) => setState(() => _tolak = null),
            petunjuk: 'hh/bb/tttt',
            keterangan: 'Hari terakhir masa jabatan. Contoh: $_hari.',
            keyboard: TextInputType.datetime,
          ),
          IsianAlur(
            label: 'Alasan · wajib',
            controller: _alasan,
            onChanged: (_) => setState(() => _tolak = null),
            baris: 3,
          ),
        ], jarak: 12),
        const Catatan(
          'Begitu masa jabatan berakhir, jabatan ini menjadi Jabatan kosong '
          'dan semua sesi yang bertindak dalam jabatan ini diakhiri.',
        ),
        if (_tolak case final t?)
          Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
        TombolBersyarat(
          label: 'Catat berakhir',
          tindakan: 'Catat berakhir',
          alasan: alasan,
          periksa: () => _alasanAkhir(a),
          sudahMulai: _alasan.text.isNotEmpty,
          onPressed: () => _akhiri(p),
          baris: [
            Tombol(
              'Batalkan',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              onPressed: () => _keDaftar(''),
            ),
          ],
        ),
      ]),
    ];
  }
}
