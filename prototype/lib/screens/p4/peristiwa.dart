import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../shell/tautan.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'jemaat_bagian.dart';

/// The kinds a member reports here (AlurPeristiwa), and the letter each
/// needs.
const _jenis = {
  LifeEventKind.baptism: 'surat-baptis.jpg',
  LifeEventKind.sidi: 'piagam-sidi.jpg',
  LifeEventKind.marriage: 'surat-nikah.jpg',
};

/// 77 · Peristiwa + 83 · AlurPeristiwa (spec 20, 21): a member reports a life
/// event of their family with its letter; the verifier of the Kolom opens it
/// from AntreanVerifikasi and verifies it or returns it with a reason. Data
/// jemaat changes only once it is verified.
class PeristiwaScreen extends ConsumerStatefulWidget {
  const PeristiwaScreen({super.key});

  @override
  ConsumerState<PeristiwaScreen> createState() => _PeristiwaScreenState();
}

class _PeristiwaScreenState extends ConsumerState<PeristiwaScreen> {
  final _tanggal = TextEditingController();
  final _alasan = TextEditingController();
  LifeEventKind? _kind;
  String? _untuk;
  String? _file;
  bool _sentuh = false, _kembali = false;
  String _pesan = '';
  Refusal? _tolakan;

  @override
  void initState() {
    super.initState();
    // "Ubah dan ajukan lagi": a returned event's values, without the letter.
    final a = ref.read(actorProvider);
    final lama = a == null
        ? null
        : ref
              .read(applicationRepositoryProvider)
              .submittedBy(a.personId)
              .where(
                (i) =>
                    i.kind == ItemKind.lifeEvent &&
                    i.status == ItemStatus.returned &&
                    i.replacedBy == null,
              )
              .firstOrNull;
    if (lama != null) {
      final e = lama.event!;
      _kind = _jenis.containsKey(e.kind) ? e.kind : null;
      _untuk = e.personIds.first;
      _tanggal.text = tgl(e.date.awal);
    }
  }

  @override
  void dispose() {
    _tanggal.dispose();
    _alasan.dispose();
    super.dispose();
  }

  Tanggal? get _tgl {
    final n = bacaTgl(_tanggal.text);
    return n == null ? null : Tanggal(n ~/ 10000, n ~/ 100 % 100, n % 100);
  }

  /// First unmet reason of "Ajukan", from the latest input (AlurPeristiwa).
  String _alasanAjukan() {
    final t = _tgl;
    if (_kind == null) return 'jenis peristiwa belum dipilih.';
    if (_untuk == null) return 'orangnya belum dipilih.';
    if (t == null) return 'tanggal peristiwa tidak dikenali.';
    if (t > ref.read(hariIniProvider)) return 'tanggal peristiwa belum tiba.';
    if (_file == null) return 'surat atau piagam belum terlampir.';
    return '';
  }

  Future<void> _ajukan(String? ganti, String kolom) async {
    final r = await jalankanJemaat(
      ref,
      (a, k) => ref
          .read(applicationRepositoryProvider)
          .submitLifeEvent(
            a,
            LifeEventDraft(
              kind: _kind!,
              personIds: [_untuk!],
              date: _tgl!,
              replaces: ganti,
            ),
            _file,
            idempotencyKey: k,
          ),
    );
    if (!mounted || r == null) return;
    setState(() {
      _tolakan = r.refusal;
      if (r.isOk) {
        _pesan = 'Diajukan. Penatua $kolom diberi tahu lewat Pemberitahuan.';
        _kind = null;
        _untuk = null;
        _file = null;
        _sentuh = false;
        _tanggal.clear();
      }
    });
  }

  Future<void> _putuskan(VerificationItem i, {required bool verif}) async {
    final repo = ref.read(verificationRepositoryProvider);
    final r = await jalankanJemaat(
      ref,
      (a, k) => verif
          ? repo.verify(
              a,
              i.id,
              expectedRevision: i.revision,
              idempotencyKey: k,
            )
          : repo.returnForChanges(
              a,
              i.id,
              reason: _alasan.text,
              expectedRevision: i.revision,
              idempotencyKey: k,
            ),
    );
    if (!mounted || r == null) return;
    setState(() {
      _tolakan = r.refusal;
      if (r.isOk) _kembali = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(actorProvider);
    final nama = ref.watch(namaJemaatProvider);
    if (a == null) return const SizedBox.shrink();
    final apps = ref.watch(applicationRepositoryProvider);
    final milik = apps.submittedBy(a.personId);
    final id = ref.watch(peristiwaDipilihProvider);
    final pilih = id == null
        ? null
        : ref.watch(verificationRepositoryProvider).item(id);
    final verifikator =
        pilih != null &&
        pilih.kind == ItemKind.lifeEvent &&
        !milik.any((x) => x.id == pilih.id);
    return KerangkaJemaat(
      judul: 'Peristiwa',
      anakJudul: 'Diajukan anggota atau keluarga, diverifikasi Penatua Kolom',
      tampilan: (verifikator, pilih?.status, _kembali),
      blok: verifikator
          ? _verifikator(pilih, a, nama)
          : _anggota(a, milik, nama),
    );
  }

  String _ket(VerificationItem i, NamaJemaat nama) =>
      '${i.event!.kind.label} · ${nama.subjek(i)}';

  String _oleh(VerificationItem i, NamaJemaat nama, String aksi) =>
      i.decidedBy == null ? '' : nama.olehSiapa(i.decidedBy!, i.id, aksi);

  /// The card of one event in its current state (the static board's views).
  Widget _kartu(VerificationItem i, NamaJemaat nama, {bool rinci = false}) {
    final e = i.event!;
    final kolom = nama.kolom(i.scopeId);
    return kartuAlur([
      KepalaKartu(judul: _ket(i, nama), ujung: lencanaSt(i.status.label)),
      switch (i.status) {
        ItemStatus.submitted => barisAlur(
          context,
          'Diajukan ${nama.orang(i.submittedBy)}, ${tgl(i.submittedAt)}',
        ),
        ItemStatus.returned => barisAlur(context, 'Alasan: ${i.reason}'),
        _ => barisAlur(context, tgl(e.date.awal)),
      },
      if (rinci && e.kind == LifeEventKind.kolomMove) ...[
        BarisInfo('Dari', nama.kolom(e.fromKolomId!)),
        BarisInfo('Ke', nama.kolom(e.toKolomId!)),
        BarisInfo('Berlaku', tgl(e.effective!.awal)),
        BarisInfo('Siapa', 'Seluruh keluarga (${e.personIds.length} orang)'),
      ] else if (rinci) ...[
        BarisInfo('Tanggal peristiwa', tgl(e.date.awal)),
        if (i.attachment != null) BarisInfo('Lampiran', i.attachment!),
      ],
      ...switch (i.status) {
        ItemStatus.submitted when e.kind == LifeEventKind.kolomMove => [
          keteranganAlur(
            context,
            'Diverifikasi oleh Penatua Kolom asal dan tujuan. Jabatan tidak '
            'ikut pindah. Penugasan ${nama.kolom(e.fromKolomId!)} disimpan '
            'dengan tanggal berakhirnya.',
          ),
          if (i.verifiedScopes.isNotEmpty)
            keteranganAlur(
              context,
              'Sudah diverifikasi Penatua '
              '${i.verifiedScopes.map(nama.kolom).join(', ')}.',
            ),
        ],
        ItemStatus.submitted => [
          keteranganAlur(
            context,
            'Data anggota belum berubah sampai peristiwa ini Diverifikasi '
            'oleh Penatua $kolom.',
          ),
        ],
        ItemStatus.returned => [
          keteranganAlur(
            context,
            'Oleh ${_oleh(i, nama, 'membership.return')}, '
            '${tgl(i.decidedAt!)}',
          ),
        ],
        ItemStatus.verified => [
          keteranganAlur(
            context,
            'Diverifikasi oleh ${_oleh(i, nama, 'membership.verify')}, '
            '${tgl(i.decidedAt!)}. Tercatat di data ${nama.subjek(i)}.',
          ),
          if (e.kind == LifeEventKind.death)
            keteranganAlur(
              context,
              'Status menjadi Meninggal dunia; orangnya tidak dihapus. Sebab '
              'kematian tidak pernah tampil di publikasi.',
            ),
          if (e.kind == LifeEventKind.marriage)
            keteranganAlur(
              context,
              'Peristiwa Pernikahan yang Diverifikasi mengubah Kategori BIPRA '
              'kedua mempelai menjadi Bapa dan Ibu sejak tanggal pernikahan.',
            ),
        ],
        ItemStatus.declined => [
          keteranganAlur(
            context,
            'Oleh ${_oleh(i, nama, 'membership.decline')}, '
            '${tgl(i.decidedAt!)}. Data anggota tidak berubah.',
          ),
        ],
      },
    ]);
  }

  /// The verifier side (AlurPeristiwa "Penatua").
  List<Widget> _verifikator(VerificationItem i, Actor a, NamaJemaat nama) {
    if (!i.open) {
      return [
        _kartu(i, nama, rinci: true),
        if (i.status == ItemStatus.verified &&
            ref.watch(penjagaProvider(Layar.dataAnggota)) == null)
          Tekan(
            onTap: () {
              ref
                  .read(anggotaDipilihProvider.notifier)
                  .pilih(i.event!.personIds.first);
              context.dorongKe(Layar.dataAnggota);
            },
            peran: PeranTekan.tautan,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: TautanTeks(
                  'Buka data ${nama.subjek(i)}',
                  berat: FontWeight.w700,
                  ukuran: 14,
                ),
              ),
            ),
          ),
      ];
    }
    if (_kembali) {
      return [
        ...formAlasan(
          judul: _ket(i, nama),
          tindakan: 'Kembalikan',
          alasan: _alasan,
          onUbah: () => setState(() {}),
          kirim: () => _putuskan(i, verif: false),
          batal: () => setState(() => _kembali = false),
        ),
        ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
      ];
    }
    final sebab = ref
        .read(verificationRepositoryProvider)
        .whyNotVerify(a, i.id);
    return [
      _kartu(i, nama, rinci: true),
      keteranganAlur(context, hanyaKolom(nama.kolom(i.scopeId))),
      ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
      if (sebab != null)
        Penolakan(
          tindakan: 'Verifikasi data',
          sebab: sebab,
          jalan: const [],
          ukuranTeks: 14,
        )
      else
        tombolPenatua(
          verif: () => _putuskan(i, verif: true),
          keKembali: () => setState(() {
            _kembali = true;
            _alasan.clear();
            _tolakan = null;
          }),
        ),
    ];
  }

  /// The member side: the family's open and decided events, then the form.
  List<Widget> _anggota(
    Actor a,
    List<VerificationItem> milik,
    NamaJemaat nama,
  ) {
    final peristiwa = [
      for (final i in milik)
        if (i.kind == ItemKind.lifeEvent &&
            i.replacedBy == null &&
            (i.decidedBy != null || i.open))
          i,
    ];
    final dikembalikan = peristiwa
        .where((i) => i.status == ItemStatus.returned)
        .firstOrNull;
    final keluarga = [
      a.personId,
      for (final p
          in ref
                  .watch(memberRepositoryProvider)
                  .member(a.personId)
                  ?.household
                  ?.memberIds ??
              const <String>[])
        if (p != a.personId) p,
    ];
    final kolom = nama.kolom(
      ref.watch(memberRepositoryProvider).member(a.personId)?.kolomId ?? '',
    );
    final alasan = _alasanAjukan();
    final mulai = _sentuh || _file != null || _kind != null;
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      for (final i in peristiwa)
        if (i.status != ItemStatus.returned) _kartu(i, nama),
      if (dikembalikan != null)
        CatatanDikembalikan(
          'Penatua ${nama.kolom(dikembalikan.scopeId)}',
          dikembalikan.reason ?? '',
        ),
      ChipPilihan<LifeEventKind>(
        label: 'Jenis peristiwa',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [for (final k in _jenis.keys) (nilai: k, teks: k.label)],
        terpilih: _kind,
        onPilih: (k) => setState(() {
          _kind = k;
          _pesan = '';
        }),
      ),
      if (_kind == LifeEventKind.marriage)
        keteranganAlur(
          context,
          'Setelah Diverifikasi, Kategori BIPRA kedua mempelai menjadi Bapa '
          'dan Ibu sejak tanggal pernikahan.',
        ),
      ChipPilihan<String>(
        label: 'Untuk siapa',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [
          for (final p in keluarga)
            (nilai: p, teks: p == a.personId ? 'Saya sendiri' : nama.orang(p)),
        ],
        terpilih: _untuk,
        onPilih: (p) => setState(() {
          _untuk = p;
          _pesan = '';
        }),
      ),
      IsianAlur(
        label: 'Tanggal peristiwa',
        controller: _tanggal,
        petunjuk: 'hh/bb/tttt',
        keterangan: 'Tanggal yang tertulis di suratnya.',
        onChanged: (_) => setState(() => _sentuh = true),
      ),
      kartuAlur([
        KepalaKartu(
          judul: 'Surat atau piagam',
          ujung: _file != null
              ? const LencanaStatus('Terlampir', bentuk: BentukLencana.garis)
              : const LencanaStatus(
                  'Wajib, belum ada',
                  bentuk: BentukLencana.bata,
                ),
        ),
        if (_file != null)
          keteranganAlur(context, '1 file terlampir · $_file')
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Tombol(
              'Pilih file',
              onPressed: () => setState(
                () => _file = _jenis[_kind] ?? 'surat-peristiwa.jpg',
              ),
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              lebarPenuh: false,
            ),
          ),
      ], status: GarisStatus.draf),
      keteranganAlur(
        context,
        'Kelahiran tidak otomatis berarti baptisan. Peristiwa tidak otomatis '
        'tampil di Warta Jemaat.',
      ),
      if (mulai && alasan.isNotEmpty)
        Penolakan(
          tindakan: 'Ajukan',
          sebab: alasan,
          jalan: const [],
          ukuranTeks: 14,
        ),
      ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Ajukan peristiwa',
            tindakan: 'Ajukan',
            alasan: alasan,
            periksa: _alasanAjukan,
            sudahMulai: false,
            onPressed: () => _ajukan(dikembalikan?.id, kolom),
          ),
        ],
      ),
    ];
  }
}
