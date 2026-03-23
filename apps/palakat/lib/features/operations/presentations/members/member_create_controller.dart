import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:palakat_shared/services.dart';

String _languageCodeFromLocaleName(String localeName) {
  final underscoreIndex = localeName.indexOf('_');
  final hyphenIndex = localeName.indexOf('-');
  final separatorIndex = underscoreIndex == -1
      ? hyphenIndex
      : hyphenIndex == -1
      ? underscoreIndex
      : underscoreIndex < hyphenIndex
      ? underscoreIndex
      : hyphenIndex;
  if (separatorIndex == -1) return localeName;
  return localeName.substring(0, separatorIndex);
}

String _digitsOnly(String value) {
  final buffer = StringBuffer();
  for (final codeUnit in value.codeUnits) {
    if (codeUnit >= 48 && codeUnit <= 57) {
      buffer.writeCharCode(codeUnit);
    }
  }
  return buffer.toString();
}

String _stripPhoneFormatting(String value) {
  final buffer = StringBuffer();
  for (final codeUnit in value.codeUnits) {
    if (codeUnit == 32 || codeUnit == 45 || codeUnit == 40 || codeUnit == 41) {
      continue;
    }
    buffer.writeCharCode(codeUnit);
  }
  return buffer.toString();
}

bool _isAsciiLetterOrDigit(int codeUnit) {
  return (codeUnit >= 48 && codeUnit <= 57) ||
      (codeUnit >= 65 && codeUnit <= 90) ||
      (codeUnit >= 97 && codeUnit <= 122);
}

bool _isValidEmail(String value) {
  final trimmed = value.trim();
  final atIndex = trimmed.indexOf('@');
  if (atIndex <= 0 ||
      atIndex != trimmed.lastIndexOf('@') ||
      atIndex == trimmed.length - 1) {
    return false;
  }

  final local = trimmed.substring(0, atIndex);
  final domain = trimmed.substring(atIndex + 1);
  if (local.startsWith('.') ||
      local.endsWith('.') ||
      domain.startsWith('.') ||
      domain.endsWith('.') ||
      !domain.contains('.')) {
    return false;
  }

  for (final codeUnit in local.codeUnits) {
    final isValid =
        _isAsciiLetterOrDigit(codeUnit) ||
        codeUnit == 45 ||
        codeUnit == 46 ||
        codeUnit == 95;
    if (!isValid) return false;
  }

  final labels = domain.split('.');
  if (labels.length < 2) return false;
  for (final label in labels) {
    if (label.isEmpty) return false;
    for (final codeUnit in label.codeUnits) {
      final isValid = _isAsciiLetterOrDigit(codeUnit) || codeUnit == 45;
      if (!isValid) return false;
    }
  }

  final topLevelDomain = labels.last;
  return topLevelDomain.length >= 2 && topLevelDomain.length <= 4;
}

@immutable
class MemberCreateState {
  final int? churchId;
  final int? columnId;
  final String? churchName;
  final String? columnName;
  final String name;
  final String phone;
  final String email;
  final DateTime? dob;
  final Gender? gender;
  final MaritalStatus? maritalStatus;
  final bool baptize;
  final bool sidi;
  final bool isSubmitting;
  final String? errorMessage;
  final String? errorName;
  final String? errorPhone;
  final String? errorEmail;
  final String? errorDob;
  final String? errorGender;
  final String? errorMaritalStatus;

  const MemberCreateState({
    required this.churchId,
    required this.columnId,
    required this.churchName,
    required this.columnName,
    required this.name,
    required this.phone,
    required this.email,
    required this.dob,
    required this.gender,
    required this.maritalStatus,
    required this.baptize,
    required this.sidi,
    required this.isSubmitting,
    required this.errorMessage,
    required this.errorName,
    required this.errorPhone,
    required this.errorEmail,
    required this.errorDob,
    required this.errorGender,
    required this.errorMaritalStatus,
  });

  const MemberCreateState.initial()
    : churchId = null,
      columnId = null,
      churchName = null,
      columnName = null,
      name = '',
      phone = '',
      email = '',
      dob = null,
      gender = null,
      maritalStatus = null,
      baptize = false,
      sidi = false,
      isSubmitting = false,
      errorMessage = null,
      errorName = null,
      errorPhone = null,
      errorEmail = null,
      errorDob = null,
      errorGender = null,
      errorMaritalStatus = null;

  MemberCreateState copyWith({
    int? churchId,
    int? columnId,
    String? churchName,
    String? columnName,
    String? name,
    String? phone,
    String? email,
    DateTime? dob,
    Gender? gender,
    MaritalStatus? maritalStatus,
    bool? baptize,
    bool? sidi,
    bool? isSubmitting,
    String? errorMessage,
    String? errorName,
    String? errorPhone,
    String? errorEmail,
    String? errorDob,
    String? errorGender,
    String? errorMaritalStatus,
    bool clearErrorMessage = false,
    bool clearErrorName = false,
    bool clearErrorPhone = false,
    bool clearErrorEmail = false,
    bool clearErrorDob = false,
    bool clearErrorGender = false,
    bool clearErrorMaritalStatus = false,
  }) {
    return MemberCreateState(
      churchId: churchId ?? this.churchId,
      columnId: columnId ?? this.columnId,
      churchName: churchName ?? this.churchName,
      columnName: columnName ?? this.columnName,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      baptize: baptize ?? this.baptize,
      sidi: sidi ?? this.sidi,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      errorName: clearErrorName ? null : (errorName ?? this.errorName),
      errorPhone: clearErrorPhone ? null : (errorPhone ?? this.errorPhone),
      errorEmail: clearErrorEmail ? null : (errorEmail ?? this.errorEmail),
      errorDob: clearErrorDob ? null : (errorDob ?? this.errorDob),
      errorGender: clearErrorGender ? null : (errorGender ?? this.errorGender),
      errorMaritalStatus: clearErrorMaritalStatus
          ? null
          : (errorMaritalStatus ?? this.errorMaritalStatus),
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

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = _languageCodeFromLocaleName(localeName);
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

final memberCreateControllerProvider =
    NotifierProvider<MemberCreateController, MemberCreateState>(
      MemberCreateController.new,
    );

class MemberCreateController extends Notifier<MemberCreateState> {
  MembershipRepository get _membershipRepository =>
      ref.read(membershipRepositoryProvider);

  @override
  MemberCreateState build() {
    final local = ref.read(localStorageServiceProvider);
    final membership =
        local.currentMembership ?? local.currentAuth?.account.membership;

    final churchId = membership?.church?.id ?? membership?.column?.churchId;
    final columnId = membership?.column?.id;

    return MemberCreateState(
      churchId: churchId,
      columnId: columnId,
      churchName: membership?.church?.name,
      columnName: membership?.column?.name,
      name: '',
      phone: '',
      email: '',
      dob: null,
      gender: null,
      maritalStatus: null,
      baptize: false,
      sidi: false,
      isSubmitting: false,
      errorMessage: null,
      errorName: null,
      errorPhone: null,
      errorEmail: null,
      errorDob: null,
      errorGender: null,
      errorMaritalStatus: null,
    );
  }

  void setName(String value) {
    state = state.copyWith(
      name: value,
      clearErrorName: true,
      clearErrorMessage: true,
    );
  }

  void setPhone(String value) {
    state = state.copyWith(
      phone: value,
      clearErrorPhone: true,
      clearErrorMessage: true,
    );
  }

  void setEmail(String value) {
    state = state.copyWith(
      email: value,
      clearErrorEmail: true,
      clearErrorMessage: true,
    );
  }

  void setDob(DateTime? value) {
    state = state.copyWith(
      dob: value,
      clearErrorDob: true,
      clearErrorMessage: true,
    );
  }

  void setGender(Gender value) {
    state = state.copyWith(
      gender: value,
      clearErrorGender: true,
      clearErrorMessage: true,
    );
  }

  void setMaritalStatus(MaritalStatus value) {
    state = state.copyWith(
      maritalStatus: value,
      clearErrorMaritalStatus: true,
      clearErrorMessage: true,
    );
  }

  void setBaptize(bool value) {
    state = state.copyWith(baptize: value, clearErrorMessage: true);
  }

  void setSidi(bool value) {
    state = state.copyWith(sidi: value, clearErrorMessage: true);
  }

  String? _validateName(String value) {
    final l10n = _l10n();
    if (value.trim().isEmpty) {
      return l10n.validation_nameRequired;
    }
    return null;
  }

  String? _validateEmail(String value) {
    final l10n = _l10n();
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (!_isValidEmail(trimmed)) {
      return l10n.validation_invalidEmail;
    }
    return null;
  }

  String? _validatePhone(String value) {
    final l10n = _l10n();
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final digitsOnly = _digitsOnly(trimmed);
    if (digitsOnly.length < 12) {
      return l10n.validation_invalidPhone;
    }
    return null;
  }

  String? _validateDob(DateTime? value) {
    final l10n = _l10n();
    if (value == null) {
      return l10n.validation_dateRequired;
    }
    return null;
  }

  String? _validateSelection<T>(T? value) {
    final l10n = _l10n();
    if (value == null) {
      return l10n.validation_selectionRequired;
    }
    return null;
  }

  String? _normalizeIndonesianPhone(String raw) {
    var normalized = _stripPhoneFormatting(raw.trim());

    if (normalized.startsWith('+62')) {
      normalized = '0${normalized.substring(3)}';
    } else if (normalized.startsWith('62') && normalized.length > 11) {
      normalized = '0${normalized.substring(2)}';
    }

    normalized = _digitsOnly(normalized);
    return normalized.isEmpty ? null : normalized;
  }

  Future<bool> submit() async {
    final churchId = state.churchId;
    final columnId = state.columnId;
    if (churchId == null || columnId == null) {
      state = state.copyWith(errorMessage: 'Membership scope not found');
      return false;
    }

    final nameError = _validateName(state.name);
    final phoneError = _validatePhone(state.phone);
    final emailError = _validateEmail(state.email);
    final dobError = _validateDob(state.dob);
    final genderError = _validateSelection(state.gender);
    final maritalError = _validateSelection(state.maritalStatus);

    state = state.copyWith(
      errorName: nameError,
      errorPhone: phoneError,
      errorEmail: emailError,
      errorDob: dobError,
      errorGender: genderError,
      errorMaritalStatus: maritalError,
      clearErrorMessage: true,
    );

    final hasErrors =
        nameError != null ||
        phoneError != null ||
        emailError != null ||
        dobError != null ||
        genderError != null ||
        maritalError != null;

    if (hasErrors) {
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);

    final normalizedPhone = _normalizeIndonesianPhone(state.phone);
    final normalizedEmail = state.email.trim().isEmpty
        ? null
        : state.email.trim().toLowerCase();

    final data = <String, dynamic>{
      'name': state.name.trim(),
      if (normalizedPhone != null) 'phone': normalizedPhone,
      if (normalizedEmail != null) 'email': normalizedEmail,
      'dob': state.dob?.toIso8601String(),
      'gender': state.gender?.name.toUpperCase(),
      'maritalStatus': state.maritalStatus?.name.toUpperCase(),
      'membership': {'baptize': state.baptize, 'sidi': state.sidi},
    };

    final result = await _membershipRepository.createMember(data: data);

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
