import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/collaboration/collaboration.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/akhir_bulan.dart' show perintah;
import '../../providers/repositories_kolaborasi.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'permintaan_dana_keadaan.dart';

const _namaHari = [
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

/// 90 · Ibadah dan kegiatan + the scheduling step of AlurIbadah (spec 22,
/// 23; README 7.1): a service goes Draf → Dijadwalkan → Selesai → Ditutup.
/// The Penatua or Syamas of its Kolom approves it; a Jemaat-wide service,
/// the Ketua Jemaat (DL11). Whoever approves assigns the counters (DL30).
class IbadahScreen extends ConsumerStatefulWidget {
  const IbadahScreen({super.key});

  @override
  ConsumerState<IbadahScreen> createState() => _IbadahState();
}

class _IbadahState extends ConsumerState<IbadahScreen> {
  final _tgl = TextEditingController();
  final _jam = TextEditingController();
  final _tempat = TextEditingController();

  /// The audience scope picked in the form.
  String? _untuk;

  /// The last refusal and its service ('' for the form).
  (String, Refusal)? _tolak;

  @override
  void dispose() {
    for (final c in [_tgl, _jam, _tempat]) {
      c.dispose();
    }
    super.dispose();
  }

  /// AlurIbadah's `a`: the first unmet reason of "Jadwalkan".
  String _sebab() {
    if (_untuk == null) return 'ibadah belum dipilih.';
    if (bacaTgl(_tgl.text) == null) {
      return 'tanggal tidak dikenali. Contoh: hh/bb/tttt.';
    }
    if (!RegExp(r'^([01]\d|2[0-3])\.[0-5]\d$').hasMatch(_jam.text.trim())) {
      return 'jam tidak dikenali. Contoh: 19.00.';
    }
    if (_tempat.text.trim().isEmpty) return 'tempat belum diisi.';
    return '';
  }

  Future<Result<Service>?> _jalankan(
    String id,
    Future<Result<Service>> Function(Actor a, String k) jalan,
  ) async {
    final r = await perintah(ref, jalan);
    if (!mounted) return r;
    final t = r?.refusal;
    setState(() => _tolak = t == null ? null : (id, t));
    return r;
  }

  Future<void> _setujui(Service s) => _jalankan(
    s.id,
    (a, k) => ref
        .read(serviceRepositoryProvider)
        .approve(a, s.id, expectedRevision: s.revision, idempotencyKey: k),
  );

  /// Drafts the service, then approves it at once when the actor may.
  Future<void> _jadwalkan(String judul, ServiceKind jenis) async {
    final n = bacaTgl(_tgl.text)!;
    final repo = ref.read(serviceRepositoryProvider);
    final r = await _jalankan(
      '',
      (a, k) => repo.draft(
        a,
        ServiceDraft(
          title: judul,
          kind: jenis,
          scopeId: _untuk!,
          date: Tanggal(n ~/ 10000, n ~/ 100 % 100, n % 100),
          time: _jam.text.trim(),
          place: _tempat.text.trim(),
        ),
        idempotencyKey: k,
      ),
    );
    if (r is! Ok<Service> || !mounted) return;
    final saya = ref.read(actorProvider)?.personId;
    if (repo.approversOf(r.value.id).contains(saya)) await _setujui(r.value);
    if (!mounted) return;
    setState(() {
      _untuk = null;
      for (final c in [_tgl, _jam, _tempat]) {
        c.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final c = context.warna;
    final a = ref.watch(actorProvider);
    final hari = ref.watch(hariIniProvider);
    final can = ref.watch(canProvider);
    final org = ref.watch(orgRepositoryProvider);
    final orang = ref.watch(peopleRepositoryProvider);
    final repo = ref.watch(serviceRepositoryProvider);
    final hadir = ref.watch(attendanceRepositoryProvider);
    final saya = a?.personId ?? '';
    String nama(String? id) => orang.person(id ?? '')?.name ?? '';
    final ket = TextStyle(fontSize: 13, color: c.tinta3);

    // The form's audiences: the Kolom (or unit) of each post that may draft,
    // and the whole church as AlurIbadah draws it.
    final untuk = <String, (String, ServiceKind)>{
      for (final g in can.grantsOf(saya, at: hari))
        if (g.kind != GrantKind.member &&
            g.scopeId != ScopeRef.jemaatId &&
            g.capabilities.contains(Capability.servicesDraft))
          g.scopeId: (
            'Ibadah ${org.scope(g.scopeId)?.name ?? ''}',
            switch (org.scope(g.scopeId)?.type) {
              ScopeType.bipra => ServiceKind.bipra,
              ScopeType.panitia => ServiceKind.panitia,
              _ => ServiceKind.kolom,
            },
          ),
    };
    final bolehJadwal =
        a != null &&
        can
            .grantsOf(saya, at: hari)
            .any(
              (g) =>
                  g.kind != GrantKind.member &&
                  g.capabilities.contains(Capability.servicesDraft),
            );
    untuk[ScopeRef.jemaatId] = ('Ibadah seluruh Jemaat', ServiceKind.minggu);
    final sebab = _sebab();

    Widget? penolakan(String id) =>
        _tolak?.$1 == id ? penolakanDari(_tolak!.$2) : null;

    List<Widget> kartu(Service s) {
      final h = hadir.count(s.id);
      final semua = s.forEveryone || s.kind == ServiceKind.panitia;
      final berlangsung = s.status == ServiceStatus.scheduled && s.date == hari;
      final (label, bentuk) = switch (s.status) {
        ServiceStatus.draft => ('Draf', BentukLencana.draf),
        ServiceStatus.scheduled when berlangsung => (
          'Sedang berlangsung',
          BentukLencana.laut,
        ),
        ServiceStatus.scheduled => ('Dijadwalkan', BentukLencana.lautGaris),
        ServiceStatus.done => ('Selesai', BentukLencana.garis),
        ServiceStatus.closed => ('Ditutup', BentukLencana.tinta),
      };
      final ketuaJemaat =
          'Ibadah seluruh Jemaat dan kegiatan Panitia disetujui oleh Ketua '
          'Jemaat';
      final keterangan = switch (s.status) {
        ServiceStatus.draft when semua =>
          '$ketuaJemaat. Bila tidak ada Ketua Jemaat: Sekretaris Jemaat atau '
              'yang ditunjuk.',
        ServiceStatus.draft =>
          'Disetujui oleh Penatua atau Syamas dari Kolom yang dituju: '
              '${repo.approversOf(s.id).map(nama).join(' atau ')}.',
        ServiceStatus.scheduled when berlangsung =>
          'Jumlah kehadiran sedang dihitung.',
        ServiceStatus.scheduled when semua =>
          '$ketuaJemaat: ${nama(s.approvedBy)}, '
              '${s.approvedAt == null ? '' : tgl(s.approvedAt!)}. Bila tidak '
              'ada Ketua Jemaat: Sekretaris Jemaat atau yang ditunjuk.',
        ServiceStatus.scheduled =>
          'Disetujui oleh ${nama(s.approvedBy)}, '
              '${s.approvedAt == null ? '' : tgl(s.approvedAt!)}. Yang '
              'menyetujui juga menugaskan petugas penghitung kehadiran.',
        ServiceStatus.done =>
          'Jumlah kehadiran: Sudah diperiksa, belum Ditetapkan.',
        ServiceStatus.closed =>
          'Jumlah kehadiran Ditetapkan: ${h?.total ?? 0} orang.'
              '${s.kind == ServiceKind.kolom ? ' Persembahan dicatat di Keuangan sebagai Persembahan Ibadah Kolom.' : ''}',
      };
      final waktu = [
        '${_namaHari[s.date.awal.weekday - 1]}, ${s.date}'
            '${s.time == null ? '' : ' ${s.time}'}',
        ?s.sessions,
      ].join(' · ');
      final penyetuju = s.approvedBy == saya;
      final hitung = h != null && (penyetuju || h.isCounter(saya));
      return [
        Kartu(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 6,
            children: [
              KepalaKartu(
                judul: s.title,
                ujung: LencanaStatus(label, bentuk: bentuk),
              ),
              if (!s.forEveryone) BarisInfo('Jenis', s.kind.label),
              BarisInfo('Waktu', waktu),
              BarisInfo(
                'Ditujukan untuk',
                s.forEveryone
                    ? 'Semua anggota'
                    : org.scope(s.scopeId)?.name ?? '',
              ),
              if (s.place != null) BarisInfo('Tempat', s.place!),
              Text(keterangan, style: ket),
            ],
          ),
        ),
        if (s.status == ServiceStatus.draft &&
            repo.approversOf(s.id).contains(saya))
          BarisTombol(
            anak: [
              Tombol(
                'Setujui dan jadwalkan',
                jenis: JenisTombol.tinta,
                onPressed: () => _setujui(s),
              ),
            ],
          ),
        if (hitung)
          BarisTombol(
            tautan: const {0: 35},
            anak: [
              // An `<a>` is content-box: min-height 48 plus the 1.5 line twice.
              SizedBox(
                height: 51,
                child: Tombol(
                  penyetuju && h.posts.isEmpty
                      ? 'Tugaskan penghitung kehadiran'
                      : 'Buka jumlah kehadiran',
                  onPressed: null,
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  ke: Layar.kehadiran,
                  param: {'ibadah': s.id},
                ),
              ),
            ],
          ),
        ?penolakan(s.id),
      ];
    }

    final isi = <Widget>[
      for (final s in repo.list())
        Column(
          key: ValueKey(s.id),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: kartu(s),
        ),
      if (bolehJadwal) ...[
        Semantics(
          header: true,
          child: const Text(
            'Jadwalkan ibadah',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        ChipPilihan<String>(
          label: 'Ibadah',
          jarakLabel: 6,
          jarakBawah: 0,
          pilihan: [
            for (final e in untuk.entries) (nilai: e.key, teks: e.value.$1),
          ],
          terpilih: _untuk,
          onPilih: (v) => setState(() {
            _untuk = v;
            _tolak = null;
          }),
        ),
        IsianAlur(
          label: 'Tanggal',
          controller: _tgl,
          petunjuk: 'hh/bb/tttt',
          keterangan: 'Hari ini atau sesudahnya.',
          onChanged: (_) => setState(() => _tolak = null),
        ),
        IsianAlur(
          label: 'Jam',
          controller: _jam,
          petunjuk: 'jj.mm',
          keterangan: 'Contoh: 19.00',
          onChanged: (_) => setState(() => _tolak = null),
        ),
        IsianAlur(
          label: 'Tempat',
          controller: _tempat,
          petunjuk: 'Contoh: rumah Kel. Wenas-Lasut',
          onChanged: (_) => setState(() => _tolak = null),
        ),
        if (penolakan('') case final p?)
          p
        else if ((_untuk != null ||
                _tgl.text.isNotEmpty ||
                _jam.text.isNotEmpty ||
                _tempat.text.isNotEmpty) &&
            sebab.isNotEmpty)
          Penolakan(
            tindakan: 'Jadwalkan',
            sebab: sebab,
            jalan: const [],
            ukuranTeks: 14,
          ),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Jadwalkan',
              tindakan: 'Jadwalkan',
              alasan: sebab,
              periksa: _sebab,
              sudahMulai: false,
              onPressed: () => _jadwalkan(untuk[_untuk]!.$1, untuk[_untuk]!.$2),
            ),
          ],
        ),
      ],
    ];

    return Material(
      type: MaterialType.transparency,
      child: LayarPonsel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Ibadah dan kegiatan',
              anakJudul:
                  'Jadwal dan persetujuan; tanpa daftar petugas pelayanan',
              kembaliKe: Layar.beranda,
              labelKembali: 'Kembali ke Beranda',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                // ponytail: IsianTeks inherits the theme bodyLarge's 0.5
                // letterSpacing; drop this once IsianTeks sets 0 itself.
                child: DefaultTextStyle.merge(
                  style: const TextStyle(letterSpacing: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: isi,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
