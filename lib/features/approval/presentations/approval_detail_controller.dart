import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/constants/enums/enums.dart';
import 'package:palakat/features/approval/presentations/approval_detail_state.dart';

part 'approval_detail_controller.g.dart';

@riverpod
class ApprovalDetailController extends _$ApprovalDetailController {
  @override
  ApprovalDetailState build({required int activityId}) {
    // Kick off fetch
    fetch(activityId);
    return const ApprovalDetailState();
  }

  Future<void> fetch(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    // Use dummy map
    final activity = _dummyActivity(id);
    state = state.copyWith(activity: activity, loadingScreen: false);
  }

  Activity _dummyActivity(int id) {
    // Shared dummy memberships
    final supervisor1 = Membership(
      id: 1,
      accountId: 1,
      churchId: 10,
      columnId: 1,
      baptize: true,
      sidi: true,
      membershipPositions: [
        MemberPosition(id: 2, churchId: 10, columnId: 1, name: "Penatua WKI"),
        MemberPosition(
          id: 3,
          churchId: 10,
          columnId: 1,
          name: "Penatua Kolom 1",
        ),
        MemberPosition(
          id: 5,
          churchId: 10,
          columnId: 1,
          name: "Diaken Kolom 1",
        ),
        MemberPosition(
          id: 5,
          churchId: 10,
          columnId: 1,
          name: "Diaken Kolom 1",
        ),
        MemberPosition(
          id: 5,
          churchId: 10,
          columnId: 1,
          name: "Diaken Kolom 1",
        ),
      ],
      account: Account(
        id: 1,
        phone: '+1 555-0001',
        name: 'Jane Doe',
        dob: DateTime(1990, 5, 20),
        gender: Gender.female,
        married: false,
      ),
    );

    final supervisor2 = Membership(
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

    List<Approver> approversUnconfirmed() => [
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
        id: 5002,
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
    ];

    List<Approver> approversApproved() => [
      Approver(
        id: 5003,
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
    ];

    List<Approver> approversRejected() => [
      Approver(
        id: 5004,
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
    ];

    switch (id) {
      case 1:
        return Activity(
          id: 1,
          supervisorId: supervisor1.id,
          bipra: Bipra.fathers,
          title: 'Buying of the office supplies',
          description: 'Buying of the office supplies',
          date: DateTime.now(),
          note: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          fileUrl: "https://file-examples.com/wp-content/storage/2017/10/file-example_PDF_500_kB.pdf",
          type: ActivityType.announcement,
          createdAt: DateTime(2025, 9, 14),
          updatedAt: DateTime(2025, 9, 14),
          location: Location(
            name: 'Location 1',
            latitude: 1.422,
            longitude: 0.44,
            id: 1,
          ),
          supervisor: supervisor1,
          approvers: approversUnconfirmed(),
        );
      case 2:
        return Activity(
          id: 2,
          supervisorId: supervisor2.id,
          bipra: Bipra.general,
          title: 'Income: Donation Transfer',
          description: 'Income: Donation Transfer',
          date: DateTime.now(),
          note: null,
          fileUrl: null,
          type: ActivityType.announcement,
          createdAt: DateTime(2025, 9, 12),
          updatedAt: DateTime(2025, 9, 12),
          supervisor: supervisor2,
          approvers: approversApproved(),
        );
      case 3:
        return Activity(
          id: 3,
          supervisorId: supervisor2.id,
          bipra: Bipra.mothers,
          title: 'Document Request',
          description: 'Document Request',
          date: DateTime.now(),
          note: null,
          fileUrl: null,
          type: ActivityType.announcement,
          createdAt: DateTime(2025, 9, 12),
          updatedAt: DateTime(2025, 9, 12),
          supervisor: supervisor2,
          approvers: approversRejected(),
        );
      default:
        return Activity(
          id: id,
          supervisorId: supervisor1.id,
          bipra: Bipra.youths,
          title: 'Activity #$id',
          description: 'Generated dummy for activity #$id',
          date: DateTime.now(),
          note: null,
          fileUrl: null,
          type: ActivityType.event,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          supervisor: supervisor1,
          approvers: approversUnconfirmed(),
        );
    }
  }
}
