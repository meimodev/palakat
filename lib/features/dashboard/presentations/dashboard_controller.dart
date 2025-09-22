import 'package:palakat/features/account/data/membership_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:palakat/features/presentation.dart';
import 'package:palakat/core/models/models.dart' hide Column;
import 'package:palakat/core/constants/enums/enums.dart';

part 'dashboard_controller.g.dart';

@riverpod
class DashboardController extends _$DashboardController {
  @override
  DashboardState build() {
    fetchData();

    // Use defaults from Freezed state (loading flags true initially)
    return const DashboardState();
  }

  MembershipRepository get _membershipRepo =>
      ref.read(membershipRepositoryProvider);

  void fetchData() async {
    await fetchMembershipData();
    _setDummyDashboardData();
  }

  Future<void> fetchMembershipData() async {
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
      accountId: 1001,
      churchId: 10,
      columnId: 1,
      baptize: true,
      sidi: true,
      account: Account(
        id: 1001,
        phone: '+1 555-0101',
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
        phone: '+1 555-0102',
        name: 'John Smith',
        dob: DateTime(1985, 7, 11),
        gender: Gender.male,
        married: true,
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
        bipra: Bipra.general,
        title: 'Sunday Service',
        description: 'Weekly worship service',
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
        note: null,
        fileUrl: null,
        type: ActivityType.service,
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
        date: DateTime(now.year, now.month, now.day).add(const Duration(days: 3)),
        note: null,
        fileUrl: null,
        type: ActivityType.event,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        supervisor: supervisor2,
        approvers: dummyApprovers,
      ),
    ];

    // Announcements (use Activity with type announcement)
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
        type: ActivityType.announcement,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now,
        supervisor: supervisor1,
        approvers: dummyApprovers,
      ),
      Activity(
        id: 4,
        supervisorId: supervisor2.id,
        bipra: Bipra.general,
        title: 'Donation Transfer Received',
        description: 'Income: Donation transfer has been received',
        date: now.subtract(const Duration(days: 2)),
        note: null,
        fileUrl: null,
        type: ActivityType.announcement,
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
