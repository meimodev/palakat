# Scripts Updated for Prisma 7

All root-level scripts have been updated to support Prisma 7 with the latest implementation patterns.

## Updated Scripts

### 1. `scripts/setup.sh`
**Changes:**
- Added Prisma Client generation step after installing backend dependencies
- Now runs `pnpm run prisma:generate` automatically during setup

**Usage:**
```bash
./scripts/setup.sh
```

### 2. `scripts/backend-local.sh`
**Changes:**
- Renamed `push_database()` to `setup_database()`
- Added Prisma Client generation before database operations
- Now checks for existing migrations and runs them, or pushes schema if no migrations exist
- Better support for Prisma 7 workflow

**Usage:**
```bash
# Full setup and start backend
./scripts/backend-local.sh

# Setup only, don't start backend
./scripts/backend-local.sh --no-start

# Skip Docker (if already running)
./scripts/backend-local.sh --skip-docker

# Skip database seeding
./scripts/backend-local.sh --skip-seed
```

### 3. `scripts/clean.sh`
**Changes:**
- Added cleanup for old Prisma 6 generated folder (`prisma/generated`)
- Ensures clean state when switching between Prisma versions

**Usage:**
```bash
# Clean everything
./scripts/clean.sh

# Clean only Flutter apps
./scripts/clean.sh --flutter-only

# Clean only backend
./scripts/clean.sh --backend-only

# Clean and remove generated files
./scripts/clean.sh --generated
```

### 4. `scripts/prisma.sh` (NEW)
**New comprehensive Prisma management script** with all common operations:

**Commands:**
- `generate` - Generate Prisma Client
- `migrate` - Create and apply a new migration
- `migrate-dev` - Run migrations in development
- `migrate-deploy` - Deploy migrations to production
- `push` - Push schema changes without migration
- `studio` - Open Prisma Studio
- `validate` - Validate the Prisma schema
- `format` - Format the Prisma schema
- `seed` - Seed the database
- `reset` - Reset the database (with confirmation)
- `status` - Show migration status
- `test` - Test Prisma connection

**Usage Examples:**
```bash
# Generate Prisma Client
./scripts/prisma.sh generate

# Create a new migration
./scripts/prisma.sh migrate

# Open Prisma Studio
./scripts/prisma.sh studio

# Validate schema
./scripts/prisma.sh validate

# Format schema
./scripts/prisma.sh format

# Check migration status
./scripts/prisma.sh status

# Test database connection
./scripts/prisma.sh test

# Seed database
./scripts/prisma.sh seed

# Reset database (WARNING: deletes all data)
./scripts/prisma.sh reset
```

## Unchanged Scripts

These scripts work without modifications:
- `scripts/check-backend.sh` - Backend connectivity check
- `scripts/dev.sh` - Development environment runner
- `scripts/admin.sh` - Admin app runner

## Prisma 7 Workflow

### Development Workflow

1. **Initial Setup:**
   ```bash
   ./scripts/setup.sh
   ```

2. **Start Development:**
   ```bash
   ./scripts/backend-local.sh
   ```

3. **Make Schema Changes:**
   - Edit `apps/palakat_backend/prisma/schema.prisma`
   - Validate: `./scripts/prisma.sh validate`
   - Format: `./scripts/prisma.sh format`

4. **Apply Changes:**
   ```bash
   # For development (creates migration)
   ./scripts/prisma.sh migrate
   
   # OR for prototyping (no migration)
   ./scripts/prisma.sh push
   ```

5. **Regenerate Client:**
   ```bash
   ./scripts/prisma.sh generate
   ```

### Production Workflow

1. **Deploy Migrations:**
   ```bash
   ./scripts/prisma.sh migrate-deploy
   ```

2. **Check Status:**
   ```bash
   ./scripts/prisma.sh status
   ```

## Key Differences from Prisma 6

### Configuration
- **Prisma 6:** Connection URL in `schema.prisma`
- **Prisma 7:** Connection URL in `prisma.config.ts` with adapter pattern

### Client Generation
- **Prisma 6:** Custom output location supported
- **Prisma 7:** Default location only (node_modules)

### Connection Pooling
- **Prisma 6:** Built-in connection pooling
- **Prisma 7:** Explicit adapter with pg Pool for better control

## Troubleshooting

### Issue: "Cannot find Prisma Client"
**Solution:**
```bash
./scripts/prisma.sh generate
```

### Issue: "Database connection failed"
**Solution:**
1. Check Docker is running: `docker ps`
2. Check .env file has correct DATABASE_POSTGRES_URL
3. Test connection: `./scripts/prisma.sh test`

### Issue: "Migration failed"
**Solution:**
1. Check migration status: `./scripts/prisma.sh status`
2. Validate schema: `./scripts/prisma.sh validate`
3. Check database logs: `docker-compose logs postgres`

### Issue: "Schema out of sync"
**Solution:**
```bash
# For development
./scripts/prisma.sh push

# For production
./scripts/prisma.sh migrate-deploy
```

## Quick Reference

### Common Tasks

| Task | Command |
|------|---------|
| Setup everything | `./scripts/setup.sh` |
| Start backend | `./scripts/backend-local.sh` |
| Generate Prisma Client | `./scripts/prisma.sh generate` |
| Create migration | `./scripts/prisma.sh migrate` |
| Open Prisma Studio | `./scripts/prisma.sh studio` |
| Validate schema | `./scripts/prisma.sh validate` |
| Test connection | `./scripts/prisma.sh test` |
| Clean everything | `./scripts/clean.sh` |

### Backend Commands (from apps/palakat_backend)

| Task | Command |
|------|---------|
| Generate Client | `pnpm run prisma:generate` |
| Run migrations | `pnpm run db:migrate` |
| Deploy migrations | `pnpm run db:deploy` |
| Push schema | `pnpm run db:push` |
| Seed database | `pnpm run db:seed` |
| Open Studio | `pnpm run prisma:studio` |
| Test connection | `pnpm run test:prisma` |

## Benefits of Updated Scripts

1. **Automated Prisma 7 Setup** - Scripts handle Prisma Client generation automatically
2. **Better Error Handling** - More informative error messages and validation
3. **Flexible Workflows** - Support for both migration-based and push-based workflows
4. **Comprehensive Management** - New `prisma.sh` script covers all common operations
5. **Backward Compatible** - Cleans up old Prisma 6 artifacts automatically

## Migration from Prisma 6

If you're upgrading an existing environment:

1. **Clean old artifacts:**
   ```bash
   ./scripts/clean.sh --backend-only
   ```

2. **Reinstall dependencies:**
   ```bash
   cd apps/palakat_backend
   pnpm install
   ```

3. **Generate Prisma Client:**
   ```bash
   ./scripts/prisma.sh generate
   ```

4. **Verify setup:**
   ```bash
   ./scripts/prisma.sh validate
   ./scripts/prisma.sh test
   ```

## Additional Resources

- [Prisma 7 Upgrade Guide](apps/palakat_backend/PRISMA_7_UPGRADE.md)
- [Tech Stack Documentation](.kiro/steering/tech.md)
- [Project Structure](.kiro/steering/structure.md)
