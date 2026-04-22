-- Non-backward-compatible: every Revenue/Expense must now be tied to a CashAccount.
-- Safe for empty/dev data; drops existing revenue/expense + cash mutation rows first.
DELETE FROM "CashMutation" WHERE "referenceType" IN ('REVENUE', 'EXPENSE');
DELETE FROM "RevenueApprover";
DELETE FROM "ExpenseApprover";
DELETE FROM "Revenue";
DELETE FROM "Expense";

ALTER TABLE "Revenue" ADD COLUMN "cashAccountId" INTEGER NOT NULL;
ALTER TABLE "Expense" ADD COLUMN "cashAccountId" INTEGER NOT NULL;

CREATE INDEX "Revenue_cashAccountId_idx" ON "Revenue"("cashAccountId");
CREATE INDEX "Expense_cashAccountId_idx" ON "Expense"("cashAccountId");

ALTER TABLE "Revenue"
  ADD CONSTRAINT "Revenue_cashAccountId_fkey"
  FOREIGN KEY ("cashAccountId") REFERENCES "CashAccount"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "Expense"
  ADD CONSTRAINT "Expense_cashAccountId_fkey"
  FOREIGN KEY ("cashAccountId") REFERENCES "CashAccount"("id")
  ON DELETE RESTRICT ON UPDATE CASCADE;
