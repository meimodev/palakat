-- AlterEnum
ALTER TABLE "Report" ALTER COLUMN "type" DROP DEFAULT;

ALTER TYPE "ReportGenerateType" RENAME TO "ReportGenerateType_old";

CREATE TYPE "ReportGenerateType" AS ENUM (
  'DOCUMENT',
  'CONGREGATION',
  'SERVICES',
  'ACTIVITY',
  'FINANCIAL'
);

ALTER TABLE "Report"
ALTER COLUMN "type" TYPE "ReportGenerateType"
USING (
  CASE
    WHEN "type"::text IN ('INCOMING_DOCUMENT', 'OUTCOMING_DOCUMENT')
      THEN 'DOCUMENT'::"ReportGenerateType"
    ELSE "type"::text::"ReportGenerateType"
  END
);

ALTER TABLE "ReportJob"
ALTER COLUMN "type" TYPE "ReportGenerateType"
USING (
  CASE
    WHEN "type"::text IN ('INCOMING_DOCUMENT', 'OUTCOMING_DOCUMENT')
      THEN 'DOCUMENT'::"ReportGenerateType"
    ELSE "type"::text::"ReportGenerateType"
  END
);

DROP TYPE "ReportGenerateType_old";

ALTER TABLE "Report" ALTER COLUMN "type" SET DEFAULT 'DOCUMENT';
