import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/mock/format.dart';
import 'package:palakat_prototype/widgets/input_format.dart';

String _ketik(TextInputFormatter f, String teks) => f
    .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: teks))
    .text;

void main() {
  test('rp', () {
    expect(rp(-15000), '−Rp15.000');
    expect(rp(-15000).codeUnitAt(0), 0x2212);
    expect(rp(1250000), 'Rp1.250.000');
    expect(rp(0), 'Rp0');
    expect(rp(999), 'Rp999');
    expect(rp(38415000), 'Rp38.415.000');
    expect(kosong, '—');
  });

  test('rpDigit, rpBeda, titik', () {
    expect(rpDigit('1500000'), 'Rp1.500.000');
    expect(rpDigit(''), 'Rp0');
    expect(rpBeda(3150000), '+ Rp3.150.000');
    expect(rpBeda(-500000), '− Rp500.000');
    expect(titik('1250000'), '1.250.000');
    expect(titik(''), '');
  });

  test('hanyaAngka', () {
    expect(hanyaAngka('0012'), '12');
    expect(hanyaAngka('0'), '');
    expect(hanyaAngka('0', simpanNol: true), '0');
    expect(hanyaAngka('007', simpanNol: true), '7');
    expect(hanyaAngka('Rp 1.250.000'), '1250000');
    expect(hanyaAngka('123456789012'), '12345678901');
    expect(hanyaAngka('123456789012', max: 12), '123456789012');
  });

  test('dates and time', () {
    expect(tgl(DateTime(2026, 10, 6)), '06/10/2026');
    expect(tglPanjang(DateTime(2026, 10, 6)), '6 Oktober 2026');
    expect(jam(DateTime(2026, 1, 1, 11, 5)), '11.05');
    expect(tglJam(DateTime(2026, 11, 16, 11, 5)), '16/11/2026 11.05');
    expect(bulanTahun(2026, 10), 'Oktober 2026');
    expect(bulanTahun(2026, 1), 'Januari 2026');
  });

  test('bacaTgl', () {
    expect(bacaTgl('16/11/2026'), 20261116);
    expect(bacaTgl('30/11/2026'), 20261130);
    expect(bacaTgl('31/02/2026'), 20260231);
    expect(bacaTgl(' 16/11/2026 '), 20261116);
    expect(bacaTgl('3/11/2026'), isNull);
    expect(bacaTgl('16-11-2026'), isNull);
    expect(bacaTgl('16/13/2026'), isNull);
    expect(bacaTgl('00/11/2026'), isNull);
    expect(hari, 20261116);
  });

  test('catat, samar, sah, hitungNaik', () {
    expect(catat(['a'], 'b'), ['16/11/2026 · b', 'a']);
    expect(samarHp('081298765432'), '0812 ···· 5432');
    expect(samarEmail('olvie@contoh.id'), 'o···@contoh.id');
    expect(samarEmail(''), 'Belum diisi');
    expect(hpSah('081298765432'), isTrue);
    expect(hpSah('0812345'), isFalse);
    expect(hpSah('091298765432'), isFalse);
    expect(emailSah('olvie@contoh.id'), isTrue);
    expect(emailSah('olvie@contoh'), isFalse);
    expect(hitungNaik(100, 200, 0, 26), 100);
    expect(hitungNaik(100, 200, 26, 26), 200);
    expect(hitungNaik(0, 1000, 11, 22), 875);
  });

  test('RupiahInputFormatter', () {
    const f = RupiahInputFormatter();
    expect(_ketik(f, '0012'), '12');
    expect(_ketik(f, '0'), '');
    expect(_ketik(const RupiahInputFormatter(sisakanNol: true), '0'), '0');
    expect(_ketik(f, '1250000'), '1.250.000');
    expect(_ketik(f, '123456789012'), '12.345.678.901');
    expect(
      _ketik(const RupiahInputFormatter(maks: 12), '123456789012'),
      '123.456.789.012',
    );
    expect(_ketik(f, '12a5x'), '125');
    expect(_ketik(f, ''), '');
    final v = f.formatEditUpdate(
      TextEditingValue.empty,
      const TextEditingValue(text: '1.2500'),
    );
    expect(v.selection, const TextSelection.collapsed(offset: 6));
    expect(angkaDari('1.250.000'), 1250000);
    expect(angkaDari(''), isNull);
    expect(angkaDari('0'), 0);
  });

  test('TanggalInputFormatter', () {
    const f = TanggalInputFormatter();
    expect(_ketik(f, '16/11/2026'), '16/11/2026');
    expect(_ketik(f, '16-11-2026'), '16112026');
    expect(_ketik(f, '16/11/20261'), '16/11/2026');
    expect(_ketik(f, 'ab1/2'), '1/2');
  });
}
