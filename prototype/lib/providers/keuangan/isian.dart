import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/tanggal.dart';
import '../../domain/finance/finance.dart';

/// The open Catat form that Tanggal and Bagi work for. Catat sets it in the
/// callback that opens them; Tanggal writes back the date, Bagi the draft
/// that holds the split. Null outside a form.
class IsianCatat {
  const IsianCatat({
    required this.jenis,
    this.jumlah = 0,
    this.uraian = '',
    this.tanggal,
    this.drafId,
  });

  final TransactionType jenis;
  final int jumlah;

  /// The summary or payee ('Toko Sinar').
  final String uraian;

  /// "Tanggal transaksi"; today when null.
  final Tanggal? tanggal;

  /// The draft the form saves into, once one exists.
  final String? drafId;

  IsianCatat _dengan({Tanggal? tanggal, String? drafId}) => IsianCatat(
    jenis: jenis,
    jumlah: jumlah,
    uraian: uraian,
    tanggal: tanggal ?? this.tanggal,
    drafId: drafId ?? this.drafId,
  );
}

class IsianCatatNotifier extends Notifier<IsianCatat?> {
  @override
  IsianCatat? build() => null;

  void buka(IsianCatat isian) => state = isian;

  /// Tanggal's "Pakai {tanggal}".
  void pakaiTanggal(Tanggal t) => state = state?._dengan(tanggal: t);

  /// Bagi saved the split into [drafId].
  void pakaiDraf(String drafId, IsianCatat dasar) =>
      state = (state ?? dasar)._dengan(drafId: drafId);

  void selesai() => state = null;
}

final isianCatatProvider = NotifierProvider<IsianCatatNotifier, IsianCatat?>(
  IsianCatatNotifier.new,
);

/// The board word for a transaction type: 'Belanja', 'Pendapatan'.
String namaJenis(TransactionType t) => switch (t) {
  TransactionType.income => 'Pendapatan',
  TransactionType.accountTransfer => 'Pindah antar Kas/Bank',
  _ => 'Belanja',
};
