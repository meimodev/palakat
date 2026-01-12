ALTER TYPE "NotificationType" ADD VALUE 'MEMBER_BIRTHDAY';

ALTER TABLE "Notification" ADD COLUMN "dedupeKey" TEXT;
ALTER TABLE "Notification" ADD COLUMN "data" JSONB;

CREATE UNIQUE INDEX "Notification_dedupeKey_key" ON "Notification"("dedupeKey");
