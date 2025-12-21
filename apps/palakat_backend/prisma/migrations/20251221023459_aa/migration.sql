-- CreateEnum
CREATE TYPE "ReportGenerateType" AS ENUM ('INCOMING_DOCUMENT', 'CONGREGATION', 'SERVICES', 'ACTIVITY');

-- CreateEnum
CREATE TYPE "ReportFormat" AS ENUM ('PDF', 'XLSX');

-- AlterTable
ALTER TABLE "Report" ADD COLUMN     "format" "ReportFormat" NOT NULL DEFAULT 'PDF',
ADD COLUMN     "params" JSONB,
ADD COLUMN     "type" "ReportGenerateType" NOT NULL DEFAULT 'INCOMING_DOCUMENT';

-- CreateTable
CREATE TABLE "ChurchLetterhead" (
    "id" SERIAL NOT NULL,
    "churchId" INTEGER NOT NULL,
    "logoFileId" INTEGER,
    "title" TEXT,
    "line1" TEXT,
    "line2" TEXT,
    "line3" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ChurchLetterhead_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ChurchLetterhead_churchId_key" ON "ChurchLetterhead"("churchId");

-- CreateIndex
CREATE UNIQUE INDEX "ChurchLetterhead_logoFileId_key" ON "ChurchLetterhead"("logoFileId");

-- CreateIndex
CREATE INDEX "ChurchLetterhead_churchId_idx" ON "ChurchLetterhead"("churchId");

-- CreateIndex
CREATE INDEX "Report_type_idx" ON "Report"("type");

-- CreateIndex
CREATE INDEX "Report_format_idx" ON "Report"("format");

-- AddForeignKey
ALTER TABLE "ChurchLetterhead" ADD CONSTRAINT "ChurchLetterhead_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChurchLetterhead" ADD CONSTRAINT "ChurchLetterhead_logoFileId_fkey" FOREIGN KEY ("logoFileId") REFERENCES "FileManager"("id") ON DELETE SET NULL ON UPDATE CASCADE;
