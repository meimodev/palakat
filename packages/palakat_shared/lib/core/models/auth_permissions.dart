class AuthPermissions {
  final int? churchId;
  final List<String> permissions;
  final DateTime? policyUpdatedAt;

  const AuthPermissions({
    required this.churchId,
    required this.permissions,
    required this.policyUpdatedAt,
  });

  factory AuthPermissions.fromJson(Map<String, dynamic> json) {
    final rawPermissions = json['permissions'];
    final permissions = (rawPermissions is List)
        ? rawPermissions
              .map((e) => e?.toString())
              .whereType<String>()
              .where((e) => e.trim().isNotEmpty)
              .toList(growable: false)
        : const <String>[];

    final updatedAtRaw = json['policyUpdatedAt'];
    final updatedAt = updatedAtRaw is String
        ? DateTime.tryParse(updatedAtRaw)
        : null;

    final churchIdRaw = json['churchId'];
    final churchId = churchIdRaw is int
        ? churchIdRaw
        : (churchIdRaw is num
              ? churchIdRaw.toInt()
              : int.tryParse('${churchIdRaw ?? ''}'));

    return AuthPermissions(
      churchId: churchId,
      permissions: permissions,
      policyUpdatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'churchId': churchId,
    'permissions': permissions,
    'policyUpdatedAt': policyUpdatedAt?.toIso8601String(),
  };
}
