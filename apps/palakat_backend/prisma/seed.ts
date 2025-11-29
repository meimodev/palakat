import {
  ActivityType,
  ApprovalStatus,
  Bipra,
  Book,
  FinancialType,
  Gender,
  GeneratedBy,
  MaritalStatus,
  PaymentMethod,
  PrismaClient,
  Reminder,
} from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import * as process from 'node:process';

const prisma = new PrismaClient();

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
  mainAccountPhones: ['081111111111', '081212341234'],
  activitiesPerMainAccount: 25,
  extraActivitiesPerChurch: 25,
  extraMembersPerChurch: 10,
  extraAccountsWithoutMembership: 5,
  songsPerBook: 3,
  maxApproversPerActivity: 2,
  reportsPerChurch: 2,
  documentsPerChurch: 3,
  approvalRulesPerChurch: 2,
  defaultPassword: 'password',
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

function generateNumericPhoneNumber(): string {
  const length = seededRandom() < 0.5 ? 12 : 13;
  let result = '08';
  for (let i = 2; i < length; i++) {
    result += Math.floor(seededRandom() * 10).toString();
  }
  return result;
}

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
  result.setDate(1);
  result.setHours(0, 0, 0, 0);
  return result;
}

function getCurrentDay(date: Date = new Date()): Date {
  const result = new Date(date);
  result.setHours(23, 59, 59, 999);
  return result;
}

// ============================================================================
// DATA CONSTANTS
// ============================================================================

const FIRST_NAMES = {
  MALE: [
    'John',
    'Michael',
    'David',
    'Robert',
    'Kevin',
    'Daniel',
    'Thomas',
    'James',
    'William',
    'Richard',
    'Budi',
    'Andi',
    'Agus',
    'Bambang',
    'Dedi',
  ],
  FEMALE: [
    'Jane',
    'Sarah',
    'Lisa',
    'Maria',
    'Emma',
    'Jennifer',
    'Michelle',
    'Patricia',
    'Linda',
    'Barbara',
    'Siti',
    'Dewi',
    'Ani',
    'Rina',
    'Lina',
  ],
};

const LAST_NAMES = [
  'Doe',
  'Smith',
  'Johnson',
  'Wilson',
  'Brown',
  'Anderson',
  'Taylor',
  'Garcia',
  'Lee',
  'Davis',
  'Santoso',
  'Wijaya',
  'Kusuma',
  'Pratama',
  'Setiawan',
];

const CHURCH_PREFIXES = [
  'GKI',
  'GPIB',
  'GBKP',
  'HKBP',
  'GBI',
  'GKPS',
  'GKPI',
  'GKPA',
];
const CHURCH_LOCATIONS = [
  'Pondok Indah',
  'Pluit',
  'Kelapa Gading',
  'Cawang',
  'Tanjung Duren',
  'Modernland',
  'PIK',
  'Bintaro',
  'Bekasi',
  'Tangerang',
];
const AREAS = [
  'Jakarta Selatan',
  'Jakarta Pusat',
  'Jakarta Utara',
  'Jakarta Timur',
  'Jakarta Barat',
  'Bekasi',
  'Tangerang',
  'Depok',
  'Bogor',
  'Tangerang Selatan',
];

const COLUMN_TYPES = [
  ['Kolom Dewasa', 'Kolom Pemuda', 'Kolom Anak-anak'],
  ['Kolom Keluarga', 'Kolom Single'],
  ['Kolom Profesional', 'Kolom Ibu-ibu', 'Kolom Bapak-bapak'],
];

const POSITION_NAMES = [
  'Penatua PKB',
  'Penatua Kolom',
  'Wakil Ketua',
  'Sekretaris',
  'Bendahara',
  'Anggota Majelis',
  'Ketua Komisi',
  'Koordinator Ibadah',
  'Koordinator Pemuda',
  'Koordinator Anak',
  'Diaken',
  'Pengurus Harian',
];

const APPROVAL_RULE_NAMES = [
  'Persetujuan Kegiatan Pelayanan',
  'Persetujuan Pengeluaran Dana',
  'Persetujuan Acara Besar',
  'Persetujuan Keuangan Gereja',
  'Persetujuan Penggunaan Fasilitas',
  'Persetujuan Program Jemaat',
];

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

const SONG_TITLES: Record<Book, string[]> = {
  NKB: [
    'Tuhan Allah Hadir',
    'Batu Penjuru',
    "Kar'na Jemaat",
    "Yesus Kristus Jurus'lamat",
    'Hai Umat, Nyanyilah',
  ],
  NNBT: [
    'Amazing Grace',
    'How Great Thou Art',
    'Holy Holy Holy',
    'What a Friend We Have in Jesus',
    'Great is Thy Faithfulness',
  ],
  KJ: [
    'Tuhan adalah Gembalaku',
    'Kasih Kristus yang Ajaib',
    'Kudengar Panggilan-Mu',
    'Yesus Sahabat Sejati',
    'Hatiku Bersukacita',
  ],
  DSL: [
    'Dia Sanggup',
    'Kasih-Mu Seperti Surga',
    'Ku Percaya Janjimu Tuhan',
    "S'gala Kemuliaan",
    'Tuhan Setia',
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
const GENERATED_BY_VALUES: GeneratedBy[] = [
  GeneratedBy.MANUAL,
  GeneratedBy.SYSTEM,
];
const BOOK_VALUES: Book[] = [Book.NKB, Book.NNBT, Book.KJ, Book.DSL];

const INCOME_ACCOUNTS = [
  {
    code: '4100',
    name: 'Persembahan Umum',
    description: 'Persembahan ibadah minggu dan hari raya',
  },
  {
    code: '4110',
    name: 'Persembahan Syukur',
    description: 'Persembahan syukur jemaat',
  },
  {
    code: '4120',
    name: 'Persembahan Perpuluhan',
    description: 'Persembahan perpuluhan jemaat',
  },
  {
    code: '4130',
    name: 'Persembahan Khusus',
    description: 'Persembahan untuk kegiatan khusus',
  },
  {
    code: '4200',
    name: 'Sumbangan Donatur',
    description: 'Sumbangan dari donatur tetap dan tidak tetap',
  },
  {
    code: '4210',
    name: 'Sumbangan Pembangunan',
    description: 'Sumbangan untuk pembangunan gedung gereja',
  },
  {
    code: '4300',
    name: 'Pendapatan Kegiatan',
    description: 'Pendapatan dari kegiatan gereja',
  },
  {
    code: '4310',
    name: 'Pendapatan Retreat',
    description: 'Pendapatan dari kegiatan retreat',
  },
  {
    code: '4320',
    name: 'Pendapatan Seminar',
    description: 'Pendapatan dari kegiatan seminar',
  },
  {
    code: '4400',
    name: 'Pendapatan Lain-lain',
    description: 'Pendapatan lain yang tidak terklasifikasi',
  },
];

const EXPENSE_ACCOUNTS = [
  {
    code: '5100',
    name: 'Biaya Operasional',
    description: 'Biaya operasional harian gereja',
  },
  {
    code: '5110',
    name: 'Biaya Listrik',
    description: 'Pembayaran listrik bulanan',
  },
  { code: '5120', name: 'Biaya Air', description: 'Pembayaran air bulanan' },
  {
    code: '5130',
    name: 'Biaya Internet',
    description: 'Pembayaran internet dan telepon',
  },
  {
    code: '5200',
    name: 'Biaya Pelayanan',
    description: 'Biaya untuk kegiatan pelayanan',
  },
  {
    code: '5210',
    name: 'Biaya Ibadah',
    description: 'Biaya perlengkapan ibadah',
  },
  {
    code: '5220',
    name: 'Biaya Musik',
    description: 'Biaya peralatan dan perlengkapan musik',
  },
  {
    code: '5300',
    name: 'Biaya Kegiatan',
    description: 'Biaya untuk kegiatan gereja',
  },
  {
    code: '5310',
    name: 'Biaya Retreat',
    description: 'Biaya penyelenggaraan retreat',
  },
  {
    code: '5320',
    name: 'Biaya Seminar',
    description: 'Biaya penyelenggaraan seminar',
  },
  {
    code: '5400',
    name: 'Biaya Diakonia',
    description: 'Biaya bantuan sosial dan diakonia',
  },
  {
    code: '5410',
    name: 'Biaya Bantuan Jemaat',
    description: 'Bantuan untuk jemaat yang membutuhkan',
  },
  {
    code: '5500',
    name: 'Biaya Pemeliharaan',
    description: 'Biaya pemeliharaan gedung dan fasilitas',
  },
  {
    code: '5510',
    name: 'Biaya Perbaikan',
    description: 'Biaya perbaikan gedung dan peralatan',
  },
  {
    code: '5600',
    name: 'Biaya Administrasi',
    description: 'Biaya administrasi dan ATK',
  },
  {
    code: '5700',
    name: 'Biaya Lain-lain',
    description: 'Biaya lain yang tidak terklasifikasi',
  },
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

function generateAccountData(index: number, gender?: Gender) {
  const accountGender = gender || randomElement([Gender.MALE, Gender.FEMALE]);
  const firstName = randomElement(FIRST_NAMES[accountGender]);
  const lastName = randomElement(LAST_NAMES);
  const maritalStatus = randomElement([
    MaritalStatus.MARRIED,
    MaritalStatus.SINGLE,
  ]);
  const dobStart = new Date('1950-01-01');
  const dobEnd = new Date('2010-12-31');

  return {
    name: `${firstName} ${lastName}`,
    phone: generateNumericPhoneNumber(),
    email: randomBoolean(0.7)
      ? `${firstName.toLowerCase()}.${lastName.toLowerCase()}${index}@example.com`
      : null,
    gender: accountGender,
    maritalStatus,
    dob: randomDate(dobStart, dobEnd),
    claimed: randomBoolean(0.3),
    isActive: randomBoolean(0.95),
    failedLoginAttempts: randomBoolean(0.1)
      ? Math.floor(seededRandom() * 5)
      : 0,
    lockUntil: randomBoolean(0.05) ? new Date(Date.now() + 3600000) : null,
  };
}

function generateActivityData(type: ActivityType, bipra: Bipra, index: number) {
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

// Generate all activity variations (3 types × 5 bipras = 15)
function getAllActivityVariations(): { type: ActivityType; bipra: Bipra }[] {
  const variations: { type: ActivityType; bipra: Bipra }[] = [];
  for (const activityType of ACTIVITY_TYPES) {
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
    prisma.approver.deleteMany(),
    prisma.revenue.deleteMany(),
    prisma.expense.deleteMany(),
    p.financialAccountNumber.deleteMany(),
    prisma.activity.deleteMany(),
    prisma.report.deleteMany(),
    prisma.document.deleteMany(),
    prisma.fileManager.deleteMany(),
    prisma.songPart.deleteMany(),
    prisma.song.deleteMany(),
    prisma.approvalRule.deleteMany(),
    prisma.membershipPosition.deleteMany(),
    prisma.membership.deleteMany(),
    prisma.churchRequest.deleteMany(),
    prisma.column.deleteMany(),
    prisma.church.deleteMany(),
    prisma.account.deleteMany(),
    prisma.location.deleteMany(),
  ]);
  console.log('✅ Database cleaned');
}

async function seedMainAccounts(passwordHash: string) {
  console.log('👤 Creating main accounts...');

  const mainAccounts = [];
  for (let i = 0; i < CONFIG.mainAccountPhones.length; i++) {
    const phone = CONFIG.mainAccountPhones[i];
    const accountData = generateAccountData(i);

    const account = await prisma.account.create({
      data: {
        ...accountData,
        phone,
        name: `Main User ${i + 1}`,
        email: `mainuser${i + 1}@example.com`,
        passwordHash,
        claimed: true,
        isActive: true,
      },
    });
    mainAccounts.push(account);
  }

  console.log(`✅ Created ${mainAccounts.length} main accounts`);
  return mainAccounts;
}

async function seedMainChurches(): Promise<ChurchWithColumns[]> {
  console.log('🏛️ Creating main churches for main accounts...');

  const churches: ChurchWithColumns[] = [];
  for (let i = 0; i < CONFIG.mainAccountPhones.length; i++) {
    const name = `GMIM ${CHURCH_LOCATIONS[i]} Utama`;
    const columns = COLUMN_TYPES[i % COLUMN_TYPES.length];

    const location = await prisma.location.create({
      data: {
        name: `Lokasi ${name}`,
        latitude: generateLatitude(),
        longitude: generateLongitude(),
      },
    });

    const church = await prisma.church.create({
      data: {
        name,
        phoneNumber: generateNumericPhoneNumber(),
        email: `${name.toLowerCase().replace(/\s+/g, '-')}@example.com`,
        description: `Gereja utama ${name} untuk main account ${i + 1}.`,
        documentAccountNumber: `MAIN-${String(i + 1).padStart(4, '0')}`,
        locationId: location.id,
        columns: {
          create: columns.map((col) => ({ name: col })),
        },
      },
      include: { columns: true },
    });

    churches.push(church);
  }

  console.log(`✅ Created ${churches.length} main churches`);
  return churches;
}

async function seedMainMemberships(
  mainAccounts: { id: number; phone: string }[],
  mainChurches: ChurchWithColumns[],
): Promise<MembershipWithChurch[]> {
  console.log('🤝 Creating memberships for main accounts...');

  const memberships: MembershipWithChurch[] = [];
  for (let i = 0; i < mainAccounts.length; i++) {
    const account = mainAccounts[i];
    const church = mainChurches[i];
    const column = church.columns[0];

    const membership = await prisma.membership.create({
      data: {
        accountId: account.id,
        churchId: church.id,
        columnId: column.id,
        baptize: true,
        sidi: true,
      },
    });

    memberships.push({
      id: membership.id,
      churchId: church.id,
      accountPhone: account.phone,
    });
  }

  console.log(`✅ Created ${memberships.length} main memberships`);
  return memberships;
}

async function seedExtraMembersForChurches(
  mainChurches: ChurchWithColumns[],
  passwordHash: string,
): Promise<MembershipWithChurch[]> {
  console.log('👥 Creating extra members for main churches...');

  const extraMemberships: MembershipWithChurch[] = [];
  let accountIndex = 100;

  for (const church of mainChurches) {
    for (let i = 0; i < CONFIG.extraMembersPerChurch; i++) {
      const accountData = generateAccountData(accountIndex);

      const account = await prisma.account.create({
        data: {
          ...accountData,
          passwordHash,
        },
      });

      const columnIndex = i % church.columns.length;
      const column = church.columns[columnIndex];

      const membership = await prisma.membership.create({
        data: {
          accountId: account.id,
          churchId: church.id,
          columnId: column.id,
          baptize: randomBoolean(0.8),
          sidi: randomBoolean(0.6),
        },
      });

      extraMemberships.push({ id: membership.id, churchId: church.id });
      accountIndex++;
    }
  }

  console.log(`✅ Created ${extraMemberships.length} extra memberships`);
  return extraMemberships;
}

async function seedMembershipPositions(memberships: MembershipWithChurch[]) {
  console.log('📋 Creating membership positions...');

  const positions = [];
  const membershipsWithPositions = memberships.slice(
    0,
    Math.floor(memberships.length * 0.4),
  );

  for (const membership of membershipsWithPositions) {
    const numPositions = Math.floor(seededRandom() * 3) + 1;
    const selectedPositions: string[] = [];

    for (let i = 0; i < numPositions; i++) {
      const positionName = randomElement(POSITION_NAMES);
      if (!selectedPositions.includes(positionName)) {
        selectedPositions.push(positionName);

        const position = await prisma.membershipPosition.create({
          data: {
            membershipId: membership.id,
            churchId: membership.churchId,
            name: positionName,
          },
        });

        positions.push(position);
      }
    }
  }

  console.log(`✅ Created ${positions.length} membership positions`);
  return positions;
}

async function seedApprovalRules(churches: ChurchWithColumns[]) {
  console.log('📜 Creating approval rules...');

  const approvalRules = [];

  for (const church of churches) {
    const churchPositions = await prisma.membershipPosition.findMany({
      where: { churchId: church.id, approvalRuleId: null },
    });

    if (churchPositions.length === 0) continue;

    for (let i = 0; i < CONFIG.approvalRulesPerChurch; i++) {
      const ruleName = randomElement(APPROVAL_RULE_NAMES);
      const active = i === 0;

      const availablePositions = churchPositions.filter(
        (p) =>
          !approvalRules.some((r: { positions?: { id: number }[] }) =>
            r.positions?.some((rp) => rp.id === p.id),
          ),
      );

      if (availablePositions.length === 0) continue;

      const numPositions = Math.min(
        Math.floor(seededRandom() * 3) + 1,
        availablePositions.length,
      );
      const selectedPositions = availablePositions.slice(0, numPositions);

      const approvalRule = await prisma.approvalRule.create({
        data: {
          name: `${ruleName} ${i + 1}`,
          description: `Deskripsi untuk ${ruleName} ${i + 1} di ${church.name}`,
          active,
          churchId: church.id,
        },
        include: { positions: true },
      });

      await prisma.membershipPosition.updateMany({
        where: { id: { in: selectedPositions.map((p) => p.id) } },
        data: { approvalRuleId: approvalRule.id },
      });

      const updatedRule = await prisma.approvalRule.findUnique({
        where: { id: approvalRule.id },
        include: { positions: true },
      });

      approvalRules.push(updatedRule);
    }
  }

  console.log(`✅ Created ${approvalRules.length} approval rules`);
  return approvalRules;
}

async function createActivityWithConnectedModels(
  supervisorId: number,
  churchId: number,
  activityType: ActivityType,
  bipra: Bipra,
  index: number,
  otherMemberships: MembershipWithChurch[],
  withRevenue: boolean,
  withExpense: boolean,
) {
  const activityData = generateActivityData(activityType, bipra, index);

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

  const activity = await prisma.activity.create({
    data: {
      ...activityData,
      supervisorId,
      locationId,
    },
  });

  // Add approvers with different statuses
  const numApprovers = Math.min(
    CONFIG.maxApproversPerActivity,
    otherMemberships.length,
  );

  for (let i = 0; i < numApprovers; i++) {
    const approver = otherMemberships[i];
    await prisma.approver.create({
      data: {
        activityId: activity.id,
        membershipId: approver.id,
        status: APPROVAL_STATUSES[i % APPROVAL_STATUSES.length],
      },
    });
  }

  // Add revenue if specified (for SERVICE and EVENT types)
  if (withRevenue && activityType !== ActivityType.ANNOUNCEMENT) {
    await prisma.revenue.create({
      data: {
        accountNumber: `${Math.floor(1000000000 + seededRandom() * 9000000000)}`,
        amount: Math.floor(seededRandom() * 3000000) + 500000,
        churchId,
        activityId: activity.id,
        paymentMethod: PAYMENT_METHODS[index % PAYMENT_METHODS.length],
      },
    });
  }

  // Add expense if specified (for EVENT types primarily)
  if (withExpense && activityType === ActivityType.EVENT) {
    await prisma.expense.create({
      data: {
        accountNumber: `${Math.floor(1000000000 + seededRandom() * 9000000000)}`,
        amount: Math.floor(seededRandom() * 2000000) + 300000,
        churchId,
        activityId: activity.id,
        paymentMethod: PAYMENT_METHODS[index % PAYMENT_METHODS.length],
      },
    });
  }

  return activity;
}

async function seedMainAccountActivities(
  mainMemberships: MembershipWithChurch[],
  extraMemberships: MembershipWithChurch[],
) {
  console.log(
    '📅 Creating activities for main accounts (25 each with all variations)...',
  );

  const activities = [];
  const variations = getAllActivityVariations(); // 15 variations
  let globalIndex = 0;

  for (const mainMembership of mainMemberships) {
    const churchMemberships = extraMemberships.filter(
      (m) => m.churchId === mainMembership.churchId,
    );

    console.log(
      `   Creating 25 activities for main account (phone: ${mainMembership.accountPhone})...`,
    );

    // First 15 activities: cover all variations (3 types × 5 bipras)
    for (let i = 0; i < variations.length; i++) {
      const variation = variations[i];
      // Vary connected models: some with revenue, some with expense, some with both, some with neither
      const withRevenue = i % 4 === 0 || i % 4 === 2;
      const withExpense = i % 4 === 1 || i % 4 === 2;

      const activity = await createActivityWithConnectedModels(
        mainMembership.id,
        mainMembership.churchId,
        variation.type,
        variation.bipra,
        globalIndex,
        churchMemberships,
        withRevenue,
        withExpense,
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
      const withRevenue = i % 3 === 0;
      const withExpense = i % 3 === 1;

      const activity = await createActivityWithConnectedModels(
        mainMembership.id,
        mainMembership.churchId,
        variation.type,
        variation.bipra,
        globalIndex,
        churchMemberships,
        withRevenue,
        withExpense,
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
) {
  console.log(
    '📅 Creating extra activities for churches (25 each, not connected to main accounts)...',
  );

  const activities = [];
  const variations = getAllActivityVariations();
  let globalIndex = 1000;

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

    // First 15 activities: cover all variations
    for (let i = 0; i < variations.length; i++) {
      const variation = variations[i];
      const supervisorIndex = i % churchExtraMembers.length;
      const supervisor = churchExtraMembers[supervisorIndex];

      // Other members for approvers (excluding supervisor)
      const otherMembers = churchExtraMembers.filter(
        (m) => m.id !== supervisor.id,
      );

      const withRevenue = i % 4 === 0 || i % 4 === 3;
      const withExpense = i % 4 === 1 || i % 4 === 3;

      const activity = await createActivityWithConnectedModels(
        supervisor.id,
        church.id,
        variation.type,
        variation.bipra,
        globalIndex,
        otherMembers,
        withRevenue,
        withExpense,
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

      const otherMembers = churchExtraMembers.filter(
        (m) => m.id !== supervisor.id,
      );

      const withRevenue = i % 2 === 0;
      const withExpense = i % 2 === 1;

      const activity = await createActivityWithConnectedModels(
        supervisor.id,
        church.id,
        variation.type,
        variation.bipra,
        globalIndex,
        otherMembers,
        withRevenue,
        withExpense,
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

async function seedFinancialAccountNumbers(
  churches: ChurchWithColumns[],
): Promise<FinancialAccountWithType[]> {
  console.log('💳 Creating financial account numbers...');

  const financialAccounts: FinancialAccountWithType[] = [];
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const p = prisma as any;

  for (const church of churches) {
    for (const incomeAccount of INCOME_ACCOUNTS) {
      const account = await p.financialAccountNumber.create({
        data: {
          accountNumber: incomeAccount.code,
          description: `${incomeAccount.name} - ${incomeAccount.description}`,
          type: FinancialType.REVENUE,
          churchId: church.id,
        },
      });
      financialAccounts.push({
        id: account.id,
        churchId: church.id,
        type: 'income',
        name: incomeAccount.name,
      });
    }

    for (const expenseAccount of EXPENSE_ACCOUNTS) {
      const account = await p.financialAccountNumber.create({
        data: {
          accountNumber: expenseAccount.code,
          description: `${expenseAccount.name} - ${expenseAccount.description}`,
          type: FinancialType.EXPENSE,
          churchId: church.id,
        },
      });
      financialAccounts.push({
        id: account.id,
        churchId: church.id,
        type: 'expense',
        name: expenseAccount.name,
      });
    }
  }

  console.log(
    `✅ Created ${financialAccounts.length} financial account numbers`,
  );
  return financialAccounts;
}

async function linkFinancialAccountsToTransactions(
  financialAccounts: FinancialAccountWithType[],
  churches: ChurchWithColumns[],
) {
  console.log('🔗 Linking financial accounts to revenues and expenses...');

  let linkedRevenues = 0;
  let linkedExpenses = 0;

  for (const church of churches) {
    const churchIncomeAccounts = financialAccounts.filter(
      (fa) => fa.churchId === church.id && fa.type === 'income',
    );
    const churchExpenseAccounts = financialAccounts.filter(
      (fa) => fa.churchId === church.id && fa.type === 'expense',
    );

    const revenues = await prisma.revenue.findMany({
      where: { churchId: church.id },
    });
    const expenses = await prisma.expense.findMany({
      where: { churchId: church.id },
    });

    // Link revenues to income accounts (distribute across accounts using modulo)
    for (let i = 0; i < revenues.length; i++) {
      if (churchIncomeAccounts.length === 0) break;
      const accountIndex = i % churchIncomeAccounts.length;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await prisma.revenue.update({
        where: { id: revenues[i].id },
        data: {
          financialAccountNumberId: churchIncomeAccounts[accountIndex].id,
        } as any,
      });
      linkedRevenues++;
    }

    // Link expenses to expense accounts (distribute across accounts using modulo)
    for (let i = 0; i < expenses.length; i++) {
      if (churchExpenseAccounts.length === 0) break;
      const accountIndex = i % churchExpenseAccounts.length;
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      await prisma.expense.update({
        where: { id: expenses[i].id },
        data: {
          financialAccountNumberId: churchExpenseAccounts[accountIndex].id,
        } as any,
      });
      linkedExpenses++;
    }
  }

  console.log(
    `✅ Linked ${linkedRevenues} revenues and ${linkedExpenses} expenses to financial accounts`,
  );
}

async function seedSongs() {
  console.log('🎵 Creating songs...');

  const songs = [];

  for (const book of BOOK_VALUES) {
    const titles = SONG_TITLES[book];

    for (let i = 0; i < CONFIG.songsPerBook; i++) {
      const title = titles[i % titles.length];
      const index = BOOK_VALUES.indexOf(book) * 100 + i + 1;

      const song = await prisma.song.create({
        data: {
          title: `${title} ${i + 1}`,
          index,
          book,
          link: `https://example.com/song/${book.toLowerCase()}-${index}`,
          parts: {
            create: [
              {
                index: 1,
                name: 'Bait 1',
                content: `Lirik bait 1 untuk ${title}`,
              },
              { index: 2, name: 'Reff', content: `Lirik reff untuk ${title}` },
              {
                index: 3,
                name: 'Bait 2',
                content: `Lirik bait 2 untuk ${title}`,
              },
            ],
          },
        },
        include: { parts: true },
      });

      songs.push(song);
    }
  }

  console.log(`✅ Created ${songs.length} songs with parts`);
  return songs;
}

async function seedFiles() {
  console.log('📁 Creating files...');

  const files = [];
  const fileExtensions = ['pdf', 'docx', 'xlsx', 'png', 'jpg'];
  const baseUrls = [
    'https://storage.example.com/files/',
    'https://cdn.example.com/documents/',
    'https://assets.example.com/uploads/',
  ];

  const totalFiles =
    CONFIG.mainAccountPhones.length * (CONFIG.reportsPerChurch + 2);

  for (let i = 0; i < totalFiles; i++) {
    const extension = randomElement(fileExtensions);
    const baseUrl = randomElement(baseUrls);
    const sizeInKB = parseFloat((seededRandom() * 5000 + 100).toFixed(2));

    const file = await prisma.fileManager.create({
      data: {
        sizeInKB,
        url: `${baseUrl}file-${i}.${extension}`,
      },
    });

    files.push(file);
  }

  console.log(`✅ Created ${files.length} files`);
  return files;
}

async function seedReports(
  churches: ChurchWithColumns[],
  files: { id: number }[],
) {
  console.log('📊 Creating reports...');

  const reports = [];
  const reportTypes = [
    'Laporan Keuangan',
    'Laporan Kegiatan',
    'Laporan Jemaat',
    'Laporan Kolom',
    'Laporan Tahunan',
  ];
  let fileIndex = 0;

  for (let i = 0; i < churches.length * CONFIG.reportsPerChurch; i++) {
    const churchIndex = Math.floor(i / CONFIG.reportsPerChurch);
    const church = churches[churchIndex];
    const reportType = randomElement(reportTypes);
    const generatedBy = GENERATED_BY_VALUES[i % GENERATED_BY_VALUES.length];
    const year = 2024 - Math.floor(seededRandom() * 3);
    const month = Math.floor(seededRandom() * 12) + 1;

    const report = await prisma.report.create({
      data: {
        name: `${reportType} ${church.name} ${year}-${String(month).padStart(2, '0')}`,
        generatedBy,
        churchId: church.id,
        fileId: files[fileIndex].id,
      },
    });

    reports.push(report);
    fileIndex++;
  }

  console.log(`✅ Created ${reports.length} reports`);
  return reports;
}

async function seedDocuments(
  churches: ChurchWithColumns[],
  files: { id: number }[],
) {
  console.log('📄 Creating documents...');

  const documents = [];
  let fileIndex = churches.length * CONFIG.reportsPerChurch;

  const documentTypes = [
    'Surat Keterangan Baptis',
    'Surat Keterangan Sidi',
    'Surat Keterangan Nikah',
    'Surat Keterangan Jemaat',
    'Surat Rekomendasi',
    'Surat Pengantar',
  ];

  for (let i = 0; i < churches.length * CONFIG.documentsPerChurch; i++) {
    const churchIndex = Math.floor(i / CONFIG.documentsPerChurch);
    const church = churches[churchIndex];
    const docIndex = i % CONFIG.documentsPerChurch;

    const hasFile = docIndex !== 2;
    const accountNumber = `DOC-${String(church.id).padStart(3, '0')}-${String(i).padStart(4, '0')}`;
    const documentType = randomElement(documentTypes);

    const document = await prisma.document.create({
      data: {
        name: `${documentType} - ${church.name}`,
        accountNumber,
        churchId: church.id,
        fileId: hasFile && files[fileIndex] ? files[fileIndex].id : null,
      },
    });

    documents.push(document);
    if (hasFile) fileIndex++;
  }

  console.log(`✅ Created ${documents.length} documents`);
  return documents;
}

async function seedExtraAccountsWithoutMembership(passwordHash: string) {
  console.log('👤 Creating extra accounts without membership...');

  const accounts = [];
  for (let i = 0; i < CONFIG.extraAccountsWithoutMembership; i++) {
    const accountData = generateAccountData(500 + i);

    const account = await prisma.account.create({
      data: {
        ...accountData,
        passwordHash,
      },
    });
    accounts.push(account);
  }

  console.log(`✅ Created ${accounts.length} accounts without membership`);
  return accounts;
}

async function seedChurchRequests(
  accountsWithoutMembership: { id: number; name: string; phone: string }[],
) {
  console.log('⛪ Creating church requests...');

  const churchRequests = [];
  const numRequests = Math.min(3, accountsWithoutMembership.length);

  for (let i = 0; i < numRequests; i++) {
    const requester = accountsWithoutMembership[i];
    const churchPrefix = randomElement(CHURCH_PREFIXES);
    const location = randomElement(CHURCH_LOCATIONS);

    const churchRequest = await prisma.churchRequest.create({
      data: {
        churchName: `${churchPrefix} ${location} Baru`,
        churchAddress: `Jl. ${location} No. ${Math.floor(seededRandom() * 100) + 1}, ${randomElement(AREAS)}`,
        contactPerson: requester.name,
        contactPhone: requester.phone,
        requesterId: requester.id,
      },
    });

    churchRequests.push(churchRequest);
  }

  console.log(`✅ Created ${churchRequests.length} church requests`);
  return churchRequests;
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
  console.log(`📜 Approval Rules: ${await prisma.approvalRule.count()}`);
  console.log(`📅 Activities: ${await prisma.activity.count()}`);
  console.log(`✔️  Approvers: ${await prisma.approver.count()}`);
  console.log(`💰 Revenues: ${await prisma.revenue.count()}`);
  console.log(`💸 Expenses: ${await prisma.expense.count()}`);
  console.log(`🎵 Songs: ${await prisma.song.count()}`);
  console.log(`📁 Files: ${await prisma.fileManager.count()}`);
  console.log(`📊 Reports: ${await prisma.report.count()}`);
  console.log(`📄 Documents: ${await prisma.document.count()}`);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const p = prisma as any;
  console.log(
    `💳 Financial Account Numbers: ${await p.financialAccountNumber.count()}`,
  );
  console.log(`⛪ Church Requests: ${await prisma.churchRequest.count()}`);

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
        account: { phone: { in: CONFIG.mainAccountPhones } },
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
    process.env.DATABASE_POSTGRES_URL?.includes(host),
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

    // Create main accounts and their churches
    const mainAccounts = await seedMainAccounts(passwordHash);
    const mainChurches = await seedMainChurches();
    const mainMemberships = await seedMainMemberships(
      mainAccounts,
      mainChurches,
    );

    // Create extra members for each main church
    const extraMemberships = await seedExtraMembersForChurches(
      mainChurches,
      passwordHash,
    );

    // Create membership positions and approval rules
    const allMemberships = [...mainMemberships, ...extraMemberships];
    await seedMembershipPositions(allMemberships);
    await seedApprovalRules(mainChurches);

    // Create activities for main accounts (25 each)
    await seedMainAccountActivities(mainMemberships, extraMemberships);

    // Create extra activities for each church (25 each, not connected to main accounts)
    await seedExtraChurchActivities(mainChurches, extraMemberships);

    // Create financial account numbers and link them
    const financialAccounts = await seedFinancialAccountNumbers(mainChurches);
    await linkFinancialAccountsToTransactions(financialAccounts, mainChurches);

    // Create songs
    await seedSongs();

    // Create files, reports, and documents
    const files = await seedFiles();
    await seedReports(mainChurches, files);
    await seedDocuments(mainChurches, files);

    // Create extra accounts without membership and church requests
    const accountsWithoutMembership =
      await seedExtraAccountsWithoutMembership(passwordHash);
    await seedChurchRequests(accountsWithoutMembership);

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
  });
