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

  void _setDummyApprovals() {
    final a1 = Approval(
      id: 1,
      description: 'Buying of the office supplies',
      supervisor: Membership(
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
      ),
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
      createdAt: DateTime(2025, 9, 14),
    );

    final a2 = Approval(
      id: 2,
      description: 'Income: Donation Transfer',
      supervisor: Membership(
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
      ),
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
      createdAt: DateTime(2025, 9, 12),
    );

    final a3 = Approval(
      id: 2,
      description: 'Document Request',
      supervisor: Membership(
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
      ),
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
      createdAt: DateTime(2025, 9, 12),
    );

    state = state.copyWith(approvals: [a1, a2, a3]);
  }
}
