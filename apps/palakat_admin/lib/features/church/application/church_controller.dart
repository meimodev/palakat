import 'package:palakat_admin/extensions.dart';
import 'package:palakat_admin/models.dart' hide Column;
import 'package:palakat_admin/repositories.dart';
import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat_admin/models.dart' as cm show Column;
import 'church_state.dart';

part 'church_controller.g.dart';

@riverpod
class ChurchController extends _$ChurchController {
  ChurchRepository get churchRepo => ref.read(churchRepositoryProvider);

  late Church locallyStoredChurch;
  @override
  ChurchState build() {
    final church = ref
        .read(authControllerProvider)
        .value
        ?.account
        .membership
        ?.church;

    // Initialize both church and location from cached/auth state
    final initial = ChurchState(church: AsyncData(church!));

    locallyStoredChurch = church;

    Future.microtask(() {
      fetchChurch();
      fetchLocation(church.locationId!);
      fetchColumns(church.id!);
      fetchPositions(church.id!);
    });

    return initial;
  }

  Future<void> saveChurch(Church updated) async {
    final previous = state.church.value!;
    try {
      state = state.copyWith(church: AsyncLoading());

      final payload = updated.toJson().stripUnchangedFields(previous.toJson());

      final result = await churchRepo.updateChurchProfile(
        churchId: updated.id!,
        update: payload,
      );
      result.when(
        onSuccess: (church) {
          state = state.copyWith(church: AsyncData(church));
          _updateCachedAccountLocation();
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> savePosition(MemberPosition updated) async {
    final prev = state.positions;
    try {
      state = state.copyWith(positions: const AsyncLoading());

      // Find existing column to compute delta
      final currentList = prev.value ?? const <MemberPosition>[];
      final existing = currentList.firstWhere(
        (c) => c.id == updated.id,
        orElse: () => updated,
      );

      final original = existing.toJson();
      final altered = updated.toJson();
      final payload = altered.stripUnchangedFields(original);

      final result = await churchRepo.updateMemberPosition(
        positionId: updated.id ?? 0,
        update: payload,
      );

      result.when(
        onSuccess: (position) {
          final updatedPositions = currentList
              .map<MemberPosition>((e) => e.id == position.id ? position : e)
              .toList();
          state = state.copyWith(positions: AsyncData(updatedPositions));
          _updateCachedAccountLocation();
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> fetchChurch() async {
    final previous = state.church.value ?? locallyStoredChurch;
    try {
      state = state.copyWith(church: AsyncLoading());
      final result = await churchRepo.fetchChurchProfile(previous.id!);
      result.when(
        onSuccess: (church) => state = state.copyWith(church: AsyncData(church)),
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> saveLocation(Location updated) async {
    final previous = state.location;
    try {
      state = state.copyWith(location: const AsyncLoading());

      final originalLoc = previous.value?.toJson() ?? <String, dynamic>{};
      final alteredLoc = updated.toJson();
      final payload = alteredLoc.stripUnchangedFields(originalLoc);

      final result = await churchRepo.updateLocation(
        locationId: updated.id!,
        update: payload,
      );

      result.when(
        onSuccess: (location) {
          state = state.copyWith(location: AsyncData(location));
          _updateCachedAccountLocation();
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  void fetchLocation(int locationId) async {
    try {
      state = state.copyWith(location: AsyncLoading());
      final result = await churchRepo.fetchLocation(locationId);
      result.when(
        onSuccess: (location) => state = state.copyWith(location: AsyncData(location)),
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<Location> fetchLocationDetail(int locationId) async {
    try {
      final result = await churchRepo.fetchLocation(locationId);
      final value = result.when<Location>(
        onSuccess: (location) => location,
        onFailure: (failure) => throw Exception(failure.message),
      );
      return value!;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> saveColumn(cm.Column updated) async {
    // Optimistically set columns to loading while saving, then update list
    final previousColumns = state.columns;
    try {
      state = state.copyWith(columns: const AsyncLoading());

      // Find existing column to compute delta
      final currentList = previousColumns.value ?? const <cm.Column>[];
      final existing = currentList.firstWhere(
        (c) => c.id == updated.id,
        orElse: () => cm.Column(
          id: updated.id,
          name: '',
          churchId: updated.churchId,
          createdAt: updated.createdAt,
        ),
      );

      final original = existing.toJson();
      final altered = updated.toJson();
      final payload = altered.stripUnchangedFields(original);

      final result = await churchRepo.updateColumn(
        columnId: updated.id ?? 0,
        update: payload,
      );

      result.when(
        onSuccess: (column) {
          final updatedColumns = [
            for (final c in currentList)
              if (c.id == column.id) column else c,
          ];
          state = state.copyWith(columns: AsyncData(updatedColumns));
          _updateCachedAccountLocation();
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> createColumn(cm.Column toCreate) async {
    final previousColumns = state.columns;
    try {
      state = state.copyWith(columns: const AsyncLoading());

      final payload = {'name': toCreate.name, 'churchId': toCreate.churchId};
      final result = await churchRepo.createColumn(data: payload);

      result.when(
        onSuccess: (created) {
          final current = previousColumns.value ?? const <cm.Column>[];
          final updatedColumns = List<cm.Column>.from(current)..add(created);
          state = state.copyWith(columns: AsyncData(updatedColumns));
          _updateCachedAccountLocation();
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> deleteColumn(int columnId) async {
    // Optimistically set columns to loading while deleting, then update list
    final previousColumns = state.columns;
    try {
      state = state.copyWith(columns: const AsyncLoading());
      final result = await churchRepo.deleteColumn(columnId: columnId);

      result.when(
        onSuccess: (_) {
          final current = previousColumns.value ?? const <cm.Column>[];
          final updatedColumns = current.where((c) => c.id != columnId).toList();
          state = state.copyWith(columns: AsyncData(updatedColumns));
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<ColumnDetail> fetchColumn(int columnId) async {
    try {
      final result = await churchRepo.fetchColumn(columnId: columnId);
      final value = result.when<ColumnDetail>(
        onSuccess: (column) => column,
        onFailure: (failure) => throw Exception(failure.message),
      );
      return value!;
    } catch (e) {
      rethrow;
    }
  }

  Future<MemberPositionDetail> fetchPosition(int positionId) async {
    try {
      final result = await churchRepo.fetchPosition(positionId: positionId);
      final value = result.when<MemberPositionDetail>(
        onSuccess: (position) => position,
        onFailure: (failure) => throw Exception(failure.message),
      );
      return value!;
    } catch (e) {
      rethrow;
    }
  }


  void fetchColumns(int churchId) async {
    try {
      state = state.copyWith(columns: const AsyncLoading());
      final paginationRequest = PaginationRequestWrapper<GetFetchColumnsRequest>(
        page: 1,
        pageSize: 100,
        data: GetFetchColumnsRequest(churchId: churchId),
      );
      final result = await churchRepo.fetchColumns(paginationRequest: paginationRequest);
      result.when(
        onSuccess: (paginatedColumns) => state = state.copyWith(columns: AsyncData(paginatedColumns.data)),
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  void fetchPositions(int churchId) async {
    try {
      state = state.copyWith(positions: const AsyncLoading());
      final result = await churchRepo.fetchPositions(churchId: churchId);
      result.when(
        onSuccess: (positions) => state = state.copyWith(positions: AsyncData(positions)),
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> createPosition(MemberPosition toCreate) async {
    final previousPositions = state.positions;
    try {
      state = state.copyWith(positions: const AsyncLoading());

      final payload = {'name': toCreate.name, 'churchId': toCreate.churchId};
      final result = await churchRepo.createMemberPosition(data: payload);

      result.when(
        onSuccess: (created) {
          final current = previousPositions.value ?? const <MemberPosition>[];
          final updated = List<MemberPosition>.from(current)..add(created);
          state = state.copyWith(positions: AsyncData(updated));
          _updateCachedAccountLocation();
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<void> deletePosition(int positionId) async {
    final previousPositions = state.positions;
    try {
      state = state.copyWith(positions: const AsyncLoading());
      final result = await churchRepo.deletePosition(positionId: positionId);

      result.when(
        onSuccess: (_) {
          final current = previousPositions.value ?? const <MemberPosition>[];
          final updated = current.where((p) => p.id != positionId).toList();
          state = state.copyWith(positions: AsyncData(updated));
        },
        onFailure: (failure) => throw Exception(failure.message),
      );
    } catch (e, st) {
      _catchError(e, st);
    }
  }

  Future<Church> fetchChurchDetail(int churchId) async {
    try {
      final result = await churchRepo.fetchChurchProfile(churchId);
      final value = result.when<Church>(
        onSuccess: (church) => church,
        onFailure: (failure) => throw Exception(failure.message),
      );
      return value!;
    } catch (e) {
      rethrow;
    }
  }

  // Centralized error handler: if a slice is currently loading, restore its previous
  // value (when available) to avoid leaving the UI stuck in loading state; otherwise
  // set it to AsyncError. Always rethrow with the original stack to let callers handle UI.
  void _catchError(Object e, StackTrace st) {
    AsyncValue<T> restore<T>(AsyncValue<T> slice) {
      if (slice.isLoading) {
        if (slice.hasValue) {
          return AsyncData(slice.value as T);
        } else {
          return AsyncError(e, st);
        }
      }
      return slice;
    }

    state = state.copyWith(
      church: restore(state.church),
      location: restore(state.location),
      columns: restore(state.columns),
      positions: restore(state.positions),
    );

    // Preserve original stack trace on rethrow
    Error.throwWithStackTrace(e, st);
  }

  // Helper: Update cached auth account.membership.church.location (and locationId)
  Future<void> _updateCachedAccountLocation() async {
    final authState = ref.read(authControllerProvider);
    final currentAuth = authState.value;
    if (currentAuth == null) return;

    final currentAccount = currentAuth.account;

    final membership = currentAccount.membership;
    if (membership == null) return;

    final currentChurch = membership.church;
    if (currentChurch == null) return;

    final updatedAccount = currentAccount.copyWith(
      membership: membership.copyWith(
        church: state.church.value?.copyWith(
          location: state.location.value ?? currentChurch.location,
          membershipPositions:
              state.positions.value ?? currentChurch.membershipPositions,
          columns: state.columns.value ?? currentChurch.columns,
        ),
      ),
    );

    await ref
        .read(authControllerProvider.notifier)
        .updateCachedAccount(updatedAccount);
  }
}
