import '../../domain/core/core.dart';
import '../repositories/notification_repository.dart';
import 'memory_context.dart';

class MemoryNotificationRepository implements NotificationRepository {
  MemoryNotificationRepository(this.ctx);
  final MemoryContext ctx;

  @override
  List<AppNotification> inbox(String personId) {
    final pref = ctx.inti.preferencesOf(personId);
    return [
      for (final n in ctx.inti.notifications.reversed)
        if (n.recipientId == personId && pref.allows(n.type)) n,
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  int unreadCount(String personId) =>
      inbox(personId).where((n) => !n.read).length;

  @override
  NotificationPreferences preferences(String personId) =>
      ctx.inti.preferencesOf(personId);

  @override
  Future<Result<void>> markRead(
    Actor actor,
    String id, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Tandai dibaca';
    final n = ctx.inti.notifications.where((n) => n.id == id).firstOrNull;
    if (n == null || n.recipientId != actor.personId) {
      return ctx.no(aksi, 'Pemberitahuan ini bukan untuk Anda.');
    }
    final basi = ctx.stale<void>(n.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    if (n.readAt != null) return const Ok(null);
    n
      ..readAt = ctx.now
      ..revision += 1;
    ctx.audit(
      ctx.own(actor),
      action: 'notification.read',
      summary: 'Membaca pemberitahuan: ${n.title}',
      module: n.module,
      ref: RecordRef('notification', n.id),
    );
    return const Ok(null);
  });

  @override
  Future<Result<void>> setPreference(
    Actor actor,
    String type,
    bool on, {
    required int expectedRevision,
    required String idempotencyKey,
  }) => ctx.command(idempotencyKey, () {
    const aksi = 'Ubah pemberitahuan';
    final p = ctx.inti.preferencesOf(actor.personId);
    final basi = ctx.stale<void>(p.revision, expectedRevision, aksi);
    if (basi != null) return basi;
    final sebelum = p.allows(type);
    p
      ..on[type] = on
      ..revision += 1;
    ctx.audit(
      ctx.own(actor),
      action: 'notification.preference',
      summary: 'Pemberitahuan $type ${on ? 'hidup' : 'mati'}',
      before: '$sebelum',
      after: '$on',
    );
    return const Ok(null);
  });
}
