import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/finance/finance.dart';
import '../../providers/keuangan/beranda.dart';
import 'draf.dart';

import '../../motion/kerangka.dart';
import '../../shell/halaman_web.dart';
import '../../shell/nav_samping.dart';
import '../../shell/panel_samping.dart';
import '../../shell/tautan.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/chip_pilihan.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/isian_alasan.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/status_simpan.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../app/layar.dart';

/// WebDraf: the draft `/draf/:id` (see [LogikaDraf]); Pindah tanggal and
/// Batalkan open a side panel (docs/build/screens/06-bukti.md).
class WebDrafScreen extends ConsumerStatefulWidget {
  const WebDrafScreen({super.key});

  @override
  ConsumerState<WebDrafScreen> createState() => _WebDrafScreenState();
}

class _WebDrafScreenState extends ConsumerState<WebDrafScreen> with LogikaDraf {
  @override
  Widget build(BuildContext context) {
    final c = context.warna;
    final x = t;
    final draf = x != null && x.isDraft;
    final b = bulan;
    final teks13 = TextStyle(fontSize: 13, color: c.tinta3);
    final teks14 = TextStyle(fontSize: 14, color: c.tinta2);

    Widget kolom(List<Widget> anak, double jarak) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < anak.length; i++) ...[
          if (i > 0) SizedBox(height: jarak),
          anak[i],
        ],
      ],
    );

    // The board's button row is a wrapping flex row with `align-items:
    // stretch`: a 48 button that shares the first line with the 52 high
    // "Periksa dan bukukan" grows to 52.
    final bisaBuku = draf && !tutup;
    final gayaTombol = DefaultTextStyle.of(context).style
        .copyWith(fontWeight: FontWeight.w700);
    double lebarTombol(String label) =>
        (TextPainter(
          text: TextSpan(text: label, style: gayaTombol),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout()).width +
        43; // padding 2 × 20 + the 1.5 line on each side
    Widget tombol(String label, VoidCallback onTap, bool tinggi) => Tombol(
      label,
      onPressed: onTap,
      jenis: JenisTombol.kedua,
      ukuran: tinggi ? UkuranTombol.besar : UkuranTombol.sedang,
      paddingH: 20,
      lebarPenuh: false,
    );

    final kiri = kolom([
      if (x == null) Text('Draf tidak ditemukan.', style: teks14),
      if (konflik)
        PitaDiubahOrangLain(oleh: pengubah.$1, jam: pengubah.$2, onMuat: muat),
      if (draf) ...[
        Kartu(
          status: GarisStatus.draf,
          radius: 16,
          padding: const EdgeInsets.all(18),
          child: kolom([
            const Align(
              alignment: Alignment.centerLeft,
              child: LencanaStatus(
                'Draf · belum masuk saldo',
                bentuk: BentukLencana.draf,
              ),
            ),
            Text(
              rp(jumlah),
              style: PalakatText.jumlahIsian.copyWith(color: c.tinta2),
            ),
            Text(
              x.description,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              '$kasBank · tanggal transaksi '
              '${tglPanjang(x.effectiveDate.awal)}',
              style: teks13,
            ),
            if (b != null)
              Text(
                '${namaBulan(b)}${tutup ? ' · Sudah ditutup' : ' · Belum ditutup'}',
                style: teks13,
              ),
          ], 6),
        ),
        if (tutup) penolakanTutup(),
        if (lembar == null) ?penolakan(),
      ],
      if (x != null && x.status == TransactionStatus.cancelled)
        Gerak(
          Kerangka.muncul,
          lama: const Duration(milliseconds: 300),
          child: Kartu(
            padding: const EdgeInsets.all(18),
            child: kolom([
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: c.garis,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Dibatalkan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: c.tinta2,
                    ),
                  ),
                ),
              ),
              Text(
                rp(jumlah),
                style: PalakatText.jumlahIsian.copyWith(
                  color: c.tinta3,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: c.tinta3,
                ),
              ),
              Text(
                x.description,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text('Alasan: ${x.cancelReason ?? ''}', style: teks14),
              Text(
                'Dibatalkan oleh $dibatalkanOleh, '
                '${x.cancelledAt == null ? '' : tglJam(x.cancelledAt!)} · '
                'tidak pernah punya No. Bukti · hanya dapat dilihat',
                style: teks13,
              ),
            ], 6),
          ),
        ),
      if (draf)
        LayoutBuilder(
          builder: (context, batas) {
            // Which of Pindah tanggal / Batalkan still fit on the first line.
            var lebar = bisaBuku ? lebarTombol('Periksa dan bukukan') : 0.0;
            bool sebaris(String label) {
              if (!bisaBuku) return false;
              lebar += 8 + lebarTombol(label);
              return lebar <= batas.maxWidth;
            }

            final pindahTinggi = sebaris('Pindah tanggal');
            final batalTinggi = pindahTinggi && sebaris('Batalkan');
            return Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (bisaBuku)
                    Tombol(
                      'Periksa dan bukukan',
                      onPressed: bukukan,
                      paddingH: 20,
                      lebarPenuh: false,
                    ),
                  // Kept in full look while the conflict locks them; the
                  // conflict card above is the reason.
                  tombol('Pindah tanggal', () => buka('pindah'), pindahTinggi),
                  tombol('Batalkan', () => buka('batal'), batalTinggi),
                ],
              ),
            );
          },
        ),
      if (x != null && x.isPosted)
        Text(
          'Sudah dibukukan sebagai ${x.voucher}.',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      if (x != null)
        kolom([
          const Text(
            'Riwayat',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          for (final h in riwayat) Text(h, style: teks14),
        ], 6),
    ], 16);

    final pindah = lembar == 'pindah';
    final keBulan = keTerpilih;
    final panel = lembar == null
        ? null
        : PanelSamping(
            kotak: true,
            muncul: true,
            // flex-basis 360 is the content box: + padding 40 + border 2.
            dasar: 402,
            anak: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      pindah ? 'Pindah tanggal' : 'Batalkan draf',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    pindah
                        ? 'Hanya bulan sesudahnya yang belum ditutup. Draf '
                              'tetap Draf, dan tanda sudah diperiksa atau '
                              'persetujuan yang ada akan hilang.'
                        : 'Draf yang dibatalkan tidak pernah punya No. Bukti '
                              'dan tetap dapat dilihat bersama alasannya.',
                    style: teks14,
                  ),
                ],
              ),
              if (pindah)
                ChipPilihan<String>(
                  label: 'Pindah ke bulan',
                  pilihan: [
                    for (final p in pilihanBulan)
                      (nilai: p.id, teks: '${namaBulan(p)} · Belum ditutup'),
                  ],
                  terpilih: keBulan,
                  onPilih: (id) => setState(() => ke = id),
                  // The inline chips' line box sits 2 px lower on the board.
                  jarakLabel: 10,
                ),
              // The inline textarea leaves a line-box descent (4 px) under it.
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: IsianAlasan(
                  controller: alasan,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              ?penolakan(),
              Tombol(
                pindah && keBulan.isNotEmpty
                    ? 'Pindah tanggal ke ${namaPeriode(keBulan)}'
                    : pindah
                    ? 'Pindah tanggal'
                    : 'Batalkan draf',
                onPressed: simpan,
                jenis: JenisTombol.tinta,
                nonaktif:
                    !IsianAlasan.terisi(alasan.text) ||
                    (pindah && keBulan.isEmpty),
                paddingH: 20,
              ),
              Tombol(
                'Kembali',
                onPressed: tutupLembar,
                jenis: JenisTombol.teks,
                warnaTeks: c.tinta,
              ),
            ],
          );

    return Material(
      type: MaterialType.transparency,
      child: HalamanWeb(
        layarKeuangan: true,
        nav: const NavSamping(item: navKeuangan, aktif: 1),
        isi: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarginNegatif(
                atas: 12,
                bawah: 12,
                child: Tautan(
                  ke: Layar.transaksi,
                  cara: Cara.naik,
                  child: const Align(
                    widthFactor: 1,
                    heightFactor: 1,
                    child: TautanTeks('Transaksi', ukuran: 14),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: const Text(
                  'Draf',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          BarisLentur(
            jarak: 24,
            anak: [
              Lentur(dasar: 460, tumbuh: 999, child: kiri),
              ?panel?.lentur,
            ],
          ),
        ],
      ),
    );
  }
}
