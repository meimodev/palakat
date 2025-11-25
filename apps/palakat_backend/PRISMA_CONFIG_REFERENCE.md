# Prisma 7 Configuration Reference

## Configuration Files

### 1. `prisma/schema.prisma`
Defines your database schema, models, and relationships.

```prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
}

model User {
  id    Int    @id @default(autoincrement())
  email String @unique
  name  String
}
```

**Key Points:**
- No `url` in datasource (moved to prisma.config.ts)
- Single generator (no custom output locations in Prisma 7)
- Models, enums, and relations defined here

### 2. `prisma/prisma.config.ts`
Configures database connection for Prisma CLI commands.

```typescript
export default {
  datasources: {
    db: {
      url: process.env.DATABASE_POSTGRES_URL,
    },
  },
};
```

**Key Points:**
- Required for Prisma CLI commands (migrate, push, studio)
- Simple configuration with datasource URL
- Environment variables loaded from .env

### 3. `src/prisma.module.ts`
Global NestJS module that provides PrismaService.

```typescript
import { Global, Module } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
```

**Key Points:**
- `@Global()` decorator makes it available to all modules
- No need to import PrismaModule in feature modules
- Proper NestJS dependency injection pattern

### 4. `src/prisma.service.ts`
NestJS service that configures PrismaClient with adapter for runtime connections.

```typescript
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private pool: Pool;

  constructor() {
    const pool = new Pool({
      connectionString: process.env.DATABASE_POSTGRES_URL,
    });

    const adapter = new PrismaPg(pool);

    super({
      adapter,
    });

    this.pool = pool;
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
    await this.pool.end();
  }
}
```

**Key Points:**
- Uses PostgreSQL adapter for runtime database connections
- Connection pooling managed by pg Pool
- Proper lifecycle management (connect/disconnect)
- Injected as a global provider in NestJS

### 5. `.env`
Environment variables for database connection.

```env
DATABASE_POSTGRES_URL="postgresql://user:password@localhost:5432/database?schema=public"
```

## Configuration Breakdown

### Adapter Configuration (in PrismaService)

The adapter provides the database connection for your application:

```typescript
constructor() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_POSTGRES_URL,
    // Optional pool configuration
    max: 20,                    // Maximum pool size
    idleTimeoutMillis: 30000,   // Close idle clients after 30s
    connectionTimeoutMillis: 2000, // Return error after 2s if no connection
  });

  const adapter = new PrismaPg(pool);

  super({
    adapter,
  });

  this.pool = pool;
}
```

**Benefits:**
- Better connection pooling control
- Improved performance
- Serverless/edge runtime support
- Proper resource cleanup

### Datasources Configuration (in prisma.config.ts)

Required for CLI commands to know where to connect:

```typescript
export default {
  datasources: {
    db: {
      url: process.env.DATABASE_POSTGRES_URL,
    },
  },
};
```

**Used by:**
- `prisma migrate dev`
- `prisma migrate deploy`
- `prisma db push`
- `prisma db pull`
- `prisma studio`
- `prisma db seed`

## Common Patterns

### Development Configuration

**prisma.config.ts:**
```typescript
export default {
  datasources: {
    db: {
      url: process.env.DATABASE_POSTGRES_URL,
    },
  },
};
```

**prisma.service.ts:**
```typescript
constructor() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_POSTGRES_URL,
  });

  const adapter = new PrismaPg(pool);

  super({
    adapter,
    log: ['query', 'info', 'warn', 'error'], // Enable logging
  });

  this.pool = pool;
}
```

### Production Configuration

**prisma.service.ts:**
```typescript
constructor() {
  const pool = new Pool({
    connectionString: process.env.DATABASE_POSTGRES_URL,
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
    ssl: process.env.NODE_ENV === 'production' ? {
      rejectUnauthorized: false,
    } : false,
  });

  const adapter = new PrismaPg(pool);

  super({
    adapter,
    log: ['error'], // Only log errors in production
  });

  this.pool = pool;
}
```

## Environment Variables

### Required Variables

```env
# PostgreSQL connection string
DATABASE_POSTGRES_URL="postgresql://user:password@host:port/database?schema=public"
```

### Connection String Format

```
postgresql://[user[:password]@][host][:port][/database][?parameter_list]
```

**Examples:**

```env
# Local development
DATABASE_POSTGRES_URL="postgresql://root:root@localhost:5432/palakat?schema=public"

# Docker
DATABASE_POSTGRES_URL="postgresql://root:root@postgres:5432/palakat?schema=public"

# Production with SSL
DATABASE_POSTGRES_URL="postgresql://user:pass@prod-host:5432/db?schema=public&sslmode=require"

# Connection pooling service (e.g., PgBouncer)
DATABASE_POSTGRES_URL="postgresql://user:pass@pooler:6543/db?schema=public&pgbouncer=true"
```

## Troubleshooting

### Error: "The datasource property is required"

**Cause:** Missing `prisma.config.ts` or incorrect configuration

**Solution:**
Create `prisma/prisma.config.ts`:
```typescript
export default {
  datasources: {
    db: {
      url: process.env.DATABASE_POSTGRES_URL,
    },
  },
};
```

### Error: "Cannot find module '@prisma/client'"

**Cause:** Prisma Client not generated

**Solution:**
```bash
pnpm run prisma:generate
# or
./scripts/prisma.sh generate
```

### Error: "Connection timeout"

**Cause:** Database not accessible or wrong connection string

**Solution:**
1. Check database is running: `docker ps`
2. Verify .env has correct DATABASE_POSTGRES_URL
3. Test connection: `./scripts/prisma.sh test`

### Error: "Pool is closed"

**Cause:** Connection pool closed prematurely

**Solution:**
```typescript
// Ensure proper cleanup
process.on('beforeExit', async () => {
  await pool.end();
});
```

## Best Practices

1. **Use Environment Variables**
   - Never hardcode connection strings
   - Use different .env files for different environments

2. **Configure Connection Pool**
   - Set appropriate pool size based on your workload
   - Configure timeouts to prevent hanging connections

3. **Enable Logging in Development**
   - Use `log: ['query', 'info', 'warn', 'error']` to debug issues
   - Disable or reduce logging in production

4. **Handle Connection Errors**
   - Implement retry logic for transient failures
   - Log connection errors for monitoring

5. **Secure Production Connections**
   - Use SSL/TLS for production databases
   - Rotate credentials regularly
   - Use connection pooling services for better scalability

## Migration from Prisma 6

### What Changed

| Aspect | Prisma 6 | Prisma 7 |
|--------|----------|----------|
| Connection URL | In schema.prisma | In prisma.config.ts (CLI) + PrismaService (runtime) |
| Custom Output | Supported | Not supported |
| Connection Pooling | Built-in | Via adapter in PrismaService |
| Configuration | schema.prisma only | schema.prisma + prisma.config.ts + prisma.service.ts |

### Migration Steps

1. Remove `url` from schema.prisma datasource
2. Create `prisma/prisma.config.ts` with datasources config
3. Create `src/prisma.service.ts` with adapter configuration
4. Install adapter packages: `@prisma/adapter-pg` and `pg`
5. Update app.module.ts to use PrismaService
6. Regenerate client: `pnpm run prisma:generate`

## Additional Resources

- [Prisma 7 Documentation](https://www.prisma.io/docs)
- [PostgreSQL Adapter](https://www.prisma.io/docs/orm/overview/databases/database-drivers)
- [Connection Pooling](https://www.prisma.io/docs/orm/prisma-client/setup-and-configuration/databases-connections/connection-pool)
- [Environment Variables](https://www.prisma.io/docs/orm/more/development-environment/environment-variables)
