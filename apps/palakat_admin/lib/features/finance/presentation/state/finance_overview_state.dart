import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palakat_admin/models.dart';

class FinanceOverviewState {
  final AsyncValue<FinanceOverview> overview;

  const FinanceOverviewState({this.overview = const AsyncValue.loading()});

  FinanceOverviewState copyWith({AsyncValue<FinanceOverview>? overview}) {
    return FinanceOverviewState(overview: overview ?? this.overview);
  }
}
