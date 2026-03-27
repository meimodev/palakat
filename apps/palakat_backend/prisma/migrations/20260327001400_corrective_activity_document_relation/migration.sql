-- If Activity.documentId exists (from previous applied migration before replacement), migrate data and drop it.
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Activity' AND column_name = 'documentId') THEN
        -- Ensure Document.activityId exists (if this runs, maybe the replaced migration didn't run properly or was resolved)
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'Document' AND column_name = 'activityId') THEN
            ALTER TABLE "Document" ADD COLUMN "activityId" INTEGER;
            CREATE UNIQUE INDEX "Document_activityId_key" ON "Document"("activityId");
            ALTER TABLE "Document" ADD CONSTRAINT "Document_activityId_fkey" FOREIGN KEY ("activityId") REFERENCES "Activity"("id") ON DELETE CASCADE ON UPDATE CASCADE;
        END IF;

        -- Migrate data
        UPDATE "Document" d
        SET "activityId" = a.id
        FROM "Activity" a
        WHERE a."documentId" = d.id AND d."activityId" IS NULL;

        -- Drop old constraints and columns
        ALTER TABLE "Activity" DROP CONSTRAINT IF EXISTS "Activity_documentId_fkey";
        DROP INDEX IF EXISTS "Activity_documentId_idx";
        ALTER TABLE "Activity" DROP COLUMN "documentId";
    END IF;
END $$;
