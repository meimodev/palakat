import { PrismaClient } from '@prisma/client';

async function testConnection() {
  const prisma = new PrismaClient();

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
    console.log('✅ Disconnected from database');
  }
}

testConnection();
