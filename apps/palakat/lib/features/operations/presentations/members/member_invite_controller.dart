import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_shared/core/models/account.dart';
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
    bool? baptize,
    bool? sidi,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool clearFoundAccount = false,
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
    );

    final Result<Account, Failure> res = await _membershipRepository
        .fetchAccountByIdentifier(identifier: identifier);

    res.when(
      onSuccess: (account) {
        final existing = account.membership;
        state = state.copyWith(
          isSearching: false,
          foundAccount: account,
          baptize: existing?.baptize ?? false,
          sidi: existing?.sidi ?? false,
          clearErrorMessage: true,
        );
        return null;
      },
      onFailure: (failure) {
        final msg = failure.message;
        final isNotFound =
            msg.toLowerCase().contains('not found') ||
            msg.toLowerCase().contains('account not found');

        state = state.copyWith(
          isSearching: false,
          errorMessage: isNotFound ? null : msg,
        );
      },
    );
  }

  Future<bool> inviteToMyColumn() async {
    final account = state.foundAccount;
    final churchId = state.churchId;
    final columnId = state.columnId;

    if (account?.id == null) {
      state = state.copyWith(errorMessage: 'Please lookup a member first');
      return false;
    }
    if (churchId == null || columnId == null) {
      state = state.copyWith(errorMessage: 'Membership scope not found');
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    final dto = {
      'membership': {
        'upsert': {
          'create': {
            'baptize': state.baptize,
            'sidi': state.sidi,
            'church': {
              'connect': {'id': churchId},
            },
            'column': {
              'connect': {'id': columnId},
            },
          },
          'update': {
            'baptize': state.baptize,
            'sidi': state.sidi,
            'church': {
              'connect': {'id': churchId},
            },
            'column': {
              'connect': {'id': columnId},
            },
            'membershipPositions': {'set': []},
          },
        },
      },
    };

    final Result<Account, Failure> result = await _membershipRepository
        .updateAccount(accountId: account!.id!, update: dto);

    bool ok = false;
    result.when(
      onSuccess: (_) {
        ok = true;
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
