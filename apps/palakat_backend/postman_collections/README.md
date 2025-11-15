# Palakat Backend - Postman Collections

This folder contains separate Postman collection files for each API module in the Palakat Backend application.

## 📁 Collections

1. **Auth.postman_collection.json** - Authentication & Authorization
2. **Account.postman_collection.json** - Account Management
3. **Church.postman_collection.json** - Church Management
4. **Activity.postman_collection.json** - Activity Management  
5. **ApprovalRule.postman_collection.json** - Approval Rule Management
6. **Membership.postman_collection.json** - Membership Management
7. **Column.postman_collection.json** - Column Management
8. **MembershipPosition.postman_collection.json** - Position Management
9. **Location.postman_collection.json** - Location Management
10. **Revenue.postman_collection.json** - Revenue Management
11. **Expense.postman_collection.json** - Expense Management
12. **File.postman_collection.json** - File Management
13. **Report.postman_collection.json** - Report Management
14. **Document.postman_collection.json** - Document Management
15. **Song.postman_collection.json** - Song Management
16. **SongPart.postman_collection.json** - Song Part Management

## 🚀 How to Import

### Import All Collections
1. Open Postman
2. Click **Import** button
3. Select **Folder** tab
4. Choose the `postman_collections` folder
5. Click **Import** - All collections will be imported at once

### Import Individual Collection
1. Open Postman
2. Click **Import** button
3. Select **File** tab
4. Choose the specific `.json` file
5. Click **Import**

## ⚙️ Setup Environment Variables

After importing, create a Postman environment with these variables:

| Variable | Initial Value | Description |
|----------|---------------|-------------|
| `base_url` | `http://localhost:3000` | API base URL |
| `access_token` | `` | JWT access token (auto-saved after sign-in) |
| `refresh_token` | `` | JWT refresh token (auto-saved after sign-in) |

### Auto-Save Tokens
The **Sign In** and **Refresh Token** requests include test scripts that automatically save tokens to your environment variables.

## 📝 Usage Flow

1. **Start with Auth Collection**
   - Use "Sign In" with credentials: `081111111111` / `password`
   - Tokens are automatically saved to environment

2. **Use Other Collections**
   - All other collections use Bearer token authentication
   - Token is automatically applied from `{{access_token}}` variable

3. **Token Expired?**
   - Use "Refresh Token" from Auth collection
   - New tokens are automatically saved

## 🔑 Default Test Credentials

From seeded database:
- **Phone**: `081111111111`
- **Password**: `password`

## 📋 Request Features

Each collection includes:
- ✅ Complete CRUD operations (GET, POST, PATCH, DELETE)
- ✅ Prefilled request bodies with example data
- ✅ Query parameters with descriptions
- ✅ Path variables with example values
- ✅ Enum value documentation in descriptions
- ✅ Bearer token authentication (except Auth)

## 🎯 Common Patterns

### Pagination
Most list endpoints support:
```
?page=1&pageSize=10
```

### Prisma Relations
Connect existing records:
```json
{
  "church": {
    "connect": {"id": 1}
  }
}
```

Create nested records:
```json
{
  "location": {
    "create": {
      "name": "Jakarta",
      "latitude": -6.1751,
      "longitude": 106.8650
    }
  }
}
```

### Date Formats
- ISO 8601: `2024-12-25T10:00:00Z`
- Date only: `2024-12-25`

## 📊 Enum Values Reference

| Field | Values |
|-------|--------|
| `gender` | MALE, FEMALE |
| `maritalStatus` | MARRIED, SINGLE |
| `activityType` | SERVICE, EVENT, ANNOUNCEMENT |
| `bipra` | PKB, WKI, PMD, RMJ, ASM |
| `book` | NKB, NNBT, KJ, DSL |
| `paymentMethod` | CASH, CASHLESS |
| `generatedBy` | MANUAL, SYSTEM |

## 🔗 Related Documentation

- Main API documentation: `../API_ENDPOINTS.md`
- Prisma schema: `../prisma/schema.prisma`

## 💡 Tips

1. **Test Scripts**: Auth requests include scripts to auto-save tokens
2. **Variables**: Use `{{variable}}` syntax for dynamic values
3. **Environments**: Create separate environments for dev/staging/prod
4. **Organization**: Collections are separated by domain for easier management
5. **Batch Import**: Import the entire folder to get all collections at once

## 🐛 Troubleshooting

**401 Unauthorized?**
- Check if `access_token` is set in environment
- Try refreshing token or signing in again

**404 Not Found?**
- Verify `base_url` is correct
- Ensure backend server is running

**Validation Errors?**
- Check request body matches schema
- Verify enum values are correct
- Ensure required fields are included
