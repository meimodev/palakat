# Implementation Plan

- [-] 1. Set up Approver module structure
  - [x] 1.1 Create approver module directory and base files
    - Create `apps/palakat_backend/src/approver/` directory
    - Create `approver.module.ts` with ApproverController and ApproverService providers
    - Create `approver.controller.ts` with empty class and JWT AuthGuard
    - Create `approver.service.ts` with PrismaService injection
    - _Requirements: 5.1, 5.4_

  - [-] 1.2 Register ApproverModule in AppModule
    - Import ApproverModule in `app.module.ts`
    - Add to imports array
    - _Requirements: 5.1_

- [ ] 2. Implement DTOs with validation
  - [ ] 2.1 Create CreateApproverDto
    - Create `dto/create-approver.dto.ts`
    - Add membershipId (required, int, min 1)
    - Add activityId (required, int, min 1)
    - Use class-validator decorators
    - _Requirements: 1.1, 5.2_

  - [ ] 2.2 Create UpdateApproverDto
    - Create `dto/update-approver.dto.ts`
    - Add status field with ApprovalStatus enum validation
    - _Requirements: 3.1, 5.2_

  - [ ] 2.3 Create ApproverListQueryDto
    - Create `dto/approver-list.dto.ts`
    - Extend PaginationQueryDto
    - Add optional membershipId filter
    - Add optional activityId filter
    - Add optional status filter with ApprovalStatus enum
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 5.6_

- [ ] 3. Implement ApproverService CRUD operations
  - [ ] 3.1 Implement create method
    - Validate membership exists (throw 404 if not)
    - Validate activity exists (throw 404 if not)
    - Handle unique constraint violation for duplicate (throw 400)
    - Create approver with UNCONFIRMED status
    - Return created record with message
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 5.5_

  - [ ] 3.2 Write property test for create initializes UNCONFIRMED
    - **Property 1: Create initializes with UNCONFIRMED status**
    - **Validates: Requirements 1.1**

  - [ ] 3.3 Write property test for duplicate rejection
    - **Property 2: Duplicate creation is rejected**
    - **Validates: Requirements 1.2**

  - [ ] 3.4 Implement findAll method with filters
    - Build where clause from query parameters
    - Apply membershipId filter if provided
    - Apply activityId filter if provided
    - Apply status filter if provided
    - Use pagination (skip/take)
    - Include related activity and membership data
    - Return paginated results with total count
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 5.5_

  - [ ] 3.5 Write property test for filter consistency
    - **Property 3: Filter consistency**
    - **Validates: Requirements 2.2, 2.3, 2.4**

  - [ ] 3.6 Implement findOne method
    - Use findUniqueOrThrow for 404 handling
    - Include related activity with supervisor details
    - Include related membership with account details
    - Return record with message
    - _Requirements: 2.5, 2.6, 5.5_

  - [ ] 3.7 Implement update method
    - Use update with where clause
    - Handle not found (Prisma throws)
    - Update status field
    - Return updated record with message
    - _Requirements: 3.1, 3.3, 5.5_

  - [ ] 3.8 Write property test for status update persistence
    - **Property 4: Status update persistence**
    - **Validates: Requirements 3.1**

  - [ ] 3.9 Implement remove method
    - Use delete with where clause
    - Handle not found (Prisma throws)
    - Return success message
    - _Requirements: 4.1, 4.2, 5.5_

  - [ ] 3.10 Write property test for delete removes record
    - **Property 5: Delete removes record**
    - **Validates: Requirements 4.1**

- [ ] 4. Implement ApproverController endpoints
  - [ ] 4.1 Implement POST /approver endpoint
    - Add @Post() decorator
    - Accept CreateApproverDto in @Body()
    - Call service.create()
    - _Requirements: 1.1, 1.5_

  - [ ] 4.2 Implement GET /approver endpoint
    - Add @Get() decorator
    - Accept ApproverListQueryDto in @Query()
    - Call service.findAll()
    - _Requirements: 2.1, 2.2, 2.3, 2.4_

  - [ ] 4.3 Implement GET /approver/:id endpoint
    - Add @Get(':id') decorator
    - Use ParseIntPipe for id parameter
    - Call service.findOne()
    - _Requirements: 2.5, 2.6_

  - [ ] 4.4 Implement PATCH /approver/:id endpoint
    - Add @Patch(':id') decorator
    - Use ParseIntPipe for id parameter
    - Accept UpdateApproverDto in @Body()
    - Call service.update()
    - _Requirements: 3.1, 3.2, 3.3, 3.4_

  - [ ] 4.5 Implement DELETE /approver/:id endpoint
    - Add @Delete(':id') decorator
    - Use ParseIntPipe for id parameter
    - Call service.remove()
    - _Requirements: 4.1, 4.2, 4.3_

- [ ] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 6. Write unit tests
  - [ ] 6.1 Write unit tests for ApproverService
    - Test create with valid data
    - Test create with non-existent membership
    - Test create with non-existent activity
    - Test create with duplicate
    - Test findAll with various filters
    - Test findOne success and not found
    - Test update success and not found
    - Test remove success and not found
    - _Requirements: 1.1-1.4, 2.1-2.6, 3.1-3.3, 4.1-4.2_

  - [ ] 6.2 Write property test for response format consistency
    - **Property 6: Response format consistency**
    - **Validates: Requirements 5.5**

- [ ] 7. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
