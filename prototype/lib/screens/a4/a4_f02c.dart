import 'package:flutter/material.dart';

import '../../mock/format.dart';
import '../../mock/mock.dart';
import '../../theme/palakat_tema.dart';
import 'a4_f02b_buku.dart';

/// A4 · F02 Buku Kas Umum, halaman 3 dari 3: closing totals, closing balance
/// per Kas/Bank and the note of D13.
class A4F02cScreen extends StatelessWidget {
  const A4F02cScreen({super.key});

  // U+200B after "dan BKU-": Chrome breaks the line there, Flutter would not
  static const _catatan =
      '31 baris. Pembayaran yang dibagi ke beberapa Mata Anggaran dicetak satu kali dengan semua nomornya. Pembalikan dicetak sebagai angka negatif di kolom yang sama dengan transaksi asalnya. Nomor di antara BKU-2026-0098 dan BKU-\u200B2026-0133 yang tidak tampil di sini bukan arus kas/bank Oktober 2026; semuanya terdaftar di F12 Daftar Bukti Kas.';

  static const _kasBank = [
    ('Kas', 'kas'),
    ('Bank BNI ··4821', 'bni'),
    ('Bank SulutGo ··1107', 'bsg'),
  ];

  @override
  Widget build(BuildContext context) => HalamanBku(
    halaman: 'halaman 3 dari 3',
    pindahan: (
      'Pindahan dari halaman 2',
      f02Halaman2.masuk,
      f02Halaman2.keluar,
      f02SaldoSetelah[21],
    ),
    baris: f02Oktober.sublist(22),
    saldo: f02SaldoSetelah.sublist(22),
    akhir: (
      'Jumlah dan saldo akhir Kas/Bank',
      f02Jumlah.masuk,
      f02Jumlah.keluar,
      f02Jumlah.saldo,
    ),
    penutup: Builder(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    'Saldo akhir per Kas/Bank',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                for (final (label, id) in _kasBank)
                  Row(
                    children: [
                      Text(label),
                      const SizedBox(width: 28),
                      Expanded(
                        child: Text(
                          rp(saldo31Oktober[id]!),
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontFamily: PalakatText.mono),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Text(
              _catatan,
              style: TextStyle(color: context.warna.tinta2),
            ),
          ),
        ],
      ),
    ),
  );
}
