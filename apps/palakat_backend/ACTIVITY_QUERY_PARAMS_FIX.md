# Activity Query Parameters Fix

## Problem
When accessing the `/activity` endpoint without query parameters, the API returned a 400 Bad Request error:

```json
{
  "message": [
    "membershipId must not be less than 1",
    "columnId must not be less than 1",
    "activityType must be one of the following values: SERVICE, EVENT, ANNOUNCEMENT"
  ],
  "error": "Bad Request",
  "statusCode": 400
}
```

## Root Cause

### Issue 1: DTO Validation
The `ActivityListQueryDto` had `@IsOptional()` decorators, but the validation rules (`@Min(1)`, `@IsEnum()`) were still being applied even when values were not provided or were empty strings.

**Before:**
```typescript
@IsOptional()
@Type(() => Number)
@IsInt()
@Min(1)  // ❌ This validates even when value is undefined/null
membershipId?: number;
```

### Issue 2: Service Logic
The service was always including filter conditions in the Prisma `where` clause, even when the values were `undefined`:

**Before:**
```typescript
const where: any = {
  supervisorId: membershipId,  // ❌ Always set, even if undefined
  supervisor: {
    churchId: churchId,        // ❌ Always set, even if undefined
    columnId: columnId,        // ❌ Always set, even if undefined
  },
};
```

This caused Prisma to filter with `undefined` values, which could lead to unexpected behavior.

## Solution

### Fix 1: DTO Validation with ValidateIf
Added `@ValidateIf` decorators to only apply validation rules when values are actually provided:

**File:** `apps/palakat_backend/src/activity/dto/activity-list.dto.ts`

```typescript
@IsOptional()
@Type(() => Number)
@ValidateIf((o) => o.membershipId !== undefined && o.membershipId !== null)
@IsInt()
@Min(1)
membershipId?: number;

@IsOptional()
@Type(() => Number)
@ValidateIf((o) => o.churchId !== undefined && o.churchId !== null)
@IsInt()
@Min(1)
churchId?: number;

@IsOptional()
@Type(() => Number)
@ValidateIf((o) => o.columnId !== undefined && o.columnId !== null)
@IsInt()
@Min(1)
columnId?: number;

@IsOptional()
@ValidateIf((o) => o.activityType !== undefined && o.activityType !== null && o.activityType !== '')
@IsEnum(ActivityType)
activityType?: ActivityType;
```

**How it works:**
- `@IsOptional()` marks the field as optional
- `@ValidateIf()` only runs subsequent validators when the condition is true
- Validation only happens when the value is actually provided (not undefined, null, or empty string)

### Fix 2: Service Conditional Filtering
Updated the service to only include filter conditions when values are provided:

**File:** `apps/palakat_backend/src/activity/activity.service.ts`

```typescript
const where: any = {};

// Only filter by membershipId if provided
if (membershipId !== undefined && membershipId !== null) {
  where.supervisorId = membershipId;
}

// Only filter by churchId or columnId if provided
if (
  (churchId !== undefined && churchId !== null) ||
  (columnId !== undefined && columnId !== null)
) {
  where.supervisor = {};
  if (churchId !== undefined && churchId !== null) {
    where.supervisor.churchId = churchId;
  }
  if (columnId !== undefined && columnId !== null) {
    where.supervisor.columnId = columnId;
  }
}

if (activityType) {
  where.activityType = activityType;
}
```

**How it works:**
- Start with an empty `where` object
- Only add filter conditions when values are actually provided
- Prisma will return all records when no filters are applied

## API Behavior

### Before Fix

**Request:** `GET /activity`
**Response:** 400 Bad Request ❌
```json
{
  "message": [
    "membershipId must not be less than 1",
    "columnId must not be less than 1",
    "activityType must be one of the following values: SERVICE, EVENT, ANNOUNCEMENT"
  ],
  "error": "Bad Request",
  "statusCode": 400
}
```

### After Fix

**Request:** `GET /activity`
**Response:** 200 OK ✅
```json
{
  "message": "Activities retrieved successfully",
  "data": [...],
  "total": 100
}
```

## Query Parameter Examples

### 1. Get All Activities
```bash
GET /activity
# Returns all activities (no filters)
```

### 2. Filter by Membership
```bash
GET /activity?membershipId=5
# Returns activities where supervisorId = 5
```

### 3. Filter by Church
```bash
GET /activity?churchId=2
# Returns activities where supervisor.churchId = 2
```

### 4. Filter by Column
```bash
GET /activity?columnId=3
# Returns activities where supervisor.columnId = 3
```

### 5. Filter by Activity Type
```bash
GET /activity?activityType=SERVICE
# Returns activities where activityType = 'SERVICE'
```

### 6. Filter by Date Range
```bash
GET /activity?startDate=2024-01-01&endDate=2024-12-31
# Returns activities created between the dates
```

### 7. Search Activities
```bash
GET /activity?search=christmas
# Returns activities where title or description contains 'christmas'
```

### 8. Combined Filters
```bash
GET /activity?membershipId=5&activityType=EVENT&search=meeting
# Returns activities matching all criteria
```

### 9. Pagination
```bash
GET /activity?skip=0&take=10
# Returns first 10 activities
```

## Validation Rules

When query parameters ARE provided, they must meet these requirements:

| Parameter | Type | Validation | Example |
|-----------|------|------------|---------|
| `membershipId` | number | Must be integer ≥ 1 | `?membershipId=5` |
| `churchId` | number | Must be integer ≥ 1 | `?churchId=2` |
| `columnId` | number | Must be integer ≥ 1 | `?columnId=3` |
| `activityType` | enum | Must be SERVICE, EVENT, or ANNOUNCEMENT | `?activityType=SERVICE` |
| `startDate` | date | Must be valid date | `?startDate=2024-01-01` |
| `endDate` | date | Must be valid date, ≥ startDate | `?endDate=2024-12-31` |
| `search` | string | Any string | `?search=meeting` |
| `skip` | number | Must be integer ≥ 0 | `?skip=0` |
| `take` | number | Must be integer ≥ 1 | `?take=10` |

## Error Handling

### Invalid Values Still Validated

**Request:** `GET /activity?membershipId=0`
**Response:** 400 Bad Request
```json
{
  "message": ["membershipId must not be less than 1"],
  "error": "Bad Request",
  "statusCode": 400
}
```

**Request:** `GET /activity?activityType=INVALID`
**Response:** 400 Bad Request
```json
{
  "message": ["activityType must be one of the following values: SERVICE, EVENT, ANNOUNCEMENT"],
  "error": "Bad Request",
  "statusCode": 400
}
```

## Testing

### Test Cases

1. **No parameters** ✅
   ```bash
   curl http://localhost:3000/activity
   # Should return 200 with all activities
   ```

2. **Valid membershipId** ✅
   ```bash
   curl http://localhost:3000/activity?membershipId=5
   # Should return 200 with filtered activities
   ```

3. **Invalid membershipId** ✅
   ```bash
   curl http://localhost:3000/activity?membershipId=0
   # Should return 400 with validation error
   ```

4. **Valid activityType** ✅
   ```bash
   curl http://localhost:3000/activity?activityType=SERVICE
   # Should return 200 with filtered activities
   ```

5. **Invalid activityType** ✅
   ```bash
   curl http://localhost:3000/activity?activityType=INVALID
   # Should return 400 with validation error
   ```

6. **Combined filters** ✅
   ```bash
   curl http://localhost:3000/activity?membershipId=5&activityType=EVENT
   # Should return 200 with activities matching both filters
   ```

## Benefits

1. **Flexible Querying**: Can fetch all activities or filter by specific criteria
2. **Better UX**: No errors when accessing endpoint without parameters
3. **Proper Validation**: Still validates when parameters are provided
4. **Clean Code**: Conditional filtering logic is clear and maintainable
5. **Performance**: Only applies filters when needed

## Related Files

- `apps/palakat_backend/src/activity/dto/activity-list.dto.ts` - Query DTO with validation
- `apps/palakat_backend/src/activity/activity.service.ts` - Service with conditional filtering
- `apps/palakat_backend/src/activity/activity.controller.ts` - Controller endpoint
