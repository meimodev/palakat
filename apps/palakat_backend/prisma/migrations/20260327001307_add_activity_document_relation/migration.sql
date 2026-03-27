-- AlterTable
ALTER TABLE "Document" ADD COLUMN     "activityId" INTEGER;

-- CreateIndex
CREATE UNIQUE INDEX "Document_activityId_key" ON "Document"("activityId");

-- CreateIndex
CREATE INDEX "ChurchPermissionPolicy_churchId_idx" ON "ChurchPermissionPolicy"("churchId");

-- AddForeignKey
ALTER TABLE "Document" ADD CONSTRAINT "Document_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE CASCADE ON UPDATE CASCADE;

