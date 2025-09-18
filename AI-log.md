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
