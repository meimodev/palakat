import 'capabilities.dart';

/// Why a session ended (README 3.6).
enum SessionEnd {
  signedOut,

  /// The assignment it acted in ended (the handover of F20 activating).
  authorityEnded,
}

/// A signed-in session on this device (SessionRepository).
class SessionRecord {
  SessionRecord({
    required this.id,
    required this.personId,
    required this.startedAt,
    this.acting,
    this.choices = const [],
    this.endedAt,
    this.endReason,
    this.revision = 1,
  });

  final String id;
  final String personId;
  final DateTime startedAt;

  /// The post the person acts in. Picked at sign-in when exactly one post
  /// can act; null while [choices] waits for "Sebagai …" (Q31), and for a
  /// member without a post.
  Grant? acting;

  /// The posts to choose from when two can act; empty otherwise.
  List<Grant> choices;
  DateTime? endedAt;
  SessionEnd? endReason;
  int revision;

  bool get ended => endedAt != null;
}

/// A device the person is signed in on elsewhere (AkunSaya "Perangkat yang
/// masuk"); the current device is the session itself.
class Device {
  Device({
    required this.id,
    required this.personId,
    required this.name,
    this.lastUsed,
    this.endedAt,
    this.revision = 1,
  });

  final String id;
  final String personId;

  /// 'Ponsel lain · Samsung A15', 'Chrome di laptop'.
  final String name;
  final DateTime? lastUsed;
  DateTime? endedAt;
  int revision;
}
