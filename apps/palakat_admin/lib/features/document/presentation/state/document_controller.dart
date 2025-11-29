import 'package:palakat_admin/features/auth/application/auth_controller.dart';
import 'package:palakat_admin/features/document/presentation/state/document_screen_state.dart';
import 'package:palakat_admin/models.dart';
import 'package:palakat_admin/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'document_controller.g.dart';

@riverpod
class DocumentController extends _$DocumentController {
  @override
  DocumentScreenState build() {
    final initial = const DocumentScreenState();
    Future.microtask(() {
      _fetchDocuments();
    });
    return initial;
  }

  Church get church =>
      ref.read(authControllerProvider).value!.account.membership!.church!;

  Future<void> _fetchDocuments() async {
    state = state.copyWith(documents: const AsyncLoading());
    final repository = ref.read(documentRepositoryProvider);

    final result = await repository.fetchDocuments(
      paginationRequest: PaginationRequestWrapper(
        data: GetFetchDocumentsRequest(churchId: church.id!),
        page: state.currentPage,
        pageSize: state.pageSize,
      ),
    );

    result.when(
      onSuccess: (documents) {
        state = state.copyWith(documents: AsyncData(documents));
      },
      onFailure: (failure) {
        state = state.copyWith(
          documents: AsyncError(
            AppError.serverError(failure.message, statusCode: failure.code),
            StackTrace.current,
          ),
        );
      },
    );
  }

  Future<void> refresh() async {
    await _fetchDocuments();
  }
}
