import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/billing.dart';
import 'package:palakat_shared/core/models/result.dart';
import 'package:palakat_shared/core/utils/error_mapper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_repository.g.dart';

@riverpod
BillingRepository billingRepository(Ref ref) => BillingRepository();

class BillingRepository {
  BillingRepository();

  /// Fetch all billing items (with mock data for now)
  Future<Result<List<BillingItem>, Failure>> getBillingItemsAsync() async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      final items = _generateMockBillingItems();

      return Result.success(items);
    } on DioException catch (e, st) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch billing items', st);
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch billing items', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Fetch payment history (with mock data for now)
  Future<Result<List<PaymentHistory>, Failure>> getPaymentHistoryAsync() async {
    try {
      // TODO: Replace with real API call when backend is ready
      // final response = await apiService.get(BillingEndpoints.getPaymentHistory);
      // final payments = (response.data as List)
      //     .map((json) => PaymentHistory.fromJson(json))
      //     .toList();

      // Mock data for now
      await Future.delayed(const Duration(milliseconds: 600));
      final payments = _generateMockPaymentHistory();

      return Result.success(payments);
    } on DioException catch (e, st) {
      final error = ErrorMapper.fromDio(
        e,
        'Failed to fetch payment history',
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown(
        'Failed to fetch payment history',
        e,
        st,
      );
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Record a payment for a billing item
  Future<Result<void, Failure>> recordPaymentAsync({
    required String billingItemId,
    required PaymentMethod paymentMethod,
    String? transactionId,
    String? notes,
  }) async {
    try {
      // TODO: Implement actual API call when backend is ready
      // await apiService.post(
      //   BillingEndpoints.recordPayment,
      //   data: {
      //     'billingItemId': billingItemId,
      //     'paymentMethod': paymentMethod.name,
      //     'transactionId': transactionId,
      //     'notes': notes,
      //   },
      // );

      await Future.delayed(const Duration(milliseconds: 500));
      return Result.success(null);
    } on DioException catch (e, st) {
      final error = ErrorMapper.fromDio(e, 'Failed to record payment', st);
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to record payment', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  /// Filter billing items based on search query, status, and date range
  List<BillingItem> filterBillingItems(
    List<BillingItem> items,
    String searchQuery,
    BillingStatus? statusFilter,
    DateTimeRange? dateRange,
  ) {
    return items.where((item) {
      final q = searchQuery.trim().toLowerCase();
      final matchesQuery =
          q.isEmpty ||
          (item.id?.toLowerCase().contains(q) ?? false) ||
          item.description.toLowerCase().contains(q) ||
          item.type.displayName.toLowerCase().contains(q) ||
          item.status.displayName.toLowerCase().contains(q);

      final matchesStatus = statusFilter == null || item.status == statusFilter;

      final matchesDate =
          dateRange == null || _isInDateRange(item.dueDate, dateRange);

      return matchesQuery && matchesStatus && matchesDate;
    }).toList();
  }

  /// Get paginated billing items
  List<BillingItem> getPaginatedBillingItems(
    List<BillingItem> items,
    int page,
    int pageSize,
  ) {
    final start = (page * pageSize).clamp(0, items.length);
    final end = (start + pageSize).clamp(0, items.length);
    return start < end ? items.sublist(start, end) : [];
  }

  /// Check if a date is within a date range
  bool _isInDateRange(DateTime date, DateTimeRange range) {
    final start = DateTime(
      range.start.year,
      range.start.month,
      range.start.day,
    );
    final end = DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
    );
    final checkDate = DateTime(date.year, date.month, date.day);

    return (checkDate.isAtSameMomentAs(start) || checkDate.isAfter(start)) &&
        (checkDate.isAtSameMomentAs(end) || checkDate.isBefore(end));
  }

  /// Generate mock billing items
  List<BillingItem> _generateMockBillingItems() {
    final now = DateTime.now();
    return [
      BillingItem(
        id: 'BILL-1001',
        description: 'Monthly System Subscription - September 2024',
        amount: 1499.00,
        type: BillingType.subscription,
        status: BillingStatus.paid,
        dueDate: now.subtract(const Duration(days: 15)),
        paidDate: now.subtract(const Duration(days: 10)),
        paymentMethod: PaymentMethod.cashless,
        transactionId: 'TXN-CC-001',
        notes: 'Paid via credit card ending in 4532',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      BillingItem(
        id: 'BILL-1002',
        description: 'Setup Fee - Initial Configuration',
        amount: 2500.00,
        type: BillingType.oneTime,
        status: BillingStatus.paid,
        dueDate: now.subtract(const Duration(days: 45)),
        paidDate: now.subtract(const Duration(days: 40)),
        paymentMethod: PaymentMethod.cashless,
        transactionId: 'TXN-BT-001',
        createdAt: now.subtract(const Duration(days: 50)),
        updatedAt: now.subtract(const Duration(days: 40)),
      ),
      BillingItem(
        id: 'BILL-1003',
        description: 'Monthly System Subscription - October 2024',
        amount: 1499.00,
        type: BillingType.subscription,
        status: BillingStatus.pending,
        dueDate: now.add(const Duration(days: 5)),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      BillingItem(
        id: 'BILL-1004',
        description: 'Additional Storage - 100GB',
        amount: 299.00,
        type: BillingType.oneTime,
        status: BillingStatus.overdue,
        dueDate: now.subtract(const Duration(days: 5)),
        notes: 'Payment reminder sent',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      BillingItem(
        id: 'BILL-1005',
        description: 'Premium Support Package - Q4 2024',
        amount: 999.00,
        type: BillingType.recurring,
        status: BillingStatus.pending,
        dueDate: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      BillingItem(
        id: 'BILL-1006',
        description: 'Training Session - Staff Onboarding',
        amount: 1200.00,
        type: BillingType.oneTime,
        status: BillingStatus.cancelled,
        dueDate: now.subtract(const Duration(days: 30)),
        notes: 'Cancelled due to schedule conflict',
        createdAt: now.subtract(const Duration(days: 40)),
        updatedAt: now.subtract(const Duration(days: 25)),
      ),
    ];
  }

  /// Generate mock payment history
  List<PaymentHistory> _generateMockPaymentHistory() {
    final now = DateTime.now();
    return [
      PaymentHistory(
        id: 'PAY-1001',
        billingItemId: 'BILL-1001',
        amount: 1499.00,
        paymentMethod: PaymentMethod.cashless,
        transactionId: 'TXN-CC-001',
        paymentDate: now.subtract(const Duration(days: 10)),
        notes: 'Automatic payment via saved card',
        processedBy: 'System',
      ),
      PaymentHistory(
        id: 'PAY-1002',
        billingItemId: 'BILL-1002',
        amount: 2500.00,
        paymentMethod: PaymentMethod.cashless,
        transactionId: 'TXN-BT-001',
        paymentDate: now.subtract(const Duration(days: 40)),
        notes: 'Bank transfer from church account',
        processedBy: 'Admin User',
      ),
      PaymentHistory(
        id: 'PAY-1003',
        billingItemId: 'BILL-0998',
        amount: 1499.00,
        paymentMethod: PaymentMethod.cashless,
        transactionId: 'TXN-CC-002',
        paymentDate: now.subtract(const Duration(days: 45)),
        notes: 'Monthly subscription payment',
        processedBy: 'System',
      ),
      PaymentHistory(
        id: 'PAY-1004',
        billingItemId: 'BILL-0997',
        amount: 599.00,
        paymentMethod: PaymentMethod.cashless,
        transactionId: 'TXN-DW-001',
        paymentDate: now.subtract(const Duration(days: 60)),
        notes: 'Paid via PayPal',
        processedBy: 'Admin User',
      ),
    ];
  }
}
