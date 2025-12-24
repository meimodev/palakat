-- AlterTable
ALTER TABLE "Report" ADD COLUMN     "createdById" INTEGER;

-- CreateIndex
CREATE INDEX "Report_createdById_idx" ON "Report"("createdById");

-- AddForeignKey
ALTER TABLE "Report" ADD CONSTRAINT "Report_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;
