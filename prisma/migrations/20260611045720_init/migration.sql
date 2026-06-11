-- CreateEnum
CREATE TYPE "NaatiStatus" AS ENUM ('PENDING', 'ACTIVE', 'EXPIRED', 'REJECTED');

-- CreateEnum
CREATE TYPE "DocumentCategory" AS ENUM ('IDENTITY', 'STANDARD', 'COMPLEX');

-- CreateEnum
CREATE TYPE "OrderStatus" AS ENUM ('PENDING', 'PAID', 'IN_PROGRESS', 'DELIVERED', 'DISPUTED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "JobStatus" AS ENUM ('UNASSIGNED', 'NOTIFIED', 'ACCEPTED', 'IN_REVIEW', 'GENERATING', 'CERTIFYING', 'COMPLETE', 'FLAGGED', 'REASSIGNED');

-- CreateTable
CREATE TABLE "Translator" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "phone" TEXT,
    "passwordHash" TEXT NOT NULL,
    "naatiCpn" TEXT NOT NULL,
    "naatiStatus" "NaatiStatus" NOT NULL DEFAULT 'PENDING',
    "isAvailable" BOOLEAN NOT NULL DEFAULT false,
    "stripeAccountId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Translator_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Order" (
    "id" TEXT NOT NULL,
    "customerEmail" TEXT NOT NULL,
    "documentCategory" "DocumentCategory" NOT NULL,
    "documentType" TEXT NOT NULL,
    "countryOfIssue" TEXT NOT NULL,
    "sourceLanguage" TEXT NOT NULL,
    "status" "OrderStatus" NOT NULL DEFAULT 'PENDING',
    "stripePriceAud" INTEGER NOT NULL,
    "stripePaymentId" TEXT,
    "invoiceEmailed" BOOLEAN NOT NULL DEFAULT false,
    "s3DocumentKey" TEXT,
    "s3DeleteScheduled" TIMESTAMP(3),
    "aiConsent" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Order_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Job" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "translatorId" TEXT,
    "status" "JobStatus" NOT NULL DEFAULT 'UNASSIGNED',
    "aiDraftS3Key" TEXT,
    "certifiedPdfS3Key" TEXT,
    "extractionJson" JSONB,
    "confidenceLogs" JSONB,
    "slaDeadline" TIMESTAMP(3),
    "slaClockPaused" BOOLEAN NOT NULL DEFAULT false,
    "notificationsSent" INTEGER NOT NULL DEFAULT 0,
    "lastNotifiedAt" TIMESTAMP(3),
    "reviewTimeSeconds" INTEGER,
    "flaggedIssue" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Job_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "LanguagePair" (
    "id" TEXT NOT NULL,
    "translatorId" TEXT NOT NULL,
    "sourceLanguage" TEXT NOT NULL,
    "targetLanguage" TEXT NOT NULL DEFAULT 'en',

    CONSTRAINT "LanguagePair_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "GlossaryEntry" (
    "id" TEXT NOT NULL,
    "sourceLanguage" TEXT NOT NULL,
    "documentType" TEXT NOT NULL,
    "sourceLabel" TEXT NOT NULL,
    "englishLabel" TEXT NOT NULL,
    "confirmedCount" INTEGER NOT NULL DEFAULT 1,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "GlossaryEntry_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "WaitlistEntry" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "language" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "WaitlistEntry_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Translator_email_key" ON "Translator"("email");

-- CreateIndex
CREATE UNIQUE INDEX "Translator_naatiCpn_key" ON "Translator"("naatiCpn");

-- CreateIndex
CREATE UNIQUE INDEX "Job_orderId_key" ON "Job"("orderId");

-- CreateIndex
CREATE UNIQUE INDEX "LanguagePair_translatorId_sourceLanguage_targetLanguage_key" ON "LanguagePair"("translatorId", "sourceLanguage", "targetLanguage");

-- CreateIndex
CREATE UNIQUE INDEX "GlossaryEntry_sourceLanguage_documentType_sourceLabel_key" ON "GlossaryEntry"("sourceLanguage", "documentType", "sourceLabel");

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Job" ADD CONSTRAINT "Job_translatorId_fkey" FOREIGN KEY ("translatorId") REFERENCES "Translator"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "LanguagePair" ADD CONSTRAINT "LanguagePair_translatorId_fkey" FOREIGN KEY ("translatorId") REFERENCES "Translator"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
