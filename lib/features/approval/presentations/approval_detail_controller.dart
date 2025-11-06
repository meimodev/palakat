import 'package:palakat_admin/core/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/core/constants/constants.dart';
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
      baptize: true,
      sidi: true,
      membershipPositions: [
        MemberPosition(id: 2, churchId: 10, name: "Penatua WKI"),
        MemberPosition(id: 3, churchId: 10, name: "Penatua Kolom 1"),
        MemberPosition(id: 5, churchId: 10, name: "Diaken Kolom 1"),
        MemberPosition(id: 6, churchId: 10, name: "Sekretaris Kolom 1"),
        MemberPosition(id: 7, churchId: 10, name: "Bendahara Kolom 1"),
      ],
      account: Account(
        id: 1,
        phone: '+62 812-3456-7890',
        name: 'Jane Doe',
        dob: DateTime(1990, 5, 20),
        gender: Gender.female,
        maritalStatus: MaritalStatus.single,
      ),
    );

    final supervisor2 = Membership(
      id: 102,
      baptize: true,
      sidi: true,
      account: Account(
        id: 1002,
        phone: '+62 821-5555-7777',
        name: 'John Smith',
        dob: DateTime(1985, 7, 11),
        gender: Gender.male,
        maritalStatus: MaritalStatus.married,
      ),
    );

    List<Approver> approversUnconfirmed() => [
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
    ];

    List<Approver> approversApproved() => [
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
    ];

    List<Approver> approversRejected() => [
      Approver(
        id: 5004,
        status: ApprovalStatus.rejected,
        createdAt: DateTime(2025, 9, 5, 15, 30),
        updatedAt: DateTime(2025, 9, 6, 10, 15),
        membership: Membership(
          id: 204,
          baptize: true,
          sidi: true,
          account: Account(
            id: 2004,
            phone: '+62 857-6655-4433',
            name: 'Thomas Hutabarat',
            dob: DateTime(1983, 8, 17),
            gender: Gender.male,
            maritalStatus: MaritalStatus.married,
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
          description: 'Purchase of printer paper, pens, and folders for church office',
          date: DateTime.now(),
          note: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
          fileUrl: "https://file-examples.com/wp-content/storage/2017/10/file-example_PDF_500_kB.pdf",
          activityType: ActivityType.service,
          createdAt: DateTime(2025, 9, 14, 8, 30),
          updatedAt: DateTime(2025, 9, 14, 14, 45),
          location: Location(
            name: 'Church Main Hall',
            latitude: 1.2921,
            longitude: 103.8520,
            id: 1,
          ),
          supervisor: supervisor1,
          approvers: approversUnconfirmed(),
        );
      case 2:
        return Activity(
          id: 2,
          supervisorId: supervisor2.id,
          title: 'Income: Donation Transfer',
          description: 'Monthly donation from parish members via bank transfer',
          date: DateTime.now().subtract(const Duration(days: 5)),
          note: 'Total received: Rp 15,000,000',
          fileUrl: 'https://example.com/transactions/donation-sept-2025.pdf',
          activityType: ActivityType.service,
          createdAt: DateTime(2025, 9, 12, 11, 20),
          updatedAt: DateTime(2025, 9, 12, 16, 30),
          supervisor: supervisor2,
          approvers: approversApproved(),
        );
      case 3:
        return Activity(
          id: 3,
          supervisorId: supervisor2.id,
          bipra: Bipra.mothers,
          title: 'Document Request',
          description: 'Request for baptism certificates for 5 children',
          date: DateTime.now().subtract(const Duration(days: 10)),
          note: 'Rejected due to incomplete parent information',
          fileUrl: null,
          activityType: ActivityType.service,
          createdAt: DateTime(2025, 9, 5, 9, 0),
          updatedAt: DateTime(2025, 9, 6, 10, 15),
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
          activityType: ActivityType.event,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          supervisor: supervisor1,
          approvers: approversUnconfirmed(),
        );
    }
  }
}
