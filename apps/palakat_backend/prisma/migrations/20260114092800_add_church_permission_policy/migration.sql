-- CreateTable
CREATE TABLE "ChurchPermissionPolicy" (
    "id" SERIAL NOT NULL,
    "churchId" INTEGER NOT NULL,
    "policy" JSONB NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "ChurchPermissionPolicy_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "ChurchPermissionPolicy_churchId_key" ON "ChurchPermissionPolicy"("churchId");

-- AddForeignKey
ALTER TABLE "ChurchPermissionPolicy" ADD CONSTRAINT "ChurchPermissionPolicy_churchId_fkey" FOREIGN KEY ("churchId") REFERENCES "Church"("id") ON DELETE CASCADE ON UPDATE CASCADE;
