import 'files.dart';
import 'modules.dart';

/// Notification types a person can switch off (Pemberitahuan settings).
/// The finance four are the boards' `jenis`; [role] is the core type.
abstract final class NotificationType {
  static const action = 'tindak';
  static const due = 'tempo';
  static const file = 'file';
  static const ai = 'ai';
  static const role = 'jabatan';

  /// The defaults: tindak, tempo, file and jabatan on; ai off.
  static const defaults = {
    action: true,
    due: true,
    file: true,
    ai: false,
    role: true,
  };
}

/// One inbox row (PMP 5 Notifications). Repositories write them for their
/// recipients inside the command that causes them.
class AppNotification {
  AppNotification({
    required this.id,
    required this.recipientId,
    required this.type,
    this.module,
    required this.title,
    required this.body,
    required this.createdAt,
    this.ref,
    this.readAt,
    this.revision = 1,
  });

  final String id;
  final String recipientId;

  /// A [NotificationType] value.
  final String type;

  /// Null for core notifications.
  final Module? module;
  final String title;
  final String body;
  final DateTime createdAt;
  final RecordRef? ref;
  DateTime? readAt;
  int revision;

  bool get read => readAt != null;
}

/// A person's notification switches.
class NotificationPreferences {
  NotificationPreferences({
    required this.personId,
    Map<String, bool>? on,
    this.revision = 1,
  }) : on = {...NotificationType.defaults, ...?on};

  final String personId;
  final Map<String, bool> on;
  int revision;

  bool allows(String type) => on[type] ?? true;
}
