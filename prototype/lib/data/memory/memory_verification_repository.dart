import '../../domain/core/core.dart';
import '../../domain/membership/membership.dart';
import '../repositories/verification_repository.dart';
import 'memory_jemaat.dart';

class MemoryVerificationRepository implements VerificationRepository {
  MemoryVerificationRepository(this.j);
  final MemoryJemaat j;

  @override
  List<QueueEntry> queue(Actor actor) {
    final hasil = <QueueEntry>[];
    for (final i in j.t.items) {
      if (!i.open) continue;
      if (j.canVerify(actor.personId, i)) {
        hasil.add(QueueEntry(i));
      } else if (j.selfFor(actor.personId, i) &&
          j
              .pendingScopes(i)
              .any(
                (s) => j.ctx.can
                    .grantsFor(
                      actor.personId,
                      Capability.membershipVerify,
                      ScopeRef(s),
                      at: j.today,
                    )
                    .isNotEmpty,
              )) {
        // Their own family's item, in their scope: shown, not theirs to verify.
        hasil.add(
          QueueEntry(
            i,
            blocked: j.whyNot(actor.personId, i),
            forwardedTo: j.verifiersOf(i).firstOrNull,
          ),
        );
      }
    }
    return hasil;
  }

  @override
  VerificationItem? item(String id) => j.t.item(id);

  @override
  List<VerificationItem> pending(String scopeId) => [
    for (final i in j.t.items)
      if (i.open && j.pendingScopes(i).contains(scopeId)) i,
  ];

  @override
  List<VerificationItem> forHousehold(String householdId) => [
    for (final i in j.t.items)
      if (i.kind == ItemKind.household && i.householdId == householdId) i,
  ];

  @override
  List<String> verifiers(String itemId) {
    final i = j.t.item(itemId);
    return i == null ? const [] : j.verifiersOf(i);
  }

  @override
  String? whyNotVerify(Actor actor, String itemId) {
    final i = j.t.item(itemId);
    return i == null ? 'data tidak ditemukan.' : j.whyNot(actor.personId, i);
  }

  /// The common start of the three decisions: the item, the rule, the
  /// revision; or the refusal.
  (VerificationItem, Grant)? _siap(
    Actor actor,
    String itemId,
    int expectedRevision,
    String aksi,
    void Function(Refused<void>) tolak,
  ) {
    final i = j.t.item(itemId);
    if (i == null) {
      tolak(j.ctx.no(aksi, 'Data tidak ditemukan.'));
      return null;
    }
    final sebab = j.whyNot(actor.personId, i);
    if (sebab != null) {
      final ke = j.verifiersOf(i).map(j.name).join(', ');
      tolak(j.ctx.no(aksi, sebab, whoCanAct: ke.isEmpty ? null : ke));
      return null;
    }
    final basi = j.ctx.stale<void>(i.revision, expectedRevision, aksi);
    if (basi != null) {
      tolak(basi);
      return null;
    }
    return (i, j.grantFor(actor, i));
  }

  Future<Result<void>> _putuskan(
    Actor actor,
    String itemId,
    int expectedRevision,
    String idempotencyKey,
    String aksi,
    ItemStatus jadi,
    String? alasan,
  ) => j.ctx.command(idempotencyKey, () {
    Refused<void>? tolakan;
    final siap = _siap(
      actor,
      itemId,
      expectedRevision,
      aksi,
      (r) => tolakan = r,
    );
    if (siap == null) return tolakan!;
    final (i, g) = siap;
    if (alasan != null && alasan.trim().isEmpty) {
      return j.ctx.no(aksi, 'alasan belum diisi.');
    }
    if (jadi == ItemStatus.verified) {
      i.verifiedScopes.addAll(j.scopesFor(actor.personId, i));
      final sisa = j.pendingScopes(i);
      if (sisa.isNotEmpty) {
        // A Kolom move: one Kolom verified, the other still to verify.
        i.revision += 1;
        j.ctx.audit(
          g,
          action: 'membership.verify',
          summary:
              '${j.title(i)} diverifikasi '
              '${i.verifiedScopes.map(j.scopeName).join(', ')}',
          module: Module.membership,
          ref: RecordRef('membership_item', i.id),
        );
        j.notifyVerifiers(i);
        return const Ok(null);
      }
      _terapkan(i);
    } else if (i.kind == ItemKind.household) {
      j.t.households[i.householdId]?.status = HouseholdStatus.unconfirmed;
    }
    i
      ..status = jadi
      ..decidedBy = actor.personId
      ..decidedAt = j.ctx.now
      ..reason = alasan?.trim()
      ..revision += 1;
    final judul = j.title(i);
    j.ctx.audit(
      g,
      action: switch (jadi) {
        ItemStatus.verified => 'membership.verify',
        ItemStatus.returned => 'membership.return',
        _ => 'membership.decline',
      },
      summary: '$judul ${jadi.label.toLowerCase()}',
      module: Module.membership,
      ref: RecordRef('membership_item', i.id),
      reason: alasan?.trim(),
    );
    j.ctx.notify(
      i.submittedBy,
      title: '$judul ${jadi.label.toLowerCase()}',
      body: alasan == null
          ? 'Oleh ${j.name(actor.personId)}'
          : 'Alasan: ${alasan.trim()}',
      module: Module.membership,
      ref: RecordRef('membership_item', i.id),
    );
    return const Ok(null);
  });

  /// What a verification changes in Data jemaat (PMP 6.1).
  void _terapkan(VerificationItem i) {
    final inti = j.ctx.inti;
    switch (i.kind) {
      case ItemKind.application:
        final f = i.application!;
        final orang = inti.person(i.subjectPersonId!)!;
        orang
          ..status = PersonStatus.active
          ..birthDate = f.birthDate
          ..sex = f.sex
          ..revision += 1;
        j.t.profiles[orang.id] = MemberProfile(
          personId: orang.id,
          kolom: [KolomStint(kolomId: f.kolomId, start: j.today)],
          marital: f.marital,
          memberSince: j.today,
        );
        final h = f.householdId == null ? null : j.t.households[f.householdId];
        if (h != null) j.join(h, orang.id);
        j.t.consents.add(
          Consent(
            id: j.ctx.store.newId('izin'),
            personId: orang.id,
            version: i.consentVersion ?? consentVersion,
            at: i.submittedAt,
            channel: ConsentChannel.app,
            givenBy: orang.id,
          ),
        );
      case ItemKind.lifeEvent:
        final e = i.event!;
        switch (e.kind) {
          case LifeEventKind.marriage:
            for (final p in e.personIds) {
              j.t.profiles[p]
                ?..marital = MaritalStatus.married
                ..revision += 1;
            }
          case LifeEventKind.death:
            for (final p in e.personIds) {
              inti.person(p)
                ?..status = PersonStatus.deceased
                ..revision += 1;
            }
          case LifeEventKind.kolomMove:
            final berlaku = e.effective ?? j.today;
            final h = i.householdId == null
                ? null
                : j.t.households[i.householdId];
            for (final p in h?.memberIds ?? e.personIds) {
              final pr = j.t.profiles[p];
              if (pr == null) continue;
              pr.kolom.last.end = berlaku.tambahHari(-1);
              pr.kolom.add(KolomStint(kolomId: e.toKolomId!, start: berlaku));
              pr.revision += 1;
            }
            if (h != null) h.kolomId = e.toKolomId!;
          default:
        }
      case ItemKind.dataChange:
        break;
      case ItemKind.household:
        final h = j.t.households[i.householdId]!;
        h
          ..status = HouseholdStatus.active
          ..revision += 1;
        for (final p in h.memberIds) {
          final o = inti.person(p);
          if (o != null && o.status == PersonStatus.unconfirmed) {
            o
              ..status = PersonStatus.active
              ..revision += 1;
          }
        }
    }
  }

  @override
  Future<Result<void>> verify(
    Actor actor,
    String itemId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => _putuskan(
    actor,
    itemId,
    expectedRevision,
    idempotencyKey,
    'Verifikasi data',
    ItemStatus.verified,
    null,
  );

  @override
  Future<Result<void>> returnForChanges(
    Actor actor,
    String itemId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => _putuskan(
    actor,
    itemId,
    expectedRevision,
    idempotencyKey,
    'Kembalikan',
    ItemStatus.returned,
    reason,
  );

  @override
  Future<Result<void>> decline(
    Actor actor,
    String itemId, {
    required String reason,
    required int expectedRevision,
    required String idempotencyKey,
  }) => _putuskan(
    actor,
    itemId,
    expectedRevision,
    idempotencyKey,
    'Tidak diterima',
    ItemStatus.declined,
    reason,
  );
}
