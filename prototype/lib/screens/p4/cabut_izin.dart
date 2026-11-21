import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../../providers/actor.dart';
import '../../providers/jemaat/jemaat.dart';
import '../../providers/repositories_jemaat.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/ikon.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'jemaat_bagian.dart';

/// 79 · Cabut izin dan hapus data saya + AlurNama's "Cabut izin dan hapus
/// data saya" steps (spec 20, 21; DL13): a request through the member's own
/// login is acted on at once. Their profile, family and Kolom history, life
/// events, name choice and consent go; finance keeps the name as booked and
/// published editions stay as published.
class CabutIzinScreen extends ConsumerStatefulWidget {
  const CabutIzinScreen({super.key});

  @override
  ConsumerState<CabutIzinScreen> createState() => _CabutIzinScreenState();
}

class _CabutIzinScreenState extends ConsumerState<CabutIzinScreen> {
  static const _alasan = 'Atas permintaan anggota sendiri';
  bool _konfirmasi = false, _centang = false;
  DeletionRequest? _selesai;
  Refusal? _tolakan;

  Future<void> _hapus(String id) async {
    final izin = ref.read(consentRepositoryProvider);
    final berlaku = izin.consents(id).where((c) => c.inForce).lastOrNull;
    if (berlaku != null) {
      final r = await jalankanJemaat(
        ref,
        (a, k) => izin.withdraw(
          a,
          id,
          reason: _alasan,
          expectedRevision: berlaku.revision,
          idempotencyKey: k,
        ),
      );
      if (r?.refusal != null) return _gagal(r!.refusal!);
    }
    final minta = await jalankanJemaat(
      ref,
      (a, k) => izin.requestDeletion(a, id, reason: _alasan, idempotencyKey: k),
    );
    if (minta == null) return;
    if (minta.refusal != null) return _gagal(minta.refusal!);
    final jalan = await jalankanJemaat(
      ref,
      (a, k) => izin.executeDeletion(
        a,
        minta.value.id,
        expectedRevision: minta.value.revision,
        idempotencyKey: k,
      ),
    );
    if (!mounted || jalan == null) return;
    if (jalan.refusal != null) return _gagal(jalan.refusal!);
    setState(() => _selesai = jalan.value);
  }

  void _gagal(Refusal r) {
    if (mounted) setState(() => _tolakan = r);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final a = ref.watch(actorProvider);
    final nama = ref.watch(namaJemaatProvider);
    final id = a?.personId ?? '';
    final ada = ref.watch(memberRepositoryProvider).member(id) != null;
    final lini14 = TextStyle(fontSize: 14, color: c.tinta2);
    const judul = TextStyle(fontWeight: FontWeight.w700);
    final selesai = _selesai;
    final List<Widget> isi;
    if (selesai != null) {
      isi = [
        kartuAlur([
          const KepalaKartu(
            judul: 'Catatan penghapusan',
            ujung: LencanaStatus('Selesai', bentuk: BentukLencana.abu),
          ),
          BarisInfo('Dihapus pada', saatJemaat(selesai.executedAt)),
          const BarisInfo('Atas permintaan', 'anggota sendiri'),
          BarisInfo('Dijalankan oleh', nama.orang(selesai.executedBy!)),
          keteranganAlur(
            context,
            'Catatan ini tidak memuat data pribadi. Orangnya tidak lagi punya '
            'status di Data jemaat; anggota yang meninggal dunia tidak pernah '
            'dihapus dengan cara ini.',
          ),
        ]),
      ];
    } else if (!ada) {
      isi = [
        kartuAlur(status: GarisStatus.draf, [
          const Text('Belum ada data anggota', style: judul),
          barisAlur(context, 'Anda belum tercatat di Data jemaat.'),
        ]),
      ];
    } else {
      isi = [
        kartuAlur([
          const Text('Yang dihapus', style: judul),
          Text(
            'Data pribadi Anda, riwayat keluarga dan Kolom, peristiwa, jabatan '
            'yang sedang dipegang (menjadi Jabatan kosong), dan akun Anda.',
            style: lini14,
          ),
        ]),
        kartuAlur(status: GarisStatus.draf, [
          const Text('Yang tetap ada', style: judul),
          Text(
            'Catatan keuangan Jemaat tetap menyimpan nama seperti yang '
            'tercatat, sebagai bagian dari pembukuan gereja. Warta Jemaat dan '
            'dokumen yang sudah diterbitkan tetap persis seperti saat '
            'diterbitkan.',
            style: lini14,
          ),
        ]),
        if (!_konfirmasi)
          BarisTombol(
            tautan: const {1: 32},
            anak: [
              Tombol(
                'Lanjutkan',
                onPressed: () => setState(() => _konfirmasi = true),
                jenis: JenisTombol.kedua,
                ukuran: UkuranTombol.sedang,
              ),
              Tombol(
                'Kembali',
                onPressed: null,
                jenis: JenisTombol.teks,
                ke: ref.watch(kembaliJemaatProvider) == Layar.beranda
                    ? Layar.tampilanNama
                    : Layar.dataAnggota,
                cara: Cara.naik,
              ),
            ],
          )
        else ...[
          _Pernyataan(
            nilai: _centang,
            onUbah: () => setState(() => _centang = !_centang),
          ),
          ?(_tolakan == null ? null : penolakanDari(_tolakan!)),
          BarisTombol(
            anak: [
              TombolBersyarat(
                label: 'Cabut izin dan hapus data saya',
                tindakan: 'Cabut izin dan hapus data saya',
                alasan: _centang ? '' : 'centang dulu pernyataan di atas.',
                sudahMulai: false,
                onPressed: () => _hapus(id),
              ),
              Tombol(
                'Kembali',
                onPressed: () => setState(() {
                  _konfirmasi = false;
                  _centang = false;
                }),
                jenis: JenisTombol.teks,
              ),
            ],
          ),
          Text(
            'Tombol aktif setelah pernyataan di atas dicentang.',
            style: TextStyle(fontSize: 13, color: c.tinta3),
          ),
        ],
      ];
    }
    return KerangkaJemaat(
      judul: 'Cabut izin dan hapus data saya',
      anakJudul: 'Hak anggota; data dihapus setelah dikonfirmasi',
      tampilan: (_konfirmasi, selesai == null),
      blok: isi,
    );
  }
}

/// Statement checkbox (board `<label>`): the whole row toggles; row gap 12,
/// top-aligned, min-height 44, 14 px; the 24 px box sits 2 down.
class _Pernyataan extends StatelessWidget {
  const _Pernyataan({required this.nilai, required this.onUbah});

  final bool nilai;
  final VoidCallback onUbah;

  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    return Tekan(
      onTap: onUbah,
      tercentang: nilai,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox.square(
              dimension: 24,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                  color: nilai ? c.laut : c.permukaan,
                  shape: nilai
                      ? RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        )
                      : GarisBorder.penuh(c.garisTegas, radius: 4),
                ),
                child: nilai
                    ? Center(
                        child: PalakatIkon(
                          Ikon.centang,
                          ukuran: 16,
                          warna: c.diLaut,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Saya mengerti data saya akan dihapus dan tidak dapat '
              'dikembalikan. Untuk menjadi anggota lagi saya harus '
              'mengajukan permohonan baru.',
              style: TextStyle(fontSize: 14, color: c.tinta),
            ),
          ),
        ],
      ),
    );
  }
}
