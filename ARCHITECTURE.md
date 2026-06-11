# Translation Platform — Architecture Reference

> Read this file at the start of every Claude Code session before writing any code.
> All decisions here are closed unless explicitly reopened by the founder.

---

## 1. What This System Is

An AI-assisted certified translation marketplace for immigrants in Australia.
Customers upload identity and civil documents. An AI pipeline generates a structured
draft translation. A NAATI-certified translator reviews, corrects, and certifies the output.
The certified PDF is delivered to the customer by email within 24 hours.

**The AI does not produce a certified translation. It produces a draft. The translator certifies.**

---

## 2. Stack

| Layer | Technology | Notes |
|---|---|---|
| Framework | Next.js 14 (App Router) | Single repo. SSR for SEO. API routes for backend. |
| Language | TypeScript | Strict mode enabled. |
| Database | AWS RDS (PostgreSQL 15) | Covered by AWS credits. |
| ORM | Prisma | Schema-first. All migrations version-controlled. |
| Auth | NextAuth.js | Translators only. Email/password. No OAuth at MVP. |
| UI | Tailwind CSS + shadcn/ui | No other component libraries. |
| File storage | AWS S3 | 30-day automatic deletion enforced via lifecycle policy. |
| OCR | AWS Textract | Every page treated as an image regardless of file format. |
| AI pipeline | AWS Bedrock — Claude Sonnet | Structured JSON extraction and translation. |
| Job queue | AWS SQS + Lambda | Async post-payment pipeline. |
| Email | AWS SES | Transactional email only. Customer delivery, invoices, job notifications. |
| Payments | Stripe | Customer card processing. |
| Translator payouts | Stripe Connect | Direct bank payouts. |
| Hosting | AWS App Runner | Next.js container. Auto-scaling. |
| Output generation | Server-side docx generation | Via `docx` npm package. |

---

## 3. Authentication Model

**Translators: authenticated.**
- NextAuth.js with email/password credentials provider.
- Session stored in database (`NextAuthSession` table via Prisma adapter).
- All `/translator/*` routes protected by middleware.

**Customers: anonymous.**
- No accounts. No registration. No login.
- Customer email is collected at checkout and stored as a plain string on the `Order` record.
- Do not create a `User` table or model for customers.

---

## 4. Database Schema (Prisma)

```prisma
// Core entities — expand as needed, do not remove fields without founder approval.

model Translator {
  id                String              @id @default(cuid())
  name              String
  email             String              @unique
  phone             String?
  passwordHash      String
  naatiCpn          String              @unique
  naatiStatus       NaatiStatus         @default(PENDING)
  languagePairs     LanguagePair[]
  isAvailable       Boolean             @default(false)
  stripeAccountId   String?
  jobs              Job[]
  createdAt         DateTime            @default(now())
  updatedAt         DateTime            @updatedAt
}

model Order {
  id                String              @id @default(cuid())
  customerEmail     String
  documentCategory  DocumentCategory
  documentType      String
  countryOfIssue    String
  sourceLanguage    String
  status            OrderStatus         @default(PENDING)
  stripePriceAud    Int                 // In cents
  stripePaymentId   String?
  invoiceEmailed    Boolean             @default(false)
  s3DocumentKey     String?             // Deleted after 30 days
  s3DeleteScheduled DateTime?
  aiConsent         Boolean             @default(false)
  job               Job?
  createdAt         DateTime            @default(now())
  updatedAt         DateTime            @updatedAt
}

model Job {
  id                String              @id @default(cuid())
  order             Order               @relation(fields: [orderId], references: [id])
  orderId           String              @unique
  translator        Translator?         @relation(fields: [translatorId], references: [id])
  translatorId      String?
  status            JobStatus           @default(UNASSIGNED)
  aiDraftS3Key      String?             // Generated .docx draft
  certifiedPdfS3Key String?             // Final certified PDF from translator
  extractionJson    Json?               // Raw AI extraction output — retained for QA
  confidenceLogs    Json?               // Per-field confidence scores
  slaDeadline       DateTime?
  slaClockPaused    Boolean             @default(false)
  notificationsSent Int                 @default(0)
  lastNotifiedAt    DateTime?
  reviewTimeSeconds Int?                // Measured at completion for beta validation
  flaggedIssue      String?
  createdAt         DateTime            @default(now())
  updatedAt         DateTime            @updatedAt
}

enum NaatiStatus {
  PENDING
  ACTIVE
  EXPIRED
  REJECTED
}

enum DocumentCategory {
  IDENTITY       // Tier 1 — driver's licence, passport, ID card
  STANDARD       // Tier 2 — birth cert, marriage cert, police clearance
  COMPLEX        // Tier 3 — academic transcripts, multi-page
}

enum OrderStatus {
  PENDING
  PAID
  IN_PROGRESS
  DELIVERED
  DISPUTED
  REFUNDED
}

enum JobStatus {
  UNASSIGNED
  NOTIFIED
  ACCEPTED
  IN_REVIEW
  GENERATING
  CERTIFYING
  COMPLETE
  FLAGGED
  REASSIGNED
}

model LanguagePair {
  id            String      @id @default(cuid())
  translator    Translator  @relation(fields: [translatorId], references: [id])
  translatorId  String
  sourceLanguage String
  targetLanguage String      @default("en")

  @@unique([translatorId, sourceLanguage, targetLanguage])
}

model GlossaryEntry {
  id              String    @id @default(cuid())
  sourceLanguage  String
  documentType    String
  sourceLabel     String
  englishLabel    String
  confirmedCount  Int       @default(1)
  isDefault       Boolean   @default(false)
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  @@unique([sourceLanguage, documentType, sourceLabel])
}

model WaitlistEntry {
  id          String    @id @default(cuid())
  email       String
  language    String
  createdAt   DateTime  @default(now())
}
```

---

## 5. URL Structure

### Customer-facing

| Route | Purpose |
|---|---|
| `/` | Landing page |
| `/order` | Progressive order form |
| `/checkout` | Email + Stripe payment |
| `/confirmation` | Order received screen |

### Translator-facing

| Route | Purpose |
|---|---|
| `/translator/signup` | Name, email, phone |
| `/translator/signup/credential` | NAATI CPN + language pairs |
| `/translator/signup/submitted` | Application received |
| `/translator/onboarding/checklist` | Password, bank, availability |
| `/translator/dashboard` | Availability toggle, earnings, stats |
| `/translator/jobs/[jobId]/confirm` | Accept or decline job (from email link) |
| `/translator/jobs/[jobId]/review` | Split-panel review workspace |
| `/translator/jobs/[jobId]/certify` | Download → stamp → re-upload flow |

### API routes

| Route | Purpose |
|---|---|
| `POST /api/orders` | Create order record after form completion |
| `POST /api/webhooks/stripe` | Handle payment confirmation |
| `POST /api/jobs/[jobId]/confirm` | Translator accepts job |
| `POST /api/jobs/[jobId]/generate` | Trigger PDF generation |
| `POST /api/jobs/[jobId]/certify` | Upload certified PDF |
| `POST /api/jobs/[jobId]/flag` | Translator flags issue |
| `GET /api/translator/me` | Current translator profile |

---

## 6. Post-Payment Pipeline (Async via SQS + Lambda)

Triggered by Stripe webhook `payment_intent.succeeded`.

```
1. Generate and email customer invoice (SES)
2. Store uploaded document in S3 — schedule 30-day deletion
3. Run OCR via AWS Textract (every page as image)
4. Send extraction to Bedrock (Claude Sonnet) with document-type-specific prompt
5. Parse extraction JSON — apply translation rules — generate confidence scores + flags
6. Generate .docx draft from translated JSON
7. Store draft in S3
8. Find available translators for the language pair
9. Send job notification email to first in queue (SES)
10. If no confirmation after 20 minutes → send to next translator
    All previous notifications remain live — first to confirm claims the job
```

---

## 7. AI Pipeline Stages

Four independent stages. Each fails without corrupting upstream data.

| Stage | Name | Input | Output |
|---|---|---|---|
| 1 | Document ingestion | Customer PDF | Normalised page images + document type confirmation |
| 2 | Structured extraction | Page images | JSON field map with per-field confidence scores |
| 3 | Translation rules | Extraction JSON | Translated JSON with field-level rules applied |
| 4 | Output generation | Translated JSON | Formatted .docx draft |

### Confidence bands

| Range | Label | Behaviour |
|---|---|---|
| 0.90–1.00 | High | No flag |
| 0.70–0.89 | Medium | Yellow flag |
| 0.50–0.69 | Low | Orange flag |
| Below 0.50 | Very low | Red flag |
| null / 0.00 | Unreadable | Blank — translator must complete |

**Day-one threshold: flag everything below 0.85** (no templates exist at launch).

### Translation rules

| Rule | Applied to |
|---|---|
| CARRY VERBATIM | Names, ID numbers, licence numbers, registry codes |
| TRANSLATE | Field labels, status values, nationality values, legal prose |
| REFORMAT | Dates with two-digit years, number formats |
| FLAG + NOTE | Abbreviations, low-confidence fields, source document errors |

**Name rule — never deviate:** All names are CARRY VERBATIM including capitalisation,
accents, compound structure, and order. An altered name can cause rejection by Home Affairs.

---

## 8. Document Storage Rules

- All customer uploads stored in S3 under `uploads/{orderId}/original`
- 30-day S3 lifecycle policy applied at bucket level — hard requirement
- Generated drafts stored under `jobs/{jobId}/draft.docx`
- Certified PDFs stored under `jobs/{jobId}/certified.pdf`
- Certified PDFs available for customer download for 30 days from delivery
- NAATI stamps are never stored — added externally by translators
- Extraction JSON and confidence logs retained per job (retention period TBD — Privacy Act)

---

## 9. Translator Job Notification Model

- Sequential, not broadcast — notifications sent one at a time, staggered every 5 minutes (20 minutes at MVP)
- All previous notifications remain live — any translator can still confirm
- First to confirm claims the job
- Round-robin queue at MVP — ranking system is post-MVP
- Email is the only notification channel at MVP (WhatsApp deferred)

---

## 10. Compliance Constraints (Hard — Do Not Work Around)

| Constraint | Source | Implementation |
|---|---|---|
| AI consent required before order proceeds | AUSIT Code of Ethics | Checkbox in order form — required, not optional |
| Original document in left panel of review workspace | AUSIT Code T2 | Translator certifies against source, not AI output |
| No modification of certified document after translator submission | AUSIT Code T9 | Technical enforcement — certified PDF is write-protected after upload |
| Translator must hold current NAATI credential | NAATI requirement | CPN verified against NAATI public directory at onboarding |
| NAATI stamp downloaded fresh per job by translator | NAATI requirement | Platform generates PDF with blank stamp zone — translator adds stamp externally |
| NSW driver's licence notice | NSW Multicultural carve-out | Inline notice on order form when driver's licence + NSW selected |
| Customer documents are sensitive personal data | Privacy Act (Australia) | S3 with 30-day deletion, Privacy Policy published before launch |

---

## 11. Out of Scope — Do Not Build

- Customer accounts or login
- WhatsApp notifications
- Translator ranking algorithm
- Availability scheduling
- Automated template fingerprinting
- Mandarin, Hindi, Nepali, Punjabi language pairs
- Admin dashboard (ops is manual at MVP)
- Mobile app (responsive web only)
- In-app document annotation
- Migration agent referral portal

---

## 12. Open Questions (Unresolved — Do Not Hard-Code)

1. Stripe payout schedule — weekly or fortnightly
2. Exact pixel dimensions of NAATI digital stamp PNG
3. Correction fee amount for customer errors
4. Audit trail retention period for extraction JSON (Privacy Act)
5. NSW driver's licence — which non-Service NSW purposes are the translation valid for

---

## 13. Beta Validation Metrics (Log These Per Job)

1. AI draft accuracy — fields extracted correctly at high confidence vs. translator corrections
2. Translator review time — seconds from job assignment to completion
3. Flag false positive rate — flags triggered on fields translator accepts without changes
4. Escalation rate — Tier 2 and Tier 3 jobs in practice for target document types

---

*ARCHITECTURE.md — MVP v1.0 — June 2026*
*Confidential — Founder use only*
