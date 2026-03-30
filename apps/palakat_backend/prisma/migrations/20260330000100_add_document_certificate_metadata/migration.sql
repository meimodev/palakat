ALTER TABLE "Document"
ADD COLUMN IF NOT EXISTS "certificateType" TEXT,
ADD COLUMN IF NOT EXISTS "certificateTitle" TEXT;
