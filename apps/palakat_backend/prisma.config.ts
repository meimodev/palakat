import 'dotenv/config';
import { defineConfig } from 'prisma/config';

const databaseUrl = (() => {
  const raw = process.env.DATABASE_POSTGRES_URL;
  if (raw && !raw.includes('${')) {
    return raw;
  }

  const host = process.env.POSTGRES_HOST || 'localhost';
  const port = process.env.POSTGRES_PORT || '5432';
  const user = process.env.POSTGRES_USER || 'root';
  const password = process.env.POSTGRES_PASSWORD || 'password';
  const db = process.env.POSTGRES_DB || 'database';

  return `postgresql://${user}:${password}@${host}:${port}/${db}`;
})();

export default defineConfig({
  schema: 'prisma/schema.prisma',
  migrations: {
    path: 'prisma/migrations',
    seed: 'tsx prisma/seed.ts',
  },
  datasource: {
    url: databaseUrl,
  },
});
