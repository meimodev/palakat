import 'package:palakat/features/account/data/membership_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/approval/presentations/approval_state.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/constants/enums/enums.dart';

part 'approval_controller.g.dart';

@riverpod
class ApprovalController extends _$ApprovalController {
  MembershipRepository get _membershipRepository =>
      ref.read(membershipRepositoryProvider);

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
    final result = await _membershipRepository.getSignedInMembership();
    result.when(
      onSuccess: (data) {
        state = state.copyWith(membership: data, loadingScreen: false);
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
      final activityDate = a.date; // use activity date for filtering
      return inRange(activityDate);
    }).toList();

    state = state.copyWith(filteredApprovals: filtered);
  }

  DateTime _atStartOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _atEndOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  void _setDummyApprovals() {
    final a1Supervisor = Membership(
        id: 1,
        accountId: 1,
        churchId: 10,
        columnId: 1,
        baptize: true,
        sidi: true,
        account: Account(
          id: 1,
          phone: '+1 555-0001',
          name: 'Jane Doe',
          dob: DateTime(1990, 5, 20),
          gender: Gender.female,
          married: false,
        ),
      );

    final a1 = Activity(
      id: 1,
      supervisorId: a1Supervisor.id,
      bipra: Bipra.fathers,
      title: 'Buying of the office supplies',
      description: 'Buying of the office supplies',
      date: DateTime.now(),
      note: null,
      fileUrl: null,
      type: ActivityType.announcement,
      createdAt: DateTime(2025, 9, 14),
      updatedAt: DateTime(2025, 9, 14),
      supervisor: a1Supervisor,
      approvers: [
        Approver(
          id: 5001,
          status: ApprovalStatus.unconfirmed,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          membership: Membership(
            id: 1,
            accountId: 1,
            churchId: 10,
            columnId: 2,
            baptize: true,
            sidi: false,
            account: Account(
              id: 2001,
              phone: '+1 555-0101',
              name: 'Manembo Jhon',
              dob: DateTime(1988, 2, 14),
              gender: Gender.male,
              married: true,
            ),
          ),
        ),
        Approver(
          id: 5001,
          status: ApprovalStatus.approved,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          membership: Membership(
            id: 201,
            accountId: 2001,
            churchId: 10,
            columnId: 2,
            baptize: true,
            sidi: false,
            account: Account(
              id: 2001,
              phone: '+1 555-0101',
              name: 'John Smith',
              dob: DateTime(1988, 2, 14),
              gender: Gender.male,
              married: true,
            ),
          ),
        ),
      ],
    );

    final a2Supervisor = Membership(
        id: 102,
        accountId: 1002,
        churchId: 10,
        columnId: 1,
        baptize: true,
        sidi: true,
        account: Account(
          id: 1002,
          phone: '+1 555-0002',
          name: 'John Smith',
          dob: DateTime(1985, 7, 11),
          gender: Gender.male,
          married: true,
        ),
      );

    final a2 = Activity(
      id: 2,
      supervisorId: a2Supervisor.id,
      bipra: Bipra.general,
      title: 'Income: Donation Transfer',
      description: 'Income: Donation Transfer',
      date: DateTime.now().subtract(const Duration(days: 5)),
      note: null,
      fileUrl: null,
      type: ActivityType.announcement,
      createdAt: DateTime(2025, 9, 12),
      updatedAt: DateTime(2025, 9, 12),
      supervisor: a2Supervisor,
      approvers: [
        Approver(
          id: 5002,
          status: ApprovalStatus.approved,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          membership: Membership(
            id: 202,
            accountId: 2002,
            churchId: 10,
            columnId: 2,
            baptize: true,
            sidi: true,
            account: Account(
              id: 2002,
              phone: '+1 555-0102',
              name: 'Alex Johnson',
              dob: DateTime(1992, 3, 9),
              gender: Gender.male,
              married: false,
            ),
          ),
        ),
      ],
    );

    final a3Supervisor = Membership(
        id: 102,
        accountId: 1002,
        churchId: 10,
        columnId: 1,
        baptize: true,
        sidi: true,
        account: Account(
          id: 1002,
          phone: '+1 555-0002',
          name: 'John Smith',
          dob: DateTime(1985, 7, 11),
          gender: Gender.male,
          married: true,
        ),
      );

    final a3 = Activity(
      id: 3,
      supervisorId: a3Supervisor.id,
      bipra: Bipra.mothers,
      title: 'Document Request',
      description: 'Document Request',
      date: DateTime.now().subtract(const Duration(days: 10)),
      note: null,
      fileUrl: null,
      type: ActivityType.announcement,
      createdAt: DateTime(2025, 9, 12),
      updatedAt: DateTime(2025, 9, 12),
      supervisor: a3Supervisor,
      approvers: [
        Approver(
          id: 5002,
          status: ApprovalStatus.rejected,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          membership: Membership(
            id: 202,
            accountId: 2002,
            churchId: 10,
            columnId: 2,
            baptize: true,
            sidi: true,
            account: Account(
              id: 2002,
              phone: '+1 555-0102',
              name: 'Alex Johnson',
              dob: DateTime(1992, 3, 9),
              gender: Gender.male,
              married: false,
            ),
          ),
        ),
      ],
    );

    final approvals = [a1, a2, a3];
    state = state.copyWith(approvals: approvals, filteredApprovals: approvals);
  }
}
