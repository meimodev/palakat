import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/secretariat/secretariat.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/layout.dart';
import '../../providers/repositories_jemaat.dart';
import '../../providers/repositories_keuangan.dart';
import '../../providers/repositories_sekretariat.dart';
import '../../providers/revision.dart';
import '../../domain/membership/membership.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/tautan.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'inti_bagian.dart';

/// 52 · Cari orang + 60 · Alur · Memulihkan akun anggota (screens/15,
/// screens/16): people search (PeopleRepository) and the two-person account
/// recovery (RecoveryRepository, P07): the Operator asks with the new number,
/// the Penatua Kolom of the person's Kolom confirms.
class CariOrangScreen extends StatelessWidget {
  const CariOrangScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Cari orang',
          anakJudul:
              'Hasil hanya dari modul aktif dan dari yang boleh Anda '
              'lihat',
          kembaliKe: Layar.beranda,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: const IsiCariOrang(),
          ),
        ),
      ],
    ),
  );
}

/// The body shared by CariOrangScreen and WebCariOrangScreen.
class IsiCariOrang extends ConsumerStatefulWidget {
  const IsiCariOrang({super.key, this.web = false});
  final bool web;

  @override
  ConsumerState<IsiCariOrang> createState() => _IsiCariOrangState();
}

class _IsiCariOrangState extends ConsumerState<IsiCariOrang> {
  final _cari = TextEditingController();
  final _nama = TextEditingController();
  final _hp = TextEditingController();
  late var _pulih = _menunggu().isNotEmpty;

  /// The "Cari orang" result of the recovery form: null before searching.
  Person? _ketemu;
  var _sudahCari = false;
  var _kenal = false;
  String _pesan = '';
  Refusal? _tolak;

  @override
  void dispose() {
    for (final c in [_cari, _nama, _hp]) {
      c.dispose();
    }
    super.dispose();
  }

  bool _boleh(Capability c, [ScopeRef s = ScopeRef.anywhere]) {
    final a = ref.read(actorProvider);
    return a != null &&
        ref.read(canProvider).can(a, c, s, at: ref.read(hariIniProvider));
  }

  /// Recoveries waiting for the signed-in Penatua Kolom.
  List<AccountRecovery> _menunggu() {
    final saya = ref.read(actorProvider)?.personId;
    return [
      for (final r in ref.read(recoveryRepositoryProvider).recoveries())
        if (r.status == RecoveryStatus.waiting &&
            r.requestedBy != saya &&
            r.personId != saya &&
            _boleh(Capability.confirmRecovery, ScopeRef(r.scopeId)))
          r,
    ];
  }

  void _lihat(bool pulih, [VoidCallback? ubah]) {
    setState(() {
      ubah?.call();
      _pulih = pulih;
      _tolak = null;
    });
    keAtas(context);
  }

  String _orang(String id) =>
      ref.read(peopleRepositoryProvider).person(id)?.name ?? '—';

  String _unit(String id) =>
      ref.read(orgRepositoryProvider).scope(id)?.name ?? '';

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    return susun(_pulih ? _isiPulih() : _isiCari());
  }

  // ---------- Cari orang ----------

  List<Widget> _isiCari() {
    final q = _cari.text.trim();
    final can = ref.watch(canProvider);
    final hari = ref.watch(hariIniProvider);
    final aktor = ref.watch(actorProvider);
    final jemaat = ref.watch(memberRepositoryProvider);
    final dataAktif = can.moduleActive(Module.membership);
    // A Penatua Kolom sees only their Kolom; the Operator sees everything.
    bool lihat(String kolom) =>
        aktor != null &&
        can.can(aktor, Capability.membershipView, ScopeRef(kolom), at: hari);
    final hasil = <Widget>[
      if (q.isNotEmpty)
        for (final o in ref.watch(peopleRepositoryProvider).search(q))
          if (dataAktif ? jemaat.member(o.id) : null case final m?) ...[
            if (lihat(m.kolomId)) _anggota(m),
          ] else if (_boleh(Capability.viewPeople, ScopeRef.jemaat))
            _hasil(o, can, hari),
      if (q.isNotEmpty && dataAktif)
        for (final h in jemaat.households())
          if (h.name.toLowerCase().contains(q.toLowerCase()) &&
              lihat(h.kolomId))
            _keluarga(h),
      // Dokumen gereja: the letter requests whoever handles them sees.
      if (q.isNotEmpty &&
          can.moduleActive(Module.churchDocuments) &&
          (_boleh(Capability.documentsIssueLetter) ||
              _boleh(Capability.documentsRecordRequest)))
        for (final r in ref.watch(letterRepositoryProvider).requests())
          if (r.forName.toLowerCase().contains(q.toLowerCase())) _surat(r),
      // Keuangan: a Party's latest booked row, only from the ledger rows the
      // viewer may read.
      if (q.isNotEmpty &&
          can.moduleActive(Module.finance) &&
          _boleh(Capability.financeView))
        ..._keuangan(q),
    ];
    return [
      IsianAlur(
        label: 'Cari nama, keluarga atau Kolom',
        controller: _cari,
        onChanged: (_) => setState(() {}),
      ),
      if (hasil.isNotEmpty) ...[
        Baris2('${hasil.length} hasil untuk “$q”'),
        ...hasil,
      ],
      if (q.isNotEmpty && hasil.isEmpty)
        KotakKosong(
          'Tidak ada hasil untuk “$q”',
          teks: 'Periksa ejaan, atau cari dengan nama keluarga.',
        ),
      if (_boleh(Capability.recoverAccount))
        _tautan(
          'Orangnya kehilangan nomor ponsel? Pulihkan akun',
          () => _lihat(true, () => _pesan = ''),
        ),
      if (_boleh(Capability.confirmRecovery))
        _tautan(
          'Pemulihan akun yang menunggu Anda',
          () => _lihat(true, () => _pesan = ''),
        ),
      const Catatan(
        'Kecocokan nama tidak pernah membuka data yang tidak boleh Anda lihat, '
        'dan jumlah hasil tidak menyebut data di luar jangkauan Anda.',
      ),
    ];
  }

  Widget _tautan(String teks, VoidCallback onTap) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Tekan(
      onTap: onTap,
      child: TautanTeks(teks, berat: FontWeight.w700, ukuran: 14),
    ),
  );

  /// A member row: an unconfirmed family opens KonfirmasiKeluarga for whoever
  /// may confirm it, everything else DataAnggota (screens/15 Links out).
  Widget _anggota(Member m) {
    final h = m.household;
    final konfirmasi =
        h != null &&
        h.status != HouseholdStatus.active &&
        Layar.konfirmasiKeluarga.adaUntuk(ref.read(layoutProvider)) &&
        ref.read(penjagaProvider(Layar.konfirmasiKeluarga)) == null;
    final (label, bentuk) = h == null || h.status == HouseholdStatus.active
        ? ('Aktif', BentukLencana.laut)
        : (h.status.label, BentukLencana.draf);
    return _baris(
      m.person.name,
      [
        'Data jemaat',
        if (h != null) 'Keluarga ${h.name}',
        _unit(m.kolomId),
      ].join(' · '),
      LencanaStatus(label, bentuk: bentuk),
      () {
        if (konfirmasi) {
          ref.read(keluargaDipilihProvider.notifier).pilih(h.id);
          context.dorongKe(Layar.konfirmasiKeluarga);
        } else {
          ref.read(anggotaDipilihProvider.notifier).pilih(m.person.id);
          context.dorongKe(Layar.dataAnggota);
        }
      },
    );
  }

  Widget _keluarga(Household h) => _baris(
    'Keluarga ${h.name}',
    'Data jemaat · ${h.memberIds.length} orang · ${_unit(h.kolomId)}',
    null,
    () {
      ref
          .read(anggotaDipilihProvider.notifier)
          .pilih(h.representativeId ?? h.memberIds.first);
      context.dorongKe(Layar.dataAnggota);
    },
  );

  Widget _surat(LetterRequest r) => _baris(
    r.forName,
    'Dokumen gereja · ${r.type.label} ${tgl(r.decidedAt ?? r.requestedAt)}',
    LencanaStatus(
      r.status.label,
      bentuk: switch (r.status) {
        LetterStatus.issued => BentukLencana.tinta,
        LetterStatus.refused => BentukLencana.bata,
        LetterStatus.requested => BentukLencana.garis,
      },
    ),
    () => context.dorongKe(Layar.surat),
  );

  List<Widget> _keuangan(String q) {
    final buku = ref.watch(transactionRepositoryProvider).list(null);
    return [
      for (final p in ref.watch(peopleRepositoryProvider).parties())
        if (p.displayName.toLowerCase().contains(q.toLowerCase()))
          if (buku
                  .where(
                    (t) =>
                        t.isPosted &&
                        t.allocations.any((a) => a.partyId == p.id),
                  )
                  .lastOrNull
              case final t?)
            _baris(
              p.displayName,
              'Keuangan · ${t.description.split(',').first} '
              '${tgl(t.effectiveDate.awal)}',
              const LencanaStatus('Dibukukan', bentuk: BentukLencana.tinta),
              () => context.dorongKe(Layar.keuangan),
            ),
    ];
  }

  Widget _baris(String nama, String konteks, Widget? lencana, VoidCallback k) =>
      Tekan(
        onTap: k,
        child: Kartu(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: susun([
                  Text(
                    nama,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Catatan(konteks),
                ], jarak: 2),
              ),
              if (lencana != null) ...[const SizedBox(width: 12), lencana],
            ],
          ),
        ),
      );

  /// A person outside Data jemaat (a post holder only), for whoever sees
  /// the whole Jemaat.
  Widget _hasil(Person o, Can can, Tanggal hari) {
    final jabatan = [
      for (final g in can.grantsOf(o.id, at: hari))
        if (g.kind == GrantKind.assignment) g.title,
    ];
    final (label, bentuk) = switch (o.status) {
      PersonStatus.active => ('Aktif', BentukLencana.laut),
      PersonStatus.unconfirmed => ('Belum dikonfirmasi', BentukLencana.draf),
      PersonStatus.deceased => ('Meninggal', BentukLencana.garis),
    };
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: susun([
              Text(o.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              Catatan(jabatan.isEmpty ? 'Anggota jemaat' : jabatan.join(' · ')),
            ], jarak: 2),
          ),
          const SizedBox(width: 12),
          LencanaStatus(label, bentuk: bentuk),
        ],
      ),
    );
  }

  // ---------- Pemulihan akun ----------

  String _syaratMinta() {
    if (_ketemu == null) return 'orangnya belum ditemukan.';
    final hp = _hp.text.trim();
    if (hp.isEmpty) return 'nomor ponsel baru belum diisi.';
    if (!hpSah(hp)) return 'nomor ponsel tidak dikenali. Contoh: 081298765432.';
    return '';
  }

  void _cariPulih() => setState(() {
    final n = _nama.text.trim();
    _ketemu = n.isEmpty
        ? null
        : ref.read(peopleRepositoryProvider).search(n).firstOrNull;
    _sudahCari = true;
    _tolak = null;
  });

  Future<void> _minta() async {
    final actor = ref.read(actorProvider);
    final o = _ketemu;
    if (actor == null || o == null) return;
    final repo = ref.read(recoveryRepositoryProvider);
    final r = await repo.request(
      actor,
      o.id,
      _hp.text.trim(),
      idempotencyKey: kunciInti(ref),
    );
    if (!mounted) return;
    if (r.refusal case final t?) return setState(() => _tolak = t);
    setState(() {
      _pesan =
          'Penatua ${_unit(r.value.scopeId)} diberi tahu lewat '
          'Pemberitahuan.';
      _nama.clear();
      _hp.clear();
      _ketemu = null;
      _sudahCari = false;
    });
  }

  Future<void> _putuskan(AccountRecovery x, bool pasti) async {
    final actor = ref.read(actorProvider);
    if (actor == null) return;
    final repo = ref.read(recoveryRepositoryProvider);
    final r = pasti
        ? await repo.confirm(
            actor,
            x.id,
            expectedRevision: x.revision,
            idempotencyKey: kunciInti(ref),
          )
        : await repo.decline(
            actor,
            x.id,
            expectedRevision: x.revision,
            idempotencyKey: kunciInti(ref),
          );
    if (!mounted) return;
    if (r.refusal case final t?) return setState(() => _tolak = t);
    setState(() {
      _kenal = false;
      _pesan = pasti
          ? 'Identitas dipastikan. Nomor baru dipasang.'
          : 'Pemulihan tidak dijalankan.';
    });
  }

  List<Widget> _isiPulih() {
    final saya = ref.watch(actorProvider)?.personId;
    final semua = ref.watch(recoveryRepositoryProvider).recoveries();
    final milikSaya = semua.where((r) => r.requestedBy == saya).firstOrNull;
    final riwayat = [
      for (final a
          in ref
              .watch(auditRepositoryProvider)
              .list(const AuditFilter(actionPrefix: 'core.recovery.')))
        '${tgl(a.at)} · ${a.summary} · ${a.actorLine}',
    ];
    return [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Tombol(
          'Kembali ke Cari orang',
          jenis: JenisTombol.teks,
          ukuran: UkuranTombol.kecil,
          lebarPenuh: false,
          onPressed: () => _lihat(false, () => _pesan = ''),
        ),
      ),
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      if (_boleh(Capability.recoverAccount)) ...[
        if (milikSaya != null) _status(milikSaya),
        if (milikSaya == null || milikSaya.status != RecoveryStatus.waiting)
          _formMinta(),
      ],
      if (_boleh(Capability.confirmRecovery)) ..._penatua(),
      RiwayatAlur(baris: riwayat),
    ];
  }

  Widget _status(AccountRecovery r) {
    final nama = _orang(r.personId);
    final kolom = _unit(r.scopeId);
    final penatua = ref
        .read(canProvider)
        .whoCan(
          Capability.confirmRecovery,
          ScopeRef(r.scopeId),
          at: ref.read(hariIniProvider),
        )
        .where((p) => p.id != r.requestedBy)
        .map((p) => p.name)
        .join(', ');
    final (label, bentuk, teks) = switch (r.status) {
      RecoveryStatus.waiting => (
        'Menunggu Penatua $kolom',
        BentukLencana.garis,
        'Diminta ${tgl(r.requestedAt)} · menunggu $penatua, Penatua $kolom. '
            'Nomor lama masih berlaku sampai dipastikan.',
      ),
      RecoveryStatus.recovered => (
        'Dipulihkan',
        BentukLencana.laut,
        'Nomor baru dipasang ${tgl(r.decidedAt!)}. Semua perangkat lama '
            'dikeluarkan. $nama masuk dengan kode ke nomor barunya.',
      ),
      RecoveryStatus.notConfirmed => (
        'Tidak dipastikan',
        BentukLencana.bata,
        'Penatua $kolom tidak memastikan identitasnya. Nomor lama tetap '
            'berlaku dan tidak ada yang berubah.',
      ),
    };
    return Kartu(
      child: susun([
        // The badge takes its own line: "Menunggu Penatua Kolom N" does
        // not fit beside the title at phone width.
        KepalaKartu(judul: 'Pemulihan akun · $nama'),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: LencanaStatus(label, bentuk: bentuk),
        ),
        Baris2(teks),
      ], jarak: 6),
    );
  }

  Widget _formMinta() {
    final o = _ketemu;
    final scope = o == null
        ? null
        : ref.read(recoveryRepositoryProvider).confirmingScope(o.id);
    final kiri = susun([
      IsianAlur(
        label: 'Nama orangnya',
        controller: _nama,
        petunjuk: 'Nama lengkap',
        onChanged: (_) => setState(() {
          _ketemu = null;
          _sudahCari = false;
          _tolak = null;
        }),
      ),
      BarisTombol(
        anak: [
          Tombol('Cari orang', jenis: JenisTombol.kedua, onPressed: _cariPulih),
        ],
      ),
      if (o != null)
        Kartu(
          child: susun([
            KepalaKartu(
              judul: o.name,
              ujung: const LencanaStatus('Aktif', bentuk: BentukLencana.laut),
            ),
            BarisInfo('Kolom', scope == null ? 'Belum tercatat' : _unit(scope)),
            BarisInfo(
              'Nomor lama',
              o.phone == null ? 'Belum diisi' : samarHp(o.phone!),
              mono: true,
            ),
            BarisInfo('Email cadangan', samarEmail(o.backupEmail ?? '')),
          ], jarak: 6),
        )
      else if (_sudahCari)
        const KotakKosong('Tidak ada orang dengan nama itu'),
    ], jarak: 12);
    final kanan = susun([
      IsianAlur(
        label: 'Nomor ponsel baru',
        controller: _hp,
        petunjuk: '08…',
        keterangan: 'Nomor yang dibawa orangnya ke kantor gereja.',
        keyboard: TextInputType.phone,
        formatter: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(13),
        ],
        onChanged: (_) => setState(() => _tolak = null),
      ),
      if (_tolak case final t?)
        Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
      TombolBersyarat(
        label: 'Minta kepastian Penatua Kolom',
        tindakan: 'Minta kepastian Penatua Kolom',
        alasan: _syaratMinta(),
        periksa: _syaratMinta,
        sudahMulai: _nama.text.isNotEmpty || _hp.text.isNotEmpty,
        onPressed: _minta,
        baris: const [],
      ),
      const Catatan(
        'Operator tidak memulihkan akun seorang diri, dan tidak memulihkan '
        'akunnya sendiri. Bendahara Jemaat dipulihkan lewat Petugas '
        'verifikasi bersama BPMJ.',
      ),
    ], jarak: 12);
    if (!widget.web) return susun([kiri, kanan]);
    return BarisLentur(
      jarak: 28,
      jarakBaris: 20,
      anak: [
        Lentur(dasar: 420, tumbuh: 1.3, child: kiri),
        Lentur(dasar: 340, child: kanan),
      ],
    );
  }

  List<Widget> _penatua() {
    final x = _menunggu().firstOrNull;
    if (x == null) {
      return const [KotakKosong('Tidak ada pemulihan akun yang menunggu Anda')];
    }
    final c = context.warna;
    return [
      Kartu(
        child: susun([
          KepalaKartu(
            judul: 'Pemulihan akun · ${_orang(x.personId)}',
            ujung: const LencanaStatus(
              'Menunggu Anda',
              bentuk: BentukLencana.garis,
            ),
          ),
          BarisInfo('Diminta oleh', '${_orang(x.requestedBy)}, Operator'),
          BarisInfo(
            'Nomor ponsel baru',
            samarHp(x.newPhone),
            mono: true,
            berat: FontWeight.w600,
          ),
        ], jarak: 6),
      ),
      KotakCentang(
        nilai: _kenal,
        onUbah: (v) => setState(() => _kenal = v),
        jarakAtas: 2,
        label: Text(
          'Saya sudah bertemu atau berbicara langsung dengan orang ini, dan '
          'nomor baru itu memang miliknya.',
          style: TextStyle(color: c.tinta),
        ),
      ),
      if (_tolak case final t?)
        Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
      TombolBersyarat(
        label: 'Pastikan identitas',
        tindakan: 'Pastikan identitas',
        alasan: _kenal
            ? ''
            : 'centang dulu bahwa Anda sudah memastikan orangnya.',
        onPressed: () => _putuskan(x, true),
        baris: [
          Tombol(
            'Bukan orangnya',
            jenis: JenisTombol.kedua,
            onPressed: () => _putuskan(x, false),
          ),
        ],
      ),
    ];
  }
}
