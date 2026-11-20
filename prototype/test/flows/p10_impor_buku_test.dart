// P10 Member book import (README 8.3): Yanti checks the staged Kolom 7
// book, completes a date, decides the possible duplicate in DataGanda
// (merge on the phone, "bukan orang yang sama" on the web) and imports. On
// the phone she enters the family's signed paper form, which she may not
// verify herself; Hendrik, Penatua Kolom 7, verifies it: the family badge
// reads "Aktif" and his home count of unconfirmed members drops.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palakat_prototype/app/layar.dart';
import 'package:palakat_prototype/app/router.dart';
import 'package:palakat_prototype/core/format.dart';
import 'package:palakat_prototype/domain/core/core.dart';
import 'package:palakat_prototype/domain/membership/membership.dart';
import 'package:palakat_prototype/providers/core_repositories.dart';
import 'package:palakat_prototype/providers/repositories_jemaat.dart';
import 'package:palakat_prototype/shell/tautan.dart';

import 'harness.dart';

String _atas(ProviderContainer c) =>
    tumpukanHalaman(c.read(routerProvider)).last;

const _buku = 'Buku anggota Kolom 7 · 2019–2026';

void main() {
  group('P10 impor buku', () {
    for (final tata in [Tata.ponsel, Tata.web]) {
      testWidgets(tata.name, (tester) async {
        final ponsel = tata == Tata.ponsel;
        final c = await bukaAplikasi(tester, tata: tata);
        final impor = c.read(memberImportRepositoryProvider);
        final anggota = c.read(memberRepositoryProvider);
        ImportBatch buku() =>
            impor.batches().firstWhere((b) => b.source == _buku);
        expect(buku().status, ImportStatus.staged);
        // Ferry's family waits for its confirmation from launch (DP21).
        expect(
          anggota.member('ferry')!.household!.status,
          HouseholdStatus.unconfirmed,
        );
        final belumAwal = anggota.counts().unconfirmed;
        final lahirAgustina = c
            .read(peopleRepositoryProvider)
            .person('agustina')!
            .birthDate!;

        // Yanti: check → duplicates → import.
        await masukSebagai(tester, Persona.yanti);
        expect(
          find.text('Buku anggota: 318 baris sudah diimpor'),
          findsOneWidget,
        );
        expect(find.text('$belumAwal belum dikonfirmasi'), findsOneWidget);
        await tekan(tester, '$_buku belum diimpor');
        expect(_atas(c), Layar.imporBuku.lokasi());
        expect(find.text('28 baris · belum ada yang diimpor'), findsOneWidget);
        await tekan(tester, 'Jalankan pengecekan');
        expect(buku().status, ImportStatus.checked);
        expect(find.text('Kemungkinan data ganda'), findsOneWidget);
        expect(find.text('Tidak diimpor'), findsOneWidget);
        expect(find.text('Perlu dilengkapi'), findsOneWidget);
        expect(
          find.text(
            'Tidak dapat dilakukan: Impor. tanggal lahir Agustina Lasut '
            'belum lengkap.',
            findRichText: true,
          ),
          findsNothing,
        );
        await isi(tester, 'Tanggal lahir', tgl(lahirAgustina.awal));

        // DataGanda: Novita from the book against Novita in Data jemaat.
        await tekan(tester, 'Tinjau kemungkinan data ganda');
        expect(_atas(c), Layar.dataGanda.lokasi());
        expect(find.text('Buku anggota · baris 23'), findsOneWidget);
        await tekan(tester, ponsel ? 'Gabungkan' : 'Bukan orang yang sama');
        final ganda = impor.duplicates().single;
        expect(
          ganda.status,
          ponsel ? DuplicateStatus.merged : DuplicateStatus.notSame,
        );
        expect(
          find.textContaining('Oleh Yanti Sumual, Operator · '),
          findsOneWidget,
        );
        c.read(routerProvider).pop();
        await tester.pumpAndSettle();

        final n = ponsel ? 26 : 27;
        await tekan(tester, 'Impor $n baris');
        expect(buku().status, ImportStatus.imported);
        expect(
          find.text(
            '$n orang masuk sebagai Belum dikonfirmasi. Hanya Penatua '
            'Kolom 7 dan Operator yang dapat melihatnya. Tidak ada yang '
            'tampil di publikasi sampai keluarganya mengonfirmasi dan '
            'memberi izin.',
            findRichText: true,
          ),
          findsOneWidget,
        );
        final ferry = anggota.member('ferry')!;
        expect(ferry.person.status, PersonStatus.unconfirmed);
        expect(ferry.household!.name, 'Wenas-Lasut');
        expect(ferry.household!.status, HouseholdStatus.unconfirmed);
        expect(anggota.member('agustina')!.person.birthDate, lahirAgustina);
        final novitaLagi = c
            .read(peopleRepositoryProvider)
            .search('Novita Wenas');
        expect(novitaLagi, hasLength(ponsel ? 1 : 2));
        final belumSetelah = anggota.counts().unconfirmed;
        // Ferry (unconfirmed) and Agustina (active) were already there.
        expect(belumSetelah, belumAwal + n - 2);
        expect(
          jejakTerakhir(c, 'membership.import.commit').personName,
          'Yanti Sumual',
        );

        if (!ponsel) {
          // The family confirmation is phone-only.
          expect(find.text('Lihat konfirmasi keluarga'), findsNothing);
          await keluar(tester);
          return;
        }

        // The family's signed paper form, entered by Yanti.
        await tekan(tester, 'Lihat konfirmasi keluarga');
        expect(_atas(c), Layar.konfirmasiKeluarga.lokasi());
        expect(find.text('Keluarga Wenas-Lasut'), findsOneWidget);
        expect(find.text('Belum dikonfirmasi'), findsOneWidget);
        await tekan(tester, 'Unggah formulir kertas bertanda tangan');
        await tekan(tester, 'Pilih file');
        await tekan(
          tester,
          'Formulir memuat izin penggunaan data pribadi, naskah versi 1.',
        );
        await tekan(tester, 'Kirim untuk diverifikasi');
        expect(
          anggota.household('wenas-lasut')!.status,
          HouseholdStatus.awaiting,
        );
        expect(find.text('Menunggu verifikasi'), findsOneWidget);
        expect(
          find.text(
            'Tidak dapat dilakukan: Verifikasi data. yang memasukkan '
            'formulir tidak memverifikasinya sendiri.',
            findRichText: true,
          ),
          findsOneWidget,
        );
        await keluar(tester);

        // Hendrik verifies it.
        await masukSebagai(tester, Persona.hendrik);
        await tekan(tester, 'Sebagai Penatua Kolom 7');
        final belum7 = anggota.counts(kolom: 'kolom-7').unconfirmed;
        expect(
          find.text('$belum7 anggota Kolom 7 belum dikonfirmasi'),
          findsOneWidget,
        );
        c.read(routerProvider).push(Layar.verifikasi.lokasi());
        await tester.pumpAndSettle();
        await tekan(tester, 'Konfirmasi keluarga · Wenas-Lasut');
        expect(_atas(c), Layar.konfirmasiKeluarga.lokasi());
        await tekan(tester, 'Verifikasi data');
        expect(find.text('Aktif'), findsOneWidget);
        expect(
          anggota.household('wenas-lasut')!.status,
          HouseholdStatus.active,
        );
        expect(anggota.member('ferry')!.person.status, PersonStatus.active);
        expect(
          jejakTerakhir(c, 'membership.verify').personName,
          'Pnt. Hendrik Rumagit',
        );
        c.read(routerProvider).go(Layar.beranda.lokasi());
        await tester.pumpAndSettle();
        expect(
          find.text('${belum7 - 1} anggota Kolom 7 belum dikonfirmasi'),
          findsOneWidget,
        );
        await keluar(tester);
      });
    }
  });
}
