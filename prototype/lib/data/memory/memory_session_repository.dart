import '../../domain/core/core.dart';
import '../repositories/session_repository.dart';
import 'memory_context.dart';

class MemorySessionRepository implements SessionRepository {
  MemorySessionRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<Person> personas() => [
    for (final id in ctx.inti.personaIds) ?ctx.inti.person(id),
  ];

  @override
  SessionRecord? current() {
    final id = ctx.inti.currentSessionId;
    return ctx.inti.sessions.where((s) => s.id == id).firstOrNull;
  }

  @override
  List<Device> devices(String personId) => [
    for (final d in ctx.inti.devices)
      if (d.personId == personId && d.endedAt == null) d,
  ];

  void _end(SessionEnd reason) {
    final s = current();
    if (s != null && !s.ended) {
      s
        ..endedAt = ctx.now
        ..endReason = reason
        ..revision += 1;
    }
  }

  @override
  Future<Result<SessionRecord>> signIn(String personaId) async {
    final p = ctx.inti.person(personaId);
    if (p == null || p.isSystem) {
      return ctx.no('Masuk', 'Orang ini tidak dikenal.');
    }
    _end(SessionEnd.signedOut);
    final pilihan = ctx.can.choicesOf(personaId, at: ctx.today);
    final s = SessionRecord(
      id: ctx.store.newId('sesi'),
      personId: personaId,
      startedAt: ctx.now,
      acting: pilihan.isEmpty
          ? ctx.can.grantsOf(personaId, at: ctx.today).firstOrNull
          : null,
      choices: pilihan,
    );
    ctx.inti.sessions.add(s);
    ctx.inti.currentSessionId = s.id;
    ctx.changed();
    return Ok(s);
  }

  @override
  Future<Result<void>> signOut() async {
    _end(SessionEnd.signedOut);
    ctx.inti.currentSessionId = null;
    ctx.changed();
    return const Ok(null);
  }

  @override
  Future<Result<SessionRecord>> actAs(
    Actor actor, {
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final s = current();
    if (s == null || s.ended || s.personId != actor.personId) {
      return ctx.no('Pilih jabatan', 'Sesi sudah berakhir.');
    }
    final g = ctx.can
        .grantsOf(actor.personId, at: ctx.today)
        .where((g) => g.toActor() == actor)
        .firstOrNull;
    if (g == null) {
      return ctx.no('Pilih jabatan', 'Jabatan ini tidak dapat bertindak.');
    }
    s
      ..acting = g
      ..choices = const []
      ..revision += 1;
    ctx.audit(
      g,
      action: 'session.act_as',
      summary: 'Bertindak sebagai ${g.title}',
      ref: RecordRef('session', s.id),
    );
    return Ok(s);
  });

  @override
  Future<Result<void>> endDevice(
    Actor actor,
    String deviceId, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    final d = ctx.inti.devices.where((d) => d.id == deviceId).firstOrNull;
    if (d == null || d.personId != actor.personId || d.endedAt != null) {
      return ctx.no('Keluarkan', 'Perangkat ini tidak lagi masuk.');
    }
    final basi = ctx.stale<void>(d.revision, expectedRevision, 'Keluarkan');
    if (basi != null) return basi;
    d
      ..endedAt = ctx.now
      ..revision += 1;
    final g = ctx.own(actor);
    ctx.audit(
      g,
      action: 'session.end_device',
      summary: 'Mengakhiri sesi di ${d.name}',
      ref: RecordRef('device', d.id),
    );
    return const Ok(null);
  });
}
