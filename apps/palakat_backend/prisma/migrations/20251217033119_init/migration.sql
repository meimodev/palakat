-- CreateEnum
CREATE TYPE "ArticleType" AS ENUM ('PREACHING_MATERIAL', 'GAME_INSTRUCTION');

-- CreateEnum
CREATE TYPE "ArticleStatus" AS ENUM ('DRAFT', 'PUBLISHED', 'ARCHIVED');

-- CreateTable
CREATE TABLE "Article" (
    "id" SERIAL NOT NULL,
    "type" "ArticleType" NOT NULL,
    "status" "ArticleStatus" NOT NULL DEFAULT 'DRAFT',
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "excerpt" TEXT,
    "content" TEXT NOT NULL,
    "coverImageUrl" TEXT,
    "publishedAt" TIMESTAMP(3),
    "likesCount" INTEGER NOT NULL DEFAULT 0,
    "authorId" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Article_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "ArticleLike" (
    "id" SERIAL NOT NULL,
    "articleId" INTEGER NOT NULL,
    "accountId" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ArticleLike_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Article_slug_key" ON "Article"("slug");

-- CreateIndex
CREATE INDEX "Article_status_publishedAt_idx" ON "Article"("status", "publishedAt");

-- CreateIndex
CREATE INDEX "Article_type_idx" ON "Article"("type");

-- CreateIndex
CREATE INDEX "ArticleLike_articleId_idx" ON "ArticleLike"("articleId");

-- CreateIndex
CREATE INDEX "ArticleLike_accountId_idx" ON "ArticleLike"("accountId");

-- CreateIndex
CREATE UNIQUE INDEX "ArticleLike_articleId_accountId_key" ON "ArticleLike"("articleId", "accountId");

-- AddForeignKey
ALTER TABLE "Article" ADD CONSTRAINT "Article_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "Account"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ArticleLike" ADD CONSTRAINT "ArticleLike_articleId_fkey" FOREIGN KEY ("articleId") REFERENCES "Article"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ArticleLike" ADD CONSTRAINT "ArticleLike_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "Account"("id") ON DELETE CASCADE ON UPDATE CASCADE;
