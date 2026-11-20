import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
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
import '../../widgets/kecil.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tekan.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'jemaat_bagian.dart';

/// 74 · Konfirmasi keluarga (spec 20) with AlurKeluarga's confirmation and
/// verification steps: a family imported from the paper book confirms its
/// data and consents, in the app (its representative) or on a signed paper
/// form an officer enters; the verifier of the Kolom, never the one who
/// entered it, verifies it and the family is Aktif.
class KonfirmasiKeluargaScreen extends ConsumerStatefulWidget {
  const KonfirmasiKeluargaScreen({super.key});

  @override
  ConsumerState<KonfirmasiKeluargaScreen> createState() => _State();
}

class _State extends ConsumerState<KonfirmasiKeluargaScreen> {
  static const _formulir = 'Formulir konfirmasi bertanda tangan';
  final _alasan = TextEditingController();
  String? _file;
  bool _izin = false, _kertas = false, _kembali = false;
  String _pesan = '';
  Refusal? _tolakan;

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  /// The selected family, else the first in the actor's reach still to be
  /// confirmed or verified, else the actor's own.
  Household? _keluarga(Actor a) {
    final repo = ref.read(memberRepositoryProvider);
    final id = ref.watch(keluargaDipilihProvider);
    if (id != null) return repo.household(id);
    final can = ref.read(canProvider);
    final hari = ref.read(hariIniProvider);
    bool jangkau(Household h) => can.can(
      a,
      Capability.membershipConfirmHousehold,
      ScopeRef(h.kolomId),
      at: hari,
    );
    final semua = repo.households();
    return semua
            .where((h) => h.status != HouseholdStatus.active && jangkau(h))
            .firstOrNull ??
        repo.member(a.personId)?.household;
  }

  VerificationItem? _konfirmasi(Household h) =>
      ref.read(verificationRepositoryProvider).forHousehold(h.id).lastOrNull;

  String _alasanKirim() => _file == null
      ? 'formulir bertanda tangan belum terlampir.'
      : !_izin
      ? 'formulir harus memuat izin penggunaan data pribadi.'
      : '';

  Future<void> _kirim(Household h, {required bool kertas}) async {
    final r = await jalankanJemaat(
      ref,
      (a, k) => ref
          .read(applicationRepositoryProvider)
          .confirmHousehold(
            a,
            h.id,
            paperForm: kertas ? _file : null,
            expectedRevision: h.revision,
            idempotencyKey: k,
          ),
    );
    if (!mounted || r == null) return;
    setState(() {
      _tolakan = r.refusal;
      if (r.isOk) {
        _pesan =
            'Penatua ${ref.read(namaJemaatProvider).kolom(h.kolomId)} '
            'diberi tahu lewat Pemberitahuan.';
      }
    });
  }

  Future<void> _putuskan(VerificationItem i, {required bool verif}) async {
    final repo = ref.read(verificationRepositoryProvider);
    final r = await jalankanJemaat(
      ref,
      (a, k) => verif
          ? repo.verify(
              a,
              i.id,
              expectedRevision: i.revision,
              idempotencyKey: k,
            )
          : repo.returnForChanges(
              a,
              i.id,
              reason: _alasan.text,
              expectedRevision: i.revision,
              idempotencyKey: k,
            ),
    );
    if (!mounted || r == null) return;
    setState(() {
      _tolakan = r.refusal;
      if (r.isOk) {
        _kembali = false;
        _pesan = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = ref.watch(actorProvider);
    final nama = ref.watch(namaJemaatProvider);
    final h = a == null ? null : _keluarga(a);
    return KerangkaJemaat(
      judul: 'Konfirmasi keluarga',
      anakJudul:
          'Keluarga dari buku anggota mengonfirmasi datanya dan memberi izin',
      tampilan: (h?.id, h?.status, _kertas, _kembali),
      blok: h == null || a == null ? const [] : _isi(a, h, nama),
    );
  }

  List<Widget> _isi(Actor a, Household h, NamaJemaat nama) {
    final c = context.warna;
    final kolom = nama.kolom(h.kolomId);
    final item = _konfirmasi(h);
    final anggota = [
      for (final p in h.memberIds) nama.orang(p).split(' ').first,
    ];
    String catatan;
    switch (h.status) {
      case HouseholdStatus.unconfirmed:
        catatan =
            '${h.importedAt == null ? 'Belum dikonfirmasi.' : 'Diimpor ${tgl(h.importedAt!)} dari buku anggota.'} '
            'Tidak tampil di Warta, surat atau laporan mana pun.';
      case HouseholdStatus.awaiting:
        catatan = item?.paperForm != null
            ? 'Formulir kertas bertanda tangan dimasukkan '
                  '${nama.orang(item!.submittedBy)}, '
                  '${saatJemaat(item.submittedAt)}, untuk keluarga tanpa '
                  'ponsel.'
            : 'Wakil keluarga ${nama.orang(h.representativeId ?? '')} '
                  'mengonfirmasi data ${h.memberIds.length} orang dan memberi '
                  'izin, ${saatJemaat(item?.submittedAt)}.';
      case HouseholdStatus.active:
        catatan = item?.decidedBy == null
            ? 'Nama keluarga dapat tampil sesuai Tampilan nama yang dipilih.'
            : 'Diverifikasi oleh '
                  '${nama.olehSiapa(item!.decidedBy!, item.id, 'membership.verify')}, '
                  '${saatJemaat(item.decidedAt)}. Sejak sekarang nama keluarga '
                  'dapat tampil sesuai Tampilan nama yang dipilih.';
    }
    final kartu = kartuAlur([
      KepalaKartu(
        judul: 'Keluarga ${h.name}',
        ujung: lencanaSt(h.status.label),
      ),
      barisAlur(
        context,
        '$kolom · ${h.memberIds.length} orang: ${anggota.join(', ')}',
      ),
      keteranganAlur(context, catatan),
    ]);
    final tolakan = _tolakan == null ? null : penolakanDari(_tolakan!);
    switch (h.status) {
      case HouseholdStatus.unconfirmed:
        final wakil = h.representativeId == a.personId;
        if (!_kertas) {
          return [
            kartu,
            barisAlur(context, 'Dua jalan konfirmasi:'),
            ?tolakan,
            BarisTombol(
              anak: [
                if (wakil)
                  Tombol(
                    'Keluarga mengonfirmasi di aplikasi',
                    onPressed: () => _kirim(h, kertas: false),
                    jenis: JenisTombol.kedua,
                    ukuran: UkuranTombol.sedang,
                  ),
                Tombol(
                  'Unggah formulir kertas bertanda tangan',
                  onPressed: () => setState(() => _kertas = true),
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
              ],
            ),
          ];
        }
        final sebab = _file != null || _izin ? _alasanKirim() : '';
        return [
          kartu,
          kartuAlur(status: GarisStatus.draf, [
            KepalaKartu(
              judul: _formulir,
              ujung: _file != null
                  ? const LencanaStatus(
                      'Terlampir',
                      bentuk: BentukLencana.garis,
                    )
                  : const LencanaStatus(
                      'Wajib, belum ada',
                      bentuk: BentukLencana.bata,
                    ),
            ),
            if (_file == null)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Tombol(
                  'Pilih file',
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                  lebarPenuh: false,
                  onPressed: () => setState(
                    () => _file = 'formulir-${h.name.toLowerCase()}.jpg',
                  ),
                ),
              )
            else
              keteranganAlur(context, '1 file terlampir · $_file'),
          ]),
          KotakCentang(
            nilai: _izin,
            onUbah: (v) => setState(() => _izin = v),
            jarakAtas: 2,
            label: const Text(
              'Formulir memuat izin penggunaan data pribadi, naskah versi 1.',
            ),
          ),
          if (sebab.isNotEmpty)
            Penolakan(
              tindakan: 'Kirim untuk diverifikasi',
              sebab: sebab,
              jalan: const [],
              ukuranTeks: 14,
            ),
          ?tolakan,
          BarisTombol(
            anak: [
              TombolBersyarat(
                label: 'Kirim untuk diverifikasi',
                tindakan: 'Kirim untuk diverifikasi',
                alasan: _alasanKirim(),
                periksa: _alasanKirim,
                onPressed: () => _kirim(h, kertas: true),
                sudahMulai: false,
              ),
            ],
          ),
        ];
      case HouseholdStatus.awaiting:
        if (item == null) return [kartu];
        if (_kembali) {
          return [
            ...formAlasan(
              judul: 'Konfirmasi keluarga · ${h.name}',
              tindakan: 'Kembalikan',
              alasan: _alasan,
              onUbah: () => setState(() {}),
              kirim: () => _putuskan(item, verif: false),
              batal: () => setState(() => _kembali = false),
            ),
            ?tolakan,
          ];
        }
        final sebab = ref
            .read(verificationRepositoryProvider)
            .whyNotVerify(a, item.id);
        final siapa = ref
            .read(verificationRepositoryProvider)
            .verifiers(item.id)
            .map(nama.orang)
            .join(', ');
        return [
          if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
          kartu,
          if (item.paperForm != null)
            kartuAlur([
              KepalaKartu(
                judul: item.paperForm!,
                ujung: const LencanaStatus(
                  'Terlampir',
                  bentuk: BentukLencana.garis,
                ),
              ),
              keteranganAlur(
                context,
                'Memuat izin penggunaan data pribadi naskah '
                '${item.consentVersion ?? consentVersion}.',
              ),
            ]),
          ?tolakan,
          if (sebab != null) ...[
            Penolakan(
              tindakan: 'Verifikasi data',
              sebab: sebab,
              jalan: const [],
              ukuranTeks: 15,
            ),
            if (siapa.isNotEmpty) keteranganAlur(context, 'Menunggu $siapa.'),
          ] else ...[
            keteranganAlur(context, 'Berikutnya: verifikasi Penatua $kolom.'),
            BarisTombol(
              anak: [
                Tombol(
                  'Verifikasi data',
                  onPressed: () => _putuskan(item, verif: true),
                  jenis: JenisTombol.tinta,
                ),
                Tombol(
                  'Kembalikan dengan alasan',
                  onPressed: () => setState(() {
                    _kembali = true;
                    _alasan.clear();
                  }),
                  jenis: JenisTombol.kedua,
                  ukuran: UkuranTombol.sedang,
                ),
              ],
            ),
          ],
        ];
      case HouseholdStatus.active:
        return [
          kartu,
          // The board's `<a>` link-button: content-box, 51 tall.
          Tekan(
            onTap: () {
              ref
                  .read(anggotaDipilihProvider.notifier)
                  .pilih(h.representativeId);
              context.naikKe(Layar.dataAnggota);
            },
            radius: 14,
            peran: PeranTekan.tautan,
            child: RupaTombol(
              label: 'Buka data keluarga',
              isi: c.permukaan,
              garis: GarisBorder.penuh(c.tinta, radius: 14),
              warnaTeks: c.tinta,
              radius: 14,
              tinggi: 51,
              paddingH: 16,
            ),
          ),
        ];
    }
  }
}
