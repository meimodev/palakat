import 'package:dio/dio.dart';
import 'package:palakat_shared/core/models/request/request.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../config/endpoint.dart';
import '../models/expense.dart';
import '../models/response/response.dart';
import '../models/result.dart';
import '../services/http_service.dart';
import '../utils/error_mapper.dart';

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
      final http = _ref.read(httpServiceProvider);

      final query = paginationRequest.toJsonFlat((p) => p.toJson());

      final response = await http.get<Map<String, dynamic>>(
        Endpoints.expenses,
        queryParameters: query,
      );

      final data = response.data ?? {};
      final result = PaginationResponseWrapper.fromJson(
        data,
        (e) => Expense.fromJson(e as Map<String, dynamic>),
      );
      return Result.success(result);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch expenses');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch expenses', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  @override
  Future<Result<Expense, Failure>> fetchExpense({
    required int expenseId,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.get<Map<String, dynamic>>(
        Endpoints.expense(expenseId.toString()),
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(Failure('Invalid expense response payload'));
      }
      return Result.success(Expense.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to fetch expense');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to fetch expense', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  @override
  Future<Result<Expense, Failure>> updateExpense({
    required int expenseId,
    required Map<String, dynamic> update,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);

      final response = await http.patch<Map<String, dynamic>>(
        Endpoints.expense(expenseId.toString()),
        data: update,
      );

      final data = response.data;
      final Map<String, dynamic> json = data?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid update expense response payload'),
        );
      }

      return Result.success(Expense.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to update expense');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to update expense', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  @override
  Future<Result<Expense, Failure>> createExpense({
    required CreateExpenseRequest request,
  }) async {
    try {
      final http = _ref.read(httpServiceProvider);
      final response = await http.post<Map<String, dynamic>>(
        Endpoints.expenses,
        data: request.toJson(),
      );

      final body = response.data;
      final Map<String, dynamic> json = body?['data'] ?? {};
      if (json.isEmpty) {
        return Result.failure(
          Failure('Invalid create expense response payload'),
        );
      }
      return Result.success(Expense.fromJson(json));
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to create expense');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to create expense', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }

  @override
  Future<Result<void, Failure>> deleteExpense({required int expenseId}) async {
    try {
      final http = _ref.read(httpServiceProvider);
      await http.delete<void>(Endpoints.expense(expenseId.toString()));
      return Result.success(null);
    } on DioException catch (e) {
      final error = ErrorMapper.fromDio(e, 'Failed to delete expense');
      return Result.failure(Failure(error.message, error.statusCode));
    } catch (e, st) {
      final error = ErrorMapper.unknown('Failed to delete expense', e, st);
      return Result.failure(Failure(error.message, error.statusCode));
    }
  }
}
