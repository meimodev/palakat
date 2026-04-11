import 'dotenv/config';
import { PrismaPg } from '@prisma/adapter-pg';
import { Pool } from 'pg';
import * as fs from 'node:fs';
import * as path from 'node:path';
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
  // Use type assertion to handle Prisma client types that may not be regenerated yet
  const p = prisma as any;
  await prisma.$transaction([
    p.articleLike.deleteMany(),
    p.article.deleteMany(),
    prisma.approver.deleteMany(),
    (prisma as any).revenueApprover.deleteMany(),
    (prisma as any).expenseApprover.deleteMany(),
    prisma.revenue.deleteMany(),
    prisma.expense.deleteMany(),
    p.financialAccountNumber.deleteMany(),
    prisma.activity.deleteMany(),
    p.reportJob.deleteMany(),
    prisma.report.deleteMany(),
    prisma.document.deleteMany(),
    prisma.fileManager.deleteMany(),
    prisma.songPart.deleteMany(),
    prisma.song.deleteMany(),
    prisma.approvalRule.deleteMany(),
    prisma.membershipPosition.deleteMany(),
    p.membershipInvitation.deleteMany(),
    prisma.membership.deleteMany(),
    prisma.churchRequest.deleteMany(),
    prisma.column.deleteMany(),
    prisma.church.deleteMany(),
    prisma.account.deleteMany(),
    prisma.location.deleteMany(),
  ]);
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
  console.log('🏛️ Seeding congregations and financial accounts from JSON...');

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

  const congregations = JSON.parse(fs.readFileSync(congJsonPath, 'utf-8'));
  const finAccountsData = JSON.parse(fs.readFileSync(finJsonPath, 'utf-8'));

  const createdChurches: ChurchWithColumns[] = [];
  const mainMemberships: MembershipWithChurch[] = [];
  const financialAccounts: FinancialAccountWithType[] = [];
  const mainAccounts: { id: number; phone: string }[] = [];

  for (const cong of congregations) {
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

    for (const fin of finAccountsData) {
      const finType =
        fin.type === 'EXPENSE' ? FinancialType.EXPENSE : FinancialType.REVENUE;
      const finAcc = await (prisma as any).financialAccountNumber.create({
        data: {
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
    }

    if (cong.columns && Array.isArray(cong.columns)) {
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
                for (const pos of mem.membershipPositions) {
                  await prisma.membershipPosition.create({
                    data: {
                      name: pos.name,
                      membershipId: membership.id,
                      churchId: church.id,
                      approvalRuleId: null,
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
  }

  return { createdChurches, mainMemberships, financialAccounts, mainAccounts };
}

/**
 * Defines all approval rule variations to be seeded.
 * Each variation represents a different combination of activityType, financialType,
 * and whether a specific financial account should be linked.
 *
 * Rule Types:
 * 1. Generic (fallback) - no filters, catches all unmatched activities
 * 2. Activity Type Only - SERVICE, EVENT, ANNOUNCEMENT
 * 3. Financial Type Only - REVENUE, EXPENSE (without specific account)
 * 4. Financial Type + Account - REVENUE/EXPENSE with specific account
 * 5. Activity Type + Financial Type - combinations for specific scenarios
 */
interface ApprovalRuleVariation {
  name: string;
  description: string;
  activityType: ActivityType | null;
  financialType: FinancialType | null;
  needsFinancialAccount: boolean;
  financialAccountType?: 'income' | 'expense';
  active: boolean;
}

const APPROVAL_RULE_VARIATIONS: ApprovalRuleVariation[] = [
  // 1. Generic fallback rule (catches all unmatched activities)
  {
    name: 'Persetujuan Umum',
    description:
      'Aturan persetujuan umum untuk semua kegiatan tanpa aturan khusus',
    activityType: null,
    financialType: null,
    needsFinancialAccount: false,
    active: true,
  },

  // 2. Activity Type Only rules
  {
    name: 'Persetujuan Ibadah',
    description: 'Aturan persetujuan untuk kegiatan ibadah/pelayanan',
    activityType: ActivityType.SERVICE,
    financialType: null,
    needsFinancialAccount: false,
    active: true,
  },
  {
    name: 'Persetujuan Acara',
    description: 'Aturan persetujuan untuk acara dan kegiatan khusus',
    activityType: ActivityType.EVENT,
    financialType: null,
    needsFinancialAccount: false,
    active: true,
  },
  {
    name: 'Persetujuan Pengumuman',
    description: 'Aturan persetujuan untuk pengumuman gereja',
    activityType: ActivityType.ANNOUNCEMENT,
    financialType: null,
    needsFinancialAccount: false,
    active: true,
  },

  // 3. Financial Type Only rules (without specific account)
  {
    name: 'Persetujuan Pendapatan Umum',
    description: 'Aturan persetujuan untuk semua pendapatan tanpa akun khusus',
    activityType: null,
    financialType: FinancialType.REVENUE,
    needsFinancialAccount: false,
    active: true,
  },
  {
    name: 'Persetujuan Pengeluaran Umum',
    description: 'Aturan persetujuan untuk semua pengeluaran tanpa akun khusus',
    activityType: null,
    financialType: FinancialType.EXPENSE,
    needsFinancialAccount: false,
    active: true,
  },

  // 4. Financial Type + Specific Account rules
  {
    name: 'Persetujuan Persembahan',
    description:
      'Aturan persetujuan untuk pendapatan persembahan dengan akun khusus',
    activityType: null,
    financialType: FinancialType.REVENUE,
    needsFinancialAccount: true,
    financialAccountType: 'income',
    active: true,
  },
  {
    name: 'Persetujuan Sumbangan',
    description:
      'Aturan persetujuan untuk pendapatan sumbangan dengan akun khusus',
    activityType: null,
    financialType: FinancialType.REVENUE,
    needsFinancialAccount: true,
    financialAccountType: 'income',
    active: true,
  },
  {
    name: 'Persetujuan Biaya Operasional',
    description:
      'Aturan persetujuan untuk pengeluaran operasional dengan akun khusus',
    activityType: null,
    financialType: FinancialType.EXPENSE,
    needsFinancialAccount: true,
    financialAccountType: 'expense',
    active: true,
  },
  {
    name: 'Persetujuan Biaya Pelayanan',
    description:
      'Aturan persetujuan untuk pengeluaran pelayanan dengan akun khusus',
    activityType: null,
    financialType: FinancialType.EXPENSE,
    needsFinancialAccount: true,
    financialAccountType: 'expense',
    active: true,
  },

  // 5. Activity Type + Financial Type combinations
  {
    name: 'Persetujuan Pendapatan Ibadah',
    description: 'Aturan persetujuan untuk pendapatan dari kegiatan ibadah',
    activityType: ActivityType.SERVICE,
    financialType: FinancialType.REVENUE,
    needsFinancialAccount: false,
    active: true,
  },
  {
    name: 'Persetujuan Pengeluaran Acara',
    description: 'Aturan persetujuan untuk pengeluaran acara khusus',
    activityType: ActivityType.EVENT,
    financialType: FinancialType.EXPENSE,
    needsFinancialAccount: false,
    active: true,
  },

  // 6. Inactive rules (for testing inactive rule filtering)
  {
    name: 'Persetujuan Lama (Tidak Aktif)',
    description: 'Aturan persetujuan lama yang sudah tidak aktif',
    activityType: ActivityType.SERVICE,
    financialType: null,
    needsFinancialAccount: false,
    active: false,
  },
  {
    name: 'Persetujuan Keuangan Lama (Tidak Aktif)',
    description: 'Aturan persetujuan keuangan lama yang sudah tidak aktif',
    activityType: null,
    financialType: FinancialType.REVENUE,
    needsFinancialAccount: true,
    financialAccountType: 'income',
    active: false,
  },
];

async function seedApprovalRules(
  churches: ChurchWithColumns[],
  financialAccounts: FinancialAccountWithType[],
) {
  console.log('📜 Creating approval rules (all variations)...');

  const approvalRules = [];

  // Track which financial accounts have been assigned to ensure uniqueness
  // This is required because financialAccountNumberId has a unique constraint
  const assignedFinancialAccountIds = new Set<number>();

  for (const church of churches) {
    console.log(`   Creating approval rules for ${church.name}...`);

    // Get all positions for this church that don't have an approval rule yet
    const churchPositions = await prisma.membershipPosition.findMany({
      where: { churchId: church.id, approvalRuleId: null },
    });

    if (churchPositions.length === 0) {
      console.log(`   Skipping ${church.name} - no positions available`);
      continue;
    }

    let incomeAccountIndex = 0;
    let expenseAccountIndex = 0;

    for (const variation of APPROVAL_RULE_VARIATIONS) {
      // Determine financial account if needed
      let financialAccountNumberId: number | null = null;
      let financialAccountName: string | null = null;

      if (variation.needsFinancialAccount) {
        if (variation.financialAccountType === 'income') {
          // Re-filter to get currently available accounts
          const availableAccounts = financialAccounts.filter(
            (fa) =>
              fa.churchId === church.id &&
              fa.type === 'income' &&
              !assignedFinancialAccountIds.has(fa.id),
          );
          if (availableAccounts.length > 0) {
            const account =
              availableAccounts[incomeAccountIndex % availableAccounts.length];
            financialAccountNumberId = account.id;
            financialAccountName = account.name;
            assignedFinancialAccountIds.add(financialAccountNumberId);
            incomeAccountIndex++;
          } else {
            // Skip this variation if no accounts available
            console.log(
              `   Skipping ${variation.name} - no income accounts available`,
            );
            continue;
          }
        } else if (variation.financialAccountType === 'expense') {
          // Re-filter to get currently available accounts
          const availableAccounts = financialAccounts.filter(
            (fa) =>
              fa.churchId === church.id &&
              fa.type === 'expense' &&
              !assignedFinancialAccountIds.has(fa.id),
          );
          if (availableAccounts.length > 0) {
            const account =
              availableAccounts[expenseAccountIndex % availableAccounts.length];
            financialAccountNumberId = account.id;
            financialAccountName = account.name;
            assignedFinancialAccountIds.add(financialAccountNumberId);
            expenseAccountIndex++;
          } else {
            // Skip this variation if no accounts available
            console.log(
              `   Skipping ${variation.name} - no expense accounts available`,
            );
            continue;
          }
        }
      }

      // Get available positions (not yet assigned to any rule)
      const availablePositions = await prisma.membershipPosition.findMany({
        where: { churchId: church.id, approvalRuleId: null },
      });

      if (availablePositions.length === 0) {
        console.log(`   Skipping ${variation.name} - no positions available`);
        continue;
      }

      // Select 1-2 positions for this rule
      const numPositions = Math.min(
        Math.floor(seededRandom() * 2) + 1,
        availablePositions.length,
      );
      const selectedPositions = availablePositions.slice(0, numPositions);

      // Use financial account name as rule name if available, otherwise use variation name
      const ruleName = financialAccountName || variation.name;

      // Create the approval rule
      const approvalRule = await prisma.approvalRule.create({
        data: {
          name: ruleName,
          description: `${variation.description} di ${church.name}`,
          active: variation.active,
          churchId: church.id,
          activityType: variation.activityType,
          financialType: variation.financialType,
          financialAccountNumberId,
        } as any,
        include: { positions: true },
      });

      // Link positions to this rule
      await prisma.membershipPosition.updateMany({
        where: { id: { in: selectedPositions.map((p) => p.id) } },
        data: { approvalRuleId: approvalRule.id },
      });

      // Fetch the updated rule with positions
      const updatedRule = await prisma.approvalRule.findUnique({
        where: { id: approvalRule.id },
        include: { positions: true, financialAccountNumber: true } as any,
      });

      approvalRules.push(updatedRule);
    }
  }

  console.log(`✅ Created ${approvalRules.length} approval rules`);
  console.log(
    `   (${assignedFinancialAccountIds.size} unique financial accounts assigned)`,
  );

  // Print summary of rule types
  const activeRules = approvalRules.filter((r: any) => r?.active);
  const inactiveRules = approvalRules.filter((r: any) => !r?.active);
  const rulesWithAccount = approvalRules.filter(
    (r: any) => r?.financialAccountNumberId,
  );
  const rulesWithActivityType = approvalRules.filter(
    (r: any) => r?.activityType,
  );
  const rulesWithFinancialType = approvalRules.filter(
    (r: any) => r?.financialType,
  );
  const genericRules = approvalRules.filter(
    (r: any) => !r?.activityType && !r?.financialType,
  );

  console.log(`   Active rules: ${activeRules.length}`);
  console.log(`   Inactive rules: ${inactiveRules.length}`);
  console.log(`   Rules with specific account: ${rulesWithAccount.length}`);
  console.log(`   Rules with activity type: ${rulesWithActivityType.length}`);
  console.log(`   Rules with financial type: ${rulesWithFinancialType.length}`);
  console.log(`   Generic rules (fallback): ${genericRules.length}`);

  return approvalRules;
}

/**
 * Resolves approvers for an activity based on approval rules.
 * This is a seeder-specific implementation of the approver resolution algorithm.
 *
 * Algorithm:
 * 1. Query approval rules matching activityType and churchId where active = true
 * 2. If no type-specific rules found, query rules where activityType IS NULL
 * 3. If financial data exists, additionally query rules matching financialAccountNumberId or financialType
 * 4. Collect all MembershipPosition IDs from matched rules
 * 5. Deduplicate position IDs
 * 6. Find all Membership records that have these positions in the same church
 * 7. Include all memberships (including supervisor if they hold a matching position - self-approval scenario)
 * 8. Return unique membership IDs for approver creation
 */
async function resolveApproversForSeeder(
  churchId: number,
  activityType: ActivityType,
): Promise<number[]> {
  const positionIds = new Set<number>();

  // Step 1: Find approval rules matching the activity type
  // Use type assertion to handle Prisma client types that may not be regenerated yet
  let activityTypeRules = await prisma.approvalRule.findMany({
    where: {
      churchId,
      activityType,
      active: true,
    } as any,
    include: {
      positions: {
        select: { id: true },
      },
    },
  });

  // Step 2: If no type-specific rules found, fall back to generic rules (activityType IS NULL)
  if (activityTypeRules.length === 0) {
    activityTypeRules = await prisma.approvalRule.findMany({
      where: {
        churchId,
        activityType: null,
        active: true,
      } as any,
      include: {
        positions: {
          select: { id: true },
        },
      },
    });
  }

  // Collect positions from activity type rules
  for (const rule of activityTypeRules) {
    for (const position of (rule as any).positions) {
      positionIds.add(position.id);
    }
  }

  // If no positions found, return empty result
  if (positionIds.size === 0) {
    return [];
  }

  // Step 6: Find all memberships that hold these positions in the same church
  const positionIdArray = Array.from(positionIds);

  const membershipsWithPositions = await prisma.membership.findMany({
    where: {
      churchId,
      membershipPositions: {
        some: {
          id: {
            in: positionIdArray,
          },
        },
      },
    },
    select: { id: true },
  });

  // Return unique membership IDs (including supervisor if they match - self-approval)
  return membershipsWithPositions.map((m) => m.id);
}

async function resolveFinanceApproversForSeeder(
  churchId: number,
  financialType: FinancialType,
  financialAccountNumberId?: number,
): Promise<number[]> {
  const positionIds = new Set<number>();

  if (financialAccountNumberId) {
    const accountSpecificRules = await prisma.approvalRule.findMany({
      where: {
        churchId,
        financialAccountNumberId,
        active: true,
      } as any,
      include: {
        positions: {
          select: { id: true },
        },
      },
    });

    for (const rule of accountSpecificRules) {
      for (const position of (rule as any).positions) {
        positionIds.add(position.id);
      }
    }
  }

  const financialTypeRules = await prisma.approvalRule.findMany({
    where: {
      churchId,
      financialType,
      financialAccountNumberId: null,
      active: true,
    } as any,
    include: {
      positions: {
        select: { id: true },
      },
    },
  });

  for (const rule of financialTypeRules) {
    for (const position of (rule as any).positions) {
      positionIds.add(position.id);
    }
  }

  if (positionIds.size === 0) {
    return [];
  }

  const membershipsWithPositions = await prisma.membership.findMany({
    where: {
      churchId,
      membershipPositions: {
        some: {
          id: {
            in: Array.from(positionIds),
          },
        },
      },
    },
    select: { id: true },
  });

  return membershipsWithPositions.map((m) => m.id);
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
      revenueFinancialAccountId,
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
      expenseFinancialAccountId,
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
  console.log(
    '📅 Creating activities for main accounts (25 each with all variations)...',
  );

  const activities = [];
  const variations = getAllActivityVariations(); // 15 variations
  let globalIndex = 0;

  // Financial type cycle: revenue, expense, none (an activity can only have one)
  const financialTypes: ActivityFinancialType[] = [
    'revenue',
    'expense',
    'none',
  ];

  for (const mainMembership of mainMemberships) {
    console.log(
      `   Creating 25 activities for main account (phone: ${mainMembership.accountPhone})...`,
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
  }

  console.log(`✅ Created ${activities.length} activities for main accounts`);
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
  console.log('🎵 Creating songs from songs.json...');

  const songsJsonPath = path.resolve(
    __dirname,
    '..',
    '..',
    '..',
    'docs',
    'songs.json',
  );

  if (!fs.existsSync(songsJsonPath)) {
    console.warn(
      `⚠️ songs.json not found at ${songsJsonPath}. Skipping song seeding.`,
    );
    return [];
  }

  const rawContent = fs.readFileSync(songsJsonPath, 'utf-8');
  const songsData = JSON.parse(rawContent);
  const rawSongs = songsData.songs || [];
  const songs = [];

  for (const rawSong of rawSongs) {
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

  console.log(`✅ Created ${songs.length} songs with parts from songs.json`);
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
  } catch (_e) {
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
  } catch (_e) {}

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

  console.log('🌱 Starting comprehensive seed...\n');

  try {
    seed = 12345;

    await cleanDatabase();

    const passwordHash = await bcrypt.hash(CONFIG.defaultPassword, 12);

    // Seed congregations (regions, churches, columns, memberships) and
    // financial account numbers — all sourced from JSON files.
    const {
      createdChurches: mainChurches,
      mainMemberships,
      financialAccounts,
      mainAccounts,
    } = await seedCongregationsAndFinances(passwordHash);

    const extraMemberships: MembershipWithChurch[] = [];

    // Create approval rules with activity type and financial type filters
    await seedApprovalRules(mainChurches, financialAccounts);

    // Create activities for main accounts (25 each) - uses automatic approver linking
    await seedMainAccountActivities(mainMemberships, financialAccounts, []);

    // Create extra activities for each church (25 each, not connected to main accounts)
    await seedExtraChurchActivities(
      mainChurches,
      extraMemberships,
      financialAccounts,
      [],
    );

    // Create songs
    await seedSongs();

    await seedArticles();

    await seedSongDbFile(mainChurches);

    // Print summary
    await printSummary(mainAccounts, mainChurches);

    console.log('\n🎉 Seeding completed successfully!');
  } catch (error) {
    console.error('❌ Seeding failed:', error);
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
