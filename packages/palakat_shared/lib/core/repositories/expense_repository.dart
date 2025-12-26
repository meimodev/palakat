import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/expense.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/socket_service.dart';

part 'expense_repository.g.dart';

/// Riverpod provider for ExpenseRepository
@riverpod
ExpenseRepository expenseRepository(Ref ref) => ExpenseRepository(ref);

/// Abstract interface for expense data operations
abstract class ExpenseRepositoryBase {
  /// Creates a new expense record
  Future<Result<Expense, Failure>> createExpense({
    required CreateExpenseRequest request,
  });

  /// Fetches paginated list of expenses
  Future<Result<PaginationResponseWrapper<Expense>, Failure>> fetchExpenses({
    required PaginationRequestWrapper paginationRequest,
  });

  /// Fetches a single expense by ID
  Future<Result<Expense, Failure>> fetchExpense({required int expenseId});

  /// Updates an existing expense record
  Future<Result<Expense, Failure>> updateExpense({
    required int expenseId,
    required Map<String, dynamic> update,
  });

  /// Deletes an expense record
  Future<Result<void, Failure>> deleteExpense({required int expenseId});
}

/// Implementation of ExpenseRepository for API operations
class ExpenseRepository implements ExpenseRepositoryBase {
  ExpenseRepository(this._ref);

  final Ref _ref;

  @override
  Future<Result<PaginationResponseWrapper<Expense>, Failure>> fetchExpenses({
    required PaginationRequestWrapper paginationRequest,
  }) async {
    try {
      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final socket = _ref.read(socketServiceProvider);
      final data = await socket.rpc('expense.list', query);
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Expense.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Expense, Failure>> fetchExpense({
    required int expenseId,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('expense.get', {'id': expenseId});
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid expense response payload'));
      }
      return Result.success(Expense.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Expense, Failure>> updateExpense({
    required int expenseId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);

      final body = await socket.rpc('expense.update', {
        'id': expenseId,
        'dto': update,
      });

      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update expense response payload'),
        );
      }

      return Result.success(Expense.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<Expense, Failure>> createExpense({
    required CreateExpenseRequest request,
  }) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      final body = await socket.rpc('expense.create', request.toJson());
      final Map<String, dynamic> json =
          (body['data'] as Map?)?.cast<String, dynamic>() ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create expense response payload'),
        );
      }
      return Result.success(Expense.fromJson(json));
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }

  @override
  Future<Result<void, Failure>> deleteExpense({required int expenseId}) async {
    try {
      final socket = _ref.read(socketServiceProvider);
      await socket.rpc('expense.delete', {'id': expenseId});
      return Result.success(null);
    } catch (e) {
      return Result.failure(Failure.fromException(e));
    }
  }
}
