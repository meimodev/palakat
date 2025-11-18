import 'package:palakat/features/presentation.dart';
import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/repositories.dart';
import 'package:palakat_shared/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'membership_controller.g.dart';

@riverpod
class MembershipController extends _$MembershipController {
  @override
  MembershipState build() {
    return const MembershipState();
  }

  /// Fetch churches from backend with optional search
  Future<List<Church>> fetchChurches({String? searchQuery}) async {
    print('🔄 MembershipController: Fetching churches, search: $searchQuery');

    try {
      final churchRepo = ref.read(churchRepositoryProvider);

      final paginationRequest =
          PaginationRequestWrapper<GetFetchChurchesRequest>(
            page: 1,
            pageSize: 100,
            data: GetFetchChurchesRequest(search: searchQuery),
          );

      final result = await churchRepo.fetchChurches(
        paginationRequest: paginationRequest,
      );

      final churches = result.when<List<Church>>(
        onSuccess: (response) {
          print(
            '✅ MembershipController: Fetched ${response.data.length} churches',
          );
          return response.data.cast<Church>();
        },
        onFailure: (failure) {
          print(
            '❌ MembershipController: Failed to fetch churches: ${failure.message}',
          );
        },
      );

      return churches ?? <Church>[];
    } catch (e) {
      print('❌ MembershipController: Error fetching churches: $e');
      return [];
    }
  }

  /// Fetch columns from backend filtered by church ID with optional search
  Future<List<Column>> fetchColumns({
    required int churchId,
    String? searchQuery,
  }) async {
    print(
      '🔄 MembershipController: Fetching columns for church $churchId, search: $searchQuery',
    );

    try {
      final churchRepo = ref.read(churchRepositoryProvider);

      final paginationRequest =
          PaginationRequestWrapper<GetFetchColumnsRequest>(
            page: 1,
            pageSize: 100,
            data: GetFetchColumnsRequest(
              churchId: churchId,
              search: searchQuery,
            ),
          );

      final result = await churchRepo.fetchColumns(
        paginationRequest: paginationRequest,
      );

      final columns = result.when<List<Column>>(
        onSuccess: (response) {
          print(
            '✅ MembershipController: Fetched ${response.data.length} columns',
          );
          return response.data.cast<Column>();
        },
        onFailure: (failure) {
          print(
            '❌ MembershipController: Failed to fetch columns: ${failure.message}',
          );
        },
      );

      return columns ?? <Column>[];
    } catch (e) {
      print('❌ MembershipController: Error fetching columns: $e');
      return [];
    }
  }

  /// Fetch membership data from backend by ID
  Future<void> fetchMembership(int membershipId) async {
    print(
      '🔄 MembershipController: Fetching membership data for ID: $membershipId',
    );
    state = state.copyWith(loading: true, errorMessage: null);

    try {
      final membershipRepo = ref.read(membershipRepositoryProvider);

      final result = await membershipRepo.getMembership(membershipId);

      final membership = result.when(
        onSuccess: (m) => m,
        onFailure: (failure) {
          print(
            '❌ MembershipController: Failed to fetch membership: ${failure.message}',
          );
          state = state.copyWith(
            loading: false,
            errorMessage: 'Failed to load membership: ${failure.message}',
          );
          return;
        },
      );

      if (membership == null) {
        return;
      }

      print('✅ MembershipController: Membership fetched successfully');

      // Populate the form with fetched membership data
      state = state.copyWith(
        loading: false,
        membership: membership,
        church: membership.church,
        column: membership.column,
        baptize: membership.baptize,
        sidi: membership.sidi,
      );
    } catch (e, stackTrace) {
      print('❌ MembershipController: Error fetching membership: $e');
      print('Stack trace: $stackTrace');
      state = state.copyWith(
        loading: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  /// Fetch church request for the current user
  Future<void> fetchMyChurchRequest() async {
    try {
      final churchRequestRepo = ref.read(churchRequestRepositoryProvider);
      final result = await churchRequestRepo.getMyChurchRequest();

      result.when(
        onSuccess: (churchRequest) {
          state = state.copyWith(
            churchRequest: churchRequest,
            hasCheckedChurchRequest: true,
          );
        },
        onFailure: (failure) {
          // If error occurs, it means no request exists, which is fine
          state = state.copyWith(
            churchRequest: null,
            hasCheckedChurchRequest: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        churchRequest: null,
        hasCheckedChurchRequest: true,
      );
    }
  }

  String? validateChurch(Church? value) {
    if (value == null) {
      return 'Church Number is required';
    }
    return null;
  }

  String? validateColumn(Column? value) {
    if (value == null) {
      return 'Column is required';
    }
    return null;
  }

  String? validateBaptize(bool? value) {
    if (value == null) {
      return 'Baptize is required';
    }
    return null;
  }

  String? validateSidi(bool? value) {
    if (value == null) {
      return 'Sidi is required';
    }
    return null;
  }

  void onChangedChurch(Church? value) {
    state = state.copyWith(
      church: value,
      column: null, // Clear column when church changes
      errorChurch: null,
      errorColumn: null, // Clear column error as well
    );
  }

  void onChangedColumn(Column? value) {
    state = state.copyWith(column: value, errorColumn: null);
  }

  void onChangedBaptize(bool value) {
    state = state.copyWith(baptize: value, errorBaptize: null);
  }

  void onChangedSidi(bool value) {
    state = state.copyWith(sidi: value, errorSidi: null);
  }

  bool validateMembership() {
    return validateChurch(state.church) == null &&
        validateColumn(state.column) == null &&
        validateBaptize(state.baptize) == null &&
        validateSidi(state.sidi) == null;
  }

  Future<void> validateForm() async {
    state = state.copyWith(loading: true);
    final errorChurch = validateChurch(state.church);
    final errorColumn = validateColumn(state.column);
    final errorBaptize = validateBaptize(state.baptize);
    final errorSidi = validateSidi(state.sidi);

    final isValid =
        errorChurch == null &&
        errorColumn == null &&
        errorBaptize == null &&
        errorSidi == null;

    state = state.copyWith(
      errorChurch: errorChurch,
      errorColumn: errorColumn,
      errorBaptize: errorBaptize,
      errorSidi: errorSidi,
      isFormValid: isValid,
    );

    await Future.delayed(const Duration(milliseconds: 400));
    state = state.copyWith(loading: false);
  }

  Future<Result<Membership, Failure>> submit() async {
    await validateForm();

    if (!state.isFormValid) {
      return Result.failure(Failure('Please fill all required fields'));
    }

    state = state.copyWith(loading: true, errorMessage: null);

    try {
      final membershipRepo = ref.read(membershipRepositoryProvider);
      final storageService = ref.read(localStorageServiceProvider);

      // Prepare membership data
      final data = {
        'churchId': state.church!.id,
        'columnId': state.column!.id,
        'baptize': state.baptize,
        'sidi': state.sidi,
      };

      final Result<Membership, Failure> result;

      // Update or create based on whether we have an existing membership with id
      if (state.membership?.id != null) {
        print(
          '🔄 MembershipController: Updating membership ${state.membership!.id}',
        );
        result = await membershipRepo.updateMembership(
          membershipId: state.membership!.id!,
          data: data,
        );
      } else {
        print('🔄 MembershipController: Creating new membership');
        result = await membershipRepo.createMembership(data: data);
      }

      final membership = result.when<Membership?>(
        onSuccess: (m) => m,
        onFailure: (failure) {
          print(
            '❌ MembershipController: Failed to save membership: ${failure.message}',
          );
          state = state.copyWith(loading: false, errorMessage: failure.message);
          return null;
        },
      );

      if (membership != null) {
        print('✅ MembershipController: Membership saved successfully');

        // Save membership to local storage
        await storageService.saveMembership(membership);

        state = state.copyWith(loading: false, membership: membership);

        return Result.success(membership);
      } else {
        return Result.failure(
          Failure(state.errorMessage ?? 'Failed to save membership'),
        );
      }
    } catch (e, stackTrace) {
      print('❌ MembershipController: Error saving membership: $e');
      print('Stack trace: $stackTrace');
      state = state.copyWith(
        loading: false,
        errorMessage: 'An unexpected error occurred: ${e.toString()}',
      );
      return Result.failure(Failure('An unexpected error occurred'));
    }
  }

  void publish() {}
}
