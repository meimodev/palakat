import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../clock.dart';

import '../../core/format.dart';
import '../../core/tanggal.dart';
import '../../data/repositories/master_repository.dart';
import '../../data/seed/seed_keuangan_pengaturan.dart';
import '../../domain/core/core.dart';
import '../../domain/finance/finance.dart';
import '../actor.dart';
import '../core_repositories.dart';
import '../repositories_keuangan.dart';
import '../revision.dart';

/// '{Bulan} {tahun}' of [d].
String bulanDari(Tanggal d) => bulanTahun(d.tahun, d.bulan);

/// The 1st of the month [n] months after [d]'s.
Tanggal awalBulanKe(Tanggal d, int n) {
  final m = d.tahun * 12 + d.bulan - 1 + n;
  return Tanggal(m ~/ 12, m % 12 + 1, 1);
}

/// One Kas/Bank row of Lainnya `/kas`, WebPengaturan and KasUnit.
class BarisKasBank {
  const BarisKasBank({
    required this.akun,
    required this.sub,
    required this.mati,
    required this.akanMati,
    this.unit,
  });

  final Account akun;

  /// 'Aktif · dipakai sejak {bulan}', 'Nonaktif sejak {bulan} · …'.
  final String sub;

  /// Out of use today (shown dashed).
  final bool mati;

  /// Deactivation scheduled from a later month.
  final bool akanMati;

  /// The operating unit's name; null = the Jemaat.
  final String? unit;

  bool get bisaNonaktif => !mati && !akanMati;
}

/// Everything the settings hubs show (Lainnya, WebPengaturan, UbahPengaturan,
/// KasUnit): from the finance repositories, so every twin reads one source.
class Pengaturan {
  const Pengaturan({
    required this.jemaat,
    required this.mulai,
    required this.hariIni,
    required this.kas,
    required this.peruntukan,
    required this.lingkup,
    required this.pemeriksa,
    required this.revisiPemeriksa,
    required this.jadwalPemeriksa,
    required this.versiTerbit,
    required this.versiDraf,
    required this.riwayat,
  });

  final String jemaat;

  /// The cutover date.
  final Tanggal mulai;
  final Tanggal hariIni;
  final List<BarisKasBank> kas;

  /// Names; a later start reads '{name} (mulai {bulan})'.
  final List<String> peruntukan;
  final List<String> lingkup;

  /// The second checker in force today, its value's revision, and the
  /// scheduled change (D24), if any.
  final bool pemeriksa;
  final int revisiPemeriksa;
  final RuleValue? jadwalPemeriksa;

  /// Belanja's published version in force and its open draft (both trees
  /// share the code).
  final MasterVersion? versiTerbit;
  final MasterVersion? versiDraf;

  /// Finance history lines, newest first.
  final List<AuditRecord> riwayat;

  /// The months a change may take effect from: M+1 and M+2.
  List<Tanggal> get bulanBerlaku => [
    awalBulanKe(hariIni, 1),
    awalBulanKe(hariIni, 2),
  ];

  int get kasAktif => kas.where((k) => !k.mati).length;
  int get kasMati => kas.where((k) => k.mati).length;

  /// The second-checker line: 'hidup', or 'hidup · mati mulai {bulan}'.
  String get teksPemeriksa {
    final kini = pemeriksa ? 'hidup' : 'mati';
    final j = jadwalPemeriksa;
    if (j == null || j.on == pemeriksa) return 'Wajib pemeriksa kedua: $kini';
    return 'Wajib pemeriksa kedua: $kini · ${j.on ? 'hidup' : 'mati'} mulai '
        '${bulanDari(j.effectiveFrom)}';
  }

  /// 'Versi {a} diterbitkan · versi {b} masih draf'.
  String get teksMataAnggaran {
    final a = versiTerbit, b = versiDraf;
    return [
      if (a != null) 'Versi ${a.code} diterbitkan',
      if (b != null)
        'versi ${b.code} ${b.status == MasterVersionStatus.reviewed ? 'sudah diperiksa' : 'masih draf'}',
    ].join(' · ');
  }
}

/// One history line as the boards print it: who and what, then when.
({String judul, String waktu}) barisRiwayat(AuditRecord r) => (
  judul: '${r.personName} · ${r.summary}',
  waktu: [
    tglJam(r.at),
    if (r.reason != null) 'Alasan: ${r.reason}',
  ].join(' · '),
);

final pengaturanProvider = Provider<Pengaturan>((ref) {
  ref.watch(revisionProvider);
  final hari = ref.watch(hariIniProvider);
  final akun = ref.watch(accountRepositoryProvider);
  final org = ref.watch(orgRepositoryProvider);
  final jemaat = ref.watch(workspaceRepositoryProvider).workspace().name;
  final setel = ref.watch(settingsRepositoryProvider);
  final master = ref.watch(masterRepositoryProvider);
  final mulai =
      ref.watch(openingRepositoryProvider).opening()?.cutoverDate ?? hari;

  String? namaUnit(String? id) => id == null ? null : org.scope(id)?.name;
  final kas = [
    for (final a in akun.accounts(includeInactive: true))
      () {
        final mati = a.activeTo != null && a.activeTo! < hari;
        final akan = a.activeTo != null && !mati;
        final unit = namaUnit(a.operatedByScopeId);
        final sub = mati
            ? 'Nonaktif sejak ${bulanDari(a.activeTo!.tambahHari(1))} · '
                  'tetap tampil di laporan lama'
            : akan
            ? 'Aktif sampai akhir ${bulanDari(a.activeTo!)} · nonaktif mulai '
                  '${bulanDari(a.activeTo!.tambahHari(1))}'
            : a.activeFrom > hari
            ? 'Berlaku mulai ${bulanDari(a.activeFrom)}'
            : 'Aktif · dipakai sejak ${bulanDari(a.activeFrom)}';
        return BarisKasBank(
          akun: a,
          sub: sub,
          mati: mati,
          akanMati: akan,
          unit: unit,
        );
      }(),
  ];

  String mulaiNanti(String nama, Tanggal dari) =>
      dari > hari ? '$nama (mulai ${bulanDari(dari)})' : nama;
  final peruntukan = [
    for (final f in ref.watch(fundRepositoryProvider).funds())
      mulaiNanti(f.name, f.activeFrom),
  ];
  final lingkup = [
    for (final l in setel.lingkup(at: awalBulanKe(hari, 24)))
      mulaiNanti(
        l.scopeId == ScopeRef.jemaatId
            ? 'Jemaat'
            : org.scope(l.scopeId)?.name ?? l.scopeId,
        l.activeFrom,
      ),
  ];

  final aturan = setel.rulesInForce(at: hari);
  final jadwal = setel
      .scheduled()
      .where((v) => v.rule == FinanceRule.secondChecker)
      .firstOrNull;

  final versi = master.versions(MasterKind.belanja);
  final terbit = versi
      .where(
        (v) =>
            v.status == MasterVersionStatus.published &&
            v.effectiveFrom != null &&
            v.effectiveFrom! <= hari,
      )
      .lastOrNull;
  final draf = versi
      .where(
        (v) =>
            v.status != MasterVersionStatus.published ||
            (v.effectiveFrom != null && v.effectiveFrom! > hari),
      )
      .lastOrNull;

  // ponytail: AuditRepository.list sorts with List.sort, which is not
  // stable, so lines of one instant can come out of order; they are put
  // back in append order by their 'aud-N' id. Drop once the M5 request to
  // sort stably is applied.
  int nomor(AuditRecord r) => int.tryParse(r.id.split('-').last) ?? 0;
  final riwayat =
      [
        for (final r
            in ref.watch(auditRepositoryProvider).list(const AuditFilter()))
          if (r.module == Module.finance ||
              (r.action.startsWith('role.') && r.summary.contains('Bendahara')))
            r,
      ]..sort((a, b) {
        final d = b.at.compareTo(a.at);
        return d != 0 ? d : nomor(b).compareTo(nomor(a));
      });

  return Pengaturan(
    jemaat: jemaat,
    mulai: mulai,
    hariIni: hari,
    kas: kas,
    peruntukan: peruntukan,
    lingkup: lingkup,
    pemeriksa: aturan.secondChecker,
    // ponytail: SettingsRepository has no query for the value in force; a
    // RuleValue is never edited (a change adds a value), so its revision is
    // 1. Upgrade with the requested `valueInForce` query (M5 notes).
    revisiPemeriksa: 1,
    jadwalPemeriksa: jadwal,
    versiTerbit: terbit,
    versiDraf: draf,
    riwayat: riwayat,
  );
});

/// The Bendahara Jemaat post as RoleRepository shows it today.
final postBendaharaProvider = Provider<PostView?>((ref) {
  ref.watch(revisionProvider);
  return ref
      .watch(roleRepositoryProvider)
      .posts()
      .where((p) => p.post.role == Role.bendaharaJemaat)
      .firstOrNull;
});

/// Runs a settings command as the signed-in actor with a fresh key; the
/// refusal, or null when it went through.
Future<Refusal?> jalankanPengaturan<T>(
  WidgetRef ref,
  Future<Result<T>> Function(Actor a, String kunci) perintah,
) async {
  final a = ref.read(actorProvider);
  if (a == null) return null;
  final r = await perintah(a, kunciBaru(a.personId, ref.read(clockProvider)));
  return r is Refused<T> ? r.refusal : null;
}

/// 'Milik sendiri', 'Titipan', 'Keduanya', '' (RD10 "Boleh untuk").
String labelBoleh(AllowedEffect e) => switch (e) {
  AllowedEffect.owned => 'Milik sendiri',
  AllowedEffect.custody => 'Titipan',
  AllowedEffect.both => 'Keduanya',
  AllowedEffect.unset => '',
};

/// One Mata Anggaran release: both trees of one version code.
class RilisMataAnggaran {
  const RilisMataAnggaran({
    required this.kode,
    required this.versi,
    required this.hariIni,
  });

  final String kode;

  /// Per tree; a tree without that code is missing.
  final Map<MasterKind, MasterVersion> versi;
  final Tanggal hariIni;

  /// The least advanced tree's status.
  MasterVersionStatus get status => versi.values
      .map((v) => v.status)
      .reduce((a, b) => a.index <= b.index ? a : b);

  Tanggal? get berlaku => versi.values.first.effectiveFrom;
  bool get terbit => status == MasterVersionStatus.published;
  bool get sudahBerlaku => terbit && berlaku != null && berlaku! <= hariIni;
}

/// The versions MataAnggaran and WebMataAnggaran show: the release in force
/// and the next one (draft, reviewed, or published from a later month).
class VersiMataAnggaran {
  const VersiMataAnggaran({this.kini, this.usulan});
  final RilisMataAnggaran? kini;
  final RilisMataAnggaran? usulan;
}

final versiMataAnggaranProvider = Provider<VersiMataAnggaran>((ref) {
  ref.watch(revisionProvider);
  final hari = ref.watch(hariIniProvider);
  final master = ref.watch(masterRepositoryProvider);
  final perKode = <String, Map<MasterKind, MasterVersion>>{};
  for (final k in MasterKind.values) {
    for (final v in master.versions(k)) {
      (perKode[v.code] ??= {})[k] = v;
    }
  }
  final rilis = [
    for (final e in perKode.entries)
      RilisMataAnggaran(kode: e.key, versi: e.value, hariIni: hari),
  ];
  return VersiMataAnggaran(
    kini: rilis.where((r) => r.sudahBerlaku).lastOrNull,
    usulan: rilis.where((r) => !r.sudahBerlaku).lastOrNull,
  );
});

/// A row of the proposed version with its "Baru" or "Nama berubah" tag
/// against the version in force (DP13: computed).
typedef BarisUsulan = ({MasterRow baris, String? tanda});

List<BarisUsulan> barisUsulan(
  MasterRepository master,
  VersiMataAnggaran v,
  MasterKind k,
) {
  final usul = v.usulan?.versi[k];
  if (usul == null) return const [];
  final lama = {
    for (final r in master.rows(v.kini?.versi[k]?.id ?? '')) r.code: r.name,
  };
  return [
    for (final r in master.rows(usul.id))
      (
        baris: r,
        tanda: !lama.containsKey(r.code)
            ? 'Baru'
            : lama[r.code] != r.name
            ? 'Nama berubah'
            : null,
      ),
  ];
}

/// "2 baris baru · 1 nama berubah · dibanding versi {kini}".
String bedaUsulan(MasterRepository master, VersiMataAnggaran v) {
  final semua = [
    for (final k in MasterKind.values) ...barisUsulan(master, v, k),
  ];
  final baru = semua.where((b) => b.tanda == 'Baru').length;
  final ganti = semua.where((b) => b.tanda == 'Nama berubah').length;
  return [
    '$baru baris baru',
    '$ganti nama berubah',
    if (v.kini != null) 'dibanding versi ${v.kini!.kode}',
  ].join(' · ');
}

/// The Bendahara handover as Bendahara `serah` and WebSerahTerima show it
/// (DP39): 'belum' (nothing prepared), 'diajukan' (prepared, waiting for the
/// authorized church officer to record it), 'tunggu' ("Menunggu verifikasi
/// wewenang") or 'aktif' (the successor holds the post).
class SerahTerima {
  const SerahTerima({
    required this.tahap,
    this.post,
    this.lama,
    this.baru,
    this.namaLama = '',
    this.namaBaru = '',
    this.dokumenBaru,
  });

  final String tahap;
  final PostView? post;

  /// The outgoing holder's assignment (ended once 'aktif').
  final Assignment? lama;

  /// The successor's assignment ('tunggu', 'aktif').
  final Assignment? baru;
  final String namaLama, namaBaru;
  final String? dokumenBaru;
}

final serahTerimaProvider = Provider<SerahTerima>((ref) {
  final p = ref.watch(postBendaharaProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  String nama(String? id) => orang.person(id ?? '')?.name ?? '';
  if (p == null) return const SerahTerima(tahap: 'belum');
  final h = p.handover;
  if (p.pending != null) {
    return SerahTerima(
      tahap: 'tunggu',
      post: p,
      lama: p.holder,
      baru: p.pending,
      namaLama: nama(p.holder?.personId),
      namaBaru: nama(p.pending!.personId),
      dokumenBaru: p.pending!.documentRef,
    );
  }
  if (h != null) {
    return SerahTerima(
      tahap: 'diajukan',
      post: p,
      lama: p.holder,
      namaLama: nama(p.holder?.personId),
      namaBaru: nama(h.toPersonId),
      dokumenBaru: h.documentRef,
    );
  }
  final akhir = p.lastHolder;
  if (p.holder != null && akhir?.endedAt != null) {
    return SerahTerima(
      tahap: 'aktif',
      post: p,
      lama: akhir,
      baru: p.holder,
      namaLama: nama(akhir!.personId),
      namaBaru: nama(p.holder!.personId),
      dokumenBaru: p.holder!.documentRef,
    );
  }
  return SerahTerima(
    tahap: 'belum',
    post: p,
    lama: p.holder,
    namaLama: nama(p.holder?.personId),
    dokumenBaru: suratPenunjukanBaru(ref.watch(hariIniProvider)),
  );
});

/// "Kirim untuk diverifikasi": the holder prepares the handover to the
/// person named [nama] with the new appointment letter (DP39).
Future<Refusal?> siapkanSerahTerima(WidgetRef ref, String nama) {
  final post = ref.read(postBendaharaProvider);
  final cari = nama.trim().isEmpty
      ? const <Person>[]
      : ref.read(peopleRepositoryProvider).search(nama.trim());
  final ke = cari.where((p) => !p.isSystem).firstOrNull;
  final dokumen = ref.read(serahTerimaProvider).dokumenBaru ?? '';
  return jalankanPengaturan(
    ref,
    (a, k) => ref
        .read(roleRepositoryProvider)
        .proposeHandover(
          a,
          post?.post.id ?? '',
          ke?.id ?? '',
          dokumen,
          idempotencyKey: k,
        ),
  );
}

/// One step of Awal's six (D19: all completed, read-only).
typedef LangkahAwal = ({String judul, String sub, String? anak});

/// The opening as Awal, WebAwal and AwalIsian show it (read-only, D19).
class Awal {
  const Awal({
    required this.jemaat,
    required this.mulai,
    required this.langkah,
    required this.saldo,
    required this.total,
    required this.voucher,
    required this.sumber,
    required this.bendahara,
    required this.dokumen,
    required this.diverifikasi,
    required this.bulanFinal,
    required this.kas,
    required this.peruntukan,
    required this.lingkup,
    required this.versi,
  });

  final String jemaat;

  /// The cutover date.
  final Tanggal mulai;
  final List<LangkahAwal> langkah;

  /// Per account at the cutover: (account, total, per Fund name).
  final List<({Account akun, int jumlah, Map<String, int> dana})> saldo;
  final int total;

  /// 'OPN-{tahun}-0001'.
  final String voucher;

  /// Per account id: 'Sumber: …'.
  final Map<String, String> sumber;
  final String bendahara;
  final String dokumen;

  /// 'Petugas verifikasi · dd/mm/yyyy'.
  final String diverifikasi;

  /// "menjadi final setelah {bulan} ditutup" or "final sejak {bulan} ditutup".
  final String bulanFinal;

  /// Names as at the cutover.
  final List<String> kas, peruntukan, lingkup;

  /// 'Versi {kode} diterbitkan · berlaku mulai {bulan}'.
  final String versi;
}

final awalProvider = Provider<Awal?>((ref) {
  ref.watch(revisionProvider);
  final o = ref.watch(openingRepositoryProvider).opening();
  if (o == null) return null;
  final t = ref.watch(transactionRepositoryProvider).get(o.transactionId);
  final akun = ref.watch(accountRepositoryProvider);
  final dana = ref.watch(fundRepositoryProvider);
  final org = ref.watch(orgRepositoryProvider);
  final orang = ref.watch(peopleRepositoryProvider);
  final role = ref.watch(roleRepositoryProvider);
  final jemaat = ref.watch(workspaceRepositoryProvider).workspace().name;
  final mulai = o.cutoverDate;

  final perAkun = <String, Map<String, int>>{};
  for (final a in t?.allocations ?? const <Allocation>[]) {
    final m = perAkun[a.accountId ?? ''] ??= {};
    final f = dana.fund(a.fundId ?? '')?.name ?? a.fundId ?? '';
    m[f] = (m[f] ?? 0) + a.amount;
  }
  final semuaAkun = akun.accounts(includeInactive: true);
  final saldo = [
    for (final a in semuaAkun)
      if (perAkun[a.id] case final m?)
        (akun: a, jumlah: m.values.fold(0, (s, x) => s + x), dana: m),
  ];
  final total = saldo.fold(0, (s, x) => s + x.jumlah);

  final tugas = role
      .assignmentsOf(o.recordedBy)
      .where(
        (a) => role.posts().any(
          (p) => p.post.id == a.postId && p.post.role == Role.bendaharaJemaat,
        ),
      )
      .firstOrNull;
  final wewenang = role
      .grants(personId: o.recordedBy)
      .where((g) => g.assignmentId == tugas?.id)
      .firstOrNull;
  final penguji = orang.person(wewenang?.verifiedBy ?? '')?.name ?? '';

  // DP16: the Kas/Bank that enter the opening (Kas Panitia HUT does not).
  final kas = [for (final s in saldo) s.akun.name];
  final peruntukan = [
    for (final f in dana.funds())
      if (f.activeFrom <= mulai) f.name,
  ];
  final lingkup = [
    for (final l in ref.watch(settingsRepositoryProvider).lingkup(at: mulai))
      l.scopeId == ScopeRef.jemaatId
          ? 'Jemaat'
          : org.scope(l.scopeId)?.name ?? l.scopeId,
  ];
  final master = ref.watch(masterRepositoryProvider);
  final terbit = master
      .versions(MasterKind.belanja)
      .where(
        (v) =>
            v.status == MasterVersionStatus.published &&
            v.effectiveFrom != null &&
            v.effectiveFrom! <= mulai,
      )
      .lastOrNull;
  final versi = terbit == null
      ? ''
      : 'Versi ${terbit.code} diterbitkan · berlaku mulai '
            '${bulanDari(terbit.effectiveFrom!)}';

  final periode = ref.watch(periodRepositoryProvider).periods();
  final pertama = periode.where((p) => p.contains(mulai)).firstOrNull;
  final ditutup = periode.where((p) => p.isClosed).firstOrNull;
  final format = ref
      .watch(reportRepositoryProvider)
      .templates()
      .where((x) => x.acceptedAt != null)
      .firstOrNull;
  final namaPertama = bulanDari(mulai);
  final bulanFinal = pertama?.isClosed ?? false
      ? 'final sejak $namaPertama ditutup'
      : 'menjadi final setelah $namaPertama ditutup';
  final voucher = t?.voucher ?? '';

  return Awal(
    jemaat: jemaat,
    mulai: mulai,
    langkah: [
      (
        judul: 'Identitas Jemaat',
        sub: 'WITA · tahun buku mulai 1 Januari',
        anak: null,
      ),
      (
        judul: 'Kas/Bank, peruntukan, Lingkup',
        sub:
            '${kas.length} Kas/Bank · ${peruntukan.length} peruntukan · '
            '${lingkup.length} Lingkup',
        anak: null,
      ),
      (judul: 'Mata Anggaran', sub: versi, anak: null),
      (
        judul: 'Penunjukan Bendahara',
        sub: 'Wewenang Bendahara aktif',
        anak: 'tunjuk',
      ),
      (
        judul: 'Saldo awal pencatatan',
        sub: 'Dibukukan · $voucher',
        anak: 'saldo',
      ),
      (
        judul: 'Persetujuan format laporan',
        sub: format != null
            ? 'Dicatat ${tgl(format.acceptedAt!)} · Pimpinan Jemaat yang berwenang'
            : ditutup != null
            ? 'Dicatat sebelum tutup buku ${namaBulanPeriode(ditutup)}'
            : 'Pimpinan Jemaat yang berwenang · wajib sebelum tutup buku pertama',
        anak: null,
      ),
    ],
    saldo: saldo,
    total: total,
    voucher: voucher,
    sumber: o.sources,
    bendahara: orang.person(o.recordedBy)?.name ?? '',
    dokumen: tugas?.documentRef ?? '',
    diverifikasi: wewenang?.verifiedAt == null
        ? 'Belum diverifikasi'
        : '$penguji · ${tgl(wewenang!.verifiedAt!)}',
    bulanFinal: bulanFinal,
    kas: kas,
    peruntukan: peruntukan,
    lingkup: lingkup,
    versi: versi,
  );
});

/// '{Bulan} {tahun}' of a period.
String namaBulanPeriode(Period p) => bulanTahun(p.year, p.month);

/// The six steps are done when the format approval is recorded or a month
/// has been closed (a close needs it, RD03).
int langkahSelesai(Awal a) =>
    a.langkah.where((l) => !l.sub.contains('wajib sebelum')).length;
