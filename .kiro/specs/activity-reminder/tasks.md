# Implementation Plan

- [x] 1. Update Backend Prisma Schema
  - [x] 1.1 Add Reminder enum to schema.prisma
    - Add enum with values: TEN_MINUTES, THIRTY_MINUTES, ONE_HOUR, TWO_HOURS
    - _Requirements: 1.3_
  - [x] 1.2 Add reminder field to Activity model
    - Add optional `reminder Reminder?` field to Activity model
    - _Requirements: 1.1, 2.1_
  - [x] 1.3 Run Prisma migration
    - Generate and apply migration for the new field
    - _Requirements: 1.1_
  - [x] 1.4 Update seed.ts to include reminder data
    - Import Reminder enum from @prisma/client
    - Update generateActivityData function to include random reminder for SERVICE/EVENT types
    - Ensure ANNOUNCEMENT activities have null reminder
    - _Requirements: 7.1, 7.2, 7.3_

- [x] 2. Create Backend DTOs and Update Service
  - [x] 2.1 Create CreateActivityDto with validation
    - Create DTO class with class-validator decorators
    - Include @IsEnum(Reminder) @IsOptional() for reminder field
    - _Requirements: 1.3, 1.4_
  - [x] 2.2 Create UpdateActivityDto
    - Extend CreateActivityDto with PartialType
    - _Requirements: 3.1, 3.2, 3.3_
  - [x] 2.3 Update ActivityService.create to handle reminder
    - Include reminder field in activity creation
    - _Requirements: 1.1, 1.2_
  - [x] 2.4 Update ActivityService.update to handle reminder
    - Include reminder field in activity update
    - _Requirements: 3.1, 3.2_
  - [x] 2.5 Update ActivityController to use DTOs
    - Replace Prisma.ActivityCreateInput with CreateActivityDto
    - Replace Prisma.ActivityUpdateInput with UpdateActivityDto
    - _Requirements: 1.3, 1.4, 3.3_
  - [ ]* 2.6 Write property test for reminder validation
    - **Property 2: Reminder validation**
    - **Validates: Requirements 1.3, 1.4, 3.3**

- [x] 3. Checkpoint - Ensure backend changes work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Update Shared Package Models
  - [x] 4.1 Update Reminder enum with JSON serialization
    - Add @JsonEnum annotation with valueField
    - Add value field mapping to backend enum values
    - _Requirements: 4.1, 4.2_
  - [x] 4.2 Add reminder field to CreateActivityRequest
    - Add optional Reminder? reminder field
    - Regenerate freezed/json_serializable code
    - _Requirements: 4.1, 4.2, 4.3_
  - [ ]* 4.3 Write property test for CreateActivityRequest round-trip
    - **Property 6: CreateActivityRequest round-trip serialization**
    - **Validates: Requirements 4.1, 4.2, 4.3**
  - [x] 4.4 Update Activity model to include reminder field
    - Add optional Reminder? reminder field to Activity model
    - Regenerate freezed/json_serializable code
    - _Requirements: 5.1, 5.2_
  - [ ]* 4.5 Write property test for Activity model round-trip
    - **Property 7: Activity model round-trip serialization**
    - **Validates: Requirements 5.1, 5.2, 5.3**

- [x] 5. Checkpoint - Ensure shared package changes work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Update Mobile App Controller
  - [x] 6.1 Update ActivityPublishController.submit to include reminder
    - Add selectedReminder to CreateActivityRequest in submit method
    - _Requirements: 6.1_
  - [ ]* 6.2 Write unit test for controller reminder inclusion
    - **Property 8: Controller includes reminder in request**
    - **Validates: Requirements 6.1**

- [x] 7. Backend Integration Tests
  - [x]* 7.1 Write property test for reminder persistence on create
    - **Property 1: Reminder persistence on create**
    - **Validates: Requirements 1.1, 2.1**
  - [x]* 7.2 Write property test for announcement activities
    - **Property 3: Announcement activities accept null reminder**
    - **Validates: Requirements 1.2**
  - [x]* 7.3 Write property test for reminder in list responses
    - **Property 4: Reminder included in list responses**
    - **Validates: Requirements 2.2, 2.3**
  - [x]* 7.4 Write property test for reminder update persistence
    - **Property 5: Reminder update persistence**
    - **Validates: Requirements 3.1, 3.2**

- [x] 8. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
