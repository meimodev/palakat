import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'sekretariat_bersama.dart';

const _penerima = [
  Audience.all,
  Audience.servants,
  Audience.scope('kolom-7', 'Kolom 7'),
];

LencanaStatus lencanaPengumuman(AnnouncementStatus s) => LencanaStatus(
  s.label,
  bentuk: switch (s) {
    AnnouncementStatus.draft => BentukLencana.draf,
    AnnouncementStatus.published => BentukLencana.tinta,
    AnnouncementStatus.archived => BentukLencana.abu,
  },
);

/// The list caption: '{untuk} · berakhir pada {d}' or 'tanpa tanggal
/// berakhir'.
String ketPengumuman(Announcement a) =>
    '${a.audience.label} · '
    '${a.endsOn == null ? 'tanpa tanggal berakhir' : 'berakhir pada ${tgl(a.endsOn!.awal)}'}';

/// AlurWarta's "Tulis pengumuman" form (spec 19, view `umum`), shared by
/// Pengumuman and WartaEditor: Judul, Isi, Ditujukan untuk, Berakhir pada.
/// The Operator saves a draft; only the Sekretaris Jemaat publishes. On
/// success [onSelesai] gets the board's message.
class FormPengumuman extends ConsumerStatefulWidget {
  const FormPengumuman({
    super.key,
    required this.onSelesai,
    required this.onBatal,
    this.edisi,
  });

  final ValueChanged<String> onSelesai;
  final VoidCallback onBatal;

  /// The Warta edition being prepared, named in the message.
  final WartaEdition? edisi;

  @override
  ConsumerState<FormPengumuman> createState() => _FormPengumumanState();
}

class _FormPengumumanState extends ConsumerState<FormPengumuman> {
  final _judul = TextEditingController(), _isi = TextEditingController();
  final _akhir = TextEditingController();
  Audience? _untuk;
  Refusal? _tolak;

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    _akhir.dispose();
    super.dispose();
  }

  void _ubah([Object? _]) => setState(() => _tolak = null);

  /// `aU`: the first unmet condition, '' when met.
  String _alasan() {
    final hari = ref.read(hariIniProvider);
    final akhir = _akhir.text;
    final t = bacaTanggal(akhir);
    if (_judul.text.trim().isEmpty) return 'judul belum diisi.';
    if (_isi.text.trim().isEmpty) return 'isi belum diisi.';
    if (_untuk == null) return 'penerima belum dipilih.';
    if (akhir.trim().isNotEmpty && t == null) {
      return 'tanggal berakhir tidak dikenali. Contoh: '
          '${tgl(hari.tambahHari(14).awal)}.';
    }
    if (akhir.trim().isNotEmpty && !(t! > hari)) {
      return 'tanggal berakhir harus setelah hari ini (${tgl(hari.awal)}).';
    }
    return '';
  }

  Future<void> _simpan({required bool terbit}) async {
    final repo = ref.read(announcementRepositoryProvider);
    final j = _judul.text.trim(), p = _untuk!;
    final d = await repo.draft(
      aktorSek(ref),
      AnnouncementDraft(
        title: j,
        body: _isi.text.trim(),
        audience: p,
        endsOn: bacaTanggal(_akhir.text),
      ),
      idempotencyKey: kunciSek(ref),
    );
    if (!mounted) return;
    if (d case Refused(:final refusal)) {
      setState(() => _tolak = refusal);
      return;
    }
    final a = (d as Ok<Announcement>).value;
    if (!terbit) {
      widget.onSelesai(
        'Pengumuman “$j” disimpan sebagai Draf; belum terlihat anggota.',
      );
      return;
    }
    final r = await repo.publish(
      aktorSek(ref),
      a.id,
      expectedRevision: a.revision,
      idempotencyKey: kunciSek(ref),
    );
    if (!mounted) return;
    switch (r) {
      case Ok():
        final e = widget.edisi;
        final masuk = p == Audience.all && e != null;
        widget.onSelesai(
          'Pengumuman “$j” diterbitkan untuk ${p.label}'
          '${masuk ? ' dan dipilih masuk ke Warta edisi ${tgl(e.sunday.awal)}.' : '.'}',
        );
      case Refused(:final refusal):
        setState(() => _tolak = refusal);
    }
  }

  @override
  Widget build(BuildContext context) {
    final boleh = bolehSek(ref, Capability.announcementsPublish);
    final alasan = _alasan();
    final mulai =
        _judul.text.isNotEmpty ||
        _isi.text.isNotEmpty ||
        _untuk != null ||
        _akhir.text.isNotEmpty;
    return kolomSek([
      IsianAlur(
        label: 'Judul',
        controller: _judul,
        onChanged: _ubah,
        petunjuk: 'Judul pengumuman',
      ),
      IsianAlur(label: 'Isi', controller: _isi, onChanged: _ubah, baris: 3),
      ChipPilihan<Audience>(
        label: 'Ditujukan untuk',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [for (final p in _penerima) (nilai: p, teks: p.label)],
        terpilih: _untuk,
        onPilih: (p) => setState(() {
          _untuk = p;
          _tolak = null;
        }),
      ),
      IsianAlur(
        label: 'Berakhir pada',
        controller: _akhir,
        onChanged: _ubah,
        petunjuk: 'hh/bb/tttt',
        keterangan:
            'Boleh kosong. Setelah tanggal ini pengumuman diarsipkan sendiri.',
      ),
      kecilSek(
        context,
        'Hanya Sekretaris Jemaat yang menerbitkan. Sekretaris Jemaat juga yang '
        'memilih pengumuman mana yang masuk ke tiap edisi Warta.',
      ),
      if (_tolak != null)
        penolakanSek(_tolak!)
      else if (mulai && alasan.isNotEmpty)
        penolakanSek(
          Refusal(
            action: boleh ? 'Terbitkan' : 'Simpan sebagai draf',
            because: alasan,
          ),
        ),
      BarisTombol(
        anak: [
          if (boleh)
            TombolBersyarat(
              label: 'Terbitkan',
              tindakan: 'Terbitkan',
              alasan: alasan,
              periksa: _alasan,
              sudahMulai: false,
              onPressed: () => _simpan(terbit: true),
            ),
          TombolBersyarat(
            label: 'Simpan sebagai draf',
            tindakan: 'Simpan sebagai draf',
            alasan: alasan,
            periksa: _alasan,
            sudahMulai: false,
            warnaSiap: boleh ? JenisTombol.kedua : JenisTombol.tinta,
            onPressed: () => _simpan(terbit: false),
          ),
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: widget.onBatal,
          ),
        ],
      ),
    ], 16);
  }
}

/// Pengumuman and WebPengumuman (spec 17): the list (a writer sees every
/// announcement, anyone else those published to them), the form, and one
/// announcement in place: a draft as the board's read-only form with
/// "Terbitkan" for the Sekretaris Jemaat, a published one with its Warta
/// edition, an archived one past its end date (DL14).
class IsiPengumuman extends ConsumerStatefulWidget {
  const IsiPengumuman({super.key, required this.web});

  final bool web;

  @override
  ConsumerState<IsiPengumuman> createState() => _IsiPengumumanState();
}

class _IsiPengumumanState extends ConsumerState<IsiPengumuman> {
  /// null: the list; '': the form; else the open announcement.
  String? _v;
  String _pesan = '';
  Refusal? _tolak;

  /// The open announcement's "Ralat" form, its text.
  var _ralat = false;
  final _isiRalat = TextEditingController();

  @override
  void dispose() {
    _isiRalat.dispose();
    super.dispose();
  }

  void _ke(String? v, [String pesan = '']) {
    setState(() {
      _v = v;
      _pesan = pesan;
      _tolak = null;
      _ralat = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Scrollable.maybeOf(context)?.position.jumpTo(0);
    });
  }

  Future<void> _terbitkan(Announcement a) async {
    final r = await ref
        .read(announcementRepositoryProvider)
        .publish(
          aktorSek(ref),
          a.id,
          expectedRevision: a.revision,
          idempotencyKey: kunciSek(ref),
        );
    if (!mounted) return;
    switch (r) {
      case Ok():
        _ke(
          a.id,
          'Pengumuman “${a.title}” diterbitkan untuk ${a.audience.label}.',
        );
      case Refused(:final refusal):
        setState(() => _tolak = refusal);
    }
  }

  Future<void> _terbitRalat(Announcement a) async {
    final r = await ref
        .read(announcementRepositoryProvider)
        .revise(
          aktorSek(ref),
          a.id,
          _isiRalat.text,
          expectedRevision: a.revision,
          idempotencyKey: kunciSek(ref),
        );
    if (!mounted) return;
    switch (r) {
      case Ok(:final value):
        _ke(
          a.id,
          'Pengumuman “${a.title}”: revisi ${value.revisionNumber} '
          'diterbitkan.',
        );
      case Refused(:final refusal):
        setState(() => _tolak = refusal);
    }
  }

  /// The board's ralat card: "Ralat menjadi Revisi {n}.", Isi, "Terbitkan
  /// revisi {n}", "Batalkan".
  List<Widget> _formRalat(Announcement a) {
    final n = a.revisionNumber + 1;
    String alasan() {
      final t = _isiRalat.text.trim();
      if (t.isEmpty) return 'isi belum diisi.';
      return t == a.body ? 'isi belum diubah.' : '';
    }

    return [
      Kartu(
        status: GarisStatus.draf,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Ralat menjadi Revisi $n. ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text:
                    'Revisi ${n - 1} tetap tampil sebagai “Digantikan oleh '
                    'revisi $n”.',
                style: TextStyle(color: context.warna.tinta2),
              ),
            ],
          ),
          style: const TextStyle(fontSize: 14),
        ),
      ),
      IsianAlur(
        label: 'Isi',
        controller: _isiRalat,
        onChanged: (_) => setState(() => _tolak = null),
        baris: 3,
      ),
      if (_tolak != null) penolakanSek(_tolak!),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Terbitkan revisi $n',
            tindakan: 'Terbitkan revisi $n',
            alasan: alasan(),
            periksa: alasan,
            sudahMulai: false,
            onPressed: () => _terbitRalat(a),
          ),
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => setState(() {
              _ralat = false;
              _tolak = null;
            }),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final penulis = bolehSek(ref, Capability.announcementsDraft);
    final repo = ref.watch(announcementRepositoryProvider);
    final saya = ref.watch(actorProvider)?.personId;
    final semua = penulis ? repo.list() : repo.list(audienceOf: saya);
    final hari = ref.watch(hariIniProvider);
    final a = semua.where((x) => x.id == _v).firstOrNull;
    final isi = <Widget>[
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (_v == '')
        FormPengumuman(
          onSelesai: (p) => _ke(null, p),
          onBatal: () => _ke(null),
          edisi: _edisiDraf(),
        )
      else if (a != null)
        ..._lihat(a, a.statusAt(hari))
      else ...[
        if (widget.web)
          _Tabel(daftar: semua, hari: hari, onBuka: _ke)
        else
          for (final x in semua) _Baris(x, hari: hari, onBuka: _ke),
        if (semua.isEmpty) kecilSek(context, 'Belum ada pengumuman.'),
        if (penulis)
          BarisTombol(
            anak: [
              Tombol(
                'Tulis pengumuman',
                jenis: JenisTombol.tinta,
                onPressed: () => _ke(''),
              ),
            ],
          ),
      ],
    ];
    return kolomSek(isi, 16);
  }

  /// The edition of the coming Sunday while it is still Draf.
  WartaEdition? _edisiDraf() {
    final hari = ref.read(hariIniProvider);
    return ref
        .read(wartaRepositoryProvider)
        .editions()
        .where(
          (e) => e.status == WartaStatus.draft && e.sunday == mingguDepan(hari),
        )
        .firstOrNull;
  }

  List<Widget> _lihat(Announcement a, AnnouncementStatus s) {
    final c = context.warna;
    final kembali = Tombol(
      'Kembali',
      jenis: JenisTombol.teks,
      ukuran: UkuranTombol.kecil,
      onPressed: () => _ke(null),
    );
    final akhir = a.endsOn == null ? null : tgl(a.endsOn!.awal);
    switch (s) {
      case AnnouncementStatus.draft:
        final boleh = bolehSek(ref, Capability.announcementsPublish);
        final form = [
          Kartu(
            child: kolomSek([
              _isian(context, 'Judul', a.title),
              _isian(context, 'Isi', a.body, baris: 3),
              KisiOtomatis(
                minLebar: 300,
                jarak: 16,
                anak: [
                  _isian(context, 'Ditujukan untuk', a.audience.label),
                  kolomSek([
                    _isian(context, 'Berakhir pada', akhir ?? ''),
                    kecilSek(
                      context,
                      'Boleh kosong. Setelah tanggal ini pengumuman '
                      'diarsipkan sendiri.',
                    ),
                  ], 6),
                ],
              ),
            ], 12),
          ),
          kecilSek(
            context,
            'Draf oleh ${namaSek(ref, a.draftedBy)}. Hanya Sekretaris Jemaat '
            'yang menerbitkan.',
          ),
          if (_tolak != null) penolakanSek(_tolak!),
          BarisTombol(
            anak: [
              if (boleh)
                Tombol(
                  'Terbitkan',
                  jenis: JenisTombol.tinta,
                  onPressed: () => _terbitkan(a),
                ),
              kembali,
            ],
          ),
        ];
        if (!widget.web) return form;
        return [
          duaKolomSek(form, [
            const JudulBagian('Yang dilihat anggota'),
            Kartu(
              child: kolomSek([
                KepalaKartu(
                  judul: a.title,
                  ujung: const LencanaStatus(
                    'Belum diterbitkan',
                    bentuk: BentukLencana.draf,
                  ),
                ),
                Text(a.body, style: TextStyle(fontSize: 14, color: c.tinta2)),
                kecilSek(
                  context,
                  'Ditujukan untuk: ${a.audience.label}'
                  '${akhir == null ? '' : ' · tampil sampai $akhir'}',
                ),
              ], 6),
            ),
            kecilSek(
              context,
              'Sama seperti yang masuk ke Warta Jemaat. Draf tidak pernah '
              'terlihat anggota.',
            ),
          ]),
        ];
      case AnnouncementStatus.published:
        if (_ralat) return _formRalat(a);
        final edisi = ref
            .watch(wartaRepositoryProvider)
            .editions()
            .where((e) => e.announcementIds.contains(a.id))
            .firstOrNull;
        final n = a.revisionNumber;
        return [
          Kartu(
            child: kolomSek([
              KepalaKartu(
                judul: a.title,
                ujung: n > 1
                    ? LencanaStatus('Revisi $n', bentuk: BentukLencana.tinta)
                    : lencanaPengumuman(s),
              ),
              Text(a.body, style: TextStyle(fontSize: 14, color: c.tinta2)),
              Text(
                'Ditujukan untuk: ${a.audience.label}'
                '${akhir == null ? '' : ' · Berakhir pada $akhir'}',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              kecilSek(
                context,
                'Diterbitkan oleh ${namaSek(ref, a.publishedBy ?? '')}, '
                '${tglJam(a.publishedAt!)}.'
                '${edisi == null ? '' : ' Masuk ke Warta edisi ${tgl(edisi.sunday.awal)}.'}',
              ),
            ], 6),
          ),
          for (final r in a.superseded.reversed)
            Kartu(
              status: GarisStatus.draf,
              child: kolomSek([
                Wrap(
                  spacing: 16,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Revisi ${r.number}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    LencanaStatus(
                      'Digantikan oleh revisi ${r.number + 1}',
                      bentuk: BentukLencana.abu,
                    ),
                  ],
                ),
                Text(r.body, style: TextStyle(fontSize: 14, color: c.tinta2)),
                kecilSek(
                  context,
                  'Diterbitkan oleh ${namaSek(ref, r.publishedBy)}, '
                  '${tglJam(r.publishedAt)}. Tetap dapat dibaca.',
                ),
              ], 6),
            ),
          BarisTombol(
            anak: [
              if (bolehSek(ref, Capability.announcementsPublish))
                Tombol(
                  'Ralat',
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  onPressed: () => setState(() {
                    _ralat = true;
                    _tolak = null;
                    _isiRalat.text = a.body;
                  }),
                ),
              kembali,
            ],
          ),
        ];
      case AnnouncementStatus.archived:
        return [
          Kartu(
            status: GarisStatus.draf,
            child: kolomSek([
              KepalaKartu(judul: a.title, ujung: lencanaPengumuman(s)),
              Text(
                akhir == null ? a.body : 'Berakhir pada $akhir',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
              kecilSek(
                context,
                'Diarsipkan sendiri pada tanggal berakhirnya. Tetap dapat '
                'dibaca di arsip.',
              ),
            ], 6),
          ),
          BarisTombol(anak: [kembali]),
        ];
    }
  }
}

/// A read-only field: label 14 `tinta2` above (gap 6), value 14 `tinta2`.
Widget _isian(
  BuildContext context,
  String label,
  String nilai, {
  int baris = 1,
}) => IsianTeks(
  key: ValueKey('$label·$nilai'),
  label: label,
  nilaiAwal: nilai,
  hanyaBaca: true,
  jarakLabel: 6,
  baris: baris,
  padding: baris > 1 ? const EdgeInsets.fromLTRB(14, 12, 11, 12) : null,
  gaya: TextStyle(fontSize: 14, color: context.warna.tinta2, letterSpacing: 0),
);

/// Phone row: its own card; opens the announcement in place.
class _Baris extends StatelessWidget {
  const _Baris(this.a, {required this.hari, required this.onBuka});
  final Announcement a;
  final Tanggal hari;
  final ValueChanged<String> onBuka;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tautan(
      ke: Layar.pengumuman,
      diSini: () => onBuka(a.id),
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
                    a.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ketPengumuman(a),
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            lencanaPengumuman(a.statusAt(hari)),
            const SizedBox(width: 12),
            PalakatIkon(Ikon.lanjut, ukuran: 18, warna: c.tinta3),
          ],
        ),
      ),
    );
  }
}

/// Web table: rows with a 1 px rule between them.
class _Tabel extends StatelessWidget {
  const _Tabel({
    required this.daftar,
    required this.hari,
    required this.onBuka,
  });

  final List<Announcement> daftar;
  final Tanggal hari;
  final ValueChanged<String> onBuka;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Kartu(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, a) in daftar.indexed) ...[
            if (i > 0) GarisLurus(warna: c.garis),
            Tautan(
              ke: Layar.pengumuman,
              diSini: () => onBuka(a.id),
              child: Container(
                constraints: const BoxConstraints(minHeight: 68),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: BarisLentur(
                        jarak: 20,
                        jarakBaris: 2,
                        anak: [
                          Lentur(
                            dasar: 260,
                            child: Text(
                              a.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Lentur(
                            dasar: 300,
                            tumbuh: 1.4,
                            child: Text(
                              ketPengumuman(a),
                              style: TextStyle(fontSize: 13, color: c.tinta3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    lencanaPengumuman(a.statusAt(hari)),
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
