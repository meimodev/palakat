import {
  ActivityType,
  ApprovalStatus,
  Bipra,
  Book,
  Gender,
  GeneratedBy,
  MaritalStatus,
  PaymentMethod,
  PrismaClient,
} from '@prisma/client';
import * as bcrypt from 'bcryptjs';
import * as process from 'node:process';

const prisma = new PrismaClient();

// ============================================================================
// SEEDED RANDOM NUMBER GENERATOR
// ============================================================================
// Using mulberry32 algorithm for deterministic random numbers
let seed = 12345; // Fixed seed for consistent results

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
  churches: 10, // Minimal for variety coverage (6 column types)
  accountsPerChurch: 3,
  extraAccountsWithoutMembership: 5,
  activitiesPerChurch: 5, // At least 2 for revenue, 2 for expense, 1 extra for variation
  songsPerBook: 3,
  maxApproversPerActivity: 2,
  reportsPerChurch: 2, // 1 manual, 1 system
  documentsPerChurch: 3, // 2 with files, 1 without file
  approvalRulesPerChurch: 2, // 1 active, 1 inactive
  defaultPassword: 'password',
};

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

function generateNumericPhoneNumber(): string {
  const length = seededRandom() < 0.5 ? 12 : 13;
  let result = '08'; // Always start with 08
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

function getStartOfWeek(date: Date = new Date()): Date {
  const result = new Date(date);
  const day = result.getDay();
  const diff = day === 0 ? -6 : 1 - day; // Adjust when day is Sunday (0)
  result.setDate(result.getDate() + diff);
  result.setHours(0, 0, 0, 0);
  return result;
}

function getEndOfWeek(date: Date = new Date()): Date {
  const result = new Date(date);
  const day = result.getDay();
  const diff = day === 0 ? 0 : 7 - day; // If Sunday, use same day; else calculate days until Sunday
  result.setDate(result.getDate() + diff);
  result.setHours(23, 59, 59, 999);
  return result;
}

// ============================================================================
// DATA GENERATORS
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
  ['Kolom Lansia', 'Kolom Dewasa Muda'],
  ['Kolom Keluarga Muda', 'Kolom Remaja'],
  ['Kolom Pria', 'Kolom Wanita', 'Kolom Campuran'],
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

const SONG_TITLES = {
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

function generateChurchName(index: number): string {
  const prefix = randomElement(CHURCH_PREFIXES);
  const location = CHURCH_LOCATIONS[index % CHURCH_LOCATIONS.length];
  const suffix =
    index >= CHURCH_LOCATIONS.length
      ? ` ${Math.floor(index / CHURCH_LOCATIONS.length) + 1}`
      : '';
  return `${prefix} ${location}${suffix}`;
}

function generateActivityData(type: ActivityType, bipra: Bipra, index: number) {
  const title = randomElement(ACTIVITY_TITLES[type]);
  const weekStart = getStartOfWeek();
  const weekEnd = getEndOfWeek();
  const activityDate = randomDate(weekStart, weekEnd);

  return {
    title: `${title} ${index}`,
    activityType: type,
    bipra,
    date: activityDate,
    description: randomBoolean(0.6)
      ? `Deskripsi lengkap untuk ${title} ${index}`
      : null,
    note: randomBoolean(0.7) ? `Catatan untuk ${title} ${index}` : null,
  };
}

// ============================================================================
// MAIN SEEDING LOGIC
// ============================================================================

async function cleanDatabase() {
  console.log('🧹 Cleaning existing data...');
  await prisma.$transaction([
    prisma.approver.deleteMany(),
    prisma.revenue.deleteMany(),
    prisma.expense.deleteMany(),
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

async function seedAccounts(passwordHash: string) {
  console.log('👤 Creating accounts...');

  const accountsData = [];

  // Create diverse accounts with all possible combinations
  for (let i = 0; i < CONFIG.churches * CONFIG.accountsPerChurch; i++) {
    const accountData = {
      ...generateAccountData(i),
      passwordHash,
    };

    // Ensure the first account has the specific phone number
    if (i === 0) {
      accountData.phone = '081111111111';
    }

    accountsData.push(accountData);
  }

  // Create accounts without membership
  for (let i = 0; i < CONFIG.extraAccountsWithoutMembership; i++) {
    accountsData.push({
      ...generateAccountData(CONFIG.churches * CONFIG.accountsPerChurch + i),
      passwordHash,
    });
  }

  const accounts = await Promise.all(
    accountsData.map((data) => prisma.account.create({ data: data as any })),
  );

  console.log(`✅ Created ${accounts.length} accounts`);
  return accounts;
}

async function seedChurches() {
  console.log('🏛️ Creating churches...');

  const churches = [];
  for (let i = 0; i < CONFIG.churches; i++) {
    const name = generateChurchName(i);
    const area = AREAS[i % AREAS.length];
    const columns = COLUMN_TYPES[i % COLUMN_TYPES.length];

    // Create location first
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
        phoneNumber: randomBoolean(0.7) ? generateNumericPhoneNumber() : null,
        email: randomBoolean(0.7)
          ? `${name.toLowerCase().replace(/\s+/g, '-')}@example.com`
          : null,
        description: randomBoolean(0.6)
          ? `Gereja ${name} yang terletak di ${area}.`
          : null,
        documentAccountNumber: `CHR-${String(i + 1).padStart(4, '0')}`,
        locationId: location.id,
        columns: {
          create: columns.map((col) => ({ name: col })),
        },
      },
      include: { columns: true },
    });

    churches.push(church);
  }

  console.log(`✅ Created ${churches.length} churches`);
  return churches;
}

async function seedMemberships(accounts: any[], churches: any[]) {
  console.log('🤝 Creating memberships...');

  const memberships = [];
  const accountsWithMembership = accounts.slice(
    0,
    CONFIG.churches * CONFIG.accountsPerChurch,
  );

  for (let i = 0; i < accountsWithMembership.length; i++) {
    const account = accountsWithMembership[i];
    const churchIndex = Math.floor(i / CONFIG.accountsPerChurch);
    const church = churches[churchIndex];
    const column = randomElement(church.columns) as any;

    const membership = await prisma.membership.create({
      data: {
        accountId: account.id,
        churchId: church.id,
        columnId: column.id,
        baptize: randomBoolean(0.8),
        sidi: randomBoolean(0.6),
      },
    });

    memberships.push(membership);
  }

  console.log(`✅ Created ${memberships.length} memberships`);
  return memberships;
}

async function seedMembershipPositions(memberships: any[]) {
  console.log('📋 Creating membership positions...');

  const positions = [];

  // Assign 1-3 positions to random memberships
  const membershipsWithPositions = memberships.slice(
    0,
    Math.floor(memberships.length * 0.3),
  );

  for (const membership of membershipsWithPositions) {
    const numPositions = Math.floor(seededRandom() * 3) + 1;
    const selectedPositions = [];

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

async function seedApprovalRules(churches: any[]) {
  console.log('📜 Creating approval rules...');

  const approvalRules = [];

  for (const church of churches) {
    // Get all membership positions for this church that don't have an approval rule yet
    const churchPositions = await prisma.membershipPosition.findMany({
      where: {
        churchId: church.id,
        approvalRuleId: null,
      },
    });

    if (churchPositions.length === 0) continue;

    for (let i = 0; i < CONFIG.approvalRulesPerChurch; i++) {
      const ruleName = randomElement(APPROVAL_RULE_NAMES);
      const active = i === 0; // First rule is active, second is inactive

      // Calculate how many positions to assign to this rule
      const availablePositions = churchPositions.filter(
        (p) =>
          !approvalRules.some((r) =>
            r.positions?.some((rp: any) => rp.id === p.id),
          ),
      );

      if (availablePositions.length === 0) continue;

      // Select 1-3 positions for this approval rule (or all available if less)
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
        include: {
          positions: true,
        },
      });

      // Update the selected positions to reference this approval rule
      await prisma.membershipPosition.updateMany({
        where: {
          id: { in: selectedPositions.map((p) => p.id) },
        },
        data: {
          approvalRuleId: approvalRule.id,
        },
      });

      // Fetch the updated approval rule with positions
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

async function seedActivities(memberships: any[], churches: any[]) {
  console.log('📅 Creating activities...');

  const activities = [];
  const activityTypes = Object.values(ActivityType);
  const bipraValues = Object.values(Bipra);

  for (let i = 0; i < CONFIG.churches * CONFIG.activitiesPerChurch; i++) {
    const churchIndex = Math.floor(i / CONFIG.activitiesPerChurch);
    const church = churches[churchIndex];

    // Get memberships for this church
    const churchMemberships = memberships.filter(
      (m) => m.churchId === church.id,
    );

    if (churchMemberships.length === 0) continue;

    const supervisor = randomElement(churchMemberships) as any;
    const activityType = activityTypes[i % activityTypes.length];
    const bipra = bipraValues[i % bipraValues.length];

    const activityData = generateActivityData(activityType, bipra, i);

    // Create location first if needed
    let locationId = null;
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
        supervisorId: supervisor.id,
        locationId,
      },
    });

    activities.push(activity);
  }

  console.log(`✅ Created ${activities.length} activities`);
  return activities;
}

async function seedApprovers(activities: any[], memberships: any[]) {
  console.log('✔️ Creating approvers...');

  const approverStatuses = Object.values(ApprovalStatus);
  const approversData = [];

  for (const activity of activities) {
    // Get activity supervisor's church
    const supervisor = memberships.find((m) => m.id === activity.supervisorId);
    if (!supervisor) continue;

    // Get other memberships from the same church
    const churchMemberships = memberships.filter(
      (m) => m.churchId === supervisor.churchId && m.id !== supervisor.id,
    );

    if (churchMemberships.length === 0) continue;

    // Add 0-2 approvers per activity
    const numApprovers = Math.floor(
      seededRandom() * (CONFIG.maxApproversPerActivity + 1),
    );

    for (let i = 0; i < numApprovers && i < churchMemberships.length; i++) {
      const approver = churchMemberships[i] as any;
      const status = randomElement(approverStatuses);

      approversData.push({
        activityId: activity.id,
        membershipId: approver.id,
        status,
      });
    }
  }

  if (approversData.length > 0) {
    await prisma.approver.createMany({
      data: approversData,
      skipDuplicates: true,
    });
  }

  console.log(`✅ Created ${approversData.length} approvers`);
  return approversData;
}

async function seedRevenues(activities: any[], churches: any[]) {
  console.log('💰 Creating revenues...');

  const revenues = [];
  const paymentMethods = Object.values(PaymentMethod);

  // Group activities by church
  const activitiesByChurch = new Map<number, any[]>();
  for (const activity of activities) {
    const supervisor = await prisma.membership.findUnique({
      where: { id: activity.supervisorId },
    });
    if (supervisor && supervisor.churchId) {
      if (!activitiesByChurch.has(supervisor.churchId)) {
        activitiesByChurch.set(supervisor.churchId, []);
      }
      activitiesByChurch.get(supervisor.churchId)!.push({
        ...activity,
        churchId: supervisor.churchId,
      });
    }
  }

  // Ensure each church has exactly 2 activities with revenue
  for (const [churchId, churchActivities] of activitiesByChurch) {
    // Take the first 2 activities for revenue
    const revenueActivities = churchActivities.slice(0, 2);

    for (let i = 0; i < revenueActivities.length; i++) {
      const activity = revenueActivities[i];
      // Create variation in amounts and payment methods
      const amountMultiplier = i === 0 ? 1 : 3; // Second revenue is typically larger
      const baseAmount = Math.floor(seededRandom() * 3000000) + 500000; // 500k - 3.5M

      const revenue = await prisma.revenue.create({
        data: {
          accountNumber: `${Math.floor(1000000000 + seededRandom() * 9000000000)}`,
          amount: baseAmount * amountMultiplier,
          churchId: activity.churchId,
          activityId: activity.id,
          paymentMethod: paymentMethods[i % paymentMethods.length],
        },
      });

      revenues.push(revenue);
    }
  }

  console.log(`✅ Created ${revenues.length} revenues`);
  return revenues;
}

async function seedExpenses(activities: any[], churches: any[]) {
  console.log('💸 Creating expenses...');

  const expenses = [];
  const paymentMethods = Object.values(PaymentMethod);

  // Get activities that already have revenue
  const activitiesWithRevenue = await prisma.revenue.findMany({
    select: { activityId: true },
  });
  const revenueActivityIds = new Set(
    activitiesWithRevenue.map((r) => r.activityId),
  );

  // Group activities by church (excluding those with revenue)
  const activitiesByChurch = new Map<number, any[]>();
  for (const activity of activities) {
    if (revenueActivityIds.has(activity.id)) continue;

    const supervisor = await prisma.membership.findUnique({
      where: { id: activity.supervisorId },
    });
    if (supervisor && supervisor.churchId) {
      if (!activitiesByChurch.has(supervisor.churchId)) {
        activitiesByChurch.set(supervisor.churchId, []);
      }
      activitiesByChurch.get(supervisor.churchId)!.push({
        ...activity,
        churchId: supervisor.churchId,
      });
    }
  }

  // Ensure each church has exactly 2 activities with expense
  for (const [churchId, churchActivities] of activitiesByChurch) {
    // Take the first 2 activities for expense
    const expenseActivities = churchActivities.slice(0, 2);

    for (let i = 0; i < expenseActivities.length; i++) {
      const activity = expenseActivities[i];
      // Create variation in amounts and payment methods
      const amountMultiplier = i === 0 ? 0.5 : 1.5; // Vary the expense amounts
      const baseAmount = Math.floor(seededRandom() * 2000000) + 300000; // 300k - 2.3M

      const expense = await prisma.expense.create({
        data: {
          accountNumber: `${Math.floor(1000000000 + seededRandom() * 9000000000)}`,
          amount: Math.floor(baseAmount * amountMultiplier),
          churchId: activity.churchId,
          activityId: activity.id,
          paymentMethod: paymentMethods[(i + 1) % paymentMethods.length], // Different from revenue
        },
      });

      expenses.push(expense);
    }
  }

  console.log(`✅ Created ${expenses.length} expenses`);
  return expenses;
}

async function seedSongs() {
  console.log('🎵 Creating songs...');

  const books = Object.values(Book);
  const songs = [];

  for (const book of books) {
    const titles = SONG_TITLES[book];

    for (let i = 0; i < CONFIG.songsPerBook; i++) {
      const title = titles[i % titles.length];
      const index = books.indexOf(book) * 100 + i + 1;

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
              {
                index: 2,
                name: 'Reff',
                content: `Lirik reff untuk ${title}`,
              },
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

  // Create files for reports (2 per church) and documents (2 per church)
  const totalFiles = CONFIG.churches * (CONFIG.reportsPerChurch + 2);

  for (let i = 0; i < totalFiles; i++) {
    const extension = randomElement(fileExtensions);
    const baseUrl = randomElement(baseUrls);
    const fileName = `file-${Date.now()}-${i}.${extension}`;
    const sizeInKB = parseFloat((seededRandom() * 5000 + 100).toFixed(2)); // 100KB to 5MB

    const file = await prisma.fileManager.create({
      data: {
        sizeInKB,
        url: `https://files.testfile.org/PDF/10MB-TESTFILE.ORG.pdf`,
      },
    });

    files.push(file);
  }

  console.log(`✅ Created ${files.length} files`);
  return files;
}

async function seedReports(churches: any[], files: any[]) {
  console.log('📊 Creating reports...');

  const reports = [];
  const reportTypes = [
    'Laporan Keuangan',
    'Laporan Kegiatan',
    'Laporan Jemaat',
    'Laporan Kolom',
    'Laporan Tahunan',
  ];
  const generatedByValues = Object.values(GeneratedBy);
  let fileIndex = 0;

  for (let i = 0; i < CONFIG.churches * CONFIG.reportsPerChurch; i++) {
    const churchIndex = Math.floor(i / CONFIG.reportsPerChurch);
    const church = churches[churchIndex];
    const reportType = randomElement(reportTypes);
    const generatedBy = generatedByValues[i % generatedByValues.length];
    const year = 2024 - Math.floor(seededRandom() * 3); // 2022-2024
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

async function seedDocuments(churches: any[], files: any[]) {
  console.log('📄 Creating documents...');

  const documents = [];
  let fileIndex = CONFIG.churches * CONFIG.reportsPerChurch; // Start after report files

  const documentTypes = [
    'Surat Keterangan Baptis',
    'Surat Keterangan Sidi',
    'Surat Keterangan Nikah',
    'Surat Keterangan Jemaat',
    'Surat Rekomendasi',
    'Surat Pengantar',
  ];

  for (let i = 0; i < CONFIG.churches * CONFIG.documentsPerChurch; i++) {
    const churchIndex = Math.floor(i / CONFIG.documentsPerChurch);
    const church = churches[churchIndex];
    const docIndex = i % CONFIG.documentsPerChurch;

    // Every 3rd document (docIndex === 2) will have no file
    const hasFile = docIndex !== 2;
    const accountNumber = `DOC-${String(church.id).padStart(3, '0')}-${String(i).padStart(4, '0')}`;
    const documentType = randomElement(documentTypes);

    const document = await prisma.document.create({
      data: {
        name: `${documentType} - ${church.name}`,
        accountNumber,
        churchId: church.id,
        fileId: hasFile ? files[fileIndex]?.id : null,
      },
    });

    documents.push(document);
    if (hasFile) fileIndex++;
  }

  console.log(`✅ Created ${documents.length} documents`);
  return documents;
}

async function seedChurchRequests(accounts: any[]) {
  console.log('⛪ Creating church requests...');

  const churchRequests = [];

  // Get accounts without membership (they would request churches)
  const accountsWithoutMembership = accounts.filter(
    (account) => !account.membership,
  );

  // Create 2-3 church requests from accounts without membership
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
  accounts: any[],
  churches: any[],
  memberships: any[],
  activities: any[],
  songs: any[],
) {
  console.log('\n📊 Seed Summary:');
  console.log('================');
  console.log(`🏛️  Churches: ${churches.length}`);
  console.log(`👤 Accounts: ${accounts.length}`);
  console.log(`🤝 Memberships: ${memberships.length}`);
  console.log(
    `📋 Membership Positions: ${await prisma.membershipPosition.count()}`,
  );
  console.log(`📜 Approval Rules: ${await prisma.approvalRule.count()}`);
  console.log(`📅 Activities: ${activities.length}`);
  console.log(`💰 Revenues: ${await prisma.revenue.count()}`);
  console.log(`💸 Expenses: ${await prisma.expense.count()}`);
  console.log(`🎵 Songs: ${songs.length}`);
  console.log(`📁 Files: ${await prisma.fileManager.count()}`);
  console.log(`📊 Reports: ${await prisma.report.count()}`);
  console.log(`📄 Documents: ${await prisma.document.count()}`);
  console.log(`⛪ Church Requests: ${await prisma.churchRequest.count()}`);

  // Enum coverage
  console.log('\n📋 Enum Coverage:');
  console.log('================');

  const genderCounts = await prisma.account.groupBy({
    by: ['gender'],
    _count: true,
  });
  console.log('Gender:', genderCounts);

  const maritalStatusCounts = await prisma.account.groupBy({
    by: ['maritalStatus'],
    _count: true,
  });
  console.log('Marital Status:', maritalStatusCounts);

  const bipraCounts = await prisma.activity.groupBy({
    by: ['bipra'],
    _count: true,
  });
  console.log('Bipra:', bipraCounts);

  const activityTypeCounts = await prisma.activity.groupBy({
    by: ['activityType'],
    _count: true,
  });
  console.log('Activity Type:', activityTypeCounts);

  const bookCounts = await prisma.song.groupBy({
    by: ['book'],
    _count: true,
  });
  console.log('Book:', bookCounts);

  const approverStatusCounts = await prisma.approver.groupBy({
    by: ['status'],
    _count: true,
  });
  console.log('Approval Status:', approverStatusCounts);

  const revenuePaymentMethodCounts = await prisma.revenue.groupBy({
    by: ['paymentMethod'],
    _count: true,
  });
  console.log('Revenue Payment Method:', revenuePaymentMethodCounts);

  const expensePaymentMethodCounts = await prisma.expense.groupBy({
    by: ['paymentMethod'],
    _count: true,
  });
  console.log('Expense Payment Method:', expensePaymentMethodCounts);

  const generatedByCounts = await prisma.report.groupBy({
    by: ['generatedBy'],
    _count: true,
  });
  console.log('Report Generated By:', generatedByCounts);

  // Documents with and without files
  const documentsWithFiles = await prisma.document.count({
    where: { fileId: { not: null } },
  });
  const documentsWithoutFiles = await prisma.document.count({
    where: { fileId: null },
  });
  console.log(
    `\n📄 Documents: ${documentsWithFiles} with files, ${documentsWithoutFiles} without files`,
  );

  // Accounts without membership
  const accountsWithoutMembership = await prisma.account.findMany({
    where: { membership: { is: null } },
  });
  console.log(
    `\n👤 Accounts without membership: ${accountsWithoutMembership.length}`,
  );

  // Top churches by member count
  const topChurches = await prisma.church.findMany({
    include: {
      _count: {
        select: { memberships: true, columns: true },
      },
    },
    orderBy: { memberships: { _count: 'desc' } },
    take: 5,
  });

  console.log('\n🏆 Top 5 Churches by Member Count:');
  topChurches.forEach((church, index) => {
    console.log(
      `   ${index + 1}. ${church.name}: ${church._count.memberships} members, ${church._count.columns} columns`,
    );
  });
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
    // Reset seed for consistent results
    seed = 12345;

    // Clean database
    await cleanDatabase();

    // Generate password hash once
    const passwordHash = await bcrypt.hash(CONFIG.defaultPassword, 12);

    // Seed all entities
    const accounts = await seedAccounts(passwordHash);
    const churches = await seedChurches();
    const memberships = await seedMemberships(accounts, churches);
    await seedMembershipPositions(memberships);
    await seedApprovalRules(churches);
    const activities = await seedActivities(memberships, churches);
    await seedApprovers(activities, memberships);
    await seedRevenues(activities, churches);
    await seedExpenses(activities, churches);
    const songs = await seedSongs();
    const files = await seedFiles();
    await seedReports(churches, files);
    await seedDocuments(churches, files);
    await seedChurchRequests(accounts);

    // Print summary
    await printSummary(accounts, churches, memberships, activities, songs);

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
