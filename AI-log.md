# AI Activity Log
## 2025-09-18T11:11:19+08:00 — Model: Cascade
- Migrated approval feature to use `Activity` instead of `Approval`.
- Updated `approval_state.dart` to hold `List<Activity>`.
- Updated `approval_controller.dart` to create dummy `Activity` data.
- Updated `approval_detail_screen.dart` and `approval_card_widget.dart` to read/display `Activity` fields.
- Updated `approval_screen.dart` to use `title` and pass `activityId`.
- Removed export of `approval.dart` from `core/models/models.dart`. The file remains unreferenced and can be deleted safely.

## 2025-09-18T09:20:10+08:00 — Model: Cascade
- Refactored `Activity` model: replaced `location` (String), `latitude`, `longitude` with `Location location` (`core/models/location.dart`).
- Updated `lib/features/dashboard/presentations/view_all/view_all_controller.dart` to construct `Location(name, latitude, longitude)` when creating `Activity` instances.
- Searched for usages of old fields to ensure compatibility; publishing flows reference form state, not `Activity` fields.

## 2025-09-18T09:10:50+08:00 — Model: Cascade
- Fixed errors in `lib/features/dashboard/presentations/view_all/view_all_controller.dart` after `Activity` model changes.
- Updated controller to construct `Activity` with new required fields and dummy values.
- Added missing import `package:palakat/core/models/models.dart` for `Membership` and `Approver` types.


## 2025-09-18T07:45:51+08:00 — Model: Cascade
- Saved a persistent preference to always log each prompt to `AI-log.md`.
- Checked for existing `AI-log.md` at project root; none found.
- Created this log file and wrote the first entry.

## 2025-09-18T07:48:52+08:00 — Model: Cascade
- Saved a preference to log memory state to `AI-log-memories.md` after each prompt.
- Created `AI-log-memories.md` with the current memory state (titles, tags, IDs, content).
- Confirmed `AI-log.md` updated with this entry.

## 2025-09-18T08:03:45+08:00 — Model: Cascade
- Renamed `approvalId` to `activityId` on the approval details flow.
- Updated `lib/core/routing/approval_routing.dart` to read `activityId` from `RouteParam` and pass it to `ApprovalDetailScreen`.
- Updated `lib/features/approval/presentations/approval_detail_screen.dart` constructor, field, and lookup to use `activityId`.
- Updated navigation in `lib/features/approval/presentations/approval_screen.dart` to send `activityId` in `RouteParam`.

## 2025-09-18T15:30:42+08:00 — Model: Cascade
- Updated `lib/features/approval/presentations/approval_detail_screen.dart` to always render the "Activity information" card and display:
  - Activity ID
  - Title
  - Description (with '-' fallback)
  - Activity Type (formatted from enum name)
- Verified existing imports provide `valueOrDash` and `capitalizeEachWord` extensions used for formatting.

## 2025-09-18T15:43:37+08:00 — Model: Cascade
- Refined the "Activity information" card in `lib/features/approval/presentations/approval_detail_screen.dart` to better match app UI:
  - Converted fields into labeled rows with leading icons
  - Added consistent gaps and subtle `DividerWidget`s between rows
  - Used `BaseTypography.bodySmall` and `.toSecondary` for labels, consistent colors via `BaseColor.*.withValues(...)`

## 2025-09-18T15:51:24+08:00 — Model: Cascade
- Created `lib/features/approval/presentations/approval_detail_state.dart` using Freezed for screen-specific state.
- Created `lib/features/approval/presentations/approval_detail_controller.dart` using Riverpod codegen with parameterized `build({required int activityId})` and dummy data fetch.
- Updated `lib/features/approval/presentations/approval_detail_screen.dart` to read `approvalDetailControllerProvider(activityId: ...)` and added a loading UI.
- Note: Run `flutter pub run build_runner build -d` to generate `*.g.dart` files.

## 2025-09-18T16:06:57+08:00 — Model: Cascade
- Centered icons vertically in Activity Information rows (ID, Title, Type, Description) to match Supervisor card alignment.
- Styled Activity Type as a pill chip with leading icon, soft background, and subtle border; used orange/yellow tone for Announcement and mapped colors for other types.

## 2025-09-18T16:56:23+08:00 — Model: Cascade
- Updated Supervisor Information card in `lib/features/approval/presentations/approval_detail_screen.dart` to display multiple member positions as chips under the supervisor name, with a fallback 'Member' chip when empty.

## 2025-09-18T20:51:35+08:00 — Model: Cascade
- Updated `lib/features/approval/presentations/approval_detail_screen.dart` to conditionally render cards:
  - Hide Location card when `activity.location == null`.
  - Hide Note card when `activity.note` is null/empty.

## 2025-09-18T23:17:05+08:00 — Model: Cascade
- Added date filter card on approvals screen.
- Updated `lib/features/approval/presentations/approval_state.dart` to include `filterStartDate`, `filterEndDate`, and `filteredApprovals`.
- Updated `lib/features/approval/presentations/approval_controller.dart` with `setDateRange`, `clearDateFilter`, and `_applyFilters()` to populate `filteredApprovals`.
- Updated `lib/features/approval/presentations/approval_screen.dart` to render filter UI (uses `showDateRangePicker`) and list `state.filteredApprovals`.
- Regenerated code with `build_runner`.

## 2025-09-18T23:31:46+08:00 — Model: Cascade
- Converted the approvals date filter card to a dropdown date range picker with presets (All, Today, Last 7/30, This/Last Month, This Year) and a "Custom range…" option opening `showDateRangePicker`.
- Updated `lib/features/approval/presentations/approval_screen.dart` to add `_DateRangeDropdown`, range detection, and helpers.

## 2025-09-18T23:34:48+08:00 — Model: Cascade
- Redesigned the approvals filter UI to match app style by replacing custom Card/dropdown with `InputWidget.dropdown`.
- Added bottom sheet preset picker integrated with shared input component.
- File updated: `lib/features/approval/presentations/approval_screen.dart`.

## 2025-09-21T13:37:39+08:00 — Model: Cascade
- Updated `lib/features/approval/presentations/approval_screen.dart` so that when a custom date range is picked, the dropdown displays the formatted selected range instead of a generic label.

## 2025-09-21T15:22:10+08:00 — Model: Cascade
- Enhanced bottom sheet preset picker to display the corresponding date range under each preset label (except "All dates" and "Custom range").
- Added `_rangeForPreset(...)` helper and used it to render `subtitle` in each `ListTile` in `approval_screen.dart`.

## 2025-09-21T15:33:39+08:00 — Model: Cascade
- Extracted a reusable `DateRangePresetInput` widget at `lib/core/widgets/input/date_range_preset_input.dart` encapsulating dropdown + bottom sheet presets and custom range picker.
- Refactored `lib/features/approval/presentations/approval_screen.dart` to use `DateRangePresetInput` and removed local helpers/bottom sheet.
- Exported the new widget in `lib/core/widgets/widgets.dart` for easy import.

## 2025-09-22T10:57:20+08:00 — Model: Cascade
- Updated dashboard to align with Operations/Approvals UI and show dummy data:
  - Edited `lib/features/dashboard/presentations/dashboard_controller.dart` to populate dummy `Activity` lists for `thisWeekActivities` and `thisWeekAnnouncements`, keeping membership fetch. Loading flags now rely on `DashboardState` defaults and are turned off after dummy load.
  - Adjusted `lib/features/dashboard/presentations/dashboard_screen.dart` spacing to use `Gap.h16` after the title for consistency.
- No schema changes required; reused existing `Activity`, `Membership`, and enums. Navigation continues to use `go_router` with `RouteParam`.

## 2025-09-22T11:19:45+08:00 — Model: Cascade
- Made the weekly activity day card more compact and added colored icon chips for counts:
  - Updated `lib/features/dashboard/presentations/widgets/card_date_preview_widget.dart` to use tighter padding, and display small pill chips with icons/colors for Service (green) and Event (blue) counts.
  - Preserved the "today" emphasis border; no breaking API changes to the widget.

## 2025-09-22T11:28:49+08:00 — Model: Cascade
- Fixed dashboard announcement navigation error by passing the full `Activity` via `RouteParamKey.activity` (JSON) to match `dashboard_routing.dart` expectations.
- File updated: `lib/features/dashboard/presentations/widgets/announcement_widget.dart`.

## 2025-09-22T11:52:26+08:00 — Model: Cascade
- Implemented Account age getters and fixed Membership bipra logic:
  - Added `ageYears`, `ageMonths`, `ageDays`, and `ageYmdFormatted` getters in `lib/core/utils/extensions/account_extension.dart`.
  - Completed `lib/core/utils/extensions/membership_extension.dart` to infer `Bipra` based on marital status and `ageYears` for unmarried accounts; avoids circular imports.
  - Updated `lib/core/widgets/card/membership_card_widget.dart` to display `membership.bipra.name`.

## 2025-09-22T12:03:04+08:00 — Model: Cascade
- Simplified `lib/core/widgets/card/membership_card_widget.dart`:
  - Removed `IntrinsicHeight`, reduced nesting, and extracted a local `footer()` builder.
  - Consolidated title text style and alignment into variables; coalesced `title` to non-null `String`.
  - Preserved visuals; continued using existing colors/typography per design.

## 2025-09-22T12:10:30+08:00 — Model: Cascade
- Redesigned `lib/core/widgets/card/membership_card_widget.dart` to align with dashboard UI:
  - Switched to `ContinuousRectangleBorder` with larger radius and subtle border when signed in.
  - Added header icon tile and adjusted spacing to match `SegmentTitleWidget`/`CardDatePreviewWidget`.
  - Used pill chips for Bipra and Column; shows a bordered sign-in CTA chip when unsigned.
  - Updated typography to use `titleMedium` for name and `bodySmall.toSecondary` for subtitle.
