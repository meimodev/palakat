import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'jemaat_bagian.dart';

/// 72 · Permohonan menjadi anggota + 82 · AlurAnggota (DP36): a submitted
/// application at `/permohonan-anggota/:id`, opened from AntreanVerifikasi.
/// The verifier (here Yanti, covering Penatua Kolom 2, for Kevin Rompas)
/// reads the form and verifies it or returns it with a reason. The
/// applicant's empty form ("Ajukan permohonan", id `baru`) is kept behind
/// `membership.apply`, which no persona holds.
class PermohonanAnggotaScreen extends ConsumerStatefulWidget {
  const PermohonanAnggotaScreen({super.key});

  @override
  ConsumerState<PermohonanAnggotaScreen> createState() =>
      _PermohonanAnggotaScreenState();
}

class _PermohonanAnggotaScreenState
    extends ConsumerState<PermohonanAnggotaScreen> {
  static const _judul = 'Permohonan menjadi anggota';
  final _alasan = TextEditingController();
  bool _kembali = false;
  Refusal? _tolakan;

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
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
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    final a = ref.watch(actorProvider);
    final nama = ref.watch(namaJemaatProvider);
    final i = ref.watch(applicationRepositoryProvider).application(id);
    final List<Widget> isi;
    if (i == null || i.kind != ItemKind.application || a == null) {
      isi = [
        if (id == 'baru' &&
            ref
                .watch(canProvider)
                .can(
                  a ?? const Actor(personId: '', scopeId: ''),
                  Capability.membershipApply,
                  ScopeRef.jemaat,
                  at: ref.watch(hariIniProvider),
                ))
          const _FormulirPemohon()
        else
          kotakKosong(context, 'Pengajuan akan muncul di sini.'),
      ];
    } else {
      isi = _isi(i, a, nama);
    }
    return KerangkaJemaat(
      judul: _judul,
      anakJudul: 'Diisi sendiri, lalu diverifikasi Penatua Kolom',
      tampilan: (i?.status, _kembali),
      blok: isi,
    );
  }

  List<Widget> _isi(VerificationItem i, Actor a, NamaJemaat nama) {
    final f = i.application!;
    final kolom = nama.kolom(f.kolomId);
    final oleh = i.decidedBy == null
        ? ''
        : nama.olehSiapa(
            i.decidedBy!,
            i.id,
            i.status == ItemStatus.verified
                ? 'membership.verify'
                : i.status == ItemStatus.returned
                ? 'membership.return'
                : 'membership.decline',
          );
    switch (i.status) {
      case ItemStatus.verified:
        final keluarga = f.householdId == null
            ? ''
            : ' · Keluarga ${nama.keluarga(f.householdId!)}';
        return [
          _KartuHasil(
            judul: f.name,
            st: 'Diverifikasi',
            isi: 'Anggota jemaat$keluarga · $kolom',
            ket:
                'Diverifikasi oleh $oleh, ${saatJemaat(i.decidedAt)}. '
                'Verifikasi bukan persetujuan keuangan dan tidak dilakukan '
                'oleh pemohon sendiri.',
          ),
        ];
      case ItemStatus.returned:
        return [
          _KartuHasil(
            judul: _judul,
            st: 'Dikembalikan',
            isi: 'Alasan: ${i.reason}',
            ket: 'Oleh $oleh, ${saatJemaat(i.decidedAt)}',
          ),
        ];
      case ItemStatus.declined:
        return [
          _KartuHasil(
            judul: _judul,
            st: 'Tidak diterima',
            isi: 'Alasan: ${i.reason}',
            ket:
                'Oleh $oleh, ${saatJemaat(i.decidedAt)}. Data yang diisi '
                'tidak menjadi data anggota.',
          ),
        ];
      case ItemStatus.submitted:
        break;
    }
    if (i.submittedBy == a.personId) {
      return [
        _KartuHasil(
          judul: _judul,
          st: 'Diajukan',
          isi: 'Diajukan ${saatJemaat(i.submittedAt)}',
          ket:
              'Berikutnya: Penatua $kolom memverifikasi data ini. Anda belum '
              'menjadi anggota sampai permohonan Diverifikasi.',
        ),
      ];
    }
    if (_kembali) {
      return [
        ...formAlasan(
          judul: _judul,
          tindakan: 'Kembalikan',
          alasan: _alasan,
          onUbah: () => setState(() {}),
          kirim: () => _putuskan(i, verif: false),
          batal: () => setState(() => _kembali = false),
        ),
        ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
      ];
    }
    final hari = ref.read(hariIniProvider);
    final bipra = computeBipra(
      birthDate: f.birthDate,
      sex: f.sex,
      marital: f.marital,
      at: hari,
    );
    final sebab = ref
        .read(verificationRepositoryProvider)
        .whyNotVerify(a, i.id);
    return [
      _Formulir(f, nama, bipra),
      _KartuIzin(
        versi: i.consentVersion ?? consentVersion,
        tanggal: ref.read(tanggalNaskahProvider),
      ),
      keteranganAlur(context, hanyaKolom(kolom)),
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
}

/// The date of the consent text version (Modul: "Naskah bawaan · versi 1").
final tanggalNaskahProvider = Provider<String>((ref) {
  final t = ref.watch(consentRepositoryProvider).text().date;
  return t == null ? '' : tgl(t.awal);
});

/// The submitted form, read-only (the board's "Mengisi" fields).
class _Formulir extends StatelessWidget {
  const _Formulir(this.f, this.nama, this.bipra);
  final ApplicationForm f;
  final NamaJemaat nama;
  final Bipra? bipra;

  @override
  Widget build(BuildContext context) => Kartu(
    child: kolomJemaat(jarak: 12, [
      _Isian('Nama lengkap', f.name),
      KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          _Isian('Tanggal lahir', tgl(f.birthDate.awal)),
          _Isian(
            'Jenis kelamin',
            f.sex == Sex.male ? 'Laki-laki' : 'Perempuan',
          ),
        ],
      ),
      _Isian(
        'Status pernikahan',
        f.marital.label,
        ket:
            'Bersama tanggal lahir menentukan Kategori BIPRA: '
            '${bipra?.label ?? '—'}',
      ),
      if (f.householdId != null)
        _Isian(
          'Keluarga',
          nama.keluarga(f.householdId!) ?? '',
          ket: 'Setiap orang tetap punya datanya sendiri, termasuk anak',
        ),
      _Isian('Kolom', nama.kolom(f.kolomId)),
    ]),
  );
}

/// A read-only field: label 14 `tinta2`, gap 6, input, optional helper.
class _Isian extends StatelessWidget {
  const _Isian(this.label, this.nilai, {this.ket});

  final String label, nilai;
  final String? ket;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final isian = IsianTeks(
      key: ValueKey('$label $nilai'),
      nilaiAwal: nilai,
      label: label,
      jarakLabel: 6,
      hanyaBaca: true,
      gaya: TextStyle(fontSize: 14, color: c.tinta2),
    );
    if (ket == null) return isian;
    return kolomJemaat(jarak: 6, [isian, keteranganAlur(context, ket!)]);
  }
}

/// The consent the applicant gave (Q28), read-only.
class _KartuIzin extends StatelessWidget {
  const _KartuIzin({required this.versi, required this.tanggal});
  final String versi, tanggal;

  @override
  Widget build(BuildContext context) => kartuAlur([
    const Text(
      'Izin penggunaan data pribadi',
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    keteranganAlur(context, 'Naskah $versi · $tanggal'),
    barisAlur(
      context,
      'Data ini dipakai Jemaat Karunia untuk pelayanan, surat dan Warta '
      'Jemaat. Nama saya di publikasi mengikuti Tampilan nama yang saya '
      'pilih. Saya dapat mencabut izin dan meminta data saya dihapus.',
    ),
    const BarisInfo('Izin data pribadi', 'Diberikan'),
  ]);
}

/// Outcome card: title row with badge, 14 `tinta2` line, 13 `tinta3` note.
class _KartuHasil extends StatelessWidget {
  const _KartuHasil({
    required this.judul,
    required this.st,
    required this.isi,
    required this.ket,
  });

  final String judul, st, isi, ket;

  @override
  Widget build(BuildContext context) => kartuAlur([
    KepalaKartu(judul: judul, ujung: lencanaSt(st)),
    barisAlur(context, isi),
    keteranganAlur(context, ket),
  ]);
}

/// The applicant's own form (AlurAnggota), behind `membership.apply` (DP36).
class _FormulirPemohon extends ConsumerStatefulWidget {
  const _FormulirPemohon();

  @override
  ConsumerState<_FormulirPemohon> createState() => _FormulirPemohonState();
}

class _FormulirPemohonState extends ConsumerState<_FormulirPemohon> {
  final _nama = TextEditingController();
  final _lahir = TextEditingController();
  Sex? _jk;
  MaritalStatus? _nikah;
  String? _kolom;
  bool _izin = false, _sentuh = false;
  Refusal? _tolakan;
  String _pesan = '';

  @override
  void dispose() {
    _nama.dispose();
    _lahir.dispose();
    super.dispose();
  }

  Tanggal? get _tgl {
    final n = bacaTgl(_lahir.text);
    return n == null ? null : Tanggal(n ~/ 10000, n ~/ 100 % 100, n % 100);
  }

  String _alasanAjukan() {
    final t = _tgl;
    if (_nama.text.trim().isEmpty) return 'nama belum diisi.';
    if (t == null) return 'tanggal lahir tidak dikenali.';
    if (!(t < ref.read(hariIniProvider))) {
      return 'tanggal lahir harus sebelum hari ini.';
    }
    if (_jk == null) return 'jenis kelamin belum dipilih.';
    if (_nikah == null) return 'status pernikahan belum dipilih.';
    if (_kolom == null) return 'Kolom belum dipilih.';
    if (!_izin) return 'izin penggunaan data pribadi belum diberikan.';
    return '';
  }

  Future<void> _ajukan() async {
    final r = await jalankanJemaat(
      ref,
      (a, k) => ref
          .read(applicationRepositoryProvider)
          .apply(
            a,
            ApplicationForm(
              name: _nama.text.trim(),
              birthDate: _tgl!,
              sex: _jk!,
              marital: _nikah!,
              kolomId: _kolom!,
            ),
            _izin,
            idempotencyKey: k,
          ),
    );
    if (!mounted || r == null) return;
    setState(() {
      _tolakan = r.refusal;
      if (r.isOk) _pesan = 'Diajukan. Penatua diberi tahu lewat Pemberitahuan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final alasan = _alasanAjukan();
    final nama = ref.watch(namaJemaatProvider);
    return kolomJemaat([
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      IsianAlur(
        label: 'Nama lengkap',
        controller: _nama,
        petunjuk: 'Nama sesuai surat baptis',
        onChanged: (_) => setState(() => _sentuh = true),
      ),
      IsianAlur(
        label: 'Tanggal lahir',
        controller: _lahir,
        petunjuk: 'hh/bb/tttt',
        onChanged: (_) => setState(() => _sentuh = true),
      ),
      ChipPilihan<Sex>(
        label: 'Jenis kelamin',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: const [
          (nilai: Sex.female, teks: 'Perempuan'),
          (nilai: Sex.male, teks: 'Laki-laki'),
        ],
        terpilih: _jk,
        onPilih: (v) => setState(() => _jk = v),
      ),
      ChipPilihan<MaritalStatus>(
        label: 'Status pernikahan',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [
          for (final m in MaritalStatus.values) (nilai: m, teks: m.label),
        ],
        terpilih: _nikah,
        onPilih: (v) => setState(() => _nikah = v),
      ),
      ChipPilihan<String>(
        label: 'Kolom',
        jarakLabel: 6,
        jarakBawah: 0,
        pilihan: [
          for (var k = 1; k <= 12; k++)
            (nilai: 'kolom-$k', teks: nama.kolom('kolom-$k')),
        ],
        terpilih: _kolom,
        onPilih: (v) => setState(() => _kolom = v),
      ),
      KotakCentang(
        nilai: _izin,
        onUbah: (v) => setState(() => _izin = v),
        jarakAtas: 2,
        label: const Text('Saya memberi izin penggunaan data pribadi saya.'),
      ),
      if (_sentuh && alasan.isNotEmpty)
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
            label: 'Ajukan permohonan',
            tindakan: 'Ajukan',
            alasan: alasan,
            periksa: _alasanAjukan,
            sudahMulai: false,
            onPressed: _ajukan,
          ),
        ],
      ),
    ]);
  }
}
