-- AlterTable
ALTER TABLE "Activity" ADD COLUMN     "documentId" INTEGER;

-- CreateIndex
CREATE INDEX "Activity_documentId_idx" ON "Activity"("documentId");

-- CreateIndex
CREATE INDEX "ChurchPermissionPolicy_churchId_idx" ON "ChurchPermissionPolicy"("churchId");

-- AddForeignKey
ALTER TABLE "Activity" ADD CONSTRAINT "Activity_documentId_fkey" FOREIGN KEY ("documentId") REFERENCES "Document"("id") ON DELETE SET NULL ON UPDATE CASCADE;
