import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/layar.dart';
import '../../core/format.dart';
import '../../domain/core/core.dart';
import '../../providers/actor.dart';
import '../../providers/core_repositories.dart';
import '../../providers/keuangan/beranda.dart';
import '../../providers/revision.dart';
import '../../shell/kepala_ponsel.dart';
import '../../shell/layar_ponsel.dart';
import '../../theme/palakat_tema.dart';
import '../../widgets/alur_kit.dart';
import '../../widgets/garis_status.dart';
import '../../widgets/kecil.dart';
import '../../widgets/lencana_modul.dart';
import '../../widgets/lencana_status.dart';
import '../../widgets/penolakan.dart';
import '../../widgets/pita_jabatan_kosong.dart';
import '../../widgets/riwayat_alur.dart';
import '../../widgets/tata_letak.dart';
import '../../widgets/tombol.dart';
import '../../widgets/tombol_bersyarat.dart';
import 'inti_bagian.dart';

/// 49 · Menjalankan jabatan kosong + 54 · Alur (screens/14, screens/15): the
/// vacant posts from RoleRepository; the Operator takes one over with a reason
/// and an acknowledgement (`coverVacancy`, DL12). The cover ends by itself
/// when a holder is assigned; the strip, band and footer follow it (D18).
class JabatanKosongScreen extends StatelessWidget {
  const JabatanKosongScreen({super.key});

  @override
  Widget build(BuildContext context) => LayarPonsel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KepalaPonsel(
          judul: 'Menjalankan jabatan kosong',
          anakJudul:
              'Operator menjalankan jabatan kosong sampai ada '
              'pemegangnya',
          kembaliKe: Layar.beranda,
          labelKembali: 'Kembali ke Beranda',
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: const IsiJabatanKosong(),
          ),
        ),
      ],
    ),
  );
}

/// The body shared by JabatanKosongScreen and WebJabatanKosongScreen.
class IsiJabatanKosong extends ConsumerStatefulWidget {
  const IsiJabatanKosong({super.key, this.web = false});
  final bool web;

  @override
  ConsumerState<IsiJabatanKosong> createState() => _IsiJabatanKosongState();
}

class _IsiJabatanKosongState extends ConsumerState<IsiJabatanKosong> {
  final _alasan = TextEditingController();
  var _paham = false;
  String? _postId;
  String _pesan = '';
  Refusal? _tolak;

  @override
  void dispose() {
    _alasan.dispose();
    super.dispose();
  }

  void _lihat(String? postId, [VoidCallback? ubah]) {
    setState(() {
      ubah?.call();
      _postId = postId;
      _tolak = null;
    });
    keAtas(context);
  }

  String _syarat() {
    if (_alasan.text.trim().isEmpty) return 'alasan belum diisi.';
    if (!_paham) return 'pernyataan belum dicentang.';
    return '';
  }

  Future<void> _jalankan(PostView p) async {
    final actor = ref.read(actorProvider);
    if (actor == null) return;
    final r = await ref
        .read(roleRepositoryProvider)
        .coverVacancy(
          actor,
          p.post.id,
          reason: _alasan.text.trim(),
          expectedRevision: p.post.revision,
          idempotencyKey: kunciInti(ref),
        );
    if (!mounted) return;
    if (r.refusal case final t?) return setState(() => _tolak = t);
    _lihat(null, () {
      _pesan =
          'Anda menjalankan jabatan kosong ${p.post.title} sejak '
          '${ref.read(hariIniProvider)}.';
      _alasan.clear();
      _paham = false;
    });
  }

  String _nama(String id) =>
      ref.read(peopleRepositoryProvider).person(id)?.name ?? '—';

  @override
  Widget build(BuildContext context) {
    ref.watch(revisionProvider);
    final posts = ref.watch(roleRepositoryProvider).posts();
    final p = posts.where((x) => x.post.id == _postId).firstOrNull;
    return susun(
      p != null && p.vacant && p.cover == null ? _mulai(p) : _daftar(posts),
    );
  }

  List<Widget> _daftar(List<PostView> posts) {
    final actor = ref.watch(actorProvider);
    final saya = actor?.personId;
    final jejak = saya == null
        ? const <AuditRecord>[]
        : ref
              .watch(auditRepositoryProvider)
              .list(AuditFilter(personId: saya))
              .where(
                (a) => a.action == 'role.cover' || a.via is ViaVacancyCover,
              )
              .toList();
    // A post this Operator ran that now has a holder: "sudah terisi".
    final terisi = [
      for (final p in posts)
        if (p.holder case final h?)
          if (jejak.any(
            (a) =>
                a.action == 'role.cover' &&
                a.ref?.id == p.post.id &&
                h.recordedAt != null &&
                !h.recordedAt!.isBefore(a.at),
          ))
            (p, h),
    ];
    final kosong = [
      for (final p in posts)
        if (p.vacant) p,
    ];
    final riwayat = [
      for (final a in jejak)
        '${tgl(a.at)} · ${a.summary} · oleh ${a.actorLine}',
    ];
    return [
      if (_pesan.isNotEmpty) Pesan(Text(_pesan)),
      for (final (p, h) in terisi)
        KotakTerpilih(
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${p.post.title} sudah terisi:',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' ${_nama(h.personId)}, sejak ${h.start}. Anda tidak '
                      'lagi menjalankan jabatan ini.',
                ),
              ],
            ),
          ),
        ),
      if (kosong.isEmpty)
        const KotakKosong(
          'Tidak ada jabatan kosong',
          teks: 'Setiap jabatan sudah ada pemegangnya.',
        ),
      for (final p in kosong) ..._kosong(p, saya),
      RiwayatAlur(baris: riwayat),
      const Catatan(
        'Menjalankan jabatan kosong tidak memberi wewenang atas data keluarga '
        'sendiri, dan berakhir sendiri begitu pemegang jabatan ditugaskan.',
      ),
    ];
  }

  List<Widget> _kosong(PostView p, String? saya) {
    final cover = p.cover;
    final milikSaya = cover != null && cover.personId == saya;
    // DP19: a term that ran out leaves the post vacant the next day; one
    // ended live (endedAt) leaves it vacant at once.
    final h = p.lastHolder;
    final sejak = h?.end == null
        ? null
        : h!.endedAt != null
        ? h.end!
        : h.end!.tambahHari(1);
    final unit =
        ref.read(orgRepositoryProvider).scope(p.post.scopeId)?.name ?? '';
    return [
      if (milikSaya)
        PitaJabatanKosong.web(
          jabatan: p.post.title,
          sejak: tglJam(cover.startedAt),
          operator: _nama(cover.personId),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          siaran: false,
        ),
      Kartu(
        status: GarisStatus.draf,
        child: susun([
          KepalaKartu(
            judul: p.post.title,
            ujung: const LencanaModul.jabatan(KeadaanJabatan.jabatanKosong),
          ),
          Baris2(sejak == null ? 'Belum ada pemegang' : 'Kosong sejak $sejak'),
          Catatan(
            cover == null
                ? 'Selama kosong, pekerjaan ${p.post.title} di $unit tidak '
                      'berjalan.'
                : 'Dijalankan ${_nama(cover.personId)}, Operator sejak '
                      '${tglJam(cover.startedAt)}',
          ),
          if (cover == null)
            BarisTombol(
              anak: [
                Tombol(
                  'Jalankan jabatan kosong',
                  jenis: JenisTombol.tinta,
                  onPressed: () => _lihat(p.post.id, () => _pesan = ''),
                ),
              ],
            ),
        ], jarak: 6),
      ),
      if (milikSaya && p.post.role == Role.bendaharaJemaat) ..._keuangan(),
    ];
  }

  /// The "Pita di setiap layar" cards while running the Bendahara post.
  List<Widget> _keuangan() {
    final b = ref.watch(berandaKeuanganProvider);
    final saldo = Kartu(
      child: susun([
        KepalaKartu(
          judul: 'Saldo buku semua Kas/Bank',
          ujung: Text(
            rp(b.saldoBuku),
            style: PalakatText.jumlah.copyWith(color: context.warna.tinta),
          ),
        ),
        const Catatan('Hanya transaksi yang sudah dibukukan'),
      ], jarak: 6),
    );
    final perlu = Kartu(
      child: susun([
        KepalaKartu(
          judul: 'Perlu tindakan',
          ujung: LencanaStatus(
            '${b.perluTindakan.length}',
            bentuk: BentukLencana.bata,
          ),
        ),
        Baris2('${b.drafJumlah} draf belum dibukukan'),
      ], jarak: 6),
    );
    return [
      if (widget.web)
        BarisLentur(
          jarak: 28,
          jarakBaris: 20,
          anak: [
            Lentur(dasar: 420, tumbuh: 1.3, child: saldo),
            Lentur(dasar: 340, child: perlu),
          ],
        )
      else ...[
        saldo,
        perlu,
      ],
      const Catatan(
        'Pita ini tampil di setiap layar Keuangan selama jabatan dijalankan: '
        'Beranda, Transaksi, Rekonsiliasi, Tutup buku, Laporan.',
      ),
      BarisTombol(
        anak: [
          const Tombol(
            'Buka Keuangan',
            onPressed: null,
            jenis: JenisTombol.kedua,
            ke: Layar.keuangan,
          ),
        ],
      ),
    ];
  }

  List<Widget> _mulai(PostView p) {
    final alasan = _syarat();
    return [
      Kartu(
        child: susun([
          KepalaKartu(
            judul: p.post.title,
            ujung: const LencanaModul.jabatan(KeadaanJabatan.jabatanKosong),
          ),
          const Baris2(
            'Anda akan menjalankan jabatan ini atas nama sendiri. Nama Anda, '
            'bukan nama jabatan, yang tercatat pada setiap tindakan.',
          ),
        ], jarak: 6),
      ),
      IsianAlur(
        label: 'Alasan · wajib',
        controller: _alasan,
        onChanged: (_) => setState(() => _tolak = null),
        baris: 3,
      ),
      KotakCentang(
        nilai: _paham,
        onUbah: (v) => setState(() => _paham = v),
        jarakAtas: 2,
        label: const Text(
          'Saya mengerti setiap tindakan saya tercatat sebagai dijalankan oleh '
          'Operator, dan jabatan ini kembali kepada pemegangnya begitu '
          'ditugaskan.',
        ),
      ),
      if (_tolak case final t?)
        Penolakan(tindakan: t.action, sebab: t.because, jalan: const []),
      TombolBersyarat(
        label: 'Jalankan jabatan kosong',
        tindakan: 'Jalankan jabatan kosong',
        alasan: alasan,
        periksa: _syarat,
        sudahMulai: _alasan.text.trim().isNotEmpty || _paham,
        onPressed: () => _jalankan(p),
        baris: [
          Tombol(
            'Batalkan',
            jenis: JenisTombol.teks,
            ukuran: UkuranTombol.kecil,
            onPressed: () => _lihat(null, () => _pesan = ''),
          ),
        ],
      ),
    ];
  }
}
