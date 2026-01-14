-- AlterTable
ALTER TABLE "Report" ADD COLUMN     "publicId" TEXT,
ADD COLUMN     "verifyTokenHash" TEXT,
ADD COLUMN     "revokedAt" TIMESTAMP(3),
ADD COLUMN     "revokedReason" TEXT,
ADD COLUMN     "fileSha256" TEXT;

-- CreateIndex
CREATE UNIQUE INDEX "Report_publicId_key" ON "Report"("publicId");
