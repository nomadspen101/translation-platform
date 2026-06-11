# TASKS.md — Translation Platform Build Plan

> One task at a time. Mark a task `done` before starting the next. See CURSOR_RULES.md.

---

## Phase 0 — Foundation

| ID | Title | Description | Status |
|---|---|---|---|
| P0-T00 | Initialise git repository | Create git repo, add Next.js .gitignore, commit the four foundation files, create GitHub repo `translation-platform`, push | done |
| P0-T01 | Initialise Next.js project | Create Next.js 14 App Router project with TypeScript strict mode, Tailwind CSS, and shadcn/ui | todo |
| P0-T02 | Prisma schema + database connection | Write the full Prisma schema from ARCHITECTURE.md §4, connect to AWS RDS PostgreSQL 15, run initial migration | todo |
| P0-T03 | AWS S3 bucket setup | Create S3 bucket, configure 30-day lifecycle deletion policy, set up IAM credentials for app access | todo |
| P0-T04 | AWS SES setup | Verify sender domain, configure SES for transactional email, create reusable send helper | todo |
| P0-T05 | NextAuth.js translator auth | Configure NextAuth.js with email/password credentials provider and Prisma adapter; protect all /translator/* routes via middleware | todo |
| P0-T06 | Environment variable structure | Define and document all required env vars (database URL, AWS keys, Stripe keys, NextAuth secret); create .env.example | todo |

---

## Phase 1 — Customer Flow

| ID | Title | Description | Status |
|---|---|---|---|
| P1-T01 | Landing page | Build / — hero, pricing tiers, how it works, trust signals, footer CTA; no form fields | todo |
| P1-T02 | Order form — Section A (document category) | Build /order with three selectable category cards (Identity / Standard / Complex); updates price in order summary panel | todo |
| P1-T03 | Order form — Section B (language pair) | Add language pair dropdown that reveals after category; route unavailable languages to waitlist state | todo |
| P1-T04 | Order form — Section C (document details) | Add document type + country of issue dropdowns; reveal after language confirmed; add Category 3 extra fields | todo |
| P1-T05 | Order form — Section D + E (upload + AI consent) | Add PDF file upload with inline error handling and required AI consent checkbox; Continue button activates only when all sections complete | todo |
| P1-T06 | Order summary panel | Build persistent sidebar (desktop) / sticky bottom bar (mobile) showing category, price, language, document type throughout /order flow | todo |
| P1-T07 | Language unavailable state (Screen 2b) | Build inline waitlist state with email capture; write to WaitlistEntry table; no 'sorry' or 'unavailable' language | todo |
| P1-T08 | POST /api/orders route | Create Order record in database from completed form data; return orderId for checkout handoff | todo |
| P1-T09 | Checkout page | Build /checkout — email field, read-only order summary, Stripe payment form, terms checkbox, disabled CTA until complete | todo |
| P1-T10 | Stripe payment integration | Integrate Stripe on checkout page; create PaymentIntent; handle success and failure states inline without losing order details | todo |
| P1-T11 | Confirmation page | Build /confirmation — order received message, reference number, specific delivery time, receipt email notice, support contact | todo |
| P1-T12 | NSW driver's licence inline notice | Add inline notice on order form when driver's licence + NSW is selected; does not block order | todo |

---

## Phase 2 — Post-Payment Pipeline

| ID | Title | Description | Status |
|---|---|---|---|
| P2-T01 | Stripe webhook handler | Build POST /api/webhooks/stripe; verify signature; handle payment_intent.succeeded; update Order status to PAID; enqueue SQS pipeline job | todo |
| P2-T02 | Customer invoice email | Generate invoice with order details and price; send via SES on payment confirmation; mark invoiceEmailed on Order record | todo |
| P2-T03 | Document storage to S3 | Store uploaded document at uploads/{orderId}/original in S3; record s3DocumentKey and s3DeleteScheduled on Order | todo |
| P2-T04 | AWS Textract OCR integration | Send each page of the uploaded document to Textract as an image; collect raw text blocks per page | todo |
| P2-T05 | Bedrock integration + extraction prompt runner | Build Bedrock client; route document type to correct prompt; send Textract output; parse structured JSON response | todo |
| P2-T06 | Extraction prompt — EU driver's licence | Write and test dedicated extraction prompt for EU driver's licences in Spanish and Italian (EU Directive 2006/126/EC schema) | todo |
| P2-T07 | Extraction prompt — Spanish birth certificate (standard) | Write and test extraction prompt for Spanish standard birth certificate (post-2015 digital format) | todo |
| P2-T08 | Extraction prompt — Spanish birth certificate (naturalisation) | Write and test extraction prompt for Spanish naturalisation birth certificate (two-section structure) | todo |
| P2-T09 | Extraction prompt — Colombian birth certificate (DANE grid) | Write and test extraction prompts for Colombian DANE grid birth certificate (pre-2010 and post-2010 as separate entries) | todo |
| P2-T10 | Extraction prompt — Italian birth certificate | Write and test extraction prompt for Italian standard Comune format birth certificate | todo |
| P2-T11 | Extraction prompt — Colombian marriage certificate (DANE grid) | Write and test extraction prompt for Colombian DANE grid marriage certificate | todo |
| P2-T12 | Extraction prompt — police clearance (prose) | Write and test extraction prompt for prose-format police clearance in Spanish and Italian | todo |
| P2-T13 | Translation rules engine | Implement CARRY VERBATIM, TRANSLATE, REFORMAT, and FLAG+NOTE rules against extraction JSON; apply name rule strictly; handle compound surnames as surname_1/surname_2 | todo |
| P2-T14 | Confidence scoring + flag types | Apply confidence bands; generate all eight automatic flag types (abbreviation, verbatim_carry, name_accent, date_expansion, overflow_suspicion, handwritten_content, null_value, template_mismatch); store in confidenceLogs | todo |
| P2-T15 | .docx draft generation | Generate .docx from translated JSON using docx npm package; structured (table), prose (paragraphs), or mixed layout based on document type; apply output layout rules from PRD §4.7 | todo |
| P2-T16 | Store draft in S3 | Save generated .docx at jobs/{jobId}/draft.docx; record aiDraftS3Key on Job record | todo |
| P2-T17 | SQS + Lambda pipeline orchestration | Wire steps P2-T02 through P2-T16 as an ordered SQS + Lambda pipeline; each stage fails independently without corrupting upstream data | todo |
| P2-T18 | Sequential translator notification queue | Find available translators for the language pair; send notification to first in round-robin queue; re-send to next after 20 minutes if unconfirmed; all notifications remain live simultaneously | todo |

---

## Phase 3 — Translator Onboarding

| ID | Title | Description | Status |
|---|---|---|---|
| P3-T01 | Translator signup page | Build /translator/signup — name, email, phone; no password at this step; stores pending Translator record | todo |
| P3-T02 | NAATI credential page | Build /translator/signup/credential — NAATI CPN input + language pair selection; submits for background verification | todo |
| P3-T03 | Application submitted page | Build /translator/signup/submitted — confirmation screen; translator can close browser | todo |
| P3-T04 | NAATI CPN verification | Check submitted CPN against NAATI public directory; send welcome email (with checklist link) if active, manual review email if not found, rejection email if expired | todo |
| P3-T05 | Pre-activation checklist | Build /translator/onboarding/checklist — set password, upload stamp sample (preview only), connect bank via Stripe Connect, set availability toggle; marks Translator as ACTIVE when complete | todo |

---

## Phase 4 — Translator Job Flow

| ID | Title | Description | Status |
|---|---|---|---|
| P4-T01 | Job notification email | Build SES email template for job notification — subject line, document type, language pair, payout, estimated time, deadline, single 'Confirm this job' CTA linking to /translator/jobs/[jobId]/confirm | todo |
| P4-T02 | Job confirmation page | Build /translator/jobs/[jobId]/confirm — job summary, Accept and Decline actions; handle already-claimed state with neutral message | todo |
| P4-T03 | POST /api/jobs/[jobId]/confirm | Claim job for translator if unclaimed; update Job status to ACCEPTED; handle race condition (two translators confirming simultaneously) | todo |

---

## Phase 5 — Review Workspace

| ID | Title | Description | Status |
|---|---|---|---|
| P5-T01 | Review workspace shell | Build /translator/jobs/[jobId]/review — two-panel desktop layout; left panel ~45% width, right panel remainder; load Job and Order data | todo |
| P5-T02 | Left panel — original document viewer | Embed customer uploaded document (PDF viewer or image); scrollable for multi-page; read-only; sourced from S3 via signed URL | todo |
| P5-T03 | Right panel — Edit Draft tab (structured mode) | Render AI draft extraction JSON as editable field-label/value pairs; structured table mode for discrete fields | todo |
| P5-T04 | Right panel — Edit Draft tab (prose mode + toggle) | Add prose mode for documents that don't fit a grid; auto-set mode from document type; allow translator to override | todo |
| P5-T05 | Right panel — Translator Notes tab | Add second tab with free-text notes area; notes appear as footnotes in final document | todo |
| P5-T06 | Confidence highlighting | Apply yellow background + warning icon to fields below 0.85 confidence; tooltip on hover explaining the flag | todo |
| P5-T07 | Auto-save | Auto-save draft edits every 30 seconds with 'Saved' indicator; persist to Job.extractionJson | todo |
| P5-T08 | Flag issue drawer + API route | Build flag issue side drawer with five reason options; POST /api/jobs/[jobId]/flag pauses SLA clock and alerts ops; update Job status to FLAGGED | todo |
| P5-T09 | Generate document button + API route | Build 'Generate document' button; POST /api/jobs/[jobId]/generate triggers stamp-ready PDF generation; update Job status to GENERATING | todo |

---

## Phase 6 — Certification Flow

| ID | Title | Description | Status |
|---|---|---|---|
| P6-T01 | Stamp-ready PDF generation | Generate final PDF: original scan pages with platform header, translated content pages with footnotes, final page with certification statement and blank stamp zone (two-column layout); store at jobs/{jobId}/certified-draft.pdf | todo |
| P6-T02 | Certify screen | Build /translator/jobs/[jobId]/certify — three stepped cards (Download, Add stamp, Upload); Step 2 unlocks after download; Mac and Windows stamp instructions (expandable help) | todo |
| P6-T03 | POST /api/jobs/[jobId]/certify | Accept uploaded certified PDF; validate file size > generated draft (stamp presence check); store at jobs/{jobId}/certified.pdf in S3; mark as write-protected; update Job status to CERTIFYING then COMPLETE | todo |
| P6-T04 | Customer delivery email | Send SES email to customer with signed S3 link to certified PDF; include order reference; trigger post-delivery review request email | todo |
| P6-T05 | Stripe Connect payout trigger | Calculate 70% translator payout; initiate Stripe Connect transfer to translator's connected account; update Order status to DELIVERED | todo |
| P6-T06 | Beta metrics logging | Log per-job metrics on completion: reviewTimeSeconds (job assignment to certify), field corrections vs AI draft, flag false positive count; store on Job record | todo |

---

## Phase 7 — Translator Dashboard

| ID | Title | Description | Status |
|---|---|---|---|
| P7-T01 | Dashboard shell + availability toggle | Build /translator/dashboard — large Available/Unavailable toggle at top; active job card above toggle when job in progress; update Translator.isAvailable on toggle | todo |
| P7-T02 | Earnings + job stats | Show earnings this month, pending payout, jobs completed this month, all-time jobs count; pull from Job records and Stripe | todo |
| P7-T03 | Quality indicators | Show delivery rate, acceptance rate, quality score as simple stats (no numerical rank); amber nudges when indicators are low | todo |

---

## Phase 8 — Template Library

| ID | Title | Description | Status |
|---|---|---|---|
| P8-T01 | Glossary entry recording | Record translator label decisions to GlossaryEntry on job completion; use glossary as first lookup for subsequent AI jobs in same language/document type | todo |
| P8-T02 | Template match state banners | After extraction, determine template match state (confirmed / partial / no match); display correct banner in review workspace right panel | todo |
| P8-T03 | Template promotion (3-job threshold) | After three completed, validated jobs of the same document variant with no reclassification flags, promote field schema to Template v1 | todo |

---

## Phase 9 — Admin Tools + Beta Instrumentation

| ID | Title | Description | Status |
|---|---|---|---|
| P9-T01 | Confidence threshold admin interface | Build a simple protected page allowing confidence thresholds to be adjusted per document type without a code deploy (Open Question #8 from PRD) | todo |
| P9-T02 | Waitlist admin view | Simple protected view listing WaitlistEntry records grouped by language; used to prioritise translator onboarding | todo |

---

## Phase 10 — Compliance + Launch Prep

| ID | Title | Description | Status |
|---|---|---|---|
| P10-T01 | Write-protection enforcement on certified PDF | Technical enforcement that certified PDF at jobs/{jobId}/certified.pdf cannot be modified after translator submission — S3 object lock or equivalent | todo |
| P10-T02 | Privacy Policy page | Create /privacy — static page; must be published before any customer data is collected; content drafted by founder | todo |
| P10-T03 | AUSIT compliance audit | Walk through ARCHITECTURE.md §10 compliance table and PRD §15 checklist against the built product; document any gaps | todo |
| P10-T04 | End-to-end smoke test | Complete a full order → pipeline → review → certify → deliver flow end-to-end with a real test document; verify all beta metrics are logging | todo |

---

*Total tasks: 61 across 10 phases*
*Last updated: June 2026*
