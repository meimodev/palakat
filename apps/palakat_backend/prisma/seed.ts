// Section-aware .env loader — mirrors prisma.config.ts logic.
// Plain `dotenv/config` is NOT section-aware and picks up the last duplicate
// value per key (i.e. the [production] Supabase URL), which causes the seeder
// to connect to the wrong database.
import * as fs from 'node:fs';
import * as path from 'node:path';
import { parse } from 'dotenv';

(function loadSectionEnv() {
  const envFile = path.resolve(process.cwd(), '.env');
  if (!fs.existsSync(envFile)) return;

  const source = fs.readFileSync(envFile, 'utf8');
  const lines = source.split(/\r?\n/);
  const hasSections = lines.some((l) => /^\s*\[[^\]]+\]\s*$/.test(l));

  if (!hasSections) {
    const parsed = parse(source);
    for (const [k, v] of Object.entries(parsed)) {
      if (typeof process.env[k] === 'undefined') process.env[k] = v;
    }
    return;
  }

  const targetSection = (process.env.PALAKAT_ENV || 'local')
    .trim()
    .toLowerCase();
  const commonLines: string[] = [];
  const sectionLines: string[] = [];
  let current: string | null = null;
  let sawSection = false;

  for (const line of lines) {
    const m = line.match(/^\s*\[([^\]]+)\]\s*$/);
    if (m) {
      sawSection = true;
      current = m[1].trim().toLowerCase();
      continue;
    }
    if (!sawSection) {
      commonLines.push(line);
    } else if (current === targetSection) {
      sectionLines.push(line);
    }
  }

  const parsed = parse([...commonLines, ...sectionLines].join('\n'));
  for (const [k, v] of Object.entries(parsed)) {
    // Only set if not already set by the shell environment
    if (typeof process.env[k] === 'undefined') process.env[k] = v;
  }
})();

import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import {
  ActivityType,
  ApprovalStatus,
  Bipra,
  Book,
  FinancialType,
  PaymentMethod,
  PrismaClient,
  Reminder,
} from '../src/generated/prisma/client';
import * as bcrypt from 'bcryptjs';
import * as process from 'node:process';

const connectionString =
  process.env.DATABASE_URL && !process.env.DATABASE_URL.includes('${')
    ? process.env.DATABASE_URL
    : `postgresql://${process.env.POSTGRES_USER || 'root'}:${process.env.POSTGRES_PASSWORD || 'password'}@${process.env.POSTGRES_HOST || 'localhost'}:${process.env.POSTGRES_PORT || '5432'}/${process.env.POSTGRES_DB || 'database'}`;

const pool = new Pool({
  connectionString,
});
const adapter = new PrismaPg(pool);
const prisma = new PrismaClient({ adapter });

const CONGREGATION_SEED_LIMIT = parseCongregationSeedLimit();

// ============================================================================
// SEEDED RANDOM NUMBER GENERATOR
// ============================================================================
let seed = 12345;

function seededRandom(): number {
  seed = (seed + 0x6d2b79f5) | 0;
  let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
  t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
  return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
}

// ============================================================================
// CONFIGURATION
// ============================================================================
const CONFIG = {
  activitiesPerMainAccount: 25,
  extraActivitiesPerChurch: 25,
  maxApproversPerActivity: 2,
  defaultPassword: 'password',
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

function randomElement<T>(array: T[]): T {
  return array[Math.floor(seededRandom() * array.length)];
}

function randomBoolean(probability = 0.5): boolean {
  return seededRandom() < probability;
}

function randomDate(start: Date, end: Date): Date {
  return new Date(
    start.getTime() + seededRandom() * (end.getTime() - start.getTime()),
  );
}

function generateLatitude(): number {
  return parseFloat((-6.0 - seededRandom() * 0.5).toFixed(4));
}

function generateLongitude(): number {
  return parseFloat((106.5 + seededRandom() * 0.5).toFixed(4));
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

function getStartOfMonth(date: Date = new Date()): Date {
  const result = new Date(date);
  result.setUTCDate(1);
  result.setUTCHours(0, 0, 0, 0);
  return result;
}

function getCurrentDay(date: Date = new Date()): Date {
  const result = new Date(date);
  result.setUTCHours(23, 59, 59, 999);
  return result;
}

function addUtcDays(date: Date, days: number): Date {
  const result = new Date(date);
  result.setUTCDate(result.getUTCDate() + days);
  return result;
}

function getStartOfWeek(date: Date = new Date()): Date {
  const result = new Date(date);
  const day = result.getUTCDay();
  const daysSinceMonday = (day + 6) % 7;
  result.setUTCDate(result.getUTCDate() - daysSinceMonday);
  result.setUTCHours(0, 0, 0, 0);
  return result;
}

function getCurrentWeekDates(date: Date = new Date()): Date[] {
  const startOfWeek = getStartOfWeek(date);
  const dates: Date[] = [];
  for (let i = 0; i < 7; i++) {
    const d = addUtcDays(startOfWeek, i);
    d.setUTCHours(12, 0, 0, 0);
    dates.push(d);
  }
  return dates;
}

function getWeekDateOverrideMapForActivityVariations(
  variations: { type: ActivityType; bipra: Bipra | null }[],
  weekDates: Date[],
): Map<number, Date> {
  const map = new Map<number, Date>();
  if (weekDates.length === 0) {
    return map;
  }
  for (let i = 0; i < variations.length; i++) {
    map.set(i, weekDates[i % weekDates.length]);
  }
  return map;
}

// Approval rule names are now defined in APPROVAL_RULE_VARIATIONS

const ACTIVITY_TITLES = {
  SERVICE: [
    'Kebaktian Minggu Pagi',
    'Kebaktian Sore',
    'Kebaktian Keluarga',
    'Doa Syafaat Pagi',
    'Bible Study',
    'Persekutuan Doa',
    'Kebaktian Pemuda',
    'Sekolah Minggu',
  ],
  EVENT: [
    'Retreat Kolom',
    'Seminar Kepemimpinan',
    'Workshop Parenting',
    'Outreach',
    'Bakti Sosial',
    'Konser Rohani',
    'Camp Pemuda',
    'Pelatihan Pelayanan',
  ],
  ANNOUNCEMENT: [
    'Pengumuman Persiapan Sidi',
    'Pengumuman Acara Natal',
    'Pengumuman Acara Paskah',
    'Pengumuman Rapat Majelis',
    'Pengumuman Kegiatan Kolom',
    'Pengumuman Bakti Sosial',
  ],
};

const REMINDER_VALUES: Reminder[] = [
  Reminder.TEN_MINUTES,
  Reminder.THIRTY_MINUTES,
  Reminder.ONE_HOUR,
  Reminder.TWO_HOURS,
];
const ACTIVITY_TYPES: ActivityType[] = [
  ActivityType.SERVICE,
  ActivityType.EVENT,
  ActivityType.ANNOUNCEMENT,
];
const BIPRA_VALUES: Bipra[] = [
  Bipra.PKB,
  Bipra.WKI,
  Bipra.PMD,
  Bipra.RMJ,
  Bipra.ASM,
];
const APPROVAL_STATUSES: ApprovalStatus[] = [
  ApprovalStatus.UNCONFIRMED,
  ApprovalStatus.APPROVED,
  ApprovalStatus.REJECTED,
];
const PAYMENT_METHODS: PaymentMethod[] = [
  PaymentMethod.CASH,
  PaymentMethod.CASHLESS,
];
// ============================================================================
// TYPES
// ============================================================================
interface MembershipWithChurch {
  id: number;
  churchId: number;
  accountPhone?: string;
}

interface ChurchWithColumns {
  id: number;
  name: string;
  columns: { id: number; name: string }[];
}

interface FinancialAccountWithType {
  id: number;
  churchId: number;
  type: 'income' | 'expense';
  name: string;
}

// ============================================================================
// FACTORY FUNCTIONS
// ============================================================================

function generateActivityData(
  type: ActivityType,
  bipra: Bipra | null,
  index: number,
) {
  const title = randomElement(ACTIVITY_TITLES[type]);
  const monthStart = getStartOfMonth();
  const today = getCurrentDay();
  const activityDate = randomDate(monthStart, today);
  const reminder =
    type !== ActivityType.ANNOUNCEMENT ? randomElement(REMINDER_VALUES) : null;

  return {
    title: `${title} ${index}`,
    activityType: type,
    bipra,
    date: activityDate,
    description: randomBoolean(0.6)
      ? `Deskripsi lengkap untuk ${title} ${index}`
      : null,
    note: randomBoolean(0.7) ? `Catatan untuk ${title} ${index}` : null,
    reminder,
  };
}

// Generate all activity variations (3 types × (1 general + 5 bipras) = 18)
function getAllActivityVariations(): {
  type: ActivityType;
  bipra: Bipra | null;
}[] {
  const variations: { type: ActivityType; bipra: Bipra | null }[] = [];
  for (const activityType of ACTIVITY_TYPES) {
    variations.push({ type: activityType, bipra: null });
    for (const bipra of BIPRA_VALUES) {
      variations.push({ type: activityType, bipra });
    }
  }
  return variations;
}

// ============================================================================
// MAIN SEEDING LOGIC
// ============================================================================

async function cleanDatabase() {
  console.log('🧹 Cleaning existing data...');

  // Truncate all tables in dependency order with CASCADE.
  // We quote each name explicitly because Prisma creates tables with
  // mixed-case names that PostgreSQL only finds when double-quoted.
  // The IF EXISTS check prevents errors on fresh/partially-migrated DBs.
  await prisma.$executeRawUnsafe(`
    DO $$
    DECLARE
      _tbl TEXT;
      _tables TEXT[] := ARRAY[
        'ArticleLike',
        'Article',
        'Notification',
        'ReportJob',
        'Report',
        'Document',
        'FileManager',
        'Approver',
        'RevenueApprover',
        'ExpenseApprover',
        'Revenue',
        'Expense',
        'CashMutation',
        'CashAccount',
        'FinancialAccountNumber',
        'Activity',
        'Song',
        'SongPart',
        'ApprovalRule',
        'ChurchPermissionPolicy',
        'MembershipPosition',
        'MembershipInvitation',
        'Membership',
        'ChurchRequest',
        'Column',
        'Church',
        'Account',
        'Location',
        'Region'
      ];
    BEGIN
      FOREACH _tbl IN ARRAY _tables LOOP
        IF EXISTS (
          SELECT 1 FROM information_schema.tables
          WHERE table_schema = 'public'
            AND table_name = _tbl
        ) THEN
          EXECUTE format('TRUNCATE TABLE public."%s" CASCADE', _tbl);
        END IF;
      END LOOP;
    END $$;
  `);

  console.log('✅ Database cleaned');
}

async function seedArticles() {
  const p = prisma as any;

  const now = new Date();
  const items: any[] = [
    {
      type: 'PREACHING_MATERIAL',
      status: 'PUBLISHED',
      title: 'Renungan: Mengampuni Seperti Kristus',
      slug: 'renungan-mengampuni-seperti-kristus',
      excerpt:
        'Bahan khotbah singkat tentang pengampunan dalam kehidupan sehari-hari.',
      content:
        '# Mengampuni Seperti Kristus\n\n## Pokok\n- Mengampuni bukan berarti melupakan\n- Mengampuni adalah ketaatan\n\n## Aplikasi\nTuliskan satu langkah nyata minggu ini.',
      publishedAt: new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000),
    },
    {
      type: 'PREACHING_MATERIAL',
      status: 'PUBLISHED',
      title: 'Renungan: Berjalan Dalam Iman',
      slug: 'renungan-berjalan-dalam-iman',
      excerpt: 'Ringkasan bahan untuk memandu kelompok kecil.',
      content:
        '# Berjalan Dalam Iman\n\nBacaan: Ibrani 11\n\n- Apa itu iman?\n- Mengapa iman penting?\n\n## Diskusi\n1. Apa tantanganmu saat ini?',
      publishedAt: new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000),
    },
    {
      type: 'GAME_INSTRUCTION',
      status: 'PUBLISHED',
      title: 'Instruksi Game: Tebak Ayat',
      slug: 'instruksi-game-tebak-ayat',
      excerpt: 'Cara bermain game tebak ayat untuk kelompok pemuda.',
      content:
        '# Tebak Ayat\n\n## Tujuan\nMengenal firman melalui permainan.\n\n## Aturan\n1. Moderator membacakan potongan ayat\n2. Peserta menebak kitab/pasal/ayat\n3. Skor 10 poin untuk jawaban tepat',
      publishedAt: new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000),
    },
    {
      type: 'GAME_INSTRUCTION',
      status: 'DRAFT',
      title: 'Instruksi Game: Bible Bingo',
      slug: 'instruksi-game-bible-bingo',
      excerpt: 'Draft panduan Bible Bingo.',
      content:
        '# Bible Bingo\n\nDraft panduan. Lengkapi aturan dan contoh kartu.',
      publishedAt: null,
    },
  ];

  for (const item of items) {
    await p.article.create({
      data: {
        type: item.type,
        status: item.status,
        title: item.title,
        slug: item.slug,
        excerpt: item.excerpt,
        content: item.content,
        coverImageUrl: null,
        publishedAt: item.publishedAt,
      },
    });
  }
}

async function seedCongregationsAndFinances(passwordHash: string) {
  console.log(
    '\n🏛️  Seeding congregations and financial accounts from JSON...',
  );

  const congJsonPath = path.resolve(
    __dirname,
    '..',
    '..',
    '..',
    'docs',
    'congregation.json',
  );
  const finJsonPath = path.resolve(
    __dirname,
    '..',
    '..',
    '..',
    'docs',
    'financial_accounts_number.json',
  );

  console.log(`   📂 Reading congregation.json...`);
  console.log(`      Path: ${congJsonPath}`);
  const congRaw = fs.readFileSync(congJsonPath, 'utf-8');
  console.log(`      File size: ${(congRaw.length / 1024).toFixed(1)} KB`);
  let congregations = JSON.parse(congRaw);
  console.log(
    `      ✔ Loaded ${congregations.length} congregations from file`,
  );

  if (
    CONGREGATION_SEED_LIMIT != null &&
    congregations.length > CONGREGATION_SEED_LIMIT
  ) {
    congregations = congregations.slice(0, CONGREGATION_SEED_LIMIT);
    console.log(
      `      ⚠️ Applying CONGREGATION_SEED_LIMIT=${CONGREGATION_SEED_LIMIT}; importing first ${CONGREGATION_SEED_LIMIT} congregations only`,
    );
  }

  console.log(`   📂 Reading financial_accounts_number.json...`);
  console.log(`      Path: ${finJsonPath}`);
  const finRaw = fs.readFileSync(finJsonPath, 'utf-8');
  console.log(`      File size: ${(finRaw.length / 1024).toFixed(1)} KB`);
  const finAccountsData = JSON.parse(finRaw);
  const revenueAccounts = finAccountsData.filter(
    (f: any) => f.type !== 'EXPENSE',
  );
  const expenseAccounts = finAccountsData.filter(
    (f: any) => f.type === 'EXPENSE',
  );
  console.log(
    `      ✔ Loaded ${finAccountsData.length} account templates ` +
      `(${revenueAccounts.length} revenue, ${expenseAccounts.length} expense)`,
  );

  const createdChurches: ChurchWithColumns[] = [];
  const mainMemberships: MembershipWithChurch[] = [];
  const financialAccounts: FinancialAccountWithType[] = [];
  const mainAccounts: { id: number; phone: string }[] = [];

  console.log(`\n   ⏳ Processing ${congregations.length} congregations...\n`);
  let churchIndex = 0;

  for (const cong of congregations) {
    churchIndex++;
    process.stdout.write(
      `   [${String(churchIndex).padStart(3, ' ')}/${congregations.length}] 🏛️  ${cong.church_name}...`,
    );
    const region = await prisma.region.upsert({
      where: { sourceRegionId: cong.region_id },
      update: { name: cong.region_name },
      create: { sourceRegionId: cong.region_id, name: cong.region_name },
    });

    const locationName = cong.location?.name || `${cong.church_name} Location`;
    const location = await prisma.location.create({
      data: {
        name: locationName,
        latitude: generateLatitude(),
        longitude: generateLongitude(),
      },
    });

    const church = await prisma.church.upsert({
      where: { sourceChurchId: cong.church_id },
      update: {
        name: cong.church_name,
        regionId: region.id,
        locationId: location.id,
      },
      create: {
        sourceChurchId: cong.church_id,
        name: cong.church_name,
        regionId: region.id,
        locationId: location.id,
        documentAccountNumber: 0 as any,
        documentPrefixAccountNumber: `GMIM-${cong.church_name
          .toUpperCase()
          .replace(/\s+/g, '-')}`.substring(0, 20),
      },
      include: { columns: true },
    });

    const churchWithCols: ChurchWithColumns = {
      id: church.id,
      name: church.name,
      columns: [],
    };

    let churchColCount = 0;
    let churchMemberCount = 0;
    let churchPositionCount = 0;

    let churchFinCount = 0;
    for (const fin of finAccountsData) {
      const finType =
        fin.type === 'EXPENSE' ? FinancialType.EXPENSE : FinancialType.REVENUE;
      const finAcc = await (prisma as any).financialAccountNumber.upsert({
        where: {
          churchId_accountNumber: {
            churchId: church.id,
            accountNumber: fin.accountNumber,
          },
        },
        update: {
          description: fin.description,
          type: finType,
        },
        create: {
          accountNumber: fin.accountNumber,
          description: fin.description,
          type: finType,
          churchId: church.id,
        },
      });
      financialAccounts.push({
        id: finAcc.id,
        churchId: church.id,
        type: finType === FinancialType.EXPENSE ? 'expense' : 'income',
        name: fin.description || fin.accountNumber,
      });
      churchFinCount++;
    }

    if (cong.columns && Array.isArray(cong.columns)) {
      churchColCount = cong.columns.length;
      for (const col of cong.columns) {
        const column = await prisma.column.upsert({
          where: { sourceColumnId: col.id },
          update: { name: col.name, churchId: church.id },
          create: {
            sourceColumnId: col.id,
            name: col.name,
            churchId: church.id,
          },
        });
        churchWithCols.columns.push({ id: column.id, name: column.name });

        if (col.memberships && Array.isArray(col.memberships)) {
          churchMemberCount += col.memberships.length;
          for (const mem of col.memberships) {
            const accData = mem.account;
            let accountId = mem.accountId;
            let accountPhone = '081111111111';
            let dbAccount = null;

            if (accData) {
              const dobStr = accData.dob || '1990-01-01T00:00:00.000Z';
              accountPhone = accData.phone;
              dbAccount = await prisma.account.findUnique({
                where: { phone: accountPhone },
              });

              if (!dbAccount) {
                dbAccount = await prisma.account.create({
                  data: {
                    name: accData.name,
                    phone: accData.phone,
                    email: accData.email || null,
                    role: accData.role,
                    gender: accData.gender,
                    maritalStatus: accData.maritalStatus,
                    dob: new Date(dobStr),
                    passwordHash,
                    claimed: true,
                    isActive: true,
                  },
                });
              }
              accountId = dbAccount.id;
              if (!mainAccounts.find((a) => a.id === dbAccount!.id)) {
                mainAccounts.push({
                  id: dbAccount!.id,
                  phone: dbAccount!.phone!,
                });
              }
            }

            if (accountId) {
              const membership = await prisma.membership.create({
                data: {
                  accountId,
                  churchId: church.id,
                  columnId: column.id,
                  baptize: mem.baptize || false,
                  sidi: mem.sidi || false,
                },
              });
              mainMemberships.push({
                id: membership.id,
                churchId: church.id,
                accountPhone,
              });

              if (
                mem.membershipPositions &&
                Array.isArray(mem.membershipPositions)
              ) {
                churchPositionCount += mem.membershipPositions.length;
                for (const pos of mem.membershipPositions) {
                  await prisma.membershipPosition.create({
                    data: {
                      name: pos.name,
                      membershipId: membership.id,
                      churchId: church.id,
                    },
                  });
                }
              }
            }
          }
        }
      }
    }
    createdChurches.push(churchWithCols);
    console.log(
      ` done ` +
        `(${churchColCount} cols, ${churchMemberCount} members, ` +
        `${churchPositionCount} positions, ${churchFinCount} fin-accounts)`,
    );
  }

  console.log(`\n   ✅ Congregation seeding complete:`);
  console.log(`      Churches   : ${createdChurches.length}`);
  console.log(
    `      Memberships: ${mainMemberships.length} (with linked accounts)`,
  );
  console.log(
    `      Fin accounts: ${financialAccounts.length} total across all churches`,
  );

  return { createdChurches, mainMemberships, financialAccounts, mainAccounts };
}

interface ApprovalRuleSpec {
  name: string;
  description: string;
  active: boolean;
  activityType: ActivityType | null;
  financialType: FinancialType | null;
  positionName: string;
}

function loadApprovalRuleSpecs(): ApprovalRuleSpec[] {
  const jsonPath = path.resolve(
    __dirname,
    '..',
    '..',
    '..',
    'docs',
    'approval_rules.json',
  );
  const raw = fs.readFileSync(jsonPath, 'utf-8');
  const parsed = JSON.parse(raw) as unknown;
  if (!Array.isArray(parsed)) {
    throw new Error('docs/approval_rules.json must contain a top-level array');
  }
  return (parsed as any[]).map((entry, i) => {
    const ctx = `approval_rules.json[${i}]`;
    if (typeof entry.name !== 'string' || entry.name.trim().length === 0) {
      throw new Error(`Missing or invalid 'name' at ${ctx}`);
    }
    if (
      typeof entry.positionName !== 'string' ||
      entry.positionName.trim().length === 0
    ) {
      throw new Error(`Missing or invalid 'positionName' at ${ctx}`);
    }
    const activityType = entry.activityType
      ? (ActivityType[entry.activityType as keyof typeof ActivityType] ?? null)
      : null;
    if (entry.activityType && !activityType) {
      throw new Error(`Unknown activityType '${entry.activityType}' at ${ctx}`);
    }
    const financialType = entry.financialType
      ? (FinancialType[entry.financialType as keyof typeof FinancialType] ??
        null)
      : null;
    if (entry.financialType && !financialType) {
      throw new Error(
        `Unknown financialType '${entry.financialType}' at ${ctx}`,
      );
    }
    return {
      name: entry.name.trim(),
      description:
        typeof entry.description === 'string' ? entry.description.trim() : '',
      active: entry.active !== false,
      activityType,
      financialType,
      positionName: entry.positionName.trim(),
    } satisfies ApprovalRuleSpec;
  });
}

async function seedApprovalRules(churches: ChurchWithColumns[]) {
  const specs = loadApprovalRuleSpecs();
  console.log(
    `\n📜 Creating approval rules from docs/approval_rules.json (${specs.length} specs × ${churches.length} churches)...`,
  );

  const approvalRules = [];
  let skippedCount = 0;

  for (const church of churches) {
    let churchCreated = 0;
    let churchSkipped = 0;

    for (const spec of specs) {
      const position = await prisma.membershipPosition.findFirst({
        where: { churchId: church.id, name: spec.positionName },
      });

      if (!position) {
        console.warn(
          `   ⚠️  Position "${spec.positionName}" not found in ${church.name} — skipping "${spec.name}"`,
        );
        churchSkipped++;
        skippedCount++;
        continue;
      }

      const rule = await prisma.approvalRule.create({
        data: {
          name: spec.name,
          description: `${spec.description} di ${church.name}`,
          active: spec.active,
          churchId: church.id,
          activityType: spec.activityType,
          financialType: spec.financialType,
          positions: { connect: [{ id: position.id }] },
        } as any,
        include: { positions: true },
      });

      approvalRules.push(rule);
      churchCreated++;
    }

    if (churchCreated > 0) {
      console.log(
        `   ✔  ${church.name}: ${churchCreated} rules created` +
          (churchSkipped > 0 ? `, ${churchSkipped} skipped` : ''),
      );
    }
  }

  console.log(
    `\n   ✅ Approval rules: ${approvalRules.length} created, ${skippedCount} skipped (missing positions)`,
  );
  return approvalRules;
}

/**
 * Resolves approvers for an activity based on the canonical rule model.
 *
 * Priority (first match wins):
 * 1. activityType + bipra  (SERVICE rules scoped to a bipra group)
 * 2. activityType only     (bipra IS NULL)
 * 3. Generic fallback      (no activityType AND no financialType)
 */
async function resolveApproversForSeeder(
  churchId: number,
  activityType: ActivityType,
  bipra?: Bipra | null,
): Promise<number[]> {
  const positionIds = new Set<number>();

  const addPositions = (rules: any[]) => {
    for (const rule of rules) {
      for (const pos of rule.positions) positionIds.add(pos.id);
    }
  };

  // 1. bipra-specific rules
  if (bipra) {
    const bipraRules = await prisma.approvalRule.findMany({
      where: { churchId, activityType, bipra, active: true } as any,
      include: { positions: { select: { id: true } } },
    });
    if (bipraRules.length > 0) {
      addPositions(bipraRules);
    }
  }

  // 2. activityType-only rules (bipra IS NULL)
  if (positionIds.size === 0) {
    const typeRules = await prisma.approvalRule.findMany({
      where: { churchId, activityType, bipra: null, active: true } as any,
      include: { positions: { select: { id: true } } },
    });
    addPositions(typeRules);
  }

  // 3. Generic fallback
  if (positionIds.size === 0) {
    const genericRules = await prisma.approvalRule.findMany({
      where: {
        churchId,
        activityType: null,
        financialType: null,
        active: true,
      } as any,
      include: { positions: { select: { id: true } } },
    });
    addPositions(genericRules);
  }

  if (positionIds.size === 0) return [];

  const memberships = await prisma.membership.findMany({
    where: {
      churchId,
      membershipPositions: { some: { id: { in: Array.from(positionIds) } } },
    },
    select: { id: true },
  });

  return memberships.map((m) => m.id);
}

async function resolveFinanceApproversForSeeder(
  churchId: number,
  financialType: FinancialType,
): Promise<number[]> {
  const rules = await prisma.approvalRule.findMany({
    where: {
      churchId,
      financialType,
      active: true,
    } as any,
    include: {
      positions: { select: { id: true } },
    },
  });

  const positionIds = new Set<number>();
  for (const rule of rules) {
    for (const pos of (rule as any).positions) {
      positionIds.add(pos.id);
    }
  }

  if (positionIds.size === 0) return [];

  const memberships = await prisma.membership.findMany({
    where: {
      churchId,
      membershipPositions: { some: { id: { in: Array.from(positionIds) } } },
    },
    select: { id: true },
  });

  return memberships.map((m) => m.id);
}

/**
 * Financial type for activity: 'revenue', 'expense', or 'none'
 * An activity can only have ONE financial type (revenue OR expense), never both.
 */
type ActivityFinancialType = 'revenue' | 'expense' | 'none';

async function createActivityWithConnectedModels(
  supervisorId: number,
  churchId: number,
  activityType: ActivityType,
  bipra: Bipra | null,
  index: number,
  financialAccounts: FinancialAccountWithType[],
  financialType: ActivityFinancialType,
  dateOverride?: Date,
  forceAllApproversApproved?: boolean,
  linkedDocumentId?: number,
) {
  const baseActivityData = generateActivityData(activityType, bipra, index);
  const activityData = dateOverride
    ? { ...baseActivityData, date: dateOverride }
    : baseActivityData;

  // Create location (70% chance)
  let locationId: number | null = null;
  if (randomBoolean(0.7)) {
    const location = await prisma.location.create({
      data: {
        name: `Lokasi ${activityData.title}`,
        latitude: generateLatitude(),
        longitude: generateLongitude(),
      },
    });
    locationId = location.id;
  }

  const supervisorMembership = await prisma.membership.findUnique({
    where: { id: supervisorId },
    select: { columnId: true },
  });
  const shouldBeColumnOnly =
    supervisorMembership?.columnId != null && randomBoolean(0.35);

  const activity = await (prisma as any).activity.create({
    data: {
      ...activityData,
      supervisorId,
      locationId,
      columnId: shouldBeColumnOnly ? supervisorMembership!.columnId : null,
    },
  });

  if (linkedDocumentId) {
    await (prisma as any).document.update({
      where: { id: linkedDocumentId },
      data: { activityId: activity.id },
    });
  }

  // Determine financial data for approver resolution
  let revenueFinancialAccountId: number | undefined;
  let expenseFinancialAccountId: number | undefined;
  let revenueId: number | undefined;
  let expenseId: number | undefined;

  // Get church-specific financial accounts
  const churchIncomeAccounts = financialAccounts.filter(
    (fa) => fa.churchId === churchId && fa.type === 'income',
  );
  const churchExpenseAccounts = financialAccounts.filter(
    (fa) => fa.churchId === churchId && fa.type === 'expense',
  );

  // Add revenue if specified (for SERVICE and EVENT types only)
  if (
    financialType === 'revenue' &&
    activityType !== ActivityType.ANNOUNCEMENT
  ) {
    // Select a financial account for this revenue
    const selectedAccount =
      churchIncomeAccounts.length > 0
        ? churchIncomeAccounts[index % churchIncomeAccounts.length]
        : null;
    revenueFinancialAccountId = selectedAccount?.id;

    const revenue = await prisma.revenue.create({
      data: {
        accountNumber: `${Math.floor(1000000000 + seededRandom() * 9000000000)}`,
        amount: Math.floor(seededRandom() * 3000000) + 500000,
        churchId,
        activityId: activity.id,
        paymentMethod: PAYMENT_METHODS[index % PAYMENT_METHODS.length],
        financialAccountNumberId: revenueFinancialAccountId,
      },
    });
    revenueId = revenue.id;
  }

  // Add expense if specified (for EVENT types primarily)
  if (financialType === 'expense' && activityType === ActivityType.EVENT) {
    // Select a financial account for this expense
    const selectedAccount =
      churchExpenseAccounts.length > 0
        ? churchExpenseAccounts[index % churchExpenseAccounts.length]
        : null;
    expenseFinancialAccountId = selectedAccount?.id;

    const expense = await prisma.expense.create({
      data: {
        accountNumber: `${Math.floor(1000000000 + seededRandom() * 9000000000)}`,
        amount: Math.floor(seededRandom() * 2000000) + 300000,
        churchId,
        activityId: activity.id,
        paymentMethod: PAYMENT_METHODS[index % PAYMENT_METHODS.length],
        financialAccountNumberId: expenseFinancialAccountId,
      },
    });
    expenseId = expense.id;
  }

  // Resolve approvers using the automatic approver linking logic
  let approverMembershipIds = await resolveApproversForSeeder(
    churchId,
    activityType,
    bipra,
  );

  if (forceAllApproversApproved && approverMembershipIds.length === 0) {
    approverMembershipIds = [supervisorId];
  }

  // Create approver records with varying statuses
  for (let i = 0; i < approverMembershipIds.length; i++) {
    const membershipId = approverMembershipIds[i];
    await prisma.approver.create({
      data: {
        activityId: activity.id,
        membershipId,
        status: forceAllApproversApproved
          ? ApprovalStatus.APPROVED
          : APPROVAL_STATUSES[i % APPROVAL_STATUSES.length],
      },
    });
  }

  if (financialType === 'revenue' && revenueId) {
    let revenueApproverMembershipIds = await resolveFinanceApproversForSeeder(
      churchId,
      FinancialType.REVENUE,
    );

    if (
      forceAllApproversApproved &&
      revenueApproverMembershipIds.length === 0
    ) {
      revenueApproverMembershipIds = [supervisorId];
    }

    for (let i = 0; i < revenueApproverMembershipIds.length; i++) {
      const membershipId = revenueApproverMembershipIds[i];
      await (prisma as any).revenueApprover.create({
        data: {
          revenueId,
          membershipId,
          status: forceAllApproversApproved
            ? ApprovalStatus.APPROVED
            : APPROVAL_STATUSES[i % APPROVAL_STATUSES.length],
        },
      });
    }
  }

  if (financialType === 'expense' && expenseId) {
    let expenseApproverMembershipIds = await resolveFinanceApproversForSeeder(
      churchId,
      FinancialType.EXPENSE,
    );

    if (
      forceAllApproversApproved &&
      expenseApproverMembershipIds.length === 0
    ) {
      expenseApproverMembershipIds = [supervisorId];
    }

    for (let i = 0; i < expenseApproverMembershipIds.length; i++) {
      const membershipId = expenseApproverMembershipIds[i];
      await (prisma as any).expenseApprover.create({
        data: {
          expenseId,
          membershipId,
          status: forceAllApproversApproved
            ? ApprovalStatus.APPROVED
            : APPROVAL_STATUSES[i % APPROVAL_STATUSES.length],
        },
      });
    }
  }

  return activity;
}

async function seedMainAccountActivities(
  mainMemberships: MembershipWithChurch[],
  financialAccounts: FinancialAccountWithType[],
  documents: { id: number; churchId: number }[],
) {
  const totalActivities =
    mainMemberships.length * CONFIG.activitiesPerMainAccount;
  console.log(
    `\n📅 Seeding activities for ${mainMemberships.length} main account(s) ` +
      `(${CONFIG.activitiesPerMainAccount} each = ~${totalActivities} total)...`,
  );

  const activities = [];
  const variations = getAllActivityVariations(); // 15 variations
  console.log(
    `   Activity variations: ${variations.length} (types × bipra groups)`,
  );
  let globalIndex = 0;

  // Financial type cycle: revenue, expense, none (an activity can only have one)
  const financialTypes: ActivityFinancialType[] = [
    'revenue',
    'expense',
    'none',
  ];

  for (const mainMembership of mainMemberships) {
    console.log(
      `\n   👤 Main account [${mainMembership.accountPhone}] ` +
        `(membership #${mainMembership.id}, church #${mainMembership.churchId})`,
    );
    console.log(
      `      Creating ${CONFIG.activitiesPerMainAccount} activities...`,
    );

    const weekDates = getCurrentWeekDates();
    const weekDateOverrideMap = getWeekDateOverrideMapForActivityVariations(
      variations,
      weekDates,
    );

    // First 15 activities: cover all variations (3 types × 5 bipras)
    for (let i = 0; i < variations.length; i++) {
      const variation = variations[i];
      // Cycle through financial types: revenue, expense, none
      const financialType = financialTypes[i % financialTypes.length];

      const dateOverride = weekDateOverrideMap.get(i);
      const forceAllApproversApproved = true;

      const doc =
        variation.type === ActivityType.ANNOUNCEMENT &&
        documents.length > 0 &&
        randomBoolean(0.3)
          ? randomElement(
              documents.filter((d) => d.churchId === mainMembership.churchId),
            )
          : undefined;

      const activity = await createActivityWithConnectedModels(
        mainMembership.id,
        mainMembership.churchId,
        variation.type,
        variation.bipra,
        globalIndex,
        financialAccounts,
        financialType,
        dateOverride,
        forceAllApproversApproved,
        doc?.id,
      );

      activities.push({
        ...activity,
        churchId: mainMembership.churchId,
        isMainAccount: true,
      });
      globalIndex++;
    }

    // Next 10 activities: additional variations to reach 25 total
    for (let i = 0; i < 10; i++) {
      const variation = variations[i % variations.length];
      // Cycle through financial types: revenue, expense, none
      const financialType = financialTypes[i % financialTypes.length];

      const doc =
        variation.type === ActivityType.ANNOUNCEMENT &&
        documents.length > 0 &&
        randomBoolean(0.3)
          ? randomElement(
              documents.filter((d) => d.churchId === mainMembership.churchId),
            )
          : undefined;

      const activity = await createActivityWithConnectedModels(
        mainMembership.id,
        mainMembership.churchId,
        variation.type,
        variation.bipra,
        globalIndex,
        financialAccounts,
        financialType,
        undefined,
        undefined,
        doc?.id,
      );

      activities.push({
        ...activity,
        churchId: mainMembership.churchId,
        isMainAccount: true,
      });
      globalIndex++;
    }

    console.log(
      `      ✔ Done — ${CONFIG.activitiesPerMainAccount} activities created for this account`,
    );
  }

  console.log(`\n   ✅ Main account activities: ${activities.length} total`);
  return activities;
}

async function seedExtraChurchActivities(
  mainChurches: ChurchWithColumns[],
  extraMemberships: MembershipWithChurch[],
  financialAccounts: FinancialAccountWithType[],
  documents: { id: number; churchId: number }[],
) {
  console.log(
    '📅 Creating extra activities for churches (25 each, not connected to main accounts)...',
  );

  const activities = [];
  const variations = getAllActivityVariations();
  let globalIndex = 1000;

  // Financial type cycle: revenue, expense, none (an activity can only have one)
  const financialTypes: ActivityFinancialType[] = [
    'revenue',
    'expense',
    'none',
  ];

  for (const church of mainChurches) {
    // Get extra members (not the main account) to be supervisors
    const churchExtraMembers = extraMemberships.filter(
      (m) => m.churchId === church.id,
    );

    if (churchExtraMembers.length === 0) {
      console.log(`   Skipping church ${church.name} - no extra members`);
      continue;
    }

    console.log(`   Creating 25 extra activities for ${church.name}...`);

    const weekDates = getCurrentWeekDates();
    const weekDateOverrideMap = getWeekDateOverrideMapForActivityVariations(
      variations,
      weekDates,
    );

    // First 15 activities: cover all variations
    for (let i = 0; i < variations.length; i++) {
      const variation = variations[i];
      const supervisorIndex = i % churchExtraMembers.length;
      const supervisor = churchExtraMembers[supervisorIndex];

      // Cycle through financial types: revenue, expense, none
      const financialType = financialTypes[i % financialTypes.length];

      const dateOverride = weekDateOverrideMap.get(i);
      const forceAllApproversApproved = true;

      const doc =
        variation.type === ActivityType.ANNOUNCEMENT &&
        documents.length > 0 &&
        randomBoolean(0.3)
          ? randomElement(documents.filter((d) => d.churchId === church.id))
          : undefined;

      const activity = await createActivityWithConnectedModels(
        supervisor.id,
        church.id,
        variation.type,
        variation.bipra,
        globalIndex,
        financialAccounts,
        financialType,
        dateOverride,
        forceAllApproversApproved,
        doc?.id,
      );

      activities.push({
        ...activity,
        churchId: church.id,
        isMainAccount: false,
      });
      globalIndex++;
    }

    // Next 10 activities: additional variations
    for (let i = 0; i < 10; i++) {
      const variation = variations[i % variations.length];
      const supervisorIndex = (i + 5) % churchExtraMembers.length;
      const supervisor = churchExtraMembers[supervisorIndex];

      // Cycle through financial types: revenue, expense, none
      const financialType = financialTypes[i % financialTypes.length];

      const doc =
        variation.type === ActivityType.ANNOUNCEMENT &&
        documents.length > 0 &&
        randomBoolean(0.3)
          ? randomElement(documents.filter((d) => d.churchId === church.id))
          : undefined;

      const activity = await createActivityWithConnectedModels(
        supervisor.id,
        church.id,
        variation.type,
        variation.bipra,
        globalIndex,
        financialAccounts,
        financialType,
        undefined,
        undefined,
        doc?.id,
      );

      activities.push({
        ...activity,
        churchId: church.id,
        isMainAccount: false,
      });
      globalIndex++;
    }
  }

  console.log(`✅ Created ${activities.length} extra activities for churches`);
  return activities;
}

async function seedSongs() {
  console.log('\n🎵 Seeding songs from songs.json...');

  const songsJsonPath = path.resolve(
    __dirname,
    '..',
    '..',
    '..',
    'docs',
    'songs.json',
  );

  console.log(`   📂 Reading songs.json...`);
  console.log(`      Path: ${songsJsonPath}`);

  if (!fs.existsSync(songsJsonPath)) {
    console.warn(`   ⚠️  songs.json not found — skipping song seeding.`);
    return [];
  }

  const rawContent = fs.readFileSync(songsJsonPath, 'utf-8');
  console.log(`      File size: ${(rawContent.length / 1024).toFixed(1)} KB`);
  const songsData = JSON.parse(rawContent);
  const rawSongs = songsData.songs || [];
  const totalParts = rawSongs.reduce(
    (sum: number, s: any) => sum + (s.definition?.length || 0),
    0,
  );
  console.log(
    `      ✔ Loaded ${rawSongs.length} songs, ${totalParts} parts total ` +
      `(avg ${rawSongs.length ? (totalParts / rawSongs.length).toFixed(1) : 0} parts/song)`,
  );

  const songs = [];

  console.log(`\n   ⏳ Inserting songs into database...`);

  for (let i = 0; i < rawSongs.length; i++) {
    const rawSong = rawSongs[i];
    const book = rawSong.bookId.toUpperCase() as Book;

    const indexMatch = String(rawSong.id).match(/\d+/);
    const index = indexMatch ? parseInt(indexMatch[0], 10) : 0;

    const title = rawSong.subTitle
      ? `${rawSong.title} - ${rawSong.subTitle}`
      : rawSong.title;

    let partIndex = 1;
    const partsToCreate = (rawSong.definition || []).map((def: any) => ({
      index: partIndex++,
      name: def.type || 'VERSE',
      content: def.content || '',
    }));

    process.stdout.write(
      `   [${String(i + 1).padStart(4, ' ')}/${rawSongs.length}] ` +
        `${book} #${index} — "${title.substring(0, 40)}${title.length > 40 ? '…' : ''}" ` +
        `(${partsToCreate.length} parts)\r`,
    );

    const song = await prisma.song.create({
      data: {
        title,
        index,
        book,
        link:
          rawSong.urlVideo ||
          rawSong.urlImage ||
          `https://example.com/song/${book.toLowerCase()}-${index}`,
        parts: {
          create: partsToCreate,
        },
      },
      include: { parts: true },
    });

    songs.push(song);
  }

  const totalInsertedParts = songs.reduce((sum, s) => sum + s.parts.length, 0);
  console.log(
    `\n   ✅ Songs: ${songs.length} songs, ${totalInsertedParts} parts inserted`,
  );
  return songs;
}

async function seedSongDbFile(churches: ChurchWithColumns[]) {
  const rawId = process.env.SONG_DB_FILE_ID;
  if (!rawId || rawId.trim().length === 0) {
    console.log('ℹ️ SONG_DB_FILE_ID is not set; skipping song DB file seed');
    return null;
  }
  const fileId = Number(rawId);
  if (!Number.isFinite(fileId)) {
    console.log(
      '⚠️ SONG_DB_FILE_ID is not a valid number; skipping song DB file seed',
    );
    return null;
  }

  const churchId = churches?.[0]?.id;
  if (!churchId) {
    throw new Error('No churches available to attach song DB file');
  }

  const bucket = process.env.FIREBASE_STORAGE_BUCKET ?? 'seed-bucket';
  const originalName = 'songs.json';
  const storagePath = 'db/songs.json';
  const localTemplatePath = path.resolve(
    __dirname,
    '..',
    '..',
    '..',
    'docs',
    originalName,
  );

  let sizeInKB = 1;
  try {
    const buf = fs.readFileSync(localTemplatePath);
    sizeInKB = Math.max(0.01, parseFloat((buf.byteLength / 1024).toFixed(2)));
  } catch {
    console.log(
      `⚠️ Song DB template not found at ${localTemplatePath}. Record will be seeded with sizeInKB=${sizeInKB}.`,
    );
  }

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
  } catch {}

  console.log('✅ Seeded Song DB FileManager record');
  console.log(`   id=${file.id} bucket=${bucket} path=${storagePath}`);
  console.log(
    `   Upload template file to Firebase Storage: ${bucket}/${storagePath} (template: ${localTemplatePath})`,
  );

  return file;
}

async function printSummary(
  mainAccounts: { id: number; phone: string }[],
  mainChurches: ChurchWithColumns[],
) {
  console.log('\n📊 Seed Summary:');
  console.log('================');
  console.log(`🏛️  Churches: ${await prisma.church.count()}`);
  console.log(`👤 Accounts: ${await prisma.account.count()}`);
  console.log(`🤝 Memberships: ${await prisma.membership.count()}`);
  console.log(
    `📋 Membership Positions: ${await prisma.membershipPosition.count()}`,
  );
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const p = prisma as any;
  console.log(`📜 Approval Rules: ${await prisma.approvalRule.count()}`);
  console.log(`📅 Activities: ${await prisma.activity.count()}`);
  console.log(`✔️  Approvers: ${await prisma.approver.count()}`);
  console.log(`💰 Revenues: ${await prisma.revenue.count()}`);
  console.log(`💸 Expenses: ${await prisma.expense.count()}`);
  console.log(`🎵 Songs: ${await prisma.song.count()}`);
  console.log(
    `💳 Financial Account Numbers: ${await p.financialAccountNumber.count()}`,
  );

  console.log('\n👤 Main Accounts:');
  console.log('================');
  for (const account of mainAccounts) {
    const membership = await prisma.membership.findUnique({
      where: { accountId: account.id },
      include: { church: true },
    });
    const activityCount = membership
      ? await prisma.activity.count({
          where: { supervisorId: membership.id },
        })
      : 0;
    console.log(`   Phone: ${account.phone}`);
    console.log(`   Church: ${membership?.church?.name}`);
    console.log(`   Activities supervised: ${activityCount}`);
    console.log('');
  }

  console.log('🏛️  Main Churches Activity Summary:');
  console.log('================');
  for (const church of mainChurches) {
    const totalActivities = await prisma.activity.count({
      where: { supervisor: { churchId: church.id } },
    });

    const mainMembership = await prisma.membership.findFirst({
      where: {
        churchId: church.id,
        account: { phone: { in: mainAccounts.map((a) => a.phone) } },
      },
    });

    const mainAccountActivities = mainMembership
      ? await prisma.activity.count({
          where: { supervisorId: mainMembership.id },
        })
      : 0;

    const extraActivities = totalActivities - mainAccountActivities;

    console.log(`   ${church.name}:`);
    console.log(`     Total activities: ${totalActivities}`);
    console.log(`     Main account activities: ${mainAccountActivities}`);
    console.log(`     Extra activities: ${extraActivities}`);
  }

  console.log('\n📋 Activity Type Coverage:');
  const activityTypeCounts = await prisma.activity.groupBy({
    by: ['activityType'],
    _count: true,
  });
  console.log('   ', activityTypeCounts);

  console.log('\n📋 Bipra Coverage:');
  const bipraCounts = await prisma.activity.groupBy({
    by: ['bipra'],
    _count: true,
  });
  console.log('   ', bipraCounts);

  console.log('\n📋 Approval Status Coverage:');
  const approverStatusCounts = await prisma.approver.groupBy({
    by: ['status'],
    _count: true,
  });
  console.log('   ', approverStatusCounts);

  console.log('\n📋 Payment Method Coverage (Revenue):');
  const revenuePaymentCounts = await prisma.revenue.groupBy({
    by: ['paymentMethod'],
    _count: true,
  });
  console.log('   ', revenuePaymentCounts);

  console.log('\n📋 Payment Method Coverage (Expense):');
  const expensePaymentCounts = await prisma.expense.groupBy({
    by: ['paymentMethod'],
    _count: true,
  });
  console.log('   ', expensePaymentCounts);
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

  const seedStart = Date.now();

  console.log('╔══════════════════════════════════════════════════════╗');
  console.log('║           🌱 PALAKAT — Comprehensive Seed            ║');
  console.log('╚══════════════════════════════════════════════════════╝');
  console.log(
    `   DB  : ${process.env.DATABASE_URL?.replace(/:\/\/[^@]+@/, '://<credentials>@') ?? '(not set)'}`,
  );
  console.log(`   Time: ${new Date().toISOString()}`);
  console.log(`   Env : ${process.env.NODE_ENV ?? 'unset'}`);
  if (CONGREGATION_SEED_LIMIT != null) {
    console.log(
      `   Limit: first ${CONGREGATION_SEED_LIMIT} congregations via CONGREGATION_SEED_LIMIT`,
    );
  }
  console.log('');

  const phase = (name: string) => {
    const t = Date.now();
    console.log(`\n${'─'.repeat(56)}`);
    console.log(`  Phase: ${name}`);
    console.log(`${'─'.repeat(56)}`);
    return () => {
      const elapsed = ((Date.now() - t) / 1000).toFixed(1);
      console.log(`  ✓ ${name} completed in ${elapsed}s`);
    };
  };

  try {
    seed = 12345;

    // Always push the schema first so tables exist regardless of migration state.
    // This is safe for local/dev: it's a no-op when the DB is already in sync.
    const doneSync = phase('Sync schema (db push)');
    const { execSync } = await import('node:child_process');
    execSync('./node_modules/.bin/prisma db push --accept-data-loss', {
      stdio: 'inherit',
      env: { ...process.env },
    });
    doneSync();

    const doneClean = phase('Clean database');
    await cleanDatabase();
    doneClean();

    const passwordHash = await bcrypt.hash(CONFIG.defaultPassword, 12);

    const doneCong = phase('Congregations + financial accounts (JSON)');
    const {
      createdChurches: mainChurches,
      mainMemberships,
      financialAccounts,
      mainAccounts,
    } = await seedCongregationsAndFinances(passwordHash);
    doneCong();

    const extraMemberships: MembershipWithChurch[] = [];

    const doneRules = phase('Approval rules');
    await seedApprovalRules(mainChurches);
    doneRules();

    const doneMainActs = phase('Main account activities');
    await seedMainAccountActivities(mainMemberships, financialAccounts, []);
    doneMainActs();

    const doneExtraActs = phase('Extra church activities');
    await seedExtraChurchActivities(
      mainChurches,
      extraMemberships,
      financialAccounts,
      [],
    );
    doneExtraActs();

    const doneSongs = phase('Songs (JSON)');
    await seedSongs();
    doneSongs();

    const doneArticles = phase('Articles');
    await seedArticles();
    doneArticles();

    const doneSongDb = phase('Song DB file record');
    await seedSongDbFile(mainChurches);
    doneSongDb();

    const doneSummary = phase('Database summary');
    await printSummary(mainAccounts, mainChurches);
    doneSummary();

    const totalElapsed = ((Date.now() - seedStart) / 1000).toFixed(1);
    console.log('');
    console.log('╔══════════════════════════════════════════════════════╗');
    console.log(
      `║  🎉 Seed completed successfully in ${totalElapsed.padStart(6, ' ')}s          ║`,
    );
    console.log('╚══════════════════════════════════════════════════════╝');
  } catch (error) {
    const totalElapsed = ((Date.now() - seedStart) / 1000).toFixed(1);
    console.error(`\n❌ Seeding failed after ${totalElapsed}s:`, error);
    throw error;
  }
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
    await pool.end();
  });
