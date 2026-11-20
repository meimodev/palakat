import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/clock.dart';
import '../../providers/core_repositories.dart';
import '../../providers/revision.dart';

import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/sakelar.dart';
import '../../widgets/tekan.dart';
import '../../app/layar.dart';

/// 26 · Pemberitahuan: the in-app notification list with per-type switches
/// (D28, C06). The list and switches are shared with WebPemberitahuan.
class PemberitahuanScreen extends ConsumerStatefulWidget {
  const PemberitahuanScreen({super.key});

  @override
  ConsumerState<PemberitahuanScreen> createState() =>
      _PemberitahuanScreenState();
}

class _PemberitahuanScreenState extends ConsumerState<PemberitahuanScreen>
    with PemberitahuanLogika {
  @override
  Widget build(BuildContext context) => Material(
    type: MaterialType.transparency,
    child: LayarPonsel(
      layarKeuangan: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Pemberitahuan',
            kembaliKe: Layar.keuangan,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CatatanPemberitahuan(),
                  const SizedBox(height: 16),
                  barisBelumDibaca(),
                  const SizedBox(height: 16),
                  kartuDaftar(),
                  const SizedBox(height: 16),
                  judulDitampilkan,
                  const SizedBox(height: 16),
                  kartuJenis(),
                  const SizedBox(height: 16),
                  keteranganJenis(context),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

const List<({String kunci, String nama, String ket})> _jenis = [
  (
    kunci: NotificationType.action,
    nama: 'Perlu tindakan',
    ket: 'Hambatan, draf, dokumen pendukung',
  ),
  (
    kunci: NotificationType.due,
    nama: 'Jatuh tempo',
    ket: 'Uang muka dan titipan',
  ),
  (kunci: NotificationType.file, nama: 'File laporan', ket: 'Siap diunduh'),
  (kunci: NotificationType.ai, nama: 'Bantuan AI', ket: 'Batas biaya'),
];

/// "Hari ini 08.00" for today, else dd/mm/yyyy.
String waktuPemberitahuan(DateTime t, DateTime kini) =>
    tgl(t) == tgl(kini) ? 'Hari ini ${jam(t)}' : tgl(t);

/// The board's logic class: the signed-in person's finance notifications
/// from NotificationRepository (types switched off are left out) and their
/// per-type switches; opening a row marks it read (F21).
mixin PemberitahuanLogika<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  String get _saya => ref.watch(actorProvider)?.personId ?? '';

  List<AppNotification> get _tampil {
    ref.watch(revisionProvider);
    return [
      for (final n in ref.watch(notificationRepositoryProvider).inbox(_saya))
        if (n.module == Module.finance) n,
    ];
  }

  String _kunci(Actor a) => kunciBaru(a.personId, ref.read(clockProvider));

  Future<void> _baca(Iterable<AppNotification> semua) async {
    final a = ref.read(actorProvider);
    if (a == null) return;
    final repo = ref.read(notificationRepositoryProvider);
    for (final n in semua.where((n) => !n.read).toList()) {
      await repo.markRead(
        a,
        n.id,
        expectedRevision: n.revision,
        idempotencyKey: _kunci(a),
      );
    }
  }

  Future<void> _atur(String jenis, bool on) async {
    final a = ref.read(actorProvider);
    if (a == null) return;
    final repo = ref.read(notificationRepositoryProvider);
    await repo.setPreference(
      a,
      jenis,
      on,
      expectedRevision: repo.preferences(a.personId).revision,
      idempotencyKey: _kunci(a),
    );
  }

  /// "Belum dibaca · n" with "Tandai semua dibaca".
  Widget barisBelumDibaca() {
    final c = context.warna;
    final n = _tampil.where((x) => !x.read).length;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 16,
      children: [
        Text(
          'Belum dibaca · $n',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        Flexible(
          child: Tekan(
            onTap: () => _baca(_tampil),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Align(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  'Tandai semua dibaca',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: c.laut,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// The list card, or its empty line when every type is off.
  Widget kartuDaftar() {
    final c = context.warna;
    final baris = _tampil;
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < baris.length; i++)
            _barisNotif(c, baris[i], pertama: i == 0),
          if (baris.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Text(
                'Semua jenis pemberitahuan dimatikan.',
                style: TextStyle(fontSize: 14, color: c.tinta2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _barisNotif(
    PalakatWarna c,
    AppNotification n, {
    required bool pertama,
  }) {
    final dibaca = n.read;
    return Tekan(
      onTap: () => _baca([n]),
      child: Container(
        constraints: const BoxConstraints(minHeight: 64),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: pertama ? null : Border(top: BorderSide(color: c.garis)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dibaca ? null : c.laut,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: dibaca ? FontWeight.w500 : FontWeight.w700,
                    ),
                  ),
                  Text(n.body, style: TextStyle(fontSize: 13, color: c.tinta3)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              waktuPemberitahuan(n.createdAt, ref.read(clockProvider).now()),
              softWrap: false,
              style: TextStyle(fontSize: 13, color: c.tinta3),
            ),
          ],
        ),
      ),
    );
  }

  Widget get judulDitampilkan => const Text(
    'Yang ditampilkan',
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );

  /// The four type switches.
  Widget kartuJenis() {
    final c = context.warna;
    return Kartu(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _jenis.length; i++)
            Container(
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                border: i == 0 ? null : Border(top: BorderSide(color: c.garis)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _jenis[i].nama,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _jenis[i].ket,
                          style: TextStyle(fontSize: 13, color: c.tinta3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Sakelar(
                    nilai: ref
                        .watch(notificationRepositoryProvider)
                        .preferences(_saya)
                        .allows(_jenis[i].kunci),
                    label: 'Pemberitahuan ${_jenis[i].nama}',
                    onUbah: (v) => _atur(_jenis[i].kunci, v),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget keteranganJenis(BuildContext context) => Text(
    'Mematikan pemberitahuan tidak menyembunyikan hambatan: semuanya tetap '
    'ada di Beranda dan di kesiapan tutup buku.',
    style: TextStyle(fontSize: 13, color: context.warna.tinta3),
  );
}

/// The draf note "Hanya di dalam aplikasi."
class CatatanPemberitahuan extends StatelessWidget {
  const CatatanPemberitahuan({super.key});

  @override
  Widget build(BuildContext context) => Kartu(
    status: GarisStatus.draf,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Text.rich(
      TextSpan(
        style: const TextStyle(fontSize: 14),
        children: [
          const TextSpan(
            text: 'Hanya di dalam aplikasi.',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text:
                'Beranda sudah memuat semuanya di “Perlu tindakan”. Ini hanya '
                'daftar di dalam aplikasi: tanpa WhatsApp, SMS, email, atau '
                'pemberitahuan ke layar kunci. Kotak Pemberitahuan untuk semua '
                'modul ada di Putaran 2, dan pemberitahuan dorong lewat '
                'Firebase Cloud Messaging di Putaran 5.',
            style: TextStyle(color: context.warna.tinta2),
          ),
        ],
      ),
    ),
  );
}
