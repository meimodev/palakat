import '../../domain/core/core.dart';

/// The core tables (README 5.7), complete in M1. Mutable lists the in-memory
/// repositories change; nothing else writes them.
class TabelInti implements AuthorityFacts {
  Workspace workspace = Workspace(name: 'Jemaat Karunia');

  /// By id, in seed order.
  final Map<String, Person> peopleById = {};
  final List<Party> parties = [];
  final List<Scope> scopes = [];
  @override
  final List<Post> posts = [];
  @override
  final List<Assignment> assignments = [];
  @override
  final List<AuthorityGrant> authorityGrants = [];
  @override
  final List<Delegation> delegations = [];
  @override
  final List<VacancyCover> covers = [];
  final List<HandoverProposal> handovers = [];
  final List<ModuleState> modules = [];

  /// Append-only, oldest first.
  final List<AuditRecord> audit = [];
  final List<AppNotification> notifications = [];
  final Map<String, NotificationPreferences> preferences = {};
  final List<SessionRecord> sessions = [];

  /// The picker's 11 people, in picker order (README 5.2, D17).
  final List<String> personaIds = [];

  /// The session on this device; null after sign-out.
  String? currentSessionId;
  final List<Device> devices = [];
  final List<FileRecord> files = [];

  void addPerson(Person p) => peopleById[p.id] = p;

  @override
  Iterable<Person> get people => peopleById.values;

  @override
  Person? person(String id) => peopleById[id];

  @override
  Post? post(String id) => posts.where((p) => p.id == id).firstOrNull;

  @override
  Scope? scope(String id) => scopes.where((s) => s.id == id).firstOrNull;

  @override
  ModuleStatus moduleStatus(Module module) =>
      moduleState(module)?.status ?? ModuleStatus.off;

  ModuleState? moduleState(Module module) =>
      modules.where((m) => m.module == module).firstOrNull;

  Assignment? assignment(String id) =>
      assignments.where((a) => a.id == id).firstOrNull;

  NotificationPreferences preferencesOf(String personId) => preferences
      .putIfAbsent(personId, () => NotificationPreferences(personId: personId));
}
