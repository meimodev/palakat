import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as fs from 'node:fs';
import * as path from 'node:path';
import * as process from 'node:process';
import { PrismaClient } from '../src/generated/prisma/client';

const connectionString =
  process.env.DATABASE_POSTGRES_URL &&
  !process.env.DATABASE_POSTGRES_URL.includes('${')
    ? process.env.DATABASE_POSTGRES_URL
    : `postgresql://${process.env.POSTGRES_USER || 'root'}:${process.env.POSTGRES_PASSWORD || 'password'}@${process.env.POSTGRES_HOST || 'localhost'}:${process.env.POSTGRES_PORT || '5432'}/${process.env.POSTGRES_DB || 'database'}`;

async function main() {
  const rawId = process.env.SONG_DB_FILE_ID;
  if (!rawId || rawId.trim().length === 0) {
    throw new Error('SONG_DB_FILE_ID is not set');
  }
  const fileId = Number(rawId);
  if (!Number.isFinite(fileId)) {
    throw new Error('SONG_DB_FILE_ID is not a valid number');
  }

  const pool = new Pool({ connectionString });
  const adapter = new PrismaPg(pool);
  const prisma = new PrismaClient({ adapter });

  try {
    const bucket = process.env.FIREBASE_STORAGE_BUCKET ?? 'seed-bucket';
    const originalName = 'songs.json';
    const storagePath = 'db/songs.json';

    const churchIdFromEnv = process.env.SONG_DB_CHURCH_ID?.trim();
    const churchId = churchIdFromEnv?.length
      ? Number(churchIdFromEnv)
      : (await prisma.church.findFirst({ select: { id: true } }))?.id;

    if (!churchId || !Number.isFinite(churchId)) {
      throw new Error(
        'No Church found. Set SONG_DB_CHURCH_ID to an existing church id.',
      );
    }

    const localTemplatePath = path.resolve(
      __dirname,
      'seed_assets',
      'song_db',
      originalName,
    );

    let sizeInKB = 1;
    try {
      const buf = fs.readFileSync(localTemplatePath);
      sizeInKB = Math.max(0.01, parseFloat((buf.byteLength / 1024).toFixed(2)));
    } catch (_) {}

    const file = await (prisma as any).fileManager.upsert({
      where: { id: fileId },
      update: {
        provider: 'FIREBASE_STORAGE',
        bucket,
        path: storagePath,
        sizeInKB,
        contentType: 'application/json',
        originalName,
        churchId,
      },
      create: {
        id: fileId,
        provider: 'FIREBASE_STORAGE',
        bucket,
        path: storagePath,
        sizeInKB,
        contentType: 'application/json',
        originalName,
        churchId,
      },
    });

    try {
      await prisma.$executeRawUnsafe(
        `SELECT setval(pg_get_serial_sequence('"FileManager"', 'id'), (SELECT MAX(id) FROM "FileManager"));`,
      );
    } catch (_) {}

    console.log('OK');
    console.log(`SONG_DB_FILE_ID=${file.id}`);
    console.log(`bucket=${bucket}`);
    console.log(`path=${storagePath}`);
    console.log(`template=${localTemplatePath}`);
  } finally {
    await prisma.$disconnect();
    await pool.end();
  }
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
