import 'package:flutter/material.dart';

import '../../motion/kerangka.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/batang_pembagian.dart';
import '../../widgets/garis.dart';
import '../../widgets/ikon.dart';
import '../../widgets/lembar_bawah.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol.dart';
import 'bagi_logika.dart';
import '../../app/layar.dart';

/// 6 · Bagi ke beberapa Mata Anggaran (spec 03, Bagi).
class BagiScreen extends StatefulWidget {
  const BagiScreen({super.key});
  @override
  State<BagiScreen> createState() => _BagiScreenState();
}

class _BagiScreenState extends State<BagiScreen> with LogikaBagi {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final pilihanSisa = pilihan;
    return DefaultTextHeightBehavior(
      textHeightBehavior: cssLeading,
      child: LayarPonsel(
        layarKeuangan: true,
        overlay: [
          if (pilih)
            Positioned.fill(
              child: LembarBawah(
                judul: 'Pilih Mata Anggaran',
                labelTirai: 'Kembali ke pembagian',
                jarak: 0,
                onTutup: tutupPilih,
                isi: [
                  for (final k in pilihanSisa)
                    Tekan(
                      onTap: () => tambah(k),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 60),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: c.garis)),
                        ),
                        // A `<button>` centres its content in the 60 px.
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Belanja $k',
                              style: TextStyle(
                                fontFamily: PalakatText.mono,
                                fontSize: 13,
                                color: c.tinta2,
                              ),
                            ),
                            Text(
                              maBagi[k]!,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (pilihanSisa.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Semua baris contoh sudah dipakai.',
                        style: TextStyle(fontSize: 14, color: c.tinta2),
                      ),
                    ),
                ],
              ),
            ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KepalaPonsel(
              judul: 'Bagi ke beberapa Mata Anggaran',
              anakJudul: 'Belanja · Toko Sinar · satu pembayaran',
              kembaliKe: Layar.keuangan,
              labelKembali: 'Kembali ke transaksi',
              ujung: LencanaStatus(
                'Belanja',
                bentuk: BentukLencana.tinta,
                kepala: true,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jumlah (Rp)',
                          style: TextStyle(fontSize: 14, color: c.tinta2),
                        ),
                        const Text(
                          'Rp1.250.000',
                          style: TextStyle(
                            fontFamily: PalakatText.mono,
                            fontSize: 34,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    BatangPembagian(total: jumlahBagi, bagian: bagian(context)),
                    const SizedBox(height: 8),
                    SisaPembagian(
                      label: labelSisa,
                      jumlah: sisa.abs(),
                      pas: sisa == 0,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: c.permukaan,
                        border: Border.all(color: c.garis),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < baris.length; i++)
                            _baris(context, i),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Tekan(
                      onTap: bukaPilih,
                      radius: 12,
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 48),
                        alignment: Alignment.center,
                        decoration: ShapeDecoration(
                          shape: GarisBorder.putus(c.putus, radius: 12),
                        ),
                        child: Text(
                          '+ Tambah baris',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: c.laut,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pembayaran ini tetap satu transaksi dengan satu No. Bukti. '
                      'Di laporan, jumlahnya tampil sekali dengan daftar Mata '
                      'Anggarannya.',
                      style: TextStyle(fontSize: 13, color: c.tinta3),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
              decoration: BoxDecoration(
                color: c.permukaan,
                border: Border(top: BorderSide(color: c.garis)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!pas) ...[
                    Text(
                      alasan,
                      style: TextStyle(fontSize: 14, color: c.tinta2),
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (dipakai) ...[
                    Gerak(
                      Kerangka.muncul,
                      lama: const Duration(milliseconds: 300),
                      child: Semantics(
                        liveRegion: true,
                        container: true,
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: c.laut,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  TekanAria(
                    onTap: pakai,
                    aktif: pas,
                    petunjuk: pas ? null : alasan,
                    radius: 14,
                    child: RupaTombol(
                      label: 'Pakai pembagian ini',
                      isi: pas ? c.laut : c.garis,
                      warnaTeks: pas ? c.diLaut : c.tinta3,
                      radius: 14,
                      tinggi: 52,
                      paddingH: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _baris(BuildContext context, int i) {
    final c = context.warna;
    final b = baris[i];
    return Container(
      key: ValueKey(b.k),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: i > 0 ? Border(top: BorderSide(color: c.garis)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: warnaBaris(context, i),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belanja ${b.k}',
                      style: TextStyle(
                        fontFamily: PalakatText.mono,
                        fontSize: 13,
                        color: c.tinta2,
                      ),
                    ),
                    ExcludeSemantics(
                      // An inline label: its line keeps the 16 / 1.4 strut.
                      child: Text(
                        b.nama,
                        strutStyle: const StrutStyle(
                          fontFamily: PalakatText.sans,
                          fontSize: 16,
                          height: 1.4,
                          leadingDistribution: TextLeadingDistribution.even,
                        ),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Board margin −8 −10 0 0: drawn 8 up and 10 right of its box.
              // ponytail: the 10 px past the row edge is not hittable.
              MarginNegatif(
                atas: 8,
                child: Transform.translate(
                  offset: const Offset(10, 0),
                  child: Tekan(
                    onTap: () => lepas(b),
                    label: 'Lepas baris ${b.nama}',
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: PalakatIkon(
                          Ikon.silang,
                          ukuran: 18,
                          warna: c.tinta3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (bisaSisa(b)) ...[
                IsiSisaBagi(onTap: () => isiSisa(b)),
                const SizedBox(width: 10),
              ],
              IsianBarisBagi(
                label: b.nama,
                controller: isian(b),
                onChanged: (t) => ubah(b, t),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
