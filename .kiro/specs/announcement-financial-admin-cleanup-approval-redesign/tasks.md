# Implementation Plan

## Part 1: Announcement Activity Financial Support

- [ ] 1. Verify and test announcement activity financial support
  - [ ] 1.1 Verify backend activity service handles ANNOUNCEMENT with finance
    - Review activity.service.ts create method for ANNOUNCEMENT type handling
    - Confirm finance object is processed for all activity types
    - _Requirements: 1.1, 1.2_

  - [ ] 1.2 Verify approver resolver handles ANNOUNCEMENT with financial account
    - Review approver-resolver.service.ts for ANNOUNCEMENT type support
    - Confirm financialAccountNumberId is considered in rule matching
    - _Requirements: 1.5_

  - [ ]* 1.3 Write property test for announcement financial record creation
    - **Property 1: Announcement activity with finance creates linked record**
    - **Validates: Requirements 1.1, 1.2, 1.4**
    - Create test in `apps/palakat_backend/test/property/announcement-financial.property.spec.ts`
    - Use fast-check to generate ANNOUNCEMENT activities with finance objects
    - Verify Revenue/Expense record is created and linked

  - [ ]* 1.4 Write property test for financial filter with announcements
    - **Property 2: Financial filter includes announcement activities**
    - **Validates: Requirements 1.3**
    - Test hasExpense/hasRevenue filters return ANNOUNCEMENT activities correctly

  - [ ]* 1.5 Write property test for approver resolution with financial account
    - **Property 3: Approver resolution considers financial account for announcements**
    - **Validates: Requirements 1.5**
    - Test approver resolution includes rules matching financialAccountNumberId

- [ ] 2. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Part 2: Admin Panel Inventory Removal

- [ ] 3. Remove inventory feature from admin panel
  - [ ] 3.1 Remove inventory directory and files
    - Delete `apps/palakat_admin/lib/features/inventory/` directory
    - _Requirements: 2.3_

  - [ ] 3.2 Remove inventory route from main.dart
    - Remove inventory import from `apps/palakat_admin/lib/main.dart`
    - Remove inventory GoRoute from router configuration
    - _Requirements: 2.2_

  - [ ] 3.3 Remove inventory navigation from sidebar
    - Remove inventory _NavItem from `packages/palakat_shared/lib/core/widgets/sidebar.dart`
    - _Requirements: 2.1_

  - [ ] 3.4 Remove inventory from dashboard
    - Remove inventoryStatus field from `apps/palakat_admin/lib/features/dashboard/presentation/state/dashboard_screen_state.dart`
    - Remove inventory ActivityType enum value
    - Remove inventory stat card from `apps/palakat_admin/lib/features/dashboard/presentation/screens/dashboard_screen.dart`
    - Remove inventory data from `apps/palakat_admin/lib/features/dashboard/presentation/state/dashboard_controller.dart`
    - _Requirements: 2.4_

  - [ ] 3.5 Remove inventory report option
    - Remove inventory _GenerateCard from `apps/palakat_admin/lib/features/report/presentation/screens/report_screen.dart`
    - _Requirements: 2.5_

  - [ ]* 3.6 Write unit tests for inventory removal verification
    - Test sidebar does not contain inventory navigation
    - Test dashboard state does not include inventory fields
    - Test report screen does not include inventory option

- [ ] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Part 3: Mobile Approval Screen Redesign

- [ ] 5. Update approval state and controller for real API integration
  - [ ] 5.1 Update approval state with status grouping
    - Add ApprovalFilterStatus enum to approval_state.dart
    - Add pendingMyAction, pendingOthers, approved, rejected lists
    - Add statusFilter and isRefreshing fields
    - Run `melos run build:runner` to regenerate freezed files
    - _Requirements: 3.1_

  - [ ] 5.2 Implement real API data fetching in controller
    - Replace dummy data with actual API call to activity service
    - Add fetchActivities() method using activity repository
    - Implement _groupActivitiesByStatus() helper method
    - _Requirements: 3.8_

  - [ ] 5.3 Implement quick approve/reject actions
    - Add approveActivity(activityId, approverId) method
    - Add rejectActivity(activityId, approverId) method
    - Call approver API to update status
    - Refresh activity list after action
    - _Requirements: 3.5_

  - [ ] 5.4 Implement status filtering
    - Add setStatusFilter(ApprovalFilterStatus) method
    - Update filtered list based on selected status
    - Maintain date filter compatibility
    - _Requirements: 3.1, 3.6_

  - [ ] 5.5 Implement pull-to-refresh
    - Add refresh() method that re-fetches data
    - Set isRefreshing flag during refresh
    - _Requirements: 3.10_

  - [ ]* 5.6 Write property test for status grouping correctness
    - **Property 4: Status grouping correctness**
    - **Validates: Requirements 3.1**
    - Test activities are correctly categorized by approval status

  - [ ]* 5.7 Write property test for pending action prioritization
    - **Property 5: Pending action prioritization**
    - **Validates: Requirements 3.2**
    - Test pending my action activities appear before pending others

  - [ ]* 5.8 Write property test for date filter with status grouping
    - **Property 9: Date filter preserves status grouping**
    - **Validates: Requirements 3.6**
    - Test date filtering maintains correct status groups

  - [ ]* 5.9 Write property test for pending count accuracy
    - **Property 10: Pending count accuracy**
    - **Validates: Requirements 3.7**
    - Test pending count matches activities with user's UNCONFIRMED status

- [ ] 6. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 7. Redesign approval screen UI
  - [ ] 7.1 Add pending action summary badge
    - Create widget showing count of pending approvals for current user
    - Display prominently at top of screen
    - _Requirements: 3.7_

  - [ ] 7.2 Add status filter chips
    - Create horizontal chip row for status filtering
    - Options: All, Pending My Action, Pending Others, Approved, Rejected
    - Connect to controller setStatusFilter method
    - _Requirements: 3.1_

  - [ ] 7.3 Update activity card with financial indicator
    - Add revenue/expense icon badge when hasRevenue or hasExpense is true
    - Display activity type badge
    - Ensure all required info is displayed (title, supervisor, date, status)
    - _Requirements: 3.3, 3.9_

  - [ ] 7.4 Update activity card quick actions
    - Show approve/reject buttons when current user has UNCONFIRMED status
    - Connect buttons to controller approve/reject methods
    - Show loading state during action
    - _Requirements: 3.4, 3.5_

  - [ ] 7.5 Implement pull-to-refresh UI
    - Wrap list with RefreshIndicator
    - Connect to controller refresh method
    - _Requirements: 3.10_

  - [ ] 7.6 Implement status-based list display
    - Group activities by status with section headers
    - Show pending my action section first
    - Maintain grouping when filters applied
    - _Requirements: 3.1, 3.2_

  - [ ]* 7.7 Write property test for activity card content
    - **Property 6: Activity card displays required information**
    - **Validates: Requirements 3.3, 3.9**
    - Test card contains title, supervisor, date, type, status, financial indicator

  - [ ]* 7.8 Write property test for quick action button visibility
    - **Property 7: Quick action buttons visibility**
    - **Validates: Requirements 3.4**
    - Test buttons appear when user has UNCONFIRMED status

  - [ ]* 7.9 Write widget tests for approval screen
    - Test screen renders status groups
    - Test filter chips work correctly
    - Test pull-to-refresh triggers reload

- [ ] 8. Update approval detail screen
  - [ ] 8.1 Replace dummy data with real API call
    - Update approval_detail_controller.dart to fetch from API
    - Remove _dummyActivity method
    - _Requirements: 3.8_

  - [ ] 8.2 Add financial data display to detail screen
    - Show revenue/expense details when present
    - Display amount, account number, payment method
    - _Requirements: 3.9_

  - [ ]* 8.3 Write unit tests for detail controller
    - Test fetch method calls API correctly
    - Test error handling for failed requests

- [ ] 9. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

