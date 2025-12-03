# Requirements Document

## Introduction

This document specifies the requirements for creating an Approver module in the Palakat backend. The Approver module provides full CRUD operations for managing approver records, enabling church members to update their approval status (APPROVED, REJECTED, or UNCONFIRMED) for activities they are assigned to approve. Currently, the mobile app attempts to call `PATCH /api/v1/approver/:id` but this endpoint does not exist, resulting in 404 errors.

## Glossary

- **Approver**: A database record linking a Membership to an Activity, with an ApprovalStatus indicating whether the member has approved, rejected, or not yet confirmed the activity.
- **ApprovalStatus**: An enum with values UNCONFIRMED (default), APPROVED, or REJECTED.
- **Activity**: A church event, service, or announcement that may require approval from designated members.
- **Membership**: A church member's record, linked to their account and church.
- **Approver Module**: A NestJS module providing REST API endpoints for managing approver records.

## Requirements

### Requirement 1

**User Story:** As a church administrator, I want to create approver records, so that I can assign members to approve specific activities.

#### Acceptance Criteria

1. WHEN a user sends a POST request to `/approver` with valid membershipId and activityId, THE Approver Module SHALL create a new approver record with UNCONFIRMED status and return the created record.
2. WHEN a user sends a POST request with a duplicate membershipId and activityId combination, THE Approver Module SHALL reject the request with a 400 Bad Request error indicating the approver already exists.
3. WHEN a user sends a POST request with a non-existent membershipId, THE Approver Module SHALL reject the request with a 404 Not Found error.
4. WHEN a user sends a POST request with a non-existent activityId, THE Approver Module SHALL reject the request with a 404 Not Found error.
5. WHEN a user sends a POST request without authentication, THE Approver Module SHALL return a 401 Unauthorized error.

### Requirement 2

**User Story:** As a church member, I want to view approver records, so that I can see which activities require approval and their current status.

#### Acceptance Criteria

1. WHEN a user sends a GET request to `/approver` without filters, THE Approver Module SHALL return a paginated list of all approver records.
2. WHEN a user sends a GET request to `/approver` with a membershipId query parameter, THE Approver Module SHALL return only approver records for that membership.
3. WHEN a user sends a GET request to `/approver` with an activityId query parameter, THE Approver Module SHALL return only approver records for that activity.
4. WHEN a user sends a GET request to `/approver` with a status query parameter, THE Approver Module SHALL return only approver records matching that status.
5. WHEN a user sends a GET request to `/approver/:id`, THE Approver Module SHALL return the specific approver record with related activity and membership details.
6. WHEN a user sends a GET request for a non-existent approver ID, THE Approver Module SHALL return a 404 Not Found error.

### Requirement 3

**User Story:** As a church member assigned as an approver, I want to update my approval status for an activity, so that I can approve or reject activities I'm responsible for reviewing.

#### Acceptance Criteria

1. WHEN a user sends a PATCH request to `/approver/:id` with a valid status, THE Approver Module SHALL update the approver record's status and return the updated record.
2. WHEN a user sends a PATCH request with an invalid status value, THE Approver Module SHALL reject the request with a 400 Bad Request error.
3. WHEN a user sends a PATCH request for a non-existent approver ID, THE Approver Module SHALL return a 404 Not Found error.
4. WHEN a user sends a PATCH request without authentication, THE Approver Module SHALL return a 401 Unauthorized error.

### Requirement 4

**User Story:** As a church administrator, I want to delete approver records, so that I can remove members from approval workflows when needed.

#### Acceptance Criteria

1. WHEN a user sends a DELETE request to `/approver/:id`, THE Approver Module SHALL delete the approver record and return a success message.
2. WHEN a user sends a DELETE request for a non-existent approver ID, THE Approver Module SHALL return a 404 Not Found error.
3. WHEN a user sends a DELETE request without authentication, THE Approver Module SHALL return a 401 Unauthorized error.

### Requirement 5

**User Story:** As a system administrator, I want the approver module to follow existing backend patterns, so that the codebase remains consistent and maintainable.

#### Acceptance Criteria

1. THE Approver Module SHALL use the same NestJS module structure as existing modules (controller, service, module, DTOs).
2. THE Approver Module SHALL use class-validator decorators for DTO validation.
3. THE Approver Module SHALL use Prisma for database operations.
4. THE Approver Module SHALL be protected by JWT authentication using the existing AuthGuard.
5. THE Approver Module SHALL follow the existing response format with `message` and `data` fields.
6. THE Approver Module SHALL use PaginationQueryDto for list endpoints with skip/take pagination.
