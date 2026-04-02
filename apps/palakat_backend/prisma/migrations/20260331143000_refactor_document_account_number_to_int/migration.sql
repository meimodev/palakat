ALTER TABLE "Church"
ALTER COLUMN "documentAccountNumber" TYPE INTEGER
USING CASE
  WHEN "documentAccountNumber" IS NULL THEN 0
  WHEN BTRIM("documentAccountNumber"::TEXT) = '' THEN 0
  WHEN BTRIM("documentAccountNumber"::TEXT) ~ '^[0-9]+$'
    AND BTRIM("documentAccountNumber"::TEXT)::NUMERIC <= 2147483647
    THEN BTRIM("documentAccountNumber"::TEXT)::INTEGER
  ELSE 0
END,
ALTER COLUMN "documentAccountNumber" SET DEFAULT 0,
ALTER COLUMN "documentAccountNumber" SET NOT NULL;
