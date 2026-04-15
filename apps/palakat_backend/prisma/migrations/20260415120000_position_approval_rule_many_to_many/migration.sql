-- Migration: Replace MembershipPosition.approvalRuleId (singular FK) with a
-- true many-to-many join table between MembershipPosition and ApprovalRule.
--
-- Step 1: Create the join table
CREATE TABLE "_ApprovalRuleToMembershipPosition" (
    "A" INTEGER NOT NULL,
    "B" INTEGER NOT NULL,
    CONSTRAINT "_ApprovalRuleToMembershipPosition_A_fkey"
        FOREIGN KEY ("A") REFERENCES "ApprovalRule"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "_ApprovalRuleToMembershipPosition_B_fkey"
        FOREIGN KEY ("B") REFERENCES "MembershipPosition"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- Step 2: Migrate existing singular links into the new join table before dropping the column
INSERT INTO "_ApprovalRuleToMembershipPosition" ("A", "B")
SELECT "approvalRuleId", "id"
FROM   "MembershipPosition"
WHERE  "approvalRuleId" IS NOT NULL;

-- Step 3: Add unique constraint and index on the join table (Prisma implicit m2m convention)
CREATE UNIQUE INDEX "_ApprovalRuleToMembershipPosition_AB_unique"
    ON "_ApprovalRuleToMembershipPosition"("A", "B");

CREATE INDEX "_ApprovalRuleToMembershipPosition_B_index"
    ON "_ApprovalRuleToMembershipPosition"("B");

-- Step 4: Drop the now-redundant singular FK column
ALTER TABLE "MembershipPosition" DROP COLUMN IF EXISTS "approvalRuleId";
