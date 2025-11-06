import 'package:palakat_admin/core/models/models.dart';
import 'package:palakat_admin/core/repositories/repositories.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/core/constants/constants.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    Future.microtask(() {
      fetchData();
    });

    return const DashboardState();
  }

  MembershipRepository get _membershipRepo =>
      ref.read(membershipRepositoryProvider);

  void fetchData() async {
    await fetchMembershipData();
    _setDummyDashboardData();
  }

  Future<void> fetchMembershipData() async {
    state = state.copyWith(membershipLoading: true);
    final result = await _membershipRepo.getSignedInMembership();
    result.when(
      onSuccess: (membership) {
        state = state.copyWith(
          membershipLoading: false,
          membership: membership,
          account: membership?.account,
        );
      },
      onFailure: (failure) {
        state = state.copyWith(membershipLoading: false, membership: null);
      },
    );
  }

  void _setDummyDashboardData() {
    // Create a couple of dummy supervisors for activities/announcements
    final supervisor1 = Membership(
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

    // Dummy approvers (not displayed on dashboard but required by model)
    final dummyApprovers = <Approver>[
      Approver(
        id: 5001,
        status: ApprovalStatus.unconfirmed,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        membership: supervisor2,
      ),
    ];

    final now = DateTime.now();

    // Activities for this week (services/events)
    final activities = <Activity>[
      Activity(
        id: 1,
        supervisorId: supervisor1.id,
        title: 'Sunday Service',
        description: 'Weekly worship service',
        date: DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 1)),
        note: null,
        fileUrl: null,
        activityType: ActivityType.service,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        supervisor: supervisor1,
        approvers: dummyApprovers,
      ),
      Activity(
        id: 2,
        supervisorId: supervisor2.id,
        bipra: Bipra.youths,
        title: 'Community Outreach',
        description: 'Neighborhood clean-up event',
        date: DateTime(
          now.year,
          now.month,
          now.day,
        ).add(const Duration(days: 3)),
        note: null,
        fileUrl: null,
        activityType: ActivityType.event,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        supervisor: supervisor2,
        approvers: dummyApprovers,
      ),
    ];

    // Announcements (use Activity with type service)
    final announcements = <Activity>[
      Activity(
        id: 3,
        supervisorId: supervisor1.id,
        bipra: Bipra.fathers,
        title: 'Buying of the office supplies',
        description: 'Office supply purchasing scheduled this week',
        date: now,
        note: null,
        fileUrl: null,
        activityType: ActivityType.service,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        supervisor: supervisor1,
        approvers: dummyApprovers,
      ),
      Activity(
        id: 4,
        supervisorId: supervisor2.id,
        title: 'Donation Transfer Received',
        description: 'Income: Donation transfer has been received',
        date: now.subtract(const Duration(days: 2)),
        note: null,
        fileUrl: null,
        activityType: ActivityType.service,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
        supervisor: supervisor2,
        approvers: dummyApprovers,
      ),
    ];

    state = state.copyWith(
      thisWeekActivities: activities,
      thisWeekAnnouncements: announcements,
      thisWeekActivitiesLoading: false,
      thisWeekAnnouncementsLoading: false,
    );
  }
}
