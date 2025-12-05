# Requirements Document

## Introduction

This specification defines an enhancement to the Activity list endpoint in the Backend_API. The enhancement adds optional filtering capabilities to retrieve activities based on their associated financial records (Revenue or Expense). This allows users to filter activities by whether they have an expense attached, a revenue attached, or neither financial record.

The Activity model has optional one-to-one relationships with both Revenue and Expense models. This enhancement enables querying activities based on the presence or absence of these financial associations.

## Glossary

- **Backend_API**: NestJS REST API providing data persistence and business logic located at `apps/palakat_backend`
- **Activity**: A church event, service, or announcement requiring approval workflow
- **Revenue**: A financial record representing income associated with a church activity (one-to-one optional relationship)
- **Expense**: A financial record representing expenditure associated with a church activity (one-to-one optional relationship)
- **Financial_Filter**: A query parameter that filters activities based on their financial record associations
- **ActivityListQueryDto**: The Data Transfer Object that defines query parameters for the activity list endpoint

## Requirements

---

### Requirement 1: Activity Financial Filter Query Parameters

**User Story:** As an API consumer, I want to filter activities by their financial record status, so that I can retrieve only activities that have expenses, revenues, or no financial records attached.

#### Acceptance Criteria

1. WHEN the `hasExpense` query parameter is set to `true`, THE Backend_API SHALL return only activities that have an associated Expense record
2. WHEN the `hasExpense` query parameter is set to `false`, THE Backend_API SHALL return only activities that do not have an associated Expense record
3. WHEN the `hasRevenue` query parameter is set to `true`, THE Backend_API SHALL return only activities that have an associated Revenue record
4. WHEN the `hasRevenue` query parameter is set to `false`, THE Backend_API SHALL return only activities that do not have an associated Revenue record
5. WHEN both `hasExpense` and `hasRevenue` query parameters are omitted, THE Backend_API SHALL return activities regardless of their financial record status
6. WHEN `hasExpense=false` AND `hasRevenue=false` are both provided, THE Backend_API SHALL return only activities that have neither an Expense nor a Revenue record
7. WHEN `hasExpense=true` AND `hasRevenue=true` are both provided, THE Backend_API SHALL return only activities that have both an Expense AND a Revenue record
8. WHEN financial filters are combined with existing filters (membershipId, churchId, columnId, startDate, endDate, activityType, search), THE Backend_API SHALL apply all filters together using AND logic

---

### Requirement 2: Query Parameter Validation

**User Story:** As an API consumer, I want clear validation of financial filter parameters, so that I receive meaningful error messages for invalid inputs.

#### Acceptance Criteria

1. WHEN the `hasExpense` query parameter is provided, THE Backend_API SHALL validate that the value is a boolean (true/false)
2. WHEN the `hasRevenue` query parameter is provided, THE Backend_API SHALL validate that the value is a boolean (true/false)
3. IF an invalid value is provided for `hasExpense`, THEN THE Backend_API SHALL return a validation error with a descriptive message
4. IF an invalid value is provided for `hasRevenue`, THEN THE Backend_API SHALL return a validation error with a descriptive message
5. WHEN the query parameters are serialized and then deserialized, THE Backend_API SHALL produce equivalent filter behavior (round-trip consistency)

---

### Requirement 3: Response Consistency

**User Story:** As an API consumer, I want the filtered activity response to maintain the same structure as unfiltered responses, so that I can use the same client code for processing results.

#### Acceptance Criteria

1. WHEN activities are filtered by financial status, THE Backend_API SHALL return the same response structure including message, data array, and total count
2. WHEN activities are filtered by financial status, THE Backend_API SHALL include the same activity fields and relationships (supervisor, approvers) in the response
3. WHEN the total count is returned, THE Backend_API SHALL reflect the count of activities matching all applied filters including financial filters
4. WHEN pagination is applied with financial filters, THE Backend_API SHALL correctly paginate the filtered result set
