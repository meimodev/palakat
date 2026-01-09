-- CreateEnum
CREATE TYPE "MembershipInvitationStatus" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateTable
CREATE TABLE "MembershipInvitation" (
    "id" SERIAL NOT NULL,
    "inviterId" INTEGER NOT NULL,
    "inviteeId" INTEGER NOT NULL,
    "churchId" INTEGER NOT NULL,
    "columnId" INTEGER NOT NULL,
    "baptize" BOOLEAN NOT NULL DEFAULT false,
    "sidi" BOOLEAN NOT NULL DEFAULT false,
    "status" "MembershipInvitationStatus" NOT NULL DEFAULT 'PENDING',
    "rejectedReason" TEXT,
    "rejectedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "MembershipInvitation_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "MembershipInvitation_inviterId_idx" ON "MembershipInvitation"("inviterId");

-- CreateIndex
CREATE INDEX "MembershipInvitation_inviteeId_idx" ON "MembershipInvitation"("inviteeId");

-- CreateIndex
CREATE INDEX "MembershipInvitation_inviteeId_status_idx" ON "MembershipInvitation"("inviteeId", "status");

-- CreateIndex
CREATE INDEX "MembershipInvitation_status_idx" ON "MembershipInvitation"("status");

-- CreateIndex
CREATE INDEX "MembershipInvitation_churchId_idx" ON "MembershipInvitation"("churchId");

-- CreateIndex
CREATE INDEX "MembershipInvitation_columnId_idx" ON "MembershipInvitation"("columnId");

-- CreateIndex
CREATE INDEX "MembershipInvitation_createdAt_idx" ON "MembershipInvitation"("createdAt");

-- AddForeignKey
ALTER TABLE "MembershipInvitation" ADD CONSTRAINT "MembershipInvitation_inviterId_fkey" FOREIGN KEY ("inviterId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipInvitation" ADD CONSTRAINT "MembershipInvitation_inviteeId_fkey" FOREIGN KEY ("inviteeId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipInvitation" ADD CONSTRAINT "MembershipInvitation_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "MembershipInvitation" ADD CONSTRAINT "MembershipInvitation_columnId_fkey" FOREIGN KEY ("columnId") REFERENCES "Column"("id") ON DELETE CASCADE ON UPDATE CASCADE;
