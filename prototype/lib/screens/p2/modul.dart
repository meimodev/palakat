import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../shell/tautan.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_modul.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'inti_bagian.dart';

enum _Tampil { daftar, aktif, mati }

/// 47 · Modul + 57 · Alur · Modul (screens/14, screens/15; phone only): the
/// module registry (WorkspaceRepository). Switching on follows the
/// dependency order; switching off needs a reason and leaves the module Hanya
/// baca (PMP 8). Menus, home rows and routes follow at once (D21).
class ModulScreen extends ConsumerStatefulWidget {
  const ModulScreen({super.key});

  @override
  ConsumerState<ModulScreen> createState() => _ModulScreenState();
}

class _ModulScreenState extends ConsumerState<ModulScreen> {
  final _alasan = TextEditingController();
  var _tampil = _Tampil.daftar;
  Module? _sel;
  String _pesan = '';
  Refusal? _tolak;

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  void _ke(_Tampil t, [VoidCallback? ubah]) {
    setState(() {
      ubah?.call();
      _tampil = t;
      _tolak = null;
    });
    keAtas(context);
  }

  String? _perlu(Module m) {
    final n = m.needs;
    return n != null && !ref.read(canProvider).moduleActive(n)
        ? 'modul ${n.label} harus aktif lebih dulu.'
        : null;
  }

  Future<void> _ubah(ModuleState m, ModuleStatus ke) async {
    final actor = ref.read(actorProvider);
    if (actor == null) return;
    final alasan = _alasan.text.trim();
    final r = await ref
        .read(workspaceRepositoryProvider)
        .setModuleStatus(
          actor,
          m.module,
          ke,
          reason: ke == ModuleStatus.active ? null : alasan,
          expectedRevision: m.revision,
          idempotencyKey: kunciInti(ref),
        );
    if (!mounted) return;
    if (r.refusal case final t?) return setState(() => _tolak = t);
    _ke(_Tampil.daftar, () {
      _alasan.clear();
      _pesan = ke == ModuleStatus.active
          ? 'Modul ${m.module.label} aktif sejak ${ref.read(hariIniProvider)}.'
          : 'Modul ${m.module.label} dinonaktifkan dan menjadi Hanya baca · '
                'alasan: $alasan.';
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final semua = ref.watch(workspaceRepositoryProvider).modules();
    final m = semua.where((x) => x.module == _sel).firstOrNull;
    final isi = switch (_tampil) {
      _Tampil.aktif when m != null => _aktifkan(m),
      _Tampil.mati when m != null => _matikan(m),
      _ => _daftar(semua),
    };
    return LayarPonsel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const KepalaPonsel(
            judul: 'Modul',
            anakJudul:
                'Pimpinan Jemaat yang berwenang mengaktifkan modul saat '
                'orangnya siap',
            kembaliKe: Layar.beranda,
            labelKembali: 'Kembali ke Beranda',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: susun(isi),
            ),
          ),
        ],
      ),
    );
  }

  static KeadaanModul _keadaan(ModuleStatus s) => switch (s) {
    ModuleStatus.active => KeadaanModul.aktif,
    ModuleStatus.off => KeadaanModul.tidakAktif,
    ModuleStatus.readOnly => KeadaanModul.hanyaBaca,
  };

  List<Widget> _daftar(List<ModuleState> semua) {
    final orang = ref.read(peopleRepositoryProvider);
    final riwayat = [
      for (final a
          in ref
              .watch(auditRepositoryProvider)
              .list(const AuditFilter(actionPrefix: 'module.')))
        '${tgl(a.at)} · ${a.summary}'
            '${a.reason == null ? '' : ' · alasan: ${a.reason}'}'
            ' · Oleh ${a.personName}',
    ];
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      KisiOtomatis(
        minLebar: 300,
        jarak: 16,
        anak: [
          for (final m in semua)
            Kartu(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: susun([
                KepalaKartu(
                  judul: m.module.label,
                  ujung: LencanaModul.modul(_keadaan(m.status)),
                ),
                Catatan(
                  m.module.needs != null
                      ? 'Perlu: ${m.module.needs!.label} aktif'
                      : m.status == ModuleStatus.readOnly
                      ? 'Riwayat tetap dapat dibaca'
                      : 'Tidak bergantung pada modul lain',
                ),
                if (m.changedAt case final t?)
                  Catatan(
                    '${m.status == ModuleStatus.active ? 'Diaktifkan' : 'Dinonaktifkan'}'
                    ' ${tgl(t)} oleh ${orang.person(m.changedBy ?? '')?.name ?? ''}',
                  ),
                // Keuangan, the first card, never shows a button (AlurModul).
                if (m.module != Module.finance)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: m.status == ModuleStatus.active
                        ? Tombol(
                            'Nonaktifkan modul',
                            jenis: JenisTombol.teks,
                            ukuran: UkuranTombol.kecil,
                            lebarPenuh: false,
                            onPressed: () => _ke(_Tampil.mati, () {
                              _sel = m.module;
                              _alasan.clear();
                              _pesan = '';
                            }),
                          )
                        : Tombol(
                            'Aktifkan modul',
                            jenis: JenisTombol.kedua,
                            ukuran: UkuranTombol.sedang,
                            lebarPenuh: false,
                            onPressed: () => _ke(_Tampil.aktif, () {
                              _sel = m.module;
                              _pesan = '';
                            }),
                          ),
                  ),
              ], jarak: 4),
            ),
        ],
      ),
      const Catatan(
        'Modul yang tidak aktif tidak tampil di navigasi, pencarian, '
        'pemberitahuan atau keadaan kosong mana pun.',
      ),
      DeretTautan(
        anak: [
          Tautan(
            ke: Layar.pemberiPersetujuan,
            child: const TautanTeks('Tabel pemberi persetujuan', ukuran: 14),
          ),
          Tautan(
            ke: Layar.kasUnit,
            child: const TautanTeks('Kas/Bank yang dikelola unit', ukuran: 14),
          ),
        ],
      ),
      RiwayatAlur(baris: riwayat),
    ];
  }

  Widget _kembali() => Tombol(
    'Kembali',
    jenis: JenisTombol.teks,
    ukuran: UkuranTombol.kecil,
    onPressed: () => _ke(_Tampil.daftar, () => _pesan = ''),
  );

  List<Widget> _aktifkan(ModuleState m) {
    final perlu = _perlu(m.module) ?? '';
    return [
      Kartu(
        child: susun([
          KepalaKartu(
            judul: 'Aktifkan modul: ${m.module.label}',
            ujung: const LencanaModul.modul(KeadaanModul.tidakAktif),
          ),
          if (m.module.needs case final n?)
            BarisInfo('Harus aktif lebih dulu', n.label),
          const Catatan(
            'Mengaktifkan modul membuka layarnya bagi jabatan yang berwenang. '
            'Tidak ada data yang dibuat sendiri oleh aplikasi.',
          ),
        ], jarak: 6),
      ),
      if (_tolak case final t?)
        Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
      TombolBersyarat(
        label: 'Aktifkan modul',
        tindakan: 'Aktifkan modul',
        alasan: perlu,
        periksa: () => _perlu(m.module) ?? '',
        onPressed: () => _ubah(m, ModuleStatus.active),
        baris: [_kembali()],
      ),
    ];
  }

  List<Widget> _matikan(ModuleState m) {
    String syarat() => _alasan.text.trim().isEmpty ? 'Alasan · wajib' : '';
    return [
      Kartu(
        child: susun([
          KepalaKartu(
            judul: 'Nonaktifkan modul: ${m.module.label}',
            ujung: const LencanaModul.modul(KeadaanModul.aktif),
          ),
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Menonaktifkan tidak menghapus apa pun. Modul menjadi ',
                ),
                TextSpan(
                  text: 'Hanya baca',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ': yang sudah ada tetap dapat dibaca, tetapi tidak ada '
                      'yang baru.',
                ),
              ],
            ),
            style: TextStyle(fontSize: 14),
          ),
        ], jarak: 6),
      ),
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasan,
        onChanged: (_) => setState(() => _tolak = null),
        baris: 3,
      ),
      if (_tolak case final t?)
        Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
      // P12: no minimum length, so no sentence; the hint names the field.
      TombolBersyarat(
        label: 'Nonaktifkan modul',
        tindakan: 'Nonaktifkan modul',
        alasan: syarat(),
        periksa: syarat,
        sudahMulai: false,
        onPressed: () => _ubah(m, ModuleStatus.readOnly),
        baris: [_kembali()],
      ),
    ];
  }
}
