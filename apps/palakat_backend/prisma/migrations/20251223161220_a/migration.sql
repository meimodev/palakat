-- CreateEnum
CREATE TYPE "CashMutationType" AS ENUM ('IN', 'OUT', 'TRANSFER', 'ADJUSTMENT');

-- CreateEnum
CREATE TYPE "CashMutationReferenceType" AS ENUM ('REVENUE', 'EXPENSE', 'MANUAL', 'TRANSFER');

-- CreateEnum
CREATE TYPE "DocumentInput" AS ENUM ('INCOME', 'OUTCOME');

-- AlterEnum
ALTER TYPE "ReportGenerateType" ADD VALUE 'FINANCIAL';

-- AlterTable
ALTER TABLE "Document" ADD COLUMN     "input" "DocumentInput" NOT NULL DEFAULT 'INCOME';

-- CreateTable
CREATE TABLE "CashAccount" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'IDR',
    "openingBalance" INTEGER NOT NULL DEFAULT 0,
    "churchId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CashAccount_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CashMutation" (
    "id" SERIAL NOT NULL,
    "type" "CashMutationType" NOT NULL,
    "amount" INTEGER NOT NULL,
    "fromAccountId" INTEGER,
    "toAccountId" INTEGER,
    "happenedAt" TIMESTAMP(3) NOT NULL,
    "note" TEXT,
    "referenceType" "CashMutationReferenceType",
    "referenceId" INTEGER,
    "churchId" INTEGER NOT NULL,
    "createdById" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CashMutation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "CashAccount_churchId_idx" ON "CashAccount"("churchId");

-- CreateIndex
CREATE UNIQUE INDEX "CashAccount_churchId_name_key" ON "CashAccount"("churchId", "name");

-- CreateIndex
CREATE INDEX "CashMutation_churchId_idx" ON "CashMutation"("churchId");

-- CreateIndex
CREATE INDEX "CashMutation_happenedAt_idx" ON "CashMutation"("happenedAt");

-- CreateIndex
CREATE INDEX "CashMutation_type_idx" ON "CashMutation"("type");

-- CreateIndex
CREATE INDEX "CashMutation_fromAccountId_idx" ON "CashMutation"("fromAccountId");

-- CreateIndex
CREATE INDEX "CashMutation_toAccountId_idx" ON "CashMutation"("toAccountId");

-- AddForeignKey
ALTER TABLE "CashAccount" ADD CONSTRAINT "CashAccount_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CashMutation" ADD CONSTRAINT "CashMutation_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CashMutation" ADD CONSTRAINT "CashMutation_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CashMutation" ADD CONSTRAINT "CashMutation_fromAccountId_fkey" FOREIGN KEY ("fromAccountId") REFERENCES "CashAccount"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CashMutation" ADD CONSTRAINT "CashMutation_toAccountId_fkey" FOREIGN KEY ("toAccountId") REFERENCES "CashAccount"("id") ON DELETE SET NULL ON UPDATE CASCADE;
