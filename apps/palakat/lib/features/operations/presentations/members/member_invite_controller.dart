import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/account.dart';
import 'package:palakat_shared/core/models/membership.dart';
import 'package:palakat_shared/core/models/membership_invitation.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/services.dart';

@immutable
class MemberInviteState {
  final int? churchId;
  final int? columnId;
  final String? churchName;
  final String? columnName;
  final String phone;
  final bool hasSearched;
  final bool isSearching;
  final bool isSubmitting;
  final Account? foundAccount;
  final Membership? existingMembership;
  final MembershipInvitationEligibility? invitationEligibility;
  final MembershipInvitation? pendingInvitation;
  final MembershipInvitation? latestRejectedInvitation;
  final String? infoMessage;
  final bool baptize;
  final bool sidi;
  final String? errorMessage;

  const MemberInviteState({
    required this.churchId,
    required this.columnId,
    required this.churchName,
    required this.columnName,
    required this.phone,
    required this.hasSearched,
    required this.isSearching,
    required this.isSubmitting,
    required this.foundAccount,
    required this.existingMembership,
    required this.invitationEligibility,
    required this.pendingInvitation,
    required this.latestRejectedInvitation,
    required this.infoMessage,
    required this.baptize,
    required this.sidi,
    required this.errorMessage,
  });

  const MemberInviteState.initial()
    : churchId = null,
      columnId = null,
      churchName = null,
      columnName = null,
      phone = '',
      hasSearched = false,
      isSearching = false,
      isSubmitting = false,
      foundAccount = null,
      existingMembership = null,
      invitationEligibility = null,
      pendingInvitation = null,
      latestRejectedInvitation = null,
      infoMessage = null,
      baptize = false,
      sidi = false,
      errorMessage = null;

  MemberInviteState copyWith({
    int? churchId,
    int? columnId,
    String? churchName,
    String? columnName,
    String? phone,
    bool? hasSearched,
    bool? isSearching,
    bool? isSubmitting,
    Account? foundAccount,
    Membership? existingMembership,
    MembershipInvitationEligibility? invitationEligibility,
    MembershipInvitation? pendingInvitation,
    MembershipInvitation? latestRejectedInvitation,
    String? infoMessage,
    bool? baptize,
    bool? sidi,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearFoundAccount = false,
    bool clearInvitationContext = false,
  }) {
    return MemberInviteState(
      churchId: churchId ?? this.churchId,
      columnId: columnId ?? this.columnId,
      churchName: churchName ?? this.churchName,
      columnName: columnName ?? this.columnName,
      phone: phone ?? this.phone,
      hasSearched: hasSearched ?? this.hasSearched,
      isSearching: isSearching ?? this.isSearching,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      foundAccount: clearFoundAccount
          ? null
          : (foundAccount ?? this.foundAccount),
      existingMembership: clearInvitationContext
          ? null
          : (existingMembership ?? this.existingMembership),
      invitationEligibility: clearInvitationContext
          ? null
          : (invitationEligibility ?? this.invitationEligibility),
      pendingInvitation: clearInvitationContext
          ? null
          : (pendingInvitation ?? this.pendingInvitation),
      latestRejectedInvitation: clearInvitationContext
          ? null
          : (latestRejectedInvitation ?? this.latestRejectedInvitation),
      infoMessage: clearInvitationContext
          ? null
          : (infoMessage ?? this.infoMessage),
      baptize: baptize ?? this.baptize,
      sidi: sidi ?? this.sidi,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  String? get scopeLabel {
    final c = churchName?.trim();
    final col = columnName?.trim();
    if (c == null || c.isEmpty) return col?.isNotEmpty == true ? col : null;
    if (col == null || col.isEmpty) return c;
    return '$c • $col';
  }
}

final memberInviteControllerProvider =
    NotifierProvider<MemberInviteController, MemberInviteState>(
      MemberInviteController.new,
    );

class MemberInviteController extends Notifier<MemberInviteState> {
  MembershipRepository get _membershipRepository =>
      ref.read(membershipRepositoryProvider);

  @override
  MemberInviteState build() {
    final local = ref.read(localStorageServiceProvider);
    final membership = local.currentMembership;

    final initial = MemberInviteState(
      churchId: membership?.church?.id,
      columnId: membership?.column?.id,
      churchName: membership?.church?.name,
      columnName: membership?.column?.name,
      phone: '',
      hasSearched: false,
      isSearching: false,
      isSubmitting: false,
      foundAccount: null,
      existingMembership: null,
      invitationEligibility: null,
      pendingInvitation: null,
      latestRejectedInvitation: null,
      infoMessage: null,
      baptize: false,
      sidi: false,
      errorMessage: null,
    );

    return initial;
  }

  void setPhone(String value) {
    state = state.copyWith(phone: value, clearErrorMessage: true);
  }

  void setBaptize(bool value) {
    state = state.copyWith(baptize: value, clearErrorMessage: true);
  }

  void setSidi(bool value) {
    state = state.copyWith(sidi: value, clearErrorMessage: true);
  }

  String _normalizeIndonesianPhone(String raw) {
    var normalized = raw.trim();
    normalized = normalized.replaceAll(RegExp(r'[\s\-()]'), '');

    if (normalized.startsWith('+62')) {
      normalized = '0${normalized.substring(3)}';
    } else if (normalized.startsWith('62') && normalized.length > 11) {
      normalized = '0${normalized.substring(2)}';
    }

    normalized = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    return normalized;
  }

  Future<void> lookupByPhone() async {
    final identifier = _normalizeIndonesianPhone(state.phone);
    if (identifier.isEmpty) {
      state = state.copyWith(errorMessage: 'Phone number is required');
      return;
    }

    state = state.copyWith(
      hasSearched: true,
      isSearching: true,
      clearErrorMessage: true,
      clearFoundAccount: true,
      clearInvitationContext: true,
    );

    final Result<MembershipInvitationPreview, Failure> res =
        await _membershipRepository.membershipInvitationPreview(
          identifier: identifier,
        );

    res.when(
      onSuccess: (preview) {
        final eligibility = preview.eligibility;

        final existingMembership = preview.membership;
        final pending = preview.pendingInvitation;
        final rejected = preview.latestRejectedInvitation;

        String? info;
        if (eligibility == MembershipInvitationEligibility.alreadyMember) {
          final c = existingMembership?.church?.name;
          final col = existingMembership?.column?.name;
          final scope = [
            if (c != null && c.trim().isNotEmpty) c.trim(),
            if (col != null && col.trim().isNotEmpty) 'Column ${col.trim()}',
          ].join(' • ');
          info = scope.trim().isEmpty
              ? 'This user already has membership.'
              : 'This user already has membership in $scope.';
        } else if (eligibility ==
            MembershipInvitationEligibility.pendingInviteExists) {
          final inviter = pending?.inviter?.name;
          info = inviter != null && inviter.trim().isNotEmpty
              ? 'Already invited by $inviter. Waiting for approval.'
              : 'Already invited. Waiting for approval.';
        } else if (eligibility ==
            MembershipInvitationEligibility.rejectedPreviously) {
          final note = rejected?.rejectedReason?.trim();
          info = (note == null || note.isEmpty)
              ? 'Previous invitation was rejected. You may re-invite.'
              : 'Previous invitation was rejected: $note. You may re-invite.';
        } else {
          info = null;
        }

        final initialBaptize = pending?.baptize ?? rejected?.baptize ?? false;
        final initialSidi = pending?.sidi ?? rejected?.sidi ?? false;

        state = state.copyWith(
          isSearching: false,
          foundAccount: preview.invitee,
          existingMembership: existingMembership,
          invitationEligibility: eligibility,
          pendingInvitation: pending,
          latestRejectedInvitation: rejected,
          infoMessage: info,
          baptize: initialBaptize,
          sidi: initialSidi,
          clearErrorMessage: true,
        );
        return null;
      },
      onFailure: (failure) {
        final isNotFound = failure.code == 404;
        state = state.copyWith(
          isSearching: false,
          errorMessage: isNotFound ? null : failure.message,
        );
      },
    );
  }

  Future<bool> inviteToMyColumn() async {
    final account = state.foundAccount;
    final churchId = state.churchId;
    final columnId = state.columnId;
    final eligibility = state.invitationEligibility;

    if (account?.id == null) {
      state = state.copyWith(errorMessage: 'Please lookup a member first');
      return false;
    }
    if (churchId == null || columnId == null) {
      state = state.copyWith(errorMessage: 'Membership scope not found');
      return false;
    }

    final allowed =
        eligibility == MembershipInvitationEligibility.canInvite ||
        eligibility == MembershipInvitationEligibility.rejectedPreviously;
    if (!allowed) {
      state = state.copyWith(
        errorMessage: 'Cannot invite this user at the moment',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    final Result<MembershipInvitation, Failure> result =
        await _membershipRepository.membershipInvitationCreate(
          inviteeId: account!.id!,
          churchId: churchId,
          columnId: columnId,
          baptize: state.baptize,
          sidi: state.sidi,
        );

    bool ok = false;
    result.when(
      onSuccess: (inv) {
        ok = true;
        state = state.copyWith(
          invitationEligibility:
              MembershipInvitationEligibility.pendingInviteExists,
          pendingInvitation: inv,
          infoMessage: 'Invitation sent. Waiting for approval.',
        );
        return null;
      },
      onFailure: (failure) {
        state = state.copyWith(errorMessage: failure.message);
      },
    );

    state = state.copyWith(isSubmitting: false);
    return ok;
  }
}
