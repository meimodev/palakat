-- CreateEnum
CREATE TYPE "ReportJobStatus" AS ENUM ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'REPORT_READY';
ALTER TYPE "NotificationType" ADD VALUE 'REPORT_FAILED';

-- CreateTable
CREATE TABLE "ReportJob" (
    "id" SERIAL NOT NULL,
    "status" "ReportJobStatus" NOT NULL DEFAULT 'PENDING',
    "type" "ReportGenerateType" NOT NULL,
    "format" "ReportFormat" NOT NULL DEFAULT 'PDF',
    "params" JSONB,
    "errorMessage" TEXT,
    "progress" INTEGER NOT NULL DEFAULT 0,
    "churchId" INTEGER NOT NULL,
    "requestedById" INTEGER NOT NULL,
    "reportId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "ReportJob_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ReportJob_reportId_key" ON "ReportJob"("reportId");

-- CreateIndex
CREATE INDEX "ReportJob_status_idx" ON "ReportJob"("status");

-- CreateIndex
CREATE INDEX "ReportJob_churchId_idx" ON "ReportJob"("churchId");

-- CreateIndex
CREATE INDEX "ReportJob_requestedById_idx" ON "ReportJob"("requestedById");

-- CreateIndex
CREATE INDEX "ReportJob_status_createdAt_idx" ON "ReportJob"("status", "createdAt");

-- AddForeignKey
ALTER TABLE "ReportJob" ADD CONSTRAINT "ReportJob_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReportJob" ADD CONSTRAINT "ReportJob_requestedById_fkey" FOREIGN KEY ("requestedById") REFERENCES "Account"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ReportJob" ADD CONSTRAINT "ReportJob_reportId_fkey" FOREIGN KEY ("reportId") REFERENCES "Report"("id") ON DELETE SET NULL ON UPDATE CASCADE;
