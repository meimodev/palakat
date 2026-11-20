import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';

/// 76 · Data anggota dan keluarga (phone).
class DataAnggotaScreen extends ConsumerWidget {
  const DataAnggotaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Data anggota dan keluarga',
          anakJudul:
              'Satu data untuk setiap orang; keluarga menyimpan riwayatnya',
          kembaliKe: Layar.beranda,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            // A new person starts at the top.
            key: ValueKey(ref.watch(anggotaDipilihProvider)),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: const IsiDataAnggota(),
          ),
        ),
      ],
    ),
  );
}

/// DataAnggota and WebDataAnggota: one member's record (the selected person,
/// else the actor's own), as far as the actor may see it (DL23: a Penatua
/// Kolom sees their own Kolom; the Sekretaris reads all, read-only). Links
/// to phone-only screens are left out on the web.
class IsiDataAnggota extends ConsumerWidget {
  const IsiDataAnggota({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.warna;
    final a = ref.watch(actorProvider);
    final nama = ref.watch(namaJemaatProvider);
    final hari = ref.watch(hariIniProvider);
    final can = ref.watch(canProvider);
    final id = ref.watch(anggotaDipilihProvider) ?? a?.personId;
    final m = id == null
        ? null
        : ref.watch(memberRepositoryProvider).member(id);
    Widget baris13(String t) =>
        Text(t, style: TextStyle(fontSize: 13, color: c.tinta3));
    Widget baris14(String t) =>
        Text(t, style: TextStyle(fontSize: 14, color: c.tinta2));
    if (a == null || m == null) {
      return _Kartu(status: GarisStatus.draf, [
        const Text(
          'Belum ada data anggota',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        baris14('Orang ini belum tercatat di Data jemaat.'),
      ]);
    }
    final sendiri =
        m.person.id == a.personId ||
        (m.household?.memberIds.contains(a.personId) ?? false);
    if (!sendiri &&
        !can.can(a, Capability.membershipView, ScopeRef(m.kolomId), at: hari)) {
      return _kolom([
        Penolakan(
          tindakan: 'Buka data anggota',
          sebab: '${m.person.name} bukan anggota Kolom Anda.',
          jalan: const [],
        ),
        baris13(
          'Penatua Kolom melihat data lengkap hanya untuk Kolomnya sendiri. '
          'Yang sudah diterbitkan tetap dapat dibaca di Warta Jemaat.',
        ),
      ]);
    }
    final kolom = nama.kolom(m.kolomId);
    // DL8: an unconfirmed record is seen only by its Penatua Kolom and the
    // Operator (both confirm households).
    if (!sendiri &&
        m.person.status == PersonStatus.unconfirmed &&
        !can.can(
          a,
          Capability.membershipConfirmHousehold,
          ScopeRef(m.kolomId),
          at: hari,
        )) {
      return _kolom([
        Penolakan(
          tindakan: 'Buka data anggota',
          sebab: 'hanya Penatua $kolom dan Operator yang melihat data ini.',
          jalan: const [],
        ),
      ]);
    }
    final hanyaBaca =
        !sendiri &&
        !can.can(a, Capability.membershipVerify, ScopeRef.anywhere, at: hari) &&
        !can.can(a, Capability.membershipImport, ScopeRef.anywhere, at: hari);
    final lahir = m.person.birthDate;
    switch (m.person.status) {
      case PersonStatus.deceased:
        final mati = ref
            .watch(memberRepositoryProvider)
            .events(m.person.id)
            .where((e) => e.event!.kind == LifeEventKind.death)
            .firstOrNull;
        return _Kartu([
          _Kepala(m.person.name, 'Meninggal dunia', BentukLencana.tinta),
          baris14(
            '$kolom · ${lahir == null ? '—' : tgl(lahir.awal)} – '
            '${mati == null ? '—' : tgl(mati.event!.date.awal)}',
          ),
          baris13(
            'Tidak pernah dihapus. Riwayat keluarga, jabatan, persembahan dan '
            'pelayanan tetap tersimpan. Akun dinonaktifkan dan pemberitahuan '
            'dihentikan.',
          ),
        ]);
      case PersonStatus.unconfirmed:
        final h = m.household;
        return _kolom([
          _Kartu(status: GarisStatus.draf, [
            _Kepala(m.person.name, 'Belum dikonfirmasi', BentukLencana.draf),
            baris14(
              'Dari buku anggota $kolom'
              '${m.profile.importedAt == null ? '' : ' · diimpor ${tgl(m.profile.importedAt!)}'}',
            ),
            baris13(
              'Hanya Penatua $kolom dan Operator yang melihat data ini. Tidak '
              'tampil di publikasi, surat, pencarian jabatan lain atau '
              'laporan.',
            ),
          ]),
          if (h != null && adaLayar(context, Layar.konfirmasiKeluarga))
            BarisLentur(
              jarak: 8,
              anak: [
                Lentur(
                  dasar: 185,
                  maks: 375,
                  child: Tekan(
                    onTap: () {
                      ref.read(keluargaDipilihProvider.notifier).pilih(h.id);
                      context.dorongKe(Layar.konfirmasiKeluarga);
                    },
                    radius: 14,
                    peran: PeranTekan.tautan,
                    child: RupaTombol(
                      label: 'Lihat konfirmasi keluarga',
                      isi: c.permukaan,
                      garis: GarisBorder.penuh(c.tinta, radius: 14),
                      warnaTeks: c.tinta,
                      radius: 14,
                      tinggi: 51,
                      paddingH: 16,
                    ),
                  ),
                ),
              ],
            ),
        ]);
      case PersonStatus.active:
        break;
    }
    final h = m.household;
    final peristiwa = ref.watch(memberRepositoryProvider).events(m.person.id);
    String tanggalPeristiwa(LifeEventKind k) {
      final e = peristiwa.where((x) => x.event!.kind == k).lastOrNull;
      return e == null ? '—' : '${tgl(e.event!.date.awal)} · Diverifikasi';
    }

    final umur = lahir == null ? null : ageAt(lahir, hari);
    final masking = ref.watch(maskingRepositoryProvider);
    final kisi = KisiOtomatis(
      minLebar: 300,
      jarak: 16,
      anak: [
        _Kartu([
          _Kepala(m.person.name, 'Aktif', BentukLencana.laut),
          if (h != null)
            _Info(
              'Keluarga',
              h.representativeId == null
                  ? h.name
                  : '${h.name} · Wakil keluarga: '
                        '${nama.orang(h.representativeId!)}',
            ),
          _Info('Tanggal lahir', lahir == null ? '—' : tgl(lahir.awal)),
          _Info('Status pernikahan', m.profile.marital?.label ?? '—'),
          _Info('Tampilan nama', masking.preference(m.person.id).label),
        ]),
        _Kartu([
          const Text(
            'Kategori BIPRA',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          _Kepala(
            m.bipra?.label ?? 'Belum dihitung',
            m.profile.bipraOverride == null
                ? 'Dihitung dari data'
                : 'Dikoreksi Penatua',
            BentukLencana.garis,
            berat: FontWeight.w600,
          ),
          if (umur != null && m.profile.marital != null)
            baris13(
              'Dasar: $umur tahun dan '
              '${m.profile.marital!.label.toLowerCase()}.',
            ),
          if (m.profile.bipraOverrideReason != null)
            baris13('Alasan koreksi: ${m.profile.bipraOverrideReason}'),
          baris13(
            'Anak: sampai sebelum 12 tahun. Remaja: 12 tahun sampai 17 tahun '
            '364 hari. Pemuda: 18 tahun ke atas dan belum pernah menikah. '
            'Bapa atau Ibu: sudah menikah. Yang pernah menikah tetap Bapa atau '
            'Ibu; yang belum pernah menikah tetap Pemuda, berapa pun umurnya. '
            'Aturan ini dari ketentuan GMIM; gereja tidak mengubahnya.',
          ),
          baris13(
            'Penatua Kolom dapat mengoreksi kategori satu orang dengan alasan '
            'yang tercatat.',
          ),
        ]),
        _Kartu([
          const Text('Kolom', style: TextStyle(fontWeight: FontWeight.w700)),
          for (final s in m.profile.kolom.reversed)
            _Info(
              nama.kolom(s.kolomId),
              s.start != null && s.start! > hari
                  ? 'mulai ${tgl(s.start!.awal)}'
                  : s.end != null
                  ? '${s.start == null ? '—' : tgl(s.start!.awal)} – '
                        '${tgl(s.end!.awal)}'
                  : s.start == null
                  ? 'sekarang'
                  : 'sejak ${tgl(s.start!.awal)}',
            ),
          baris13(
            'Penugasan lama disimpan dengan tanggal berakhirnya. Transaksi '
            'lama tetap pada Lingkup aslinya.',
          ),
        ]),
        _Kartu([
          const Text(
            'Peristiwa',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          _Info('Baptisan', tanggalPeristiwa(LifeEventKind.baptism)),
          _Info('Sidi', tanggalPeristiwa(LifeEventKind.sidi)),
          _Info('Pernikahan', tanggalPeristiwa(LifeEventKind.marriage)),
          if (sendiri && adaLayar(context, Layar.peristiwa))
            Tautan(
              ke: Layar.peristiwa,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1,
                  child: TautanTeks(
                    'Ajukan peristiwa',
                    berat: FontWeight.w700,
                    ukuran: 14,
                  ),
                ),
              ),
            ),
        ]),
      ],
    );
    return _kolom([
      if (hanyaBaca)
        Kartu(
          status: GarisStatus.terpilih,
          radius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Hanya baca.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' Sekretaris Jemaat membaca seluruh Data jemaat untuk '
                      'surat dan Warta, tetapi tidak mengubah atau '
                      'memverifikasinya.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14, color: c.tinta),
          ),
        ),
      kisi,
    ]);
  }
}

Widget _kolom(List<Widget> isi) => Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    for (var i = 0; i < isi.length; i++) ...[
      if (i > 0) const SizedBox(height: 16),
      isi[i],
    ],
  ],
);

/// Card (`dibukukan`, or `draf` dashed): padding 14 × 16, column gap 6.
class _Kartu extends StatelessWidget {
  const _Kartu(this.anak, {this.status = GarisStatus.dibukukan});

  final List<Widget> anak;
  final GarisStatus status;

  @override
  Widget build(BuildContext context) => Kartu(
    status: status,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          anak[i],
        ],
      ],
    ),
  );
}

/// Head row: title (wraps) and a badge that never shrinks, gap 16.
class _Kepala extends StatelessWidget {
  const _Kepala(
    this.judul,
    this.lencana,
    this.bentuk, {
    this.berat = FontWeight.w700,
  });

  final String judul, lencana;
  final BentukLencana bentuk;
  final FontWeight berat;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(judul, style: TextStyle(fontWeight: berat)),
      ),
      const SizedBox(width: 16),
      LencanaStatus(lencana, bentuk: bentuk),
    ],
  );
}

/// Info row 14: label `tinta2`, value right-aligned 600.
class _Info extends StatelessWidget {
  const _Info(this.label, this.nilai);

  final String label, nilai;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: const TextStyle(fontSize: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: context.warna.tinta2)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            nilai,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
