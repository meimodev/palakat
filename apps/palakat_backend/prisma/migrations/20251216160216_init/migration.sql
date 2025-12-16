-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE');

-- CreateEnum
CREATE TYPE "Bipra" AS ENUM ('PKB', 'WKI', 'PMD', 'RMJ', 'ASM');

-- CreateEnum
CREATE TYPE "ActivityType" AS ENUM ('SERVICE', 'EVENT', 'ANNOUNCEMENT');

-- CreateEnum
CREATE TYPE "Book" AS ENUM ('NKB', 'NNBT', 'KJ', 'DSL');

-- CreateEnum
CREATE TYPE "ApprovalStatus" AS ENUM ('UNCONFIRMED', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "RequestStatus" AS ENUM ('TODO', 'DOING', 'DONE');

-- CreateEnum
CREATE TYPE "MaritalStatus" AS ENUM ('MARRIED', 'SINGLE');

-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('CASH', 'CASHLESS');

-- CreateEnum
CREATE TYPE "Reminder" AS ENUM ('TEN_MINUTES', 'THIRTY_MINUTES', 'ONE_HOUR', 'TWO_HOURS');

-- CreateEnum
CREATE TYPE "FinancialType" AS ENUM ('REVENUE', 'EXPENSE');

-- CreateEnum
CREATE TYPE "NotificationType" AS ENUM ('ACTIVITY_CREATED', 'APPROVAL_REQUIRED', 'APPROVAL_CONFIRMED', 'APPROVAL_REJECTED');

-- CreateEnum
CREATE TYPE "GeneratedBy" AS ENUM ('MANUAL', 'SYSTEM');

-- CreateEnum
CREATE TYPE "FileProvider" AS ENUM ('FIREBASE_STORAGE');

-- CreateTable
CREATE TABLE "Church" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "phoneNumber" TEXT,
    "email" TEXT,
    "description" TEXT,
    "documentAccountNumber" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "locationId" INTEGER NOT NULL,

    CONSTRAINT "Church_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Column" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "churchId" INTEGER,

    CONSTRAINT "Column_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Membership" (
    "id" SERIAL NOT NULL,
    "baptize" BOOLEAN NOT NULL DEFAULT false,
    "sidi" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "accountId" INTEGER NOT NULL,
    "columnId" INTEGER,
    "churchId" INTEGER,

    CONSTRAINT "Membership_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "MembershipPosition" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "membershipId" INTEGER,
    "churchId" INTEGER,
    "approvalRuleId" INTEGER,

    CONSTRAINT "MembershipPosition_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Account" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "email" TEXT,
    "passwordHash" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "claimed" BOOLEAN NOT NULL DEFAULT false,
    "failedLoginAttempts" INTEGER NOT NULL DEFAULT 0,
    "lockUntil" TIMESTAMP(3),
    "refreshTokenHash" TEXT,
    "refreshTokenExpiresAt" TIMESTAMP(3),
    "refreshTokenJti" TEXT,
    "gender" "Gender" NOT NULL,
    "maritalStatus" "MaritalStatus" NOT NULL,
    "dob" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ApprovalRule" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "active" BOOLEAN NOT NULL DEFAULT true,
    "activityType" "ActivityType",
    "financialType" "FinancialType",
    "financialAccountNumberId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "churchId" INTEGER NOT NULL,

    CONSTRAINT "ApprovalRule_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Activity" (
    "id" SERIAL NOT NULL,
    "supervisorId" INTEGER NOT NULL,
    "columnId" INTEGER,
    "bipra" "Bipra",
    "title" TEXT NOT NULL,
    "description" TEXT,
    "locationId" INTEGER,
    "date" TIMESTAMP(3),
    "note" TEXT,
    "fileId" INTEGER,
    "activityType" "ActivityType" NOT NULL,
    "reminder" "Reminder",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Activity_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Revenue" (
    "id" SERIAL NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "churchId" INTEGER NOT NULL,
    "activityId" INTEGER,
    "paymentMethod" "PaymentMethod" NOT NULL,
    "financialAccountNumberId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Revenue_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Expense" (
    "id" SERIAL NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "amount" INTEGER NOT NULL,
    "churchId" INTEGER NOT NULL,
    "activityId" INTEGER,
    "paymentMethod" "PaymentMethod" NOT NULL,
    "financialAccountNumberId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Expense_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Location" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Location_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Approver" (
    "id" SERIAL NOT NULL,
    "membershipId" INTEGER NOT NULL,
    "activityId" INTEGER NOT NULL,
    "status" "ApprovalStatus" NOT NULL DEFAULT 'UNCONFIRMED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Approver_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Song" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "index" INTEGER NOT NULL,
    "book" "Book" NOT NULL,
    "link" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Song_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SongPart" (
    "id" SERIAL NOT NULL,
    "index" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "content" TEXT NOT NULL,
    "songId" INTEGER NOT NULL,

    CONSTRAINT "SongPart_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FileManager" (
    "id" SERIAL NOT NULL,
    "provider" "FileProvider" NOT NULL DEFAULT 'FIREBASE_STORAGE',
    "bucket" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "sizeInKB" DOUBLE PRECISION NOT NULL,
    "contentType" TEXT,
    "originalName" TEXT,
    "churchId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FileManager_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Report" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "generatedBy" "GeneratedBy" NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "churchId" INTEGER NOT NULL,
    "fileId" INTEGER NOT NULL,

    CONSTRAINT "Report_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Document" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "churchId" INTEGER NOT NULL,
    "fileId" INTEGER,

    CONSTRAINT "Document_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ChurchRequest" (
    "id" SERIAL NOT NULL,
    "churchName" TEXT NOT NULL,
    "churchAddress" TEXT NOT NULL,
    "contactPerson" TEXT NOT NULL,
    "contactPhone" TEXT NOT NULL,
    "status" "RequestStatus" NOT NULL DEFAULT 'TODO',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "requesterId" INTEGER NOT NULL,

    CONSTRAINT "ChurchRequest_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FinancialAccountNumber" (
    "id" SERIAL NOT NULL,
    "accountNumber" TEXT NOT NULL,
    "description" TEXT,
    "type" "FinancialType" NOT NULL,
    "churchId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FinancialAccountNumber_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Notification" (
    "id" SERIAL NOT NULL,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "type" "NotificationType" NOT NULL,
    "recipient" TEXT NOT NULL,
    "activityId" INTEGER,
    "isRead" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Notification_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Church_locationId_key" ON "Church"("locationId");

-- CreateIndex
CREATE INDEX "Church_name_idx" ON "Church"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Column_churchId_name_key" ON "Column"("churchId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "Membership_accountId_key" ON "Membership"("accountId");

-- CreateIndex
CREATE INDEX "Membership_churchId_columnId_idx" ON "Membership"("churchId", "columnId");

-- CreateIndex
CREATE UNIQUE INDEX "MembershipPosition_churchId_name_key" ON "MembershipPosition"("churchId", "name");

-- CreateIndex
CREATE UNIQUE INDEX "Account_phone_key" ON "Account"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "Account_email_key" ON "Account"("email");

-- CreateIndex
CREATE UNIQUE INDEX "ApprovalRule_financialAccountNumberId_key" ON "ApprovalRule"("financialAccountNumberId");

-- CreateIndex
CREATE INDEX "ApprovalRule_churchId_idx" ON "ApprovalRule"("churchId");

-- CreateIndex
CREATE INDEX "ApprovalRule_active_idx" ON "ApprovalRule"("active");

-- CreateIndex
CREATE INDEX "ApprovalRule_activityType_idx" ON "ApprovalRule"("activityType");

-- CreateIndex
CREATE INDEX "ApprovalRule_financialType_idx" ON "ApprovalRule"("financialType");

-- CreateIndex
CREATE UNIQUE INDEX "Activity_fileId_key" ON "Activity"("fileId");

-- CreateIndex
CREATE INDEX "Activity_date_idx" ON "Activity"("date");

-- CreateIndex
CREATE INDEX "Activity_supervisorId_idx" ON "Activity"("supervisorId");

-- CreateIndex
CREATE INDEX "Activity_supervisorId_date_idx" ON "Activity"("supervisorId", "date");

-- CreateIndex
CREATE INDEX "Activity_columnId_idx" ON "Activity"("columnId");

-- CreateIndex
CREATE INDEX "Activity_activityType_idx" ON "Activity"("activityType");

-- CreateIndex
CREATE INDEX "Activity_bipra_idx" ON "Activity"("bipra");

-- CreateIndex
CREATE UNIQUE INDEX "Revenue_activityId_key" ON "Revenue"("activityId");

-- CreateIndex
CREATE INDEX "Revenue_financialAccountNumberId_idx" ON "Revenue"("financialAccountNumberId");

-- CreateIndex
CREATE UNIQUE INDEX "Expense_activityId_key" ON "Expense"("activityId");

-- CreateIndex
CREATE INDEX "Expense_financialAccountNumberId_idx" ON "Expense"("financialAccountNumberId");

-- CreateIndex
CREATE INDEX "Approver_activityId_idx" ON "Approver"("activityId");

-- CreateIndex
CREATE INDEX "Approver_membershipId_idx" ON "Approver"("membershipId");

-- CreateIndex
CREATE INDEX "Approver_status_idx" ON "Approver"("status");

-- CreateIndex
CREATE UNIQUE INDEX "Approver_activityId_membershipId_key" ON "Approver"("activityId", "membershipId");

-- CreateIndex
CREATE UNIQUE INDEX "Song_index_key" ON "Song"("index");

-- CreateIndex
CREATE INDEX "SongPart_songId_idx" ON "SongPart"("songId");

-- CreateIndex
CREATE UNIQUE INDEX "SongPart_songId_index_key" ON "SongPart"("songId", "index");

-- CreateIndex
CREATE INDEX "FileManager_churchId_idx" ON "FileManager"("churchId");

-- CreateIndex
CREATE INDEX "FileManager_provider_idx" ON "FileManager"("provider");

-- CreateIndex
CREATE UNIQUE INDEX "FileManager_bucket_path_key" ON "FileManager"("bucket", "path");

-- CreateIndex
CREATE UNIQUE INDEX "Report_fileId_key" ON "Report"("fileId");

-- CreateIndex
CREATE INDEX "Report_churchId_idx" ON "Report"("churchId");

-- CreateIndex
CREATE INDEX "Report_generatedBy_idx" ON "Report"("generatedBy");

-- CreateIndex
CREATE UNIQUE INDEX "Document_fileId_key" ON "Document"("fileId");

-- CreateIndex
CREATE INDEX "Document_churchId_idx" ON "Document"("churchId");

-- CreateIndex
CREATE INDEX "Document_accountNumber_idx" ON "Document"("accountNumber");

-- CreateIndex
CREATE UNIQUE INDEX "ChurchRequest_requesterId_key" ON "ChurchRequest"("requesterId");

-- CreateIndex
CREATE INDEX "ChurchRequest_requesterId_idx" ON "ChurchRequest"("requesterId");

-- CreateIndex
CREATE INDEX "ChurchRequest_createdAt_idx" ON "ChurchRequest"("createdAt");

-- CreateIndex
CREATE INDEX "ChurchRequest_status_idx" ON "ChurchRequest"("status");

-- CreateIndex
CREATE INDEX "FinancialAccountNumber_churchId_idx" ON "FinancialAccountNumber"("churchId");

-- CreateIndex
CREATE INDEX "FinancialAccountNumber_accountNumber_idx" ON "FinancialAccountNumber"("accountNumber");

-- CreateIndex
CREATE INDEX "FinancialAccountNumber_type_idx" ON "FinancialAccountNumber"("type");

-- CreateIndex
CREATE UNIQUE INDEX "FinancialAccountNumber_churchId_accountNumber_key" ON "FinancialAccountNumber"("churchId", "accountNumber");

-- CreateIndex
CREATE INDEX "Notification_recipient_idx" ON "Notification"("recipient");

-- CreateIndex
CREATE INDEX "Notification_isRead_idx" ON "Notification"("isRead");

-- CreateIndex
CREATE INDEX "Notification_type_idx" ON "Notification"("type");

-- CreateIndex
CREATE INDEX "Notification_activityId_idx" ON "Notification"("activityId");

-- CreateIndex
CREATE INDEX "Notification_createdAt_idx" ON "Notification"("createdAt");

-- AddForeignKey
ALTER TABLE "Church" ADD CONSTRAINT "Church_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Column" ADD CONSTRAINT "Column_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Membership" ADD CONSTRAINT "Membership_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Membership" ADD CONSTRAINT "Membership_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Membership" ADD CONSTRAINT "Membership_columnId_fkey" FOREIGN KEY ("columnId") REFERENCES "Column"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipPosition" ADD CONSTRAINT "MembershipPosition_membershipId_fkey" FOREIGN KEY ("membershipId") REFERENCES "Membership"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipPosition" ADD CONSTRAINT "MembershipPosition_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipPosition" ADD CONSTRAINT "MembershipPosition_approvalRuleId_fkey" FOREIGN KEY ("approvalRuleId") REFERENCES "ApprovalRule"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApprovalRule" ADD CONSTRAINT "ApprovalRule_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ApprovalRule" ADD CONSTRAINT "ApprovalRule_financialAccountNumberId_fkey" FOREIGN KEY ("financialAccountNumberId") REFERENCES "FinancialAccountNumber"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_supervisorId_fkey" FOREIGN KEY ("supervisorId") REFERENCES "Membership"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_columnId_fkey" FOREIGN KEY ("columnId") REFERENCES "Column"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_locationId_fkey" FOREIGN KEY ("locationId") REFERENCES "Location"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_fileId_fkey" FOREIGN KEY ("fileId") REFERENCES "FileManager"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Revenue" ADD CONSTRAINT "Revenue_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Revenue" ADD CONSTRAINT "Revenue_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Revenue" ADD CONSTRAINT "Revenue_financialAccountNumberId_fkey" FOREIGN KEY ("financialAccountNumberId") REFERENCES "FinancialAccountNumber"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Expense" ADD CONSTRAINT "Expense_financialAccountNumberId_fkey" FOREIGN KEY ("financialAccountNumberId") REFERENCES "FinancialAccountNumber"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Approver" ADD CONSTRAINT "Approver_membershipId_fkey" FOREIGN KEY ("membershipId") REFERENCES "Membership"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Approver" ADD CONSTRAINT "Approver_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SongPart" ADD CONSTRAINT "SongPart_songId_fkey" FOREIGN KEY ("songId") REFERENCES "Song"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FileManager" ADD CONSTRAINT "FileManager_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_fileId_fkey" FOREIGN KEY ("fileId") REFERENCES "FileManager"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Document" ADD CONSTRAINT "Document_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Document" ADD CONSTRAINT "Document_fileId_fkey" FOREIGN KEY ("fileId") REFERENCES "FileManager"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChurchRequest" ADD CONSTRAINT "ChurchRequest_requesterId_fkey" FOREIGN KEY ("requesterId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FinancialAccountNumber" ADD CONSTRAINT "FinancialAccountNumber_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Notification" ADD CONSTRAINT "Notification_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE SET NULL ON UPDATE CASCADE;
