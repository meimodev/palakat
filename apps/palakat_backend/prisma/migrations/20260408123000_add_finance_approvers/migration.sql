CREATE TABLE "RevenueApprover" (
  "id" SERIAL NOT NULL,
  "membershipId" INTEGER NOT NULL,
  "revenueId" INTEGER NOT NULL,
  "status" "ApprovalStatus" NOT NULL DEFAULT 'UNCONFIRMED',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "RevenueApprover_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "ExpenseApprover" (
  "id" SERIAL NOT NULL,
  "membershipId" INTEGER NOT NULL,
  "expenseId" INTEGER NOT NULL,
  "status" "ApprovalStatus" NOT NULL DEFAULT 'UNCONFIRMED',
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "ExpenseApprover_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "RevenueApprover_revenueId_membershipId_key" ON "RevenueApprover"("revenueId", "membershipId");
CREATE INDEX "RevenueApprover_revenueId_idx" ON "RevenueApprover"("revenueId");
CREATE INDEX "RevenueApprover_membershipId_idx" ON "RevenueApprover"("membershipId");
CREATE INDEX "RevenueApprover_status_idx" ON "RevenueApprover"("status");

CREATE UNIQUE INDEX "ExpenseApprover_expenseId_membershipId_key" ON "ExpenseApprover"("expenseId", "membershipId");
CREATE INDEX "ExpenseApprover_expenseId_idx" ON "ExpenseApprover"("expenseId");
CREATE INDEX "ExpenseApprover_membershipId_idx" ON "ExpenseApprover"("membershipId");
CREATE INDEX "ExpenseApprover_status_idx" ON "ExpenseApprover"("status");

ALTER TABLE "RevenueApprover"
ADD CONSTRAINT "RevenueApprover_membershipId_fkey"
FOREIGN KEY ("membershipId") REFERENCES "Membership"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "RevenueApprover"
ADD CONSTRAINT "RevenueApprover_revenueId_fkey"
FOREIGN KEY ("revenueId") REFERENCES "Revenue"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "ExpenseApprover"
ADD CONSTRAINT "ExpenseApprover_membershipId_fkey"
FOREIGN KEY ("membershipId") REFERENCES "Membership"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE "ExpenseApprover"
ADD CONSTRAINT "ExpenseApprover_expenseId_fkey"
FOREIGN KEY ("expenseId") REFERENCES "Expense"("id") ON DELETE CASCADE ON UPDATE CASCADE;
