-- Migration: approval_rule_bipra_no_account
-- Removes financialAccountNumberId from ApprovalRule and adds bipra field.

-- Step 1: Drop the FK constraint and column
ALTER TABLE "ApprovalRule" DROP COLUMN IF EXISTS "financialAccountNumberId";

-- Step 2: Drop the back-relation index on FinancialAccountNumber if it exists
-- (Prisma may have added a unique index for the 1:1 relation)
DROP INDEX IF EXISTS "ApprovalRule_financialAccountNumberId_key";

-- Step 3: Add bipra column (enum type already exists from a previous migration)
ALTER TABLE "ApprovalRule" ADD COLUMN IF NOT EXISTS "bipra" "Bipra";
