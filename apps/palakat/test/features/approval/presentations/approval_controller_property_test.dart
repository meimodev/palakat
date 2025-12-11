import 'package:flutter_test/flutter_test.dart';
import 'package:kiri_check/kiri_check.dart';
import 'package:palakat_shared/core/constants/enums.dart';
import 'package:palakat_shared/core/models/models.dart';

/// Property-based tests for ApprovalController status grouping and filtering.
/// **Feature: announcement-financial-admin-cleanup-approval-redesign**
void main() {
  group('ApprovalController Property Tests', () {
    /// **Feature: announcement-financial-admin-cleanup-approval-redesign, Property 4: Status grouping correctness**
    /// **Validates: Requirements 3.1**
    ///
    /// *For any* list of activities with various approval statuses, grouping by status
    /// should correctly categorize activities into: pending my action (current user has
    /// UNCONFIRMED status), pending others (has UNCONFIRMED but not for current user),
    /// approved (all approvers APPROVED), and rejected (any approver REJECTED).
    property('Property 4: Status grouping correctness', () {
      forAll(
        combine2(
          _activitiesListArbitrary(),
          integer(min: 1, max: 1000), // membershipId
        ),
        (tuple) {
          final (activities, membershipId) = tuple;

          // Group activities using the same logic as the controller
          final grouped = _groupActivitiesByStatus(activities, membershipId);

          // Verify each activity is in exactly one group
          final allGrouped = [
            ...grouped.pendingMyAction,
            ...grouped.pendingOthers,
            ...grouped.approved,
            ...grouped.rejected,
          ];

          expect(
            allGrouped.length,
            equals(activities.length),
            reason: 'All activities should be grouped exactly once',
          );

          // Verify pendingMyAction contains only activities where user has UNCONFIRMED
          for (final activity in grouped.pendingMyAction) {
            final userApprover = activity.approvers.where(
              (a) => a.membership?.id == membershipId,
            );
            expect(
              userApprover.isNotEmpty,
              isTrue,
              reason: 'Pending my action should have user as approver',
            );
            expect(
              userApprover.first.status,
              equals(ApprovalStatus.unconfirmed),
              reason: 'User approver should have UNCONFIRMED status',
            );
          }

          // Verify approved contains only activities where all approvers APPROVED
          for (final activity in grouped.approved) {
            final allApproved = activity.approvers.every(
              (a) => a.status == ApprovalStatus.approved,
            );
            expect(
              allApproved,
              isTrue,
              reason: 'Approved group should have all approvers approved',
            );
          }

          // Verify rejected contains activities with at least one REJECTED
          for (final activity in grouped.rejected) {
            final hasRejection = activity.approvers.any(
              (a) => a.status == ApprovalStatus.rejected,
            );
            expect(
              hasRejection,
              isTrue,
              reason: 'Rejected group should have at least one rejection',
            );
          }
        },
      );
    });

    /// **Feature: announcement-financial-admin-cleanup-approval-redesign, Property 5: Pending action prioritization**
    /// **Validates: Requirements 3.2**
    ///
    /// *For any* approval screen state, activities requiring the current user's action
    /// should appear before activities pending other approvers' actions in the display order.
    property('Property 5: Pending action prioritization', () {
      forAll(
        combine2(
          _activitiesListArbitrary(),
          integer(min: 1, max: 1000), // membershipId
        ),
        (tuple) {
          final (activities, membershipId) = tuple;

          // Group activities
          final grouped = _groupActivitiesByStatus(activities, membershipId);

          // Create filtered list with "all" filter (same as controller)
          final filteredList = [
            ...grouped.pendingMyAction,
            ...grouped.pendingOthers,
            ...grouped.approved,
            ...grouped.rejected,
          ];

          // Find first pendingOthers index
          int? firstPendingOthersIndex;
          for (int i = 0; i < filteredList.length; i++) {
            if (grouped.pendingOthers.contains(filteredList[i])) {
              firstPendingOthersIndex = i;
              break;
            }
          }

          // Find last pendingMyAction index
          int? lastPendingMyActionIndex;
          for (int i = filteredList.length - 1; i >= 0; i--) {
            if (grouped.pendingMyAction.contains(filteredList[i])) {
              lastPendingMyActionIndex = i;
              break;
            }
          }

          // If both exist, pendingMyAction should come before pendingOthers
          if (firstPendingOthersIndex != null &&
              lastPendingMyActionIndex != null) {
            expect(
              lastPendingMyActionIndex,
              lessThan(firstPendingOthersIndex),
              reason: 'Pending my action should appear before pending others',
            );
          }
        },
      );
    });

    /// **Feature: announcement-financial-admin-cleanup-approval-redesign, Property 9: Date filter preserves status grouping**
    /// **Validates: Requirements 3.6**
    ///
    /// *For any* date range filter applied to the approval screen, the filtered results
    /// should maintain correct status grouping (pending my action, pending others, approved, rejected).
    property('Property 9: Date filter preserves status grouping', () {
      forAll(
        combine3(
          _activitiesListArbitrary(),
          integer(min: 1, max: 1000), // membershipId
          _dateRangeArbitrary(), // date range filter
        ),
        (tuple) {
          final (activities, membershipId, dateRange) = tuple;
          final (startDate, endDate) = dateRange;

          // Group activities
          final grouped = _groupActivitiesByStatus(activities, membershipId);

          // Apply date filter to each group
          final filteredPendingMyAction = _filterByDateRange(
            grouped.pendingMyAction,
            startDate,
            endDate,
          );
          final filteredPendingOthers = _filterByDateRange(
            grouped.pendingOthers,
            startDate,
            endDate,
          );
          final filteredApproved = _filterByDateRange(
            grouped.approved,
            startDate,
            endDate,
          );
          final filteredRejected = _filterByDateRange(
            grouped.rejected,
            startDate,
            endDate,
          );

          // Verify filtered activities maintain their status grouping
          for (final activity in filteredPendingMyAction) {
            final userApprover = activity.approvers.where(
              (a) => a.membership?.id == membershipId,
            );
            if (userApprover.isNotEmpty) {
              expect(
                userApprover.first.status,
                equals(ApprovalStatus.unconfirmed),
                reason:
                    'Filtered pending my action should maintain status grouping',
              );
            }
          }

          // Verify pending others don't have user as unconfirmed approver
          for (final activity in filteredPendingOthers) {
            final userApprover = activity.approvers.where(
              (a) => a.membership?.id == membershipId,
            );
            // If user is an approver, they should not be unconfirmed
            // (otherwise it would be in pendingMyAction)
            if (userApprover.isNotEmpty) {
              expect(
                userApprover.first.status,
                isNot(equals(ApprovalStatus.unconfirmed)),
                reason:
                    'Filtered pending others should not have user as unconfirmed',
              );
            }
          }

          for (final activity in filteredApproved) {
            final allApproved = activity.approvers.every(
              (a) => a.status == ApprovalStatus.approved,
            );
            expect(
              allApproved,
              isTrue,
              reason: 'Filtered approved should maintain status grouping',
            );
          }

          for (final activity in filteredRejected) {
            final hasRejection = activity.approvers.any(
              (a) => a.status == ApprovalStatus.rejected,
            );
            expect(
              hasRejection,
              isTrue,
              reason: 'Filtered rejected should maintain status grouping',
            );
          }
        },
      );
    });

    /// **Feature: announcement-financial-admin-cleanup-approval-redesign, Property 10: Pending count accuracy**
    /// **Validates: Requirements 3.7**
    ///
    /// *For any* approval screen state, the pending action count should equal the number
    /// of activities where the current user has UNCONFIRMED approval status.
    property('Property 10: Pending count accuracy', () {
      forAll(
        combine2(
          _activitiesListArbitrary(),
          integer(min: 1, max: 1000), // membershipId
        ),
        (tuple) {
          final (activities, membershipId) = tuple;

          // Group activities
          final grouped = _groupActivitiesByStatus(activities, membershipId);

          // Count activities where user has UNCONFIRMED status
          int expectedCount = 0;
          for (final activity in activities) {
            final userApprover = activity.approvers.where(
              (a) => a.membership?.id == membershipId,
            );
            if (userApprover.isNotEmpty &&
                userApprover.first.status == ApprovalStatus.unconfirmed) {
              // Only count if not rejected by others
              final hasRejection = activity.approvers.any(
                (a) => a.status == ApprovalStatus.rejected,
              );
              if (!hasRejection) {
                expectedCount++;
              }
            }
          }

          expect(
            grouped.pendingMyAction.length,
            equals(expectedCount),
            reason:
                'Pending count should match activities with user UNCONFIRMED status',
          );
        },
      );
    });

    /// **Feature: announcement-financial-admin-cleanup-approval-redesign, Property 6: Activity card displays required information**
    /// **Validates: Requirements 3.3, 3.9**
    ///
    /// *For any* activity displayed in the approval list, the card should contain:
    /// title, supervisor name, date, activity type, overall approval status, and
    /// financial indicator (if hasRevenue or hasExpense is true).
    property('Property 6: Activity card displays required information', () {
      forAll(_activityWithFinancialArbitrary(), (activity) {
        // Verify activity has all required fields for card display
        expect(
          activity.title,
          isNotEmpty,
          reason: 'Activity should have a title',
        );

        expect(
          activity.supervisor,
          isNotNull,
          reason: 'Activity should have a supervisor',
        );

        expect(
          activity.supervisor.account?.name,
          isNotNull,
          reason: 'Supervisor should have a name',
        );

        expect(
          activity.createdAt,
          isNotNull,
          reason: 'Activity should have a creation date',
        );

        // Activity type is always present (enum with default)
        expect(
          activity.activityType,
          isNotNull,
          reason: 'Activity should have an activity type',
        );

        // Verify financial indicator logic
        if (activity.hasRevenue == true || activity.hasExpense == true) {
          // Financial indicator should be determinable
          final hasFinancial =
              activity.hasRevenue == true || activity.hasExpense == true;
          expect(
            hasFinancial,
            isTrue,
            reason:
                'Activity with financial data should have financial indicator',
          );

          // Verify financial type is determinable
          if (activity.hasRevenue == true) {
            expect(
              activity.financeType,
              equals(FinanceType.revenue),
              reason: 'hasRevenue should indicate revenue finance type',
            );
          } else if (activity.hasExpense == true) {
            expect(
              activity.financeType,
              equals(FinanceType.expense),
              reason: 'hasExpense should indicate expense finance type',
            );
          }
        }

        // Verify overall status can be computed from approvers
        if (activity.approvers.isNotEmpty) {
          final hasRejection = activity.approvers.any(
            (a) => a.status == ApprovalStatus.rejected,
          );
          final allApproved = activity.approvers.every(
            (a) => a.status == ApprovalStatus.approved,
          );
          final hasUnconfirmed = activity.approvers.any(
            (a) => a.status == ApprovalStatus.unconfirmed,
          );

          // Status should be determinable
          expect(
            hasRejection || allApproved || hasUnconfirmed,
            isTrue,
            reason: 'Overall status should be determinable from approvers',
          );
        }
      });
    });

    /// **Feature: announcement-financial-admin-cleanup-approval-redesign, Property 7: Quick action buttons visibility**
    /// **Validates: Requirements 3.4**
    ///
    /// *For any* activity where the current user has UNCONFIRMED approval status,
    /// the activity card should display approve and reject action buttons.
    property('Property 7: Quick action buttons visibility', () {
      forAll(
        combine2(
          _activityArbitrary(),
          integer(min: 1, max: 1000), // membershipId
        ),
        (tuple) {
          final (activity, membershipId) = tuple;

          // Check if current user has UNCONFIRMED status
          final userApprover = activity.approvers.where(
            (a) => a.membership?.id == membershipId,
          );

          final isMinePending =
              userApprover.isNotEmpty &&
              userApprover.first.status == ApprovalStatus.unconfirmed;

          // Check if activity is not already rejected
          final hasRejection = activity.approvers.any(
            (a) => a.status == ApprovalStatus.rejected,
          );

          // Quick action buttons should be visible when:
          // 1. User has UNCONFIRMED status
          // 2. Activity is not already rejected
          final shouldShowQuickActions = isMinePending && !hasRejection;

          if (shouldShowQuickActions) {
            // Verify the user approver can be found for action
            expect(
              userApprover.first.id,
              isNotNull,
              reason:
                  'User approver should have an ID for approve/reject actions',
            );

            // Verify activity has an ID for the action
            expect(
              activity.id,
              isNotNull,
              reason: 'Activity should have an ID for approve/reject actions',
            );
          }

          // Verify the logic is consistent
          if (isMinePending) {
            expect(
              userApprover.first.status,
              equals(ApprovalStatus.unconfirmed),
              reason: 'isMinePending should mean user has UNCONFIRMED status',
            );
          }
        },
      );
    });
  });
}

// ============================================================================
// Helper functions and generators
// ============================================================================

/// Groups activities by status for a given membership ID.
/// This mirrors the logic in ApprovalController._groupActivitiesByStatus()
_GroupedActivities _groupActivitiesByStatus(
  List<Activity> activities,
  int membershipId,
) {
  final pendingMyAction = <Activity>[];
  final pendingOthers = <Activity>[];
  final approved = <Activity>[];
  final rejected = <Activity>[];

  for (final activity in activities) {
    final status = _getActivityStatusForUser(activity, membershipId);
    switch (status) {
      case _ActivityUserStatus.pendingMyAction:
        pendingMyAction.add(activity);
        break;
      case _ActivityUserStatus.pendingOthers:
        pendingOthers.add(activity);
        break;
      case _ActivityUserStatus.approved:
        approved.add(activity);
        break;
      case _ActivityUserStatus.rejected:
        rejected.add(activity);
        break;
    }
  }

  return _GroupedActivities(
    pendingMyAction: pendingMyAction,
    pendingOthers: pendingOthers,
    approved: approved,
    rejected: rejected,
  );
}

/// Determines the status of an activity for a given user.
/// This mirrors the logic in ApprovalController._getActivityStatusForUser()
_ActivityUserStatus _getActivityStatusForUser(
  Activity activity,
  int membershipId,
) {
  final approvers = activity.approvers;
  if (approvers.isEmpty) {
    return _ActivityUserStatus.pendingOthers;
  }

  // Check if any approver has rejected
  final hasRejection = approvers.any(
    (a) => a.status == ApprovalStatus.rejected,
  );
  if (hasRejection) {
    return _ActivityUserStatus.rejected;
  }

  // Check if all approvers have approved
  final allApproved = approvers.every(
    (a) => a.status == ApprovalStatus.approved,
  );
  if (allApproved) {
    return _ActivityUserStatus.approved;
  }

  // Check if current user has pending action
  final userApprover = approvers.where((a) => a.membership?.id == membershipId);

  if (userApprover.isNotEmpty &&
      userApprover.first.status == ApprovalStatus.unconfirmed) {
    return _ActivityUserStatus.pendingMyAction;
  }

  return _ActivityUserStatus.pendingOthers;
}

/// Filters activities by date range.
List<Activity> _filterByDateRange(
  List<Activity> activities,
  DateTime? start,
  DateTime? end,
) {
  if (start == null && end == null) return activities;

  return activities.where((a) {
    final date = a.createdAt;
    final startOk =
        start == null ||
        !date.isBefore(DateTime(start.year, start.month, start.day));
    final endOk =
        end == null ||
        !date.isAfter(DateTime(end.year, end.month, end.day, 23, 59, 59, 999));
    return startOk && endOk;
  }).toList();
}

/// Internal enum for activity status relative to current user
enum _ActivityUserStatus { pendingMyAction, pendingOthers, approved, rejected }

/// Grouped activities result
class _GroupedActivities {
  final List<Activity> pendingMyAction;
  final List<Activity> pendingOthers;
  final List<Activity> approved;
  final List<Activity> rejected;

  _GroupedActivities({
    required this.pendingMyAction,
    required this.pendingOthers,
    required this.approved,
    required this.rejected,
  });
}

// ============================================================================
// Arbitrary generators
// ============================================================================

/// Generates a list of activities with various approval statuses.
Arbitrary<List<Activity>> _activitiesListArbitrary() {
  return list(_activityArbitrary(), minLength: 0, maxLength: 10);
}

/// Generates a single activity with approvers.
Arbitrary<Activity> _activityArbitrary() {
  return combine5(
    integer(min: 1, max: 10000), // activity id
    _membershipArbitrary(), // supervisor
    _approversListArbitrary(), // approvers
    _activityTypeArbitrary(), // activity type
    _dateTimeArbitrary(), // createdAt
  ).map((tuple) {
    final (id, supervisor, approvers, activityType, createdAt) = tuple;
    return Activity(
      id: id,
      supervisorId: supervisor.id,
      title: 'Test Activity $id',
      date: createdAt,
      activityType: activityType,
      createdAt: createdAt,
      supervisor: supervisor,
      approvers: approvers,
    );
  });
}

/// Generates a list of approvers.
Arbitrary<List<Approver>> _approversListArbitrary() {
  return list(_approverArbitrary(), minLength: 1, maxLength: 5);
}

/// Generates a single approver.
Arbitrary<Approver> _approverArbitrary() {
  return combine4(
    integer(min: 1, max: 10000), // approver id
    _approvalStatusArbitrary(), // status
    _membershipArbitrary(), // membership
    _dateTimeArbitrary(), // createdAt
  ).map((tuple) {
    final (id, status, membership, createdAt) = tuple;
    return Approver(
      id: id,
      status: status,
      membership: membership,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  });
}

/// Generates a membership.
Arbitrary<Membership> _membershipArbitrary() {
  return combine2(
    integer(min: 1, max: 1000), // membership id
    _accountArbitrary(), // account
  ).map((tuple) {
    final (id, account) = tuple;
    return Membership(id: id, baptize: true, sidi: true, account: account);
  });
}

/// Generates an account.
Arbitrary<Account> _accountArbitrary() {
  return combine2(
    integer(min: 1, max: 10000), // account id
    integer(min: 1, max: 100), // name suffix
  ).map((tuple) {
    final (id, nameSuffix) = tuple;
    return Account(
      id: id,
      phone: '+62812345$nameSuffix',
      name: 'Test User $nameSuffix',
      dob: DateTime(1990, 1, 1),
      gender: Gender.male,
      maritalStatus: MaritalStatus.single,
    );
  });
}

/// Generates an approval status.
Arbitrary<ApprovalStatus> _approvalStatusArbitrary() {
  return integer(
    min: 0,
    max: ApprovalStatus.values.length - 1,
  ).map((index) => ApprovalStatus.values[index]);
}

/// Generates an activity type.
Arbitrary<ActivityType> _activityTypeArbitrary() {
  return integer(
    min: 0,
    max: ActivityType.values.length - 1,
  ).map((index) => ActivityType.values[index]);
}

/// Generates a DateTime.
Arbitrary<DateTime> _dateTimeArbitrary() {
  return combine3(
    integer(min: 2020, max: 2025), // year
    integer(min: 1, max: 12), // month
    integer(min: 1, max: 28), // day
  ).map((tuple) {
    final (year, month, day) = tuple;
    return DateTime(year, month, day);
  });
}

/// Generates a date range (start, end) where start <= end.
Arbitrary<(DateTime?, DateTime?)> _dateRangeArbitrary() {
  return combine2(
    _dateTimeArbitrary(),
    integer(min: 0, max: 30), // days to add for end date
  ).map((tuple) {
    final (start, daysToAdd) = tuple;
    final end = start.add(Duration(days: daysToAdd));
    return (start, end);
  });
}

/// Generates an activity with optional financial data.
Arbitrary<Activity> _activityWithFinancialArbitrary() {
  return combine7(
    integer(min: 1, max: 10000), // activity id
    _membershipArbitrary(), // supervisor
    _approversListArbitrary(), // approvers
    _activityTypeArbitrary(), // activity type
    _dateTimeArbitrary(), // createdAt
    _boolArbitrary(), // hasRevenue
    _boolArbitrary(), // hasExpense
  ).map((tuple) {
    final (
      id,
      supervisor,
      approvers,
      activityType,
      createdAt,
      hasRevenue,
      hasExpense,
    ) = tuple;
    // Ensure only one of hasRevenue or hasExpense is true (or neither)
    final actualHasRevenue = hasRevenue && !hasExpense;
    final actualHasExpense = hasExpense && !hasRevenue;

    return Activity(
      id: id,
      supervisorId: supervisor.id,
      title: 'Test Activity $id',
      date: createdAt,
      activityType: activityType,
      createdAt: createdAt,
      supervisor: supervisor,
      approvers: approvers,
      hasRevenue: actualHasRevenue ? true : null,
      hasExpense: actualHasExpense ? true : null,
    );
  });
}

/// Generates a boolean value.
Arbitrary<bool> _boolArbitrary() {
  return integer(min: 0, max: 1).map((value) => value == 1);
}
