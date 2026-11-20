import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'jemaat_bagian.dart';

/// 78 · Tampilan nama saya di publikasi + AlurNama's name-form steps (spec
/// 20, 21): the member's own choice, which every publication follows
/// (`MaskingRepository`). Without one the family default applies. Withdrawing
/// consent is CabutIzin.
class TampilanNamaScreen extends ConsumerStatefulWidget {
  const TampilanNamaScreen({super.key});

  @override
  ConsumerState<TampilanNamaScreen> createState() => _TampilanNamaScreenState();
}

class _TampilanNamaScreenState extends ConsumerState<TampilanNamaScreen> {
  NameForm? _bentuk;
  bool _pribadi = false;
  String _pesan = '';
  Refusal? _tolakan;

  Future<void> _simpan(String id, NameForm f) async {
    final m = ref.read(maskingRepositoryProvider);
    final r = await jalankanJemaat(
      ref,
      (a, k) => m.set(
        a,
        id,
        f,
        expectedRevision: m.ownChoice(id)?.revision ?? 0,
        idempotencyKey: k,
      ),
    );
    if (!mounted || r == null) return;
    setState(() {
      _tolakan = r.refusal;
      if (r.isOk) _pesan = 'Tampilan nama disimpan: ${f.label}.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final a = ref.watch(actorProvider);
    ref.watch(namaJemaatProvider);
    final id = a?.personId ?? '';
    final anggota = ref.watch(memberRepositoryProvider).member(id);
    final masking = ref.watch(maskingRepositoryProvider);
    if (anggota == null) {
      return KerangkaJemaat(
        judul: 'Tampilan nama saya di publikasi',
        anakJudul:
            'Pilihan Anda wajib diikuti di Warta Jemaat dan publikasi lain',
        tampilan: 'kosong',
        blok: [
          kartuAlur(status: GarisStatus.draf, [
            const Text(
              'Belum ada data anggota',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            barisAlur(context, 'Anda belum tercatat di Data jemaat.'),
          ]),
        ],
      );
    }
    final sendiri = masking.ownChoice(id) != null;
    final tersimpan = masking.preference(id);
    final pilih = _bentuk ?? tersimpan;
    final k13 = TextStyle(fontSize: 13, color: c.tinta3);
    Widget tebal(String awal, String nama) => Text.rich(
      TextSpan(
        text: awal,
        children: [
          TextSpan(
            text: nama,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      style: const TextStyle(fontSize: 15),
    );
    Widget pratinjau(String awal, String nama) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.lautLembut,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 6,
        children: [
          Text('Lihat tampilan nama saya', style: k13),
          tebal(awal, nama),
        ],
      ),
    );
    final riwayat = [
      for (final r
          in ref
              .watch(auditRepositoryProvider)
              .list(AuditFilter(ref: RecordRef('person', id))))
        if (r.action == 'membership.masking.set')
          '${tgl(r.at)} · ${r.summary} · ${r.personName}',
    ];
    final List<Widget> isi;
    if (!sendiri && !_pribadi) {
      final h = anggota.household;
      isi = [
        kartuAlur([
          KepalaKartu(
            judul: 'Bawaan keluarga',
            ujung: LencanaStatus(tersimpan.label, bentuk: BentukLencana.garis),
          ),
          barisAlur(
            context,
            h?.representativeId == null
                ? 'Anda belum memilih sendiri.'
                : 'Diatur Wakil keluarga '
                      '${ref.read(namaJemaatProvider).orang(h!.representativeId!)}. '
                      'Anda belum memilih sendiri.',
          ),
        ]),
        pratinjau(
          'Sampul syukur: ',
          masking.printedName(id, PrintContext.warta),
        ),
        BarisTombol(
          anak: [
            Tombol(
              'Buat pilihan pribadi',
              jenis: JenisTombol.kedua,
              ukuran: UkuranTombol.sedang,
              onPressed: () => setState(() => _pribadi = true),
            ),
          ],
        ),
      ];
    } else {
      final mudahDikenali =
          (pilih == NameForm.bipraKolom || pilih == NameForm.bipra) &&
          anggota.bipra != null;
      final sama = mudahDikenali
          ? ref
                .watch(memberRepositoryProvider)
                .members(kolom: anggota.kolomId)
                .where(
                  (m) =>
                      m.bipra == anggota.bipra &&
                      m.person.status == PersonStatus.active,
                )
                .length
          : 0;
      isi = [
        if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
        Text(
          'Pilihan pribadi',
          style: TextStyle(fontSize: 14, color: c.tinta2),
        ),
        for (final f in NameForm.values)
          _BarisRadio(
            nama: f.label,
            contoh: masking.nameWith(id, f),
            dipilih: pilih == f,
            onPilih: () => setState(() {
              _bentuk = f;
              _pesan = '';
              _tolakan = null;
            }),
          ),
        pratinjau('Syukur HUT pernikahan: ', masking.nameWith(id, pilih)),
        if (mudahDikenali && sama <= 2)
          Kartu(
            status: GarisStatus.draf,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Masih mudah dikenali.',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text:
                        '${ref.read(namaJemaatProvider).kolom(anggota.kolomId)} '
                        'hanya punya $sama anggota ${anggota.bipra!.label}. '
                        'Pilih “Kolom” atau “Tanpa nama” bila tidak ingin '
                        'dikenali.',
                    style: TextStyle(color: c.tinta2),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
        BarisTombol(
          anak: [
            TombolBersyarat(
              label: 'Simpan pilihan',
              tindakan: 'Simpan pilihan',
              alasan: sendiri && pilih == tersimpan
                  ? 'pilihan ini sudah tersimpan.'
                  : '',
              sudahMulai: false,
              onPressed: () => _simpan(id, pilih),
            ),
          ],
        ),
        Text(
          'Pilihan pribadi yang lebih tertutup mengalahkan bawaan keluarga '
          'untuk kegiatan Anda sendiri. Perubahan berlaku untuk publikasi '
          'berikutnya; edisi lama tidak berubah. Hanya Sekretaris Jemaat yang '
          'dapat menampilkan nama sebagai pengecualian, dengan alasan, dan '
          'Anda diberi tahu.',
          style: k13,
        ),
      ];
    }
    return KerangkaJemaat(
      judul: 'Tampilan nama saya di publikasi',
      anakJudul:
          'Pilihan Anda wajib diikuti di Warta Jemaat dan publikasi lain',
      tampilan: (sendiri, _pribadi),
      blok: [
        ...isi,
        BarisTombol(
          anak: [
            Tombol(
              'Cabut izin dan hapus data saya',
              jenis: JenisTombol.teks,
              ukuran: UkuranTombol.kecil,
              onPressed: () => context.dorongKe(Layar.cabutIzin),
            ),
          ],
        ),
        if (riwayat.isNotEmpty) RiwayatAlur(baris: riwayat),
      ],
    );
  }
}

/// A `<label>` radio row: the whole row is the target; the radio is the
/// TampilanNama component's drawn circle (PilihanBulat look).
class _BarisRadio extends StatelessWidget {
  const _BarisRadio({
    required this.nama,
    required this.contoh,
    required this.dipilih,
    required this.onPilih,
  });

  final String nama, contoh;
  final bool dipilih;
  final VoidCallback onPilih;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onPilih,
      tercentang: dipilih,
      label: '$nama, $contoh',
      radius: 14,
      child: Kartu(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: LayoutBuilder(
          builder: (context, ruang) => ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.permukaan,
                    border: Border.all(
                      color: dipilih ? c.tinta : c.tinta3,
                      width: dipilih ? 6 : 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(nama, style: const TextStyle(fontSize: 15)),
                ),
                // CSS flex: the sample keeps its width, shrinking only past
                // the row.
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: ruang.maxWidth - 46),
                  child: Text(
                    contoh,
                    style: TextStyle(fontSize: 13, color: c.tinta3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
