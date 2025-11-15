import 'package:palakat_shared/core/models/models.dart';
import 'package:palakat_shared/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';
import 'package:palakat/core/constants/constants.dart';

part 'approval_controller.g.dart';

@riverpod
class ApprovalController extends _$ApprovalController {
  AuthRepository get _authRepository =>
      ref.read(authRepositoryProvider);

  @override
  ApprovalState build() {
    fetchData();
    return const ApprovalState();
  }

  void fetchData() async {
    await fetchMembership();
    _setDummyApprovals();
  }

  Future<void> fetchMembership() async {
    final result = await _authRepository.getSignedInAccount();
    result.when(
      onSuccess: (account) {
        state = state.copyWith(membership: account?.membership, loadingScreen: false);
      },
      onFailure: (failure) {
        state = state.copyWith(
          loadingScreen: false,
          errorMessage: failure.message ,
        );
      },
    );
  }

  // Date filter controls
  void setDateRange({DateTime? start, DateTime? end}) {
    state = state.copyWith(
      filterStartDate: start,
      filterEndDate: end,
    );
    _applyFilters();
  }

  void clearDateFilter() {
    state = state.copyWith(filterStartDate: null, filterEndDate: null);
    _applyFilters();
  }

  void _applyFilters() {
    final start = state.filterStartDate;
    final end = state.filterEndDate;

    if (start == null && end == null) {
      state = state.copyWith(filteredApprovals: state.approvals);
      return;
    }

    bool inRange(DateTime d) {
      final sOk = start == null || !d.isBefore(_atStartOfDay(start));
      final eOk = end == null || !d.isAfter(_atEndOfDay(end));
      return sOk && eOk;
    }

    final filtered = state.approvals.where((a) {
      final activityDate = a.createdAt; // use activity date for filtering
      return inRange(activityDate);
    }).toList();

    state = state.copyWith(filteredApprovals: filtered);
  }

  DateTime _atStartOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _atEndOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  void _setDummyApprovals() {
    final a1Supervisor = Membership(
        id: 101,
        baptize: true,
        sidi: true,
        account: Account(
          id: 1001,
          phone: '+62 812-3456-7890',
          name: 'Jane Doe',
          dob: DateTime(1990, 5, 20),
          gender: Gender.female,
          maritalStatus: MaritalStatus.single,
        ),
      );

    final a1 = Activity(
      id: 1,
      supervisorId: a1Supervisor.id,
      bipra: Bipra.fathers,
      title: 'Buying of the office supplies',
      description: 'Purchase of printer paper, pens, and folders for church office',
      date: DateTime.now(),
      note: 'Urgent - office supplies running low',
      fileUrl: 'https://example.com/receipts/office-supplies-2025.pdf',
      activityType: ActivityType.service,
      createdAt: DateTime(2025, 9, 14, 8, 30),
      updatedAt: DateTime(2025, 9, 14, 14, 45),
      supervisor: a1Supervisor,
      approvers: [
        Approver(
          id: 5001,
          status: ApprovalStatus.unconfirmed,
          createdAt: DateTime(2025, 9, 14, 9, 15),
          updatedAt: DateTime(2025, 9, 14, 9, 15),
          membership: Membership(
            id: 201,
            baptize: true,
            sidi: false,
            account: Account(
              id: 2001,
              phone: '+62 813-9876-5432',
              name: 'Robert Manembo',
              dob: DateTime(1988, 2, 14),
              gender: Gender.male,
              maritalStatus: MaritalStatus.married,
            ),
          ),
        ),
        Approver(
          id: 5002,
          status: ApprovalStatus.approved,
          createdAt: DateTime(2025, 9, 14, 10, 22),
          updatedAt: DateTime(2025, 9, 14, 14, 45),
          membership: Membership(
            id: 202,
            baptize: true,
            sidi: true,
            account: Account(
              id: 2002,
              phone: '+62 815-2468-1357',
              name: 'Sarah Williams',
              dob: DateTime(1985, 11, 8),
              gender: Gender.female,
              maritalStatus: MaritalStatus.married,
            ),
          ),
        ),
      ],
    );

    final a2Supervisor = Membership(
        id: 102,
        baptize: true,
        sidi: true,
        account: Account(
          id: 1002,
          phone: '+62 821-5555-7777',
          name: 'Michael Chen',
          dob: DateTime(1985, 7, 11),
          gender: Gender.male,
          maritalStatus: MaritalStatus.married,
        ),
      );

    final a2 = Activity(
      id: 2,
      supervisorId: a2Supervisor.id,
      title: 'Income: Donation Transfer',
      description: 'Monthly donation from parish members via bank transfer',
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: 'Total received: Rp 15,000,000',
      fileUrl: 'https://example.com/transactions/donation-sept-2025.pdf',
      activityType: ActivityType.service,
      createdAt: DateTime(2025, 9, 12, 11, 20),
      updatedAt: DateTime(2025, 9, 12, 16, 30),
      supervisor: a2Supervisor,
      approvers: [
        Approver(
          id: 5003,
          status: ApprovalStatus.approved,
          createdAt: DateTime(2025, 9, 12, 13, 45),
          updatedAt: DateTime(2025, 9, 12, 16, 30),
          membership: Membership(
            id: 203,
            baptize: true,
            sidi: true,
            account: Account(
              id: 2003,
              phone: '+62 822-1122-3344',
              name: 'David Lumbantobing',
              dob: DateTime(1992, 3, 9),
              gender: Gender.male,
              maritalStatus: MaritalStatus.single,
            ),
          ),
        ),
        Approver(
          id: 5004,
          status: ApprovalStatus.approved,
          createdAt: DateTime(2025, 9, 12, 14, 10),
          updatedAt: DateTime(2025, 9, 12, 15, 55),
          membership: Membership(
            id: 204,
            baptize: true,
            sidi: true,
            account: Account(
              id: 2004,
              phone: '+62 823-9988-7766',
              name: 'Grace Sihombing',
              dob: DateTime(1990, 6, 25),
              gender: Gender.female,
              maritalStatus: MaritalStatus.married,
            ),
          ),
        ),
      ],
    );

    final a3Supervisor = Membership(
        id: 103,
        baptize: true,
        sidi: true,
        account: Account(
          id: 1003,
          phone: '+62 856-4321-8765',
          name: 'Patricia Situmorang',
          dob: DateTime(1987, 12, 3),
          gender: Gender.female,
          maritalStatus: MaritalStatus.married,
        ),
      );

    final a3 = Activity(
      id: 3,
      supervisorId: a3Supervisor.id,
      bipra: Bipra.mothers,
      title: 'Document Request',
      description: 'Request for baptism certificates for 5 children',
      date: DateTime.now().subtract(const Duration(days: 10)),
      note: 'Rejected due to incomplete parent information',
      fileUrl: null,
      activityType: ActivityType.service,
      createdAt: DateTime(2025, 9, 5, 9, 0),
      updatedAt: DateTime(2025, 9, 6, 10, 15),
      supervisor: a3Supervisor,
      approvers: [
        Approver(
          id: 5005,
          status: ApprovalStatus.rejected,
          createdAt: DateTime(2025, 9, 5, 15, 30),
          updatedAt: DateTime(2025, 9, 6, 10, 15),
          membership: Membership(
            id: 205,
            baptize: true,
            sidi: true,
            account: Account(
              id: 2005,
              phone: '+62 857-6655-4433',
              name: 'Thomas Hutabarat',
              dob: DateTime(1983, 8, 17),
              gender: Gender.male,
              maritalStatus: MaritalStatus.married,
            ),
          ),
        ),
        Approver(
          id: 5006,
          status: ApprovalStatus.rejected,
          createdAt: DateTime(2025, 9, 5, 16, 45),
          updatedAt: DateTime(2025, 9, 6, 9, 20),
          membership: Membership(
            id: 206,
            baptize: true,
            sidi: false,
            account: Account(
              id: 2006,
              phone: '+62 858-3322-1100',
              name: 'Maria Simbolon',
              dob: DateTime(1995, 1, 30),
              gender: Gender.female,
              maritalStatus: MaritalStatus.single,
            ),
          ),
        ),
      ],
    );

    final approvals = [a1, a2, a3];
    state = state.copyWith(approvals: approvals, filteredApprovals: approvals);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
