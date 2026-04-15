import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as fs from 'node:fs';
import * as path from 'node:path';
import * as process from 'node:process';
import {
  AccountRole,
  Gender,
  MaritalStatus,
  PrismaClient,
} from '../src/generated/prisma/client';
import * as bcrypt from 'bcryptjs';

const connectionString =
  process.env.DATABASE_URL && !process.env.DATABASE_URL.includes('${')
    ? process.env.DATABASE_URL
    : `postgresql://${process.env.POSTGRES_USER || 'root'}:${process.env.POSTGRES_PASSWORD || 'password'}@${process.env.POSTGRES_HOST || 'localhost'}:${process.env.POSTGRES_PORT || '5432'}/${process.env.POSTGRES_DB || 'database'}`;

const pool = new Pool({
  connectionString,
});
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const CONGREGATION_JSON_PATH = path.resolve(
  __dirname,
  '..',
  '..',
  '..',
  'docs',
  'congregation.json',
);

const REQUIRED_MEMBERSHIP_POSITION_NAMES = [
  'Ketua Jemaat',
  'Sekertaris',
  'Bendahara',
  'Admin Gereja',
] as const;

const CONGREGATION_SEED_LIMIT = parseCongregationSeedLimit();

interface RawCongregationLocation {
  name?: unknown;
}

interface RawMembershipPosition {
  name?: unknown;
}

interface RawAccount {
  name?: unknown;
  phone?: unknown;
  email?: unknown;
  role?: unknown;
  gender?: unknown;
  maritalStatus?: unknown;
  dob?: unknown;
}

interface RawMembership {
  baptize?: unknown;
  sidi?: unknown;
  membershipPositions?: unknown;
  accountId?: unknown;
  account?: unknown;
}

interface RawColumn {
  id?: unknown;
  name?: unknown;
  memberships?: unknown;
}

interface RawCongregationRecord {
  region_name?: unknown;
  region_id?: unknown;
  church_name?: unknown;
  church_id?: unknown;
  total_columns?: unknown;
  location?: unknown;
  columns?: unknown;
}

interface ImportSummary {
  regions: number;
  churches: number;
  columns: number;
  accounts: number;
  memberships: number;
  membershipPositions: number;
  totalColumnWarnings: number;
}

function assertString(
  value: unknown,
  fieldName: string,
  context: string,
): string {
  if (typeof value !== 'string' || value.trim().length === 0) {
    throw new Error(`Invalid ${fieldName} at ${context}`);
  }
  return value.trim();
}

function optionalString(value: unknown): string | null {
  if (typeof value !== 'string') {
    return null;
  }
  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function assertNumber(
  value: unknown,
  fieldName: string,
  context: string,
): number {
  if (typeof value !== 'number' || !Number.isFinite(value)) {
    throw new Error(`Invalid ${fieldName} at ${context}`);
  }
  return value;
}

function optionalBoolean(value: unknown): boolean {
  return typeof value === 'boolean' ? value : false;
}

function assertArray<T>(
  value: unknown,
  fieldName: string,
  context: string,
): T[] {
  if (!Array.isArray(value)) {
    throw new Error(`Invalid ${fieldName} at ${context}`);
  }
  return value as T[];
}

function parseRole(value: unknown, context: string): AccountRole {
  if (value == null) {
    return AccountRole.USER;
  }
  const role = assertString(value, 'account.role', context).toUpperCase();
  switch (role) {
    case AccountRole.USER:
      return AccountRole.USER;
    case AccountRole.ADMIN:
      return AccountRole.ADMIN;
    case AccountRole.SUPER_ADMIN:
      return AccountRole.SUPER_ADMIN;
    default:
      throw new Error(`Unsupported account.role '${role}' at ${context}`);
  }
}

function parseGender(value: unknown, context: string): Gender {
  const gender = assertString(value, 'account.gender', context).toUpperCase();
  switch (gender) {
    case Gender.MALE:
      return Gender.MALE;
    case Gender.FEMALE:
      return Gender.FEMALE;
    default:
      throw new Error(`Unsupported account.gender '${gender}' at ${context}`);
  }
}

function parseMaritalStatus(value: unknown, context: string): MaritalStatus {
  const maritalStatus = assertString(
    value,
    'account.maritalStatus',
    context,
  ).toUpperCase();
  switch (maritalStatus) {
    case MaritalStatus.MARRIED:
      return MaritalStatus.MARRIED;
    case MaritalStatus.SINGLE:
      return MaritalStatus.SINGLE;
    default:
      throw new Error(
        `Unsupported account.maritalStatus '${maritalStatus}' at ${context}`,
      );
  }
}

function parseDob(value: unknown, context: string): Date {
  const dob = assertString(value, 'account.dob', context);
  const parsed = new Date(dob);
  if (Number.isNaN(parsed.getTime())) {
    throw new Error(`Invalid account.dob '${dob}' at ${context}`);
  }
  return parsed;
}

function parseCongregationSeedLimit(): number | null {
  const raw = process.env.CONGREGATION_SEED_LIMIT?.trim();
  if (!raw) {
    const isProductionEnv =
      process.env.PALAKAT_ENV?.trim().toLowerCase() === 'production' ||
      process.env.NODE_ENV?.trim().toLowerCase() === 'production';
    return isProductionEnv ? null : 10;
  }

  const parsed = Number.parseInt(raw, 10);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    throw new Error(
      `Invalid CONGREGATION_SEED_LIMIT '${raw}'. Expected positive integer.`,
    );
  }

  return parsed;
}

function readCongregationJson(): RawCongregationRecord[] {
  const raw = fs.readFileSync(CONGREGATION_JSON_PATH, 'utf8');
  const parsed = JSON.parse(raw) as unknown;
  if (!Array.isArray(parsed)) {
    throw new Error('docs/congregation.json must contain a top-level array');
  }
  const records = parsed as RawCongregationRecord[];
  if (
    CONGREGATION_SEED_LIMIT != null &&
    records.length > CONGREGATION_SEED_LIMIT
  ) {
    console.log(
      `⚠️ Applying CONGREGATION_SEED_LIMIT=${CONGREGATION_SEED_LIMIT}; importing first ${CONGREGATION_SEED_LIMIT} congregations only`,
    );
    return records.slice(0, CONGREGATION_SEED_LIMIT);
  }

  return records;
}

async function cleanDatabase() {
  console.log('🧹 Cleaning existing data before congregation import...');
  const p = prisma as any;
  await prisma.$transaction([
    p.articleLike.deleteMany(),
    p.article.deleteMany(),
    p.notification.deleteMany(),
    p.approver.deleteMany(),
    p.revenueApprover.deleteMany(),
    p.expenseApprover.deleteMany(),
    p.revenue.deleteMany(),
    p.expense.deleteMany(),
    p.cashMutation.deleteMany(),
    p.cashAccount.deleteMany(),
    p.financialAccountNumber.deleteMany(),
    p.activity.deleteMany(),
    p.reportJob.deleteMany(),
    p.report.deleteMany(),
    p.document.deleteMany(),
    p.fileManager.deleteMany(),
    p.songPart.deleteMany(),
    p.song.deleteMany(),
    p.approvalRule.deleteMany(),
    p.membershipPosition.deleteMany(),
    p.membershipInvitation.deleteMany(),
    p.membership.deleteMany(),
    p.churchPermissionPolicy.deleteMany(),
    p.churchRequest.deleteMany(),
    p.column.deleteMany(),
    p.church.deleteMany(),
    p.account.deleteMany(),
    p.location.deleteMany(),
    p.region.deleteMany(),
  ]);
  console.log('✅ Database cleaned');
}

async function syncSequences() {
  const sequenceTables = [
    'Region',
    'Location',
    'Church',
    'Column',
    'Account',
    'Membership',
    'MembershipPosition',
  ];

  for (const tableName of sequenceTables) {
    await prisma.$executeRawUnsafe(
      `SELECT setval(pg_get_serial_sequence('"${tableName}"', 'id'), COALESCE((SELECT MAX(id) FROM "${tableName}"), 1), true);`,
    );
  }
}

async function ensureRequiredPositionsForChurch(params: {
  churchId: number;
  churchName: string;
  fallbackMembershipId: number | undefined;
  positionHolderByChurchAndName: Map<string, number>;
  summary: ImportSummary;
}) {
  const {
    churchId,
    churchName,
    fallbackMembershipId,
    positionHolderByChurchAndName,
    summary,
  } = params;

  if (fallbackMembershipId == null) {
    throw new Error(
      `Cannot ensure required positions for church '${churchName}' (#${churchId}) without memberships`,
    );
  }

  for (const positionName of REQUIRED_MEMBERSHIP_POSITION_NAMES) {
    const positionKey = `${churchId}:${positionName.toLowerCase()}`;
    if (positionHolderByChurchAndName.has(positionKey)) {
      continue;
    }

    await prisma.membershipPosition.create({
      data: {
        name: positionName,
        churchId,
        membershipId: fallbackMembershipId,
      },
    });
    positionHolderByChurchAndName.set(positionKey, fallbackMembershipId);
    summary.membershipPositions += 1;
  }
}

async function importCongregationData(records: RawCongregationRecord[]) {
  const p = prisma as any;
  const summary: ImportSummary = {
    regions: 0,
    churches: 0,
    columns: 0,
    accounts: 0,
    memberships: 0,
    membershipPositions: 0,
    totalColumnWarnings: 0,
  };

  const regionIdBySource = new Map<number, number>();
  const regionNameBySource = new Map<number, string>();
  const churchIdBySource = new Map<number, number>();
  const accountIdBySource = new Map<number, number>();
  const membershipIdBySourceAccount = new Map<number, number>();
  const positionHolderByChurchAndName = new Map<string, number>();
  const fallbackMembershipIdByChurch = new Map<number, number>();

  for (let recordIndex = 0; recordIndex < records.length; recordIndex++) {
    const record = records[recordIndex];
    const recordContext = `record[${recordIndex}]`;
    const regionSourceId = assertNumber(
      record.region_id,
      'region_id',
      recordContext,
    );
    const regionName = assertString(
      record.region_name,
      'region_name',
      recordContext,
    );
    const churchSourceId = assertNumber(
      record.church_id,
      'church_id',
      recordContext,
    );
    const churchName = assertString(
      record.church_name,
      'church_name',
      recordContext,
    );
    const totalColumns = assertNumber(
      record.total_columns,
      'total_columns',
      recordContext,
    );
    const location = (record.location ?? {}) as RawCongregationLocation;
    const locationName = assertString(
      location.name,
      'location.name',
      recordContext,
    );
    const columns = assertArray<RawColumn>(
      record.columns,
      'columns',
      recordContext,
    );

    if (columns.length !== totalColumns) {
      summary.totalColumnWarnings += 1;
      console.warn(
        `⚠️ total_columns mismatch at ${recordContext}: expected ${totalColumns}, got ${columns.length}`,
      );
    }

    let regionId = regionIdBySource.get(regionSourceId);
    if (!regionId) {
      const createdRegion = await p.region.create({
        data: {
          sourceRegionId: regionSourceId,
          name: regionName,
        },
      });
      regionId = createdRegion.id as number;
      regionIdBySource.set(regionSourceId, regionId);
      regionNameBySource.set(regionSourceId, regionName);
      summary.regions += 1;
    } else {
      const knownRegionName = regionNameBySource.get(regionSourceId);
      if (knownRegionName !== regionName) {
        throw new Error(
          `Conflicting region_name for region_id ${regionSourceId}: '${knownRegionName}' vs '${regionName}'`,
        );
      }
    }

    if (churchIdBySource.has(churchSourceId)) {
      throw new Error(
        `Duplicate church_id ${churchSourceId} at ${recordContext}`,
      );
    }

    const createdLocation = await prisma.location.create({
      data: {
        name: locationName,
      },
    });

    const createdChurch = await p.church.create({
      data: {
        name: churchName,
        sourceChurchId: churchSourceId,
        regionId,
        locationId: createdLocation.id,
      },
    });

    const churchId = createdChurch.id as number;
    churchIdBySource.set(churchSourceId, churchId);
    summary.churches += 1;

    for (let columnIndex = 0; columnIndex < columns.length; columnIndex++) {
      const column = columns[columnIndex];
      const columnContext = `${recordContext}.columns[${columnIndex}]`;
      const columnSourceId = assertNumber(
        column.id,
        'columns.id',
        columnContext,
      );
      const columnName = assertString(
        column.name,
        'columns.name',
        columnContext,
      );

      const createdColumn = await p.column.create({
        data: {
          name: columnName,
          sourceColumnId: columnSourceId,
          churchId,
        },
      });
      summary.columns += 1;

      const memberships = Array.isArray(column.memberships)
        ? (column.memberships as RawMembership[])
        : [];

      for (
        let membershipIndex = 0;
        membershipIndex < memberships.length;
        membershipIndex++
      ) {
        const membership = memberships[membershipIndex];
        const membershipContext = `${columnContext}.memberships[${membershipIndex}]`;
        const rawAccount = (membership.account ?? null) as RawAccount | null;

        if (!rawAccount) {
          throw new Error(`Missing account object at ${membershipContext}`);
        }

        const sourceAccountId = assertNumber(
          membership.accountId,
          'memberships.accountId',
          membershipContext,
        );

        let accountId = accountIdBySource.get(sourceAccountId);
        if (!accountId) {
          const createdAccount = await p.account.create({
            data: {
              name: assertString(
                rawAccount.name,
                'account.name',
                membershipContext,
              ),
              sourceAccountId,
              phone: optionalString(rawAccount.phone),
              email: optionalString(rawAccount.email),
              passwordHash: await bcrypt.hash('password', 12),
              role:
                rawAccount.role == null
                  ? AccountRole.SUPER_ADMIN
                  : parseRole(rawAccount.role, membershipContext),
              gender: parseGender(rawAccount.gender, membershipContext),
              maritalStatus: parseMaritalStatus(
                rawAccount.maritalStatus,
                membershipContext,
              ),
              dob: parseDob(rawAccount.dob, membershipContext),
            },
          });
          accountId = createdAccount.id as number;
          accountIdBySource.set(sourceAccountId, accountId);
          summary.accounts += 1;
        }

        if (membershipIdBySourceAccount.has(sourceAccountId)) {
          throw new Error(
            `Duplicate membership for accountId ${sourceAccountId} at ${membershipContext}`,
          );
        }

        const createdMembership = await prisma.membership.create({
          data: {
            accountId,
            churchId,
            columnId: createdColumn.id,
            baptize: optionalBoolean(membership.baptize),
            sidi: optionalBoolean(membership.sidi),
          },
        });
        membershipIdBySourceAccount.set(sourceAccountId, createdMembership.id);
        summary.memberships += 1;
        fallbackMembershipIdByChurch.set(
          churchId,
          fallbackMembershipIdByChurch.get(churchId) ?? createdMembership.id,
        );

        const membershipPositions = Array.isArray(
          membership.membershipPositions,
        )
          ? (membership.membershipPositions as RawMembershipPosition[])
          : [];

        for (
          let positionIndex = 0;
          positionIndex < membershipPositions.length;
          positionIndex++
        ) {
          const position = membershipPositions[positionIndex];
          const positionContext = `${membershipContext}.membershipPositions[${positionIndex}]`;
          const positionName = assertString(
            position.name,
            'membershipPositions.name',
            positionContext,
          );
          const positionKey = `${churchId}:${positionName.toLowerCase()}`;
          const existingHolderMembershipId =
            positionHolderByChurchAndName.get(positionKey);

          if (
            existingHolderMembershipId &&
            existingHolderMembershipId !== createdMembership.id
          ) {
            throw new Error(
              `Position '${positionName}' is assigned to multiple memberships in church_id ${churchSourceId}`,
            );
          }

          if (!existingHolderMembershipId) {
            await prisma.membershipPosition.create({
              data: {
                name: positionName,
                churchId,
                membershipId: createdMembership.id,
              },
            });
            positionHolderByChurchAndName.set(
              positionKey,
              createdMembership.id,
            );
            summary.membershipPositions += 1;
          }
        }
      }
    }

    await ensureRequiredPositionsForChurch({
      churchId,
      churchName,
      fallbackMembershipId: fallbackMembershipIdByChurch.get(churchId),
      positionHolderByChurchAndName,
      summary,
    });
  }

  await syncSequences();

  return summary;
}

function printSummary(summary: ImportSummary) {
  console.log('\n📊 Congregation Import Summary');
  console.log('============================');
  console.log(`🌍 Regions: ${summary.regions}`);
  console.log(`⛪ Churches: ${summary.churches}`);
  console.log(`🧱 Columns: ${summary.columns}`);
  console.log(`👤 Accounts: ${summary.accounts}`);
  console.log(`🤝 Memberships: ${summary.memberships}`);
  console.log(`📋 Membership Positions: ${summary.membershipPositions}`);
  console.log(`⚠️ total_columns mismatches: ${summary.totalColumnWarnings}`);
}

async function main() {
  const inServerEnvironment = !['localhost', '127.0.0.1'].some((host) =>
    process.env.DATABASE_URL?.includes(host),
  );
  const forceSeeding = process.env.FORCE_SEEDING === 'true';

  if (inServerEnvironment) {
    if (forceSeeding) {
      console.error(
        ' ⚠️⚠️⚠️ Force seeding! Hope you know what will happen ⚠️⚠️⚠️',
      );
    } else {
      console.error('❌ Seeding is only allowed on local environments.');
      process.exit(0);
    }
  }

  console.log('🌱 Starting congregation import seed...\n');
  console.log(`📄 Source: ${CONGREGATION_JSON_PATH}`);
  if (CONGREGATION_SEED_LIMIT != null) {
    console.log(
      `🔢 Limit: first ${CONGREGATION_SEED_LIMIT} congregations via CONGREGATION_SEED_LIMIT`,
    );
  }

  try {
    const records = readCongregationJson();
    await cleanDatabase();
    const summary = await importCongregationData(records);
    printSummary(summary);
    console.log('\n🎉 Congregation import completed successfully!');
  } catch (error) {
    console.error('❌ Congregation import failed:', error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error('❌ Congregation import failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
