import 'package:flutter/material.dart';

import '../../mock/mock.dart';
import 'a4_f02b_buku.dart';

/// A4 · F02 Buku Kas Umum, halaman 2 dari 3 (D12: the reversal printed as a
/// negative figure in the column of its original).
class A4F02bScreen extends StatelessWidget {
  const A4F02bScreen({super.key});

  @override
  Widget build(BuildContext context) => HalamanBku(
    halaman: 'halaman 2 dari 3',
    pindahan: (
      'Pindahan dari halaman 1',
      f02Halaman1.masuk,
      f02Halaman1.keluar,
      f02SaldoSetelah[10],
    ),
    baris: f02Oktober.sublist(11, 22),
    saldo: f02SaldoSetelah.sublist(11, 22),
    akhir: (
      'Dipindahkan ke halaman 3',
      f02Halaman2.masuk,
      f02Halaman2.keluar,
      f02SaldoSetelah[21],
    ),
  );
}
