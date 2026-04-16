-- Migration: Add isCategory boolean to FinancialAccountNumber
--
-- Safe non-destructive ADD COLUMN with DEFAULT so all existing rows are
-- backfilled to false without requiring a table rewrite on large datasets.

ALTER TABLE "FinancialAccountNumber"
  ADD COLUMN IF NOT EXISTS "isCategory" BOOLEAN NOT NULL DEFAULT false;
