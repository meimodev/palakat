# Implementation Plan

- [x] 1. Backend: Extend ActivityListQueryDto with financial filter parameters
  - [x] 1.1 Add hasExpense and hasRevenue optional boolean fields to ActivityListQueryDto
    - Add `@IsOptional()`, `@Transform()`, and `@IsBoolean()` decorators
    - Transform string 'true'/'false' to boolean values
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2_
  - [x] 1.2 Write property test for DTO round-trip consistency
    - **Property 5: DTO round-trip consistency**
    - **Validates: Requirements 2.5**

- [x] 2. Backend: Implement financial filtering in ActivityService
  - [x] 2.1 Modify findAll() method to apply hasExpense filter
    - Add Prisma where clause: `expense: { isNot: null }` for true, `expense: { is: null }` for false
    - _Requirements: 1.1, 1.2_
  - [x] 2.2 Modify findAll() method to apply hasRevenue filter
    - Add Prisma where clause: `revenue: { isNot: null }` for true, `revenue: { is: null }` for false
    - _Requirements: 1.3, 1.4_
  - [ ] 2.3 Write property test for hasExpense filter correctness
    - **Property 1: hasExpense filter correctness**
    - **Validates: Requirements 1.1, 1.2**
  - [ ] 2.4 Write property test for hasRevenue filter correctness
    - **Property 2: hasRevenue filter correctness**
    - **Validates: Requirements 1.3, 1.4**
  - [ ] 2.5 Write property test for no filter returns all financial states
    - **Property 3: No filter returns all financial states**
    - **Validates: Requirements 1.5**
  - [ ] 2.6 Write property test for combined filter AND logic
    - **Property 4: Combined filter AND logic**
    - **Validates: Requirements 1.6, 1.7, 1.8**

- [ ] 3. Checkpoint - Ensure backend tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 4. Shared Package: Extend GetFetchActivitiesRequest model
  - [x] 4.1 Add hasExpense and hasRevenue optional boolean fields to GetFetchActivitiesRequest
    - Add fields to the freezed model
    - Run `melos run build:runner` to regenerate code
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  - [ ]* 4.2 Write unit test for GetFetchActivitiesRequest serialization
    - Test JSON serialization includes new fields when set
    - Test JSON serialization excludes null fields
    - _Requirements: 2.5_

- [x] 5. Mobile App: Update Activity Picker to filter activities without financial records
  - [x] 5.1 Update ActivityPickerController to pass hasExpense=false and hasRevenue=false
    - Modify _buildRequest() to include financial filters
    - This filters to show only activities available for attaching finances
    - _Requirements: 1.6_

- [x] 6. Mobile App: Add financial filter support to Supervised Activities List
  - [x] 6.1 Add filterHasExpense and filterHasRevenue fields to SupervisedActivitiesListState
    - Add optional boolean fields to the freezed state class
    - Run `melos run build:runner` to regenerate code
    - _Requirements: 1.1, 1.2, 1.3, 1.4_
  - [x] 6.2 Add setFinancialFilter method to SupervisedActivitiesListController
    - Add method to update filter state and refresh activities
    - Update _buildRequest() to include financial filters from state
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.8_
  - [x] 6.3 Update clearFilters method to also clear financial filters
    - Reset filterHasExpense and filterHasRevenue to null
    - _Requirements: 1.5_

- [x] 7. Backend: Write remaining property tests for response consistency
  - [x] 7.1 Write property test for response structure consistency
    - **Property 6: Response structure consistency**
    - **Validates: Requirements 3.1, 3.2**
  - [x] 7.2 Write property test for total count accuracy
    - **Property 7: Total count accuracy**
    - **Validates: Requirements 3.3**
  - [x] 7.3 Write property test for pagination with filters
    - **Property 8: Pagination with filters**
    - **Validates: Requirements 3.4**

- [ ] 8. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
