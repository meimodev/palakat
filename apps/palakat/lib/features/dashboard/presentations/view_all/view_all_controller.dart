import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:palakat/core/constants/constants.dart';
import 'package:palakat_shared/core/models/models.dart' hide Column;
import 'package:palakat_shared/l10n/generated/app_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';

part 'view_all_controller.g.dart';

AppLocalizations _l10n() {
  final localeName = intl.Intl.getCurrentLocale();
  final languageCode = localeName.split(RegExp('[_-]')).first;
  return lookupAppLocalizations(
    Locale(languageCode.isEmpty ? 'en' : languageCode),
  );
}

@riverpod
class ViewAllController extends _$ViewAllController {
  @override
  ViewAllState build() {
    final l10n = _l10n();
    final rnd = Random();
    final List<Activity> activities = List<Activity>.generate(10, (index) {
      final r = rnd.nextInt(ActivityType.values.length);
      final now = DateTime.now();

      final supervisor = Membership(id: index + 1, baptize: false, sidi: false);

      return Activity(
        id: index,
        supervisorId: supervisor.id,
        bipra: Bipra.values[r % Bipra.values.length],
        title: '${l10n.lbl_activity} $index',
        location: Location(
          name: '${l10n.card_location_title} $index',
          latitude: 0,
          longitude: 0,
          id: index,
        ),
        date: now.add(Duration(days: r % 5)),
        note: '${l10n.lbl_note} $index',
        fileUrl: '',
        createdAt: now,
        updatedAt: now,
        supervisor: supervisor,
        approvers: const <Approver>[],
      );
    });

    return ViewAllState(activities: activities);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
