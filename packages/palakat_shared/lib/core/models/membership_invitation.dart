import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/account.dart';
import 'package:palakat_shared/core/models/church.dart';
import 'package:palakat_shared/core/models/column.dart';
import 'package:palakat_shared/core/models/membership.dart';

MembershipInvitationStatus _parseMembershipInvitationStatus(dynamic raw) {
  final v = (raw ?? '').toString().trim().toUpperCase();
  switch (v) {
    case 'APPROVED':
      return MembershipInvitationStatus.approved;
    case 'REJECTED':
      return MembershipInvitationStatus.rejected;
    case 'PENDING':
    default:
      return MembershipInvitationStatus.pending;
  }
}

MembershipInvitationEligibility _parseMembershipInvitationEligibility(
  dynamic raw,
) {
  final v = (raw ?? '').toString().trim().toUpperCase();
  switch (v) {
    case 'ALREADY_MEMBER':
      return MembershipInvitationEligibility.alreadyMember;
    case 'PENDING_INVITE_EXISTS':
      return MembershipInvitationEligibility.pendingInviteExists;
    case 'REJECTED_PREVIOUSLY':
      return MembershipInvitationEligibility.rejectedPreviously;
    case 'CAN_INVITE':
    default:
      return MembershipInvitationEligibility.canInvite;
  }
}

DateTime? _parseDateTime(dynamic raw) {
  if (raw == null) return null;
  if (raw is DateTime) return raw;
  return DateTime.tryParse(raw.toString());
}

class MembershipInvitation {
  final int? id;
  final int? inviterId;
  final int? inviteeId;
  final int? churchId;
  final int? columnId;
  final bool baptize;
  final bool sidi;
  final MembershipInvitationStatus status;
  final String? rejectedReason;
  final DateTime? rejectedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Account? inviter;
  final Account? invitee;
  final Church? church;
  final Column? column;

  const MembershipInvitation({
    this.id,
    this.inviterId,
    this.inviteeId,
    this.churchId,
    this.columnId,
    this.baptize = false,
    this.sidi = false,
    this.status = MembershipInvitationStatus.pending,
    this.rejectedReason,
    this.rejectedAt,
    this.createdAt,
    this.updatedAt,
    this.inviter,
    this.invitee,
    this.church,
    this.column,
  });

  factory MembershipInvitation.fromJson(Map<String, dynamic> json) {
    return MembershipInvitation(
      id: json['id'] as int?,
      inviterId: json['inviterId'] as int?,
      inviteeId: json['inviteeId'] as int?,
      churchId: json['churchId'] as int?,
      columnId: json['columnId'] as int?,
      baptize: json['baptize'] == true,
      sidi: json['sidi'] == true,
      status: _parseMembershipInvitationStatus(json['status']),
      rejectedReason: json['rejectedReason'] as String?,
      rejectedAt: _parseDateTime(json['rejectedAt']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      inviter: (json['inviter'] is Map)
          ? Account.fromJson((json['inviter'] as Map).cast<String, dynamic>())
          : null,
      invitee: (json['invitee'] is Map)
          ? Account.fromJson((json['invitee'] as Map).cast<String, dynamic>())
          : null,
      church: (json['church'] is Map)
          ? Church.fromJson((json['church'] as Map).cast<String, dynamic>())
          : null,
      column: (json['column'] is Map)
          ? Column.fromJson((json['column'] as Map).cast<String, dynamic>())
          : null,
    );
  }
}

class MembershipInvitationPreview {
  final MembershipInvitationEligibility eligibility;
  final Account invitee;
  final Membership? membership;
  final MembershipInvitation? pendingInvitation;
  final MembershipInvitation? latestRejectedInvitation;

  const MembershipInvitationPreview({
    required this.eligibility,
    required this.invitee,
    this.membership,
    this.pendingInvitation,
    this.latestRejectedInvitation,
  });

  factory MembershipInvitationPreview.fromJson(Map<String, dynamic> json) {
    final inviteeRaw = (json['invitee'] as Map).cast<String, dynamic>();
    final membershipRaw = json['membership'];
    final pendingRaw = json['pendingInvitation'];
    final rejectedRaw = json['latestRejectedInvitation'];

    return MembershipInvitationPreview(
      eligibility: _parseMembershipInvitationEligibility(json['eligibility']),
      invitee: Account.fromJson(inviteeRaw),
      membership: (membershipRaw is Map)
          ? Membership.fromJson(membershipRaw.cast<String, dynamic>())
          : null,
      pendingInvitation: (pendingRaw is Map)
          ? MembershipInvitation.fromJson(pendingRaw.cast<String, dynamic>())
          : null,
      latestRejectedInvitation: (rejectedRaw is Map)
          ? MembershipInvitation.fromJson(rejectedRaw.cast<String, dynamic>())
          : null,
    );
  }
}

class MembershipInvitationRespondResult {
  final Membership? membership;
  final MembershipInvitation invitation;

  const MembershipInvitationRespondResult({
    this.membership,
    required this.invitation,
  });

  factory MembershipInvitationRespondResult.fromJson(
    Map<String, dynamic> json,
  ) {
    final membershipRaw = json['membership'];
    final invitationRaw = (json['invitation'] as Map).cast<String, dynamic>();
    return MembershipInvitationRespondResult(
      membership: (membershipRaw is Map)
          ? Membership.fromJson(membershipRaw.cast<String, dynamic>())
          : null,
      invitation: MembershipInvitation.fromJson(invitationRaw),
    );
  }
}
