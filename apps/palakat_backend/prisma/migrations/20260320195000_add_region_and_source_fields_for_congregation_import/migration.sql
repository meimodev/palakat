-- CreateTable
CREATE TABLE "Region" (
    "id" SERIAL NOT NULL,
    "sourceRegionId" INTEGER,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Region_pkey" PRIMARY KEY ("id")
);

-- AlterTable
ALTER TABLE "Church"
ADD COLUMN "sourceChurchId" INTEGER,
ADD COLUMN "regionId" INTEGER;

-- AlterTable
ALTER TABLE "Column"
ADD COLUMN "sourceColumnId" INTEGER;

-- AlterTable
ALTER TABLE "Account"
ADD COLUMN "sourceAccountId" INTEGER;

-- CreateIndex
CREATE UNIQUE INDEX "Region_sourceRegionId_key" ON "Region"("sourceRegionId");

-- CreateIndex
CREATE INDEX "Region_name_idx" ON "Region"("name");

-- CreateIndex
CREATE UNIQUE INDEX "Church_sourceChurchId_key" ON "Church"("sourceChurchId");

-- CreateIndex
CREATE INDEX "Church_regionId_idx" ON "Church"("regionId");

-- CreateIndex
CREATE UNIQUE INDEX "Column_sourceColumnId_key" ON "Column"("sourceColumnId");

-- CreateIndex
CREATE UNIQUE INDEX "Account_sourceAccountId_key" ON "Account"("sourceAccountId");

-- AddForeignKey
ALTER TABLE "Church"
ADD CONSTRAINT "Church_regionId_fkey" FOREIGN KEY ("regionId") REFERENCES "Region"("id") ON DELETE SET NULL ON UPDATE CASCADE;
