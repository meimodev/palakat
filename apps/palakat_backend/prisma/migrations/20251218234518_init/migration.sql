/*
  Warnings:

  - A unique constraint covering the columns `[book,index]` on the table `Song` will be added. If there are existing duplicate values, this will fail.

*/
-- CreateEnum
CREATE TYPE "AccountRole" AS ENUM ('USER', 'SUPER_ADMIN');

-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "NotificationType" ADD VALUE 'CHURCH_REQUEST_APPROVED';
ALTER TYPE "NotificationType" ADD VALUE 'CHURCH_REQUEST_REJECTED';

-- AlterEnum
ALTER TYPE "RequestStatus" ADD VALUE 'REJECTED';

-- DropIndex
DROP INDEX "Song_index_key";

-- AlterTable
ALTER TABLE "Account" ADD COLUMN     "role" "AccountRole" NOT NULL DEFAULT 'USER';

-- AlterTable
ALTER TABLE "ChurchRequest" ADD COLUMN     "approvedChurchId" INTEGER,
ADD COLUMN     "decisionNote" TEXT,
ADD COLUMN     "reviewedAt" TIMESTAMP(3),
ADD COLUMN     "reviewedById" INTEGER;

-- CreateIndex
CREATE UNIQUE INDEX "Song_book_index_key" ON "Song"("book", "index");

-- AddForeignKey
ALTER TABLE "ChurchRequest" ADD CONSTRAINT "ChurchRequest_reviewedById_fkey" FOREIGN KEY ("reviewedById") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChurchRequest" ADD CONSTRAINT "ChurchRequest_approvedChurchId_fkey" FOREIGN KEY ("approvedChurchId") REFERENCES "Church"("id") ON DELETE SET NULL ON UPDATE CASCADE;
