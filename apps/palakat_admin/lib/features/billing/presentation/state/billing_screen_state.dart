import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:palakat_admin/constants.dart';
import 'package:palakat_admin/models.dart';

part 'billing_screen_state.freezed.dart';

@freezed
abstract class BillingScreenState with _$BillingScreenState {
  const factory BillingScreenState({
    @Default(AsyncValue.loading()) AsyncValue<List<BillingItem>> billingItems,
    @Default(AsyncValue.loading())
    AsyncValue<List<PaymentHistory>> paymentHistory,
    @Default('') String searchQuery,
    @Default(null) BillingStatus? statusFilter,
    @Default(null) DateTimeRange? dateRange,
    @Default(0) int page,
    @Default(10) int rowsPerPage,
  }) = _BillingScreenState;
}
