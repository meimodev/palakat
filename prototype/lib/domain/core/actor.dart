/// How an actor holds the authority they act with (README 3.4).
sealed class Via {
  const Via();

  static const direct = ViaDirect();
}

/// Through their own assignment.
final class ViaDirect extends Via {
  const ViaDirect();

  @override
  bool operator ==(Object other) => other is ViaDirect;

  @override
  int get hashCode => 0;
}

/// Through a dated, scoped delegation (PMP 5).
final class ViaDelegation extends Via {
  const ViaDelegation(this.delegationId);
  final String delegationId;

  @override
  bool operator ==(Object other) =>
      other is ViaDelegation && other.delegationId == delegationId;

  @override
  int get hashCode => delegationId.hashCode;
}

/// An Operator acting in a vacant post (DL12).
final class ViaVacancyCover extends Via {
  const ViaVacancyCover(this.postId);
  final String postId;

  @override
  bool operator ==(Object other) =>
      other is ViaVacancyCover && other.postId == postId;

  @override
  int get hashCode => postId.hashCode;
}

/// Who acts, in which post and scope, and how (README 3.4). Every command
/// takes it as its first argument.
class Actor {
  const Actor({
    required this.personId,
    this.assignmentId,
    required this.scopeId,
    this.via = Via.direct,
  });

  final String personId;

  /// The acting assignment; null for a member without a post, or while a
  /// person with two posts that can act has not chosen one yet.
  final String? assignmentId;
  final String scopeId;
  final Via via;

  @override
  bool operator ==(Object other) =>
      other is Actor &&
      other.personId == personId &&
      other.assignmentId == assignmentId &&
      other.scopeId == scopeId &&
      other.via == via;

  @override
  int get hashCode => Object.hash(personId, assignmentId, scopeId, via);

  @override
  String toString() => 'Actor($personId, $assignmentId, $scopeId, $via)';
}
