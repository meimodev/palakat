import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../widgets/alur_kit.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'sekretariat_bersama.dart';

enum _V { daftar, buka, tolak, ajukan }

/// PermohonanSurat + AlurSurat (README 7.1; screens/19), shared by the phone
/// and web screens. The Sekretaris Jemaat opens a request, reads the
/// member's data, types the outgoing-letter number, attaches the signed copy
/// and issues it, or records "Tidak diterbitkan" with a reason. The Operator
/// records a request at the office; a member files their own.
class IsiSurat extends ConsumerStatefulWidget {
  const IsiSurat({super.key, required this.web});

  final bool web;

  @override
  ConsumerState<IsiSurat> createState() => _IsiSuratState();
}

class _IsiSuratState extends ConsumerState<IsiSurat> {
  final _no = TextEditingController();
  final _alasan = TextEditingController();
  final _perlu = TextEditingController();
  final _cari = TextEditingController();

  /// The member's details typed in while Data jemaat is off (PermohonanSurat
  /// "Data jemaat tidak aktif"; PMP 6, "Member letters without Membership").
  final _nama = TextEditingController(), _rumah = TextEditingController();
  var _v = _V.daftar;
  String? _sel, _untuk;
  var _jenis = LetterType.certificate;
  var _file = false;
  var _pesan = '';
  Refusal? _tolak;

  @override
  void dispose() {
    for (final c in [_no, _alasan, _perlu, _cari, _nama, _rumah]) {
      c.dispose();
    }
    super.dispose();
  }

  /// The board's `ke(v)`: change view, clear the message, jump to the top.
  void _ke(_V v, [VoidCallback? o]) {
    setState(() {
      _v = v;
      _pesan = '';
      _tolak = null;
      o?.call();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Scrollable.maybeOf(context)?.position.jumpTo(0);
    });
  }

  void _kosongkan() {
    _no.clear();
    _alasan.clear();
    _perlu.clear();
    _cari.clear();
    _nama.clear();
    _rumah.clear();
    _file = false;
    _untuk = null;
  }

  void _selesai(String pesan) => _ke(_V.daftar, () {
    _pesan = pesan;
    _kosongkan();
  });

  void _gagal(Refusal r) => setState(() => _tolak = r);

  /// Whether Data jemaat is active: the letter reads its record; otherwise
  /// the Sekretaris types the details (PMP 6).
  bool get _dataAktif => ref.read(canProvider).moduleActive(Module.membership);

  String _alasanTerbit() => !_dataAktif && _nama.text.trim().isEmpty
      ? 'nama anggota belum diisi.'
      : _no.text.trim().isEmpty
      ? 'nomor surat belum diisi.'
      : (!_file ? 'salinan bertanda tangan belum terlampir.' : '');

  String _alasanTolak() =>
      _alasan.text.trim().isEmpty ? 'alasan belum diisi.' : '';

  LetterRequest? get _p => ref
      .read(letterRepositoryProvider)
      .requests()
      .where((r) => r.id == _sel)
      .firstOrNull;

  Future<void> _terbit() async {
    final p = _p!, n = _no.text.trim();
    final r = await ref
        .read(letterRepositoryProvider)
        .issue(
          aktorSek(ref),
          p.id,
          n,
          const SampleFile('salinan-bertanda-tangan.pdf'),
          expectedRevision: p.revision,
          idempotencyKey: kunciSek(ref),
        );
    if (!mounted) return;
    switch (r) {
      case Ok():
        _selesai('${p.type.label} ${p.forName} diterbitkan dengan No. $n.');
      case Refused(:final refusal):
        _gagal(refusal);
    }
  }

  Future<void> _catatTolak() async {
    final p = _p!, a = _alasan.text.trim();
    final r = await ref
        .read(letterRepositoryProvider)
        .refuse(
          aktorSek(ref),
          p.id,
          reason: a,
          expectedRevision: p.revision,
          idempotencyKey: kunciSek(ref),
        );
    if (!mounted) return;
    switch (r) {
      case Ok():
        _selesai(
          '${p.type.label} ${p.forName} tidak diterbitkan · alasan: $a.',
        );
      case Refused(:final refusal):
        _gagal(refusal);
    }
  }

  Future<void> _ajukan({required bool diKantor}) async {
    final repo = ref.read(letterRepositoryProvider);
    final perlu = _perlu.text;
    final r = diKantor
        ? await repo.recordAtOffice(
            aktorSek(ref),
            _untuk!,
            _jenis,
            purpose: perlu,
            idempotencyKey: kunciSek(ref),
          )
        : await repo.request(
            aktorSek(ref),
            _jenis,
            purpose: perlu,
            idempotencyKey: kunciSek(ref),
          );
    if (!mounted) return;
    switch (r) {
      case Ok(:final value):
        _selesai(
          diKantor
              ? 'Permohonan ${value.title} dicatat di kantor.'
              : 'Permohonan ${value.title} diajukan.',
        );
      case Refused(:final refusal):
        _gagal(refusal);
    }
  }

  static BentukLencana _bentuk(LetterStatus s) => switch (s) {
    LetterStatus.requested => BentukLencana.garis,
    LetterStatus.issued => BentukLencana.tinta,
    LetterStatus.refused => BentukLencana.bata,
  };

  String _ket(LetterRequest r) => switch (r.status) {
    LetterStatus.requested => [
      r.atOffice
          ? 'Dicatat Operator di kantor, ${tgl(r.requestedAt)}'
          : 'Diajukan ${tgl(r.requestedAt)}',
      ?r.purpose,
    ].join(' · '),
    LetterStatus.issued =>
      'No. ${r.number} · ${tgl(r.decidedAt!)} · hanya anggota, keluarganya '
          'dan pelayan yang menaunginya yang melihat',
    LetterStatus.refused => 'Alasan: ${r.refusalReason}',
  };

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final penerbit = bolehSek(ref, Capability.documentsIssueLetter);
    final kantor = bolehSek(ref, Capability.documentsRecordRequest);
    final pemohon = bolehSek(ref, Capability.documentsRequestLetter);
    final saya = ref.watch(actorProvider)?.personId;
    final repo = ref.watch(letterRepositoryProvider);
    final daftar = penerbit || kantor
        ? repo.requests()
        : repo.requests(personId: saya);
    final isi = switch (_v) {
      _V.buka when _p != null => _buka(),
      _V.tolak when _p != null => _tolakV(),
      _V.ajukan => _ajukanV(diKantor: kantor),
      _ => _daftar(daftar, penerbit, kantor, pemohon),
    };
    return kolomSek(isi, 16);
  }

  List<Widget> _daftar(
    List<LetterRequest> daftar,
    bool penerbit,
    bool kantor,
    bool pemohon,
  ) {
    final riwayat = riwayatSek(
      ref,
      const AuditFilter(
        module: Module.churchDocuments,
        actionPrefix: 'letter.',
      ),
    );
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      for (final r in daftar)
        Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: kolomSek([
            KepalaKartu(
              judul: r.title,
              ujung: LencanaStatus(r.status.label, bentuk: _bentuk(r.status)),
            ),
            kecilSek(context, _ket(r)),
            if (penerbit && r.status == LetterStatus.requested)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Tombol(
                  'Buka permohonan',
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  lebarPenuh: false,
                  onPressed: () => _ke(_V.buka, () {
                    _sel = r.id;
                    _kosongkan();
                    _nama.text = r.forName;
                    _rumah.text = r.household ?? '';
                    _perlu.text = r.purpose ?? '';
                  }),
                ),
              ),
          ], 6),
        ),
      if (daftar.isEmpty) kecilSek(context, 'Belum ada permohonan surat.'),
      kecilSek(
        context,
        'Permohonan datang dari anggota, atau dicatat Operator di kantor untuk '
        'anggota tanpa ponsel.',
      ),
      if (kantor || (pemohon && !penerbit))
        BarisTombol(
          anak: [
            Tombol(
              kantor ? 'Catat permohonan di kantor' : 'Ajukan permohonan',
              jenis: JenisTombol.tinta,
              onPressed: () => _ke(_V.ajukan, _kosongkan),
            ),
          ],
        ),
      if (penerbit && riwayat.isNotEmpty) RiwayatAlur(baris: riwayat),
    ];
  }

  Widget _kepalaP(LetterRequest p) => KepalaKartu(
    judul: p.title,
    ujung: const LencanaStatus('Diajukan', bentuk: BentukLencana.garis),
  );

  List<Widget> _buka() {
    final p = _p!;
    final orang = ref.watch(peopleRepositoryProvider).person(p.forPersonId);
    final status = switch (orang?.status) {
      PersonStatus.unconfirmed => 'Belum dikonfirmasi',
      PersonStatus.deceased => 'Meninggal',
      _ => 'Aktif',
    };
    final hari = ref.watch(hariIniProvider);
    final contoh = ref.watch(letterRepositoryProvider).nextNumber(at: hari);
    final alasan = _alasanTerbit();
    ref.watch(canProvider);
    void ubah(String _) => setState(() => _tolak = null);
    final kiri = [
      if (_dataAktif)
        Kartu(
          child: kolomSek([
            _kepalaP(p),
            BarisInfo('Nama', p.forName),
            if (p.household != null)
              BarisInfo('Keluarga · Kolom', p.household!),
            BarisInfo('Status', status),
            kecilSek(
              context,
              'Diambil dari Data jemaat yang sudah Diverifikasi. Sekretaris '
              'Jemaat membaca, tidak mengubah.',
            ),
          ], 6),
        )
      else ...[
        Kartu(
          status: GarisStatus.draf,
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Modul Data jemaat belum aktif. ',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      'Data anggota diketik di sini dan hanya dipakai untuk '
                      'surat ini.',
                  style: TextStyle(color: context.warna.tinta2),
                ),
              ],
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Kartu(
          child: kolomSek([
            _kepalaP(p),
            IsianAlur(label: 'Nama', controller: _nama, onChanged: ubah),
            IsianAlur(
              label: 'Keluarga · Kolom',
              controller: _rumah,
              onChanged: ubah,
            ),
            IsianAlur(label: 'Keperluan', controller: _perlu, onChanged: ubah),
          ], 12),
        ),
      ],
      IsianAlur(
        label: 'Nomor surat',
        controller: _no,
        onChanged: (_) => setState(() => _tolak = null),
        petunjuk: 'Contoh: $contoh',
        keterangan: 'Sesuai buku agenda surat keluar.',
      ),
    ];
    final kanan = [
      SlotSalinan(
        nama: 'salinan-bertanda-tangan.pdf',
        ada: _file,
        onPilih: () => setState(() => _file = true),
      ),
      if (_tolak != null)
        penolakanSek(_tolak!)
      else if ((_no.text.isNotEmpty || _file) && alasan.isNotEmpty)
        penolakanSek(Refusal(action: 'Terbitkan surat', because: alasan)),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: 'Terbitkan surat',
            tindakan: 'Terbitkan surat',
            alasan: alasan,
            periksa: _alasanTerbit,
            sudahMulai: false,
            onPressed: _terbit,
          ),
          Tombol(
            'Tidak diterbitkan',
            jenis: JenisTombol.kedua,
            ukuran: UkuranTombol.sedang,
            onPressed: () => _ke(_V.tolak),
          ),
          Tombol(
            'Kembali',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _ke(_V.daftar),
          ),
        ],
      ),
    ];
    return widget.web ? [duaKolomSek(kiri, kanan)] : [...kiri, ...kanan];
  }

  List<Widget> _tolakV() => [
    Kartu(
      child: kolomSek([
        _kepalaP(_p!),
        kecilSek(context, 'Pemohon diberi tahu, dengan alasannya.'),
      ], 6),
    ),
    IsianAlur(
      label: 'Alasan · wajib',
      controller: _alasan,
      onChanged: (_) => setState(() => _tolak = null),
      baris: 3,
    ),
    if (_tolak != null)
      penolakanSek(_tolak!)
    else if (_alasan.text.isNotEmpty && _alasanTolak().isNotEmpty)
      penolakanSek(
        Refusal(action: 'Catat tidak diterbitkan', because: _alasanTolak()),
      ),
    BarisTombol(
      anak: [
        TombolBersyarat(
          label: 'Catat tidak diterbitkan',
          tindakan: 'Catat tidak diterbitkan',
          alasan: _alasanTolak(),
          periksa: _alasanTolak,
          sudahMulai: false,
          onPressed: _catatTolak,
        ),
        Tombol(
          'Kembali',
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
          onPressed: () => _ke(_V.buka),
        ),
      ],
    ),
  ];

  /// Not drawn: the member's own request, or the Operator's record at the
  /// office, built from the flow boards' parts.
  List<Widget> _ajukanV({required bool diKantor}) {
    final orang = ref.watch(peopleRepositoryProvider);
    final q = _cari.text.trim();
    final hasil = q.length < 2
        ? const <Person>[]
        : orang.search(q).where((p) => !p.isSystem).take(5).toList();
    final dipilih = _untuk == null ? null : orang.person(_untuk!);
    String alasan() =>
        diKantor && _untuk == null ? 'anggota belum dipilih.' : '';
    return [
      if (diKantor) ...[
        IsianAlur(
          label: 'Nama anggota',
          controller: _cari,
          onChanged: (_) => setState(() => _tolak = null),
          petunjuk: 'Ketik nama',
        ),
        if (dipilih != null)
          BarisInfo('Untuk', dipilih.name)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in hasil)
                ChipSatu(
                  teks: p.name,
                  dipilih: false,
                  onTap: () => setState(() => _untuk = p.id),
                ),
            ],
          ),
      ],
      ChipPilihan<LetterType>(
        label: 'Jenis surat',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [for (final t in LetterType.values) (nilai: t, teks: t.label)],
        terpilih: _jenis,
        onPilih: (t) => setState(() => _jenis = t),
      ),
      IsianAlur(
        label: 'Keperluan',
        controller: _perlu,
        onChanged: (_) => setState(() {}),
        petunjuk: 'untuk melamar pekerjaan',
      ),
      if (_tolak != null) penolakanSek(_tolak!),
      BarisTombol(
        anak: [
          TombolBersyarat(
            label: diKantor ? 'Catat permohonan' : 'Ajukan permohonan',
            tindakan: diKantor ? 'Catat permohonan' : 'Ajukan permohonan',
            alasan: alasan(),
            periksa: alasan,
            sudahMulai: false,
            onPressed: () => _ajukan(diKantor: diKantor),
          ),
          Tombol(
            'Kembali',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _ke(_V.daftar),
          ),
        ],
      ),
    ];
  }
}
