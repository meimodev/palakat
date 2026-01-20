class ChurchPermissionPolicyRecord {
  final int churchId;
  final Map<String, dynamic> policy;
  final DateTime? updatedAt;

  const ChurchPermissionPolicyRecord({
    required this.churchId,
    required this.policy,
    required this.updatedAt,
  });

  factory ChurchPermissionPolicyRecord.fromJson(Map<String, dynamic> json) {
    final churchIdRaw = json['churchId'];
    final churchId = churchIdRaw is int
        ? churchIdRaw
        : (churchIdRaw is num
              ? churchIdRaw.toInt()
              : int.tryParse('${churchIdRaw ?? ''}') ?? 0);

    final policyRaw = json['policy'];
    final policy = (policyRaw is Map)
        ? policyRaw.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    final updatedAtRaw = json['updatedAt'];
    final updatedAt = updatedAtRaw is String
        ? DateTime.tryParse(updatedAtRaw)
        : null;

    return ChurchPermissionPolicyRecord(
      churchId: churchId,
      policy: policy,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'churchId': churchId,
    'policy': policy,
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
