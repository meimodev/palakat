import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import { PrismaClient } from './src/generated/prisma/client';

async function testConnection() {
  const connectionString =
    process.env.DATABASE_POSTGRES_URL &&
    !process.env.DATABASE_POSTGRES_URL.includes('${')
      ? process.env.DATABASE_POSTGRES_URL
      : `postgresql://${process.env.POSTGRES_USER || 'root'}:${process.env.POSTGRES_PASSWORD || 'password'}@${process.env.POSTGRES_HOST || 'localhost'}:${process.env.POSTGRES_PORT || '5432'}/${process.env.POSTGRES_DB || 'database'}`;

  const pool = new Pool({
    connectionString,
  });
  const adapter = new PrismaPg(pool);
  const prisma = new PrismaClient({ adapter });

  try {
    console.log('Testing Prisma 7 connection...');
    await prisma.$connect();
    console.log('✅ Successfully connected to database');

    // Test a simple query
    const result = await prisma.$queryRaw`SELECT version()`;
    console.log('✅ Database query successful');
    console.log('PostgreSQL version:', result);
  } catch (error) {
    console.error('❌ Connection failed:', error);
  } finally {
    await prisma.$disconnect();
    await pool.end();
    console.log('✅ Disconnected from database');
  }
}

testConnection();
