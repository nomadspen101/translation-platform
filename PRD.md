# AI-Assisted Certified Translation Platform
## MVP Product Requirements Document

| Field | Value |
|---|---|
| Version | 1.0 — MVP |
| Date | June 2026 |
| Status | Active — build-ready |
| Owner | Alejandro (Founder / CPO) |
| Audience | Developer(s), future contractors |

**CONFIDENTIAL — For founder use only**

---

## 0. How to Use This Document

This PRD is the single authoritative reference for building the MVP. Every material decision made during product design is recorded here with its rationale. Decisions already made are not open questions — they are closed. Open questions are called out explicitly.

Read the entire document before writing a line of code. Sections 1–5 establish context and scope. Sections 6–10 are the technical spec. Section 11 defines done. Section 12 lists what stays out of scope.

---

## 1. Product Overview

### 1.1 What This Platform Is

A marketplace that makes NAATI-certified document translation significantly cheaper and faster than traditional agencies by pairing AI-generated draft translations with human NAATI-certified translators who review, correct, and certify the output.

The AI does not produce a certified translation. It produces a structured draft that a NAATI-certified translator reviews, corrects, and certifies. That distinction defines every product decision downstream.

> **NAATI's own position**
> NAATI's published quality assurance guidance (January 2026) explicitly lists AI-assisted translations as a category that always requires human review. The platform model is what NAATI recommends.

### 1.2 The Three Parties

| Party | Role | What They Get |
|---|---|---|
| Customer | Immigrants needing certified translations of identity and civil documents for Australian immigration purposes | Fast, affordable, NAATI-certified PDF delivered in 24 hours |
| Translator | NAATI-certified freelance professional who reviews the AI draft, corrects errors, and applies their stamp | 70% of job revenue with no client acquisition, admin, or billing overhead |
| Platform | Recruits translators, processes payments, runs the AI pipeline, and handles all workflow automation | 30% margin reinvested into tech and growth |

### 1.3 Core Value Proposition

- **Customer:** fixed prices disclosed upfront, no quotes, no registration, no phone calls, certified PDF in 24 hours
- **Translator:** passive income stream — jobs arrive, AI removes most of the labour, Stripe handles payment
- **Market:** price 30–50% below traditional agencies by eliminating physical offices, admin staff, manual quoting, and sales teams

### 1.4 What Makes This Defensible

Anyone can call an AI API and request a translation. What cannot be replicated is the template library: validated field schemas built from real jobs confirmed by NAATI-certified translators, specific to the exact document variants Australian immigration customers actually submit. A new competitor starts from zero. This library is the platform's most durable long-term advantage.

---

## 2. Market and Regulatory Context

### 2.1 Target Market

- **Primary:** immigrants in Australia needing NAATI-certified translations for visa applications, citizenship, BDM registrations, and employment verification
- **Segments at launch:** Spanish-speaking immigrants (largest volume), Italian community
- **Price sensitivity:** high — students, recent arrivals, and working-holiday visa holders are the core customer profile
- **Acquisition channels at launch:** immigrant Facebook and WhatsApp communities (paid community posts), SEO from day one, migration agent referrals (highest-leverage channel)

### 2.2 Document Scope at Launch

| Document Type | Countries | AI Tier | Notes |
|---|---|---|---|
| Driver's licence | All EU countries | Tier 1 — Templated | EU Directive 2006/126/EC defines identical field schema across all EU. One prompt covers all. |
| Birth certificate — standard | Spain (post-2015) | Tier 1 — Templated | Consistent digital format |
| Birth certificate — naturalisation | Spain | Tier 1 — Templated | Two-section structure; separate template from standard |
| Birth certificate — DANE grid | Colombia (pre and post-2010) | Tier 1 — Templated | Pre/post-2010 are separate template entries |
| Birth certificate | Italy (standard Comune format) | Tier 1 — Templated | |
| Marriage certificate | Colombia (DANE grid) | Tier 1 — Templated | |
| Police clearance | Colombia, Spain | Tier 2 — Variable | Prose-heavy; no template at launch; higher translator review time |
| All other types / countries | All | Tier 3 — Escalate | No AI draft; routed directly to translator at premium pricing |

### 2.3 Language Pairs at Launch

- **Spanish → English** (Alejandro can personally QA output)
- **Italian → English** (Alejandro can personally QA output)
- Mandarin → English: deferred to Phase 2
- Hindi, Nepali, Punjabi: explicitly deprioritised despite volume — translator supply constraints

### 2.4 Regulatory Framework

**NAATI Certification**

NAATI certification is required for official certified translations in Australia. The platform facilitates certified translations — it does not replace the translator's credential or professional judgment. Every translation delivered by the platform must be reviewed and stamped by a practitioner with a current NAATI credential.

**AUSIT Code of Ethics**

Translators working through the platform remain bound by the AUSIT Code of Ethics. Key obligations that shape product decisions:

- **Accuracy (Principle 5 / T3):** the translator certifies against the source document, not against the AI reading of it — this is why the original document appears in the left panel of the review interface, not the AI extraction
- **Competence (Principle 3 / T5):** the platform only routes jobs to translators in language pairs for which they hold current certification
- **Confidentiality (Principle 2):** customer documents are sensitive personal data — storage, deletion, and access controls must reflect this
- **Transparency of AI use (Code of Conduct, general principle):** AI use requires explicit client consent in the order flow — this must be built into customer-facing UX
- **No modification after certification (T9):** once a translator certifies a document, the platform cannot alter it — this is a hard technical constraint

**NAATI Digital Stamp Mechanics**

> **Critical product constraint**
> The NAATI digital stamp PNG must be downloaded fresh from myNAATI by the translator on the day of each translation. QR codes are date-specific and require the translator to be logged into myNAATI with MFA enabled. The platform cannot store, generate, or reuse stamps. Agreed flow: platform generates formatted PDF with blank stamp zone and pre-filled certification statement; translator adds today's stamp PNG externally and re-uploads.

**NSW Driver's Licence Exception**

NSW requires Multicultural NSW exclusively for driver's licence translations submitted to Service NSW. This is a significant carve-out. At launch: display an inline notice on the order form when a customer selects driver's licence + NSW; do not block the order (translations may still be valid for non-Service NSW purposes). Requires follow-up legal confirmation before this edge case is handled definitively.

**Privacy Act (Australia)**

The platform holds highly sensitive personal documents — passports, birth certificates, police clearances. Privacy Policy must be drafted and published before launch. Document storage in S3 with 30-day automatic deletion is the agreed approach.

**Australian Pty Ltd Structure**

Platform operates as an Australian Pty Ltd. This is decided and non-negotiable — regulatory exposure from contractor agreements and Privacy Act compliance requires domestic incorporation. Do not propose offshore alternatives.

---

## 3. Pricing Model

### 3.1 Three-Tier Structure

Flat pricing displayed upfront. No quotes. No surprises at checkout.

| Tier | Document Types | Price (AUD) | Translator Cut (70%) | Platform Cut (30%) |
|---|---|---|---|---|
| 1 — Identity Documents | Driver's licences, passports, national ID cards | TBD — set during beta | TBD | TBD |
| 2 — Standard Documents | Birth certificates, marriage certificates, police clearances | TBD — set during beta | TBD | TBD |
| 3 — Complex / Multi-page | Academic transcripts, contracts, multi-page docs (per page) | TBD — set during beta (per page) | TBD | TBD |

> **Pricing note**
> Final prices are set after beta validation of actual translator review times. Translator effective hourly rate must be validated against the AUSIT fee guide as competitive. GST not yet obligatory at projected revenue — confirm timing with accountant.

### 3.2 Economics

- 70/30 split in favour of translators
- Platform reinvests its 30% into technology and marketing — no personal income drawn by founder initially
- Core unit economics assumption: AI draft reduces translator time sufficiently that 70% of a flat-rate job is competitive with or better than translating from scratch at market rate
- This assumption must be validated in beta before committing to SLAs or marketing claims

### 3.3 Payment Infrastructure

- Customer payments: Stripe (card only at launch)
- Translator payouts: Stripe Connect — payout schedule TBD (weekly or fortnightly — decide before launch)
- Invoice auto-generated and emailed to customer on payment confirmation
- Platform does not handle cash, bank transfer, or PayID in the tech product

---

## 4. Technical Architecture

### 4.1 Infrastructure

| Component | Technology | Notes |
|---|---|---|
| OCR | AWS Textract | Every uploaded page treated as an image regardless of file format |
| AI extraction and translation | Amazon Bedrock — Claude Sonnet | Structured JSON extraction; field-level translation |
| Document storage | AWS S3 | 30-day automatic deletion; no permanent storage of customer documents |
| Payments — customer | Stripe | Card processing; PCI-DSS handled by Stripe |
| Payments — translators | Stripe Connect | Direct payouts to translator bank accounts |
| Output generation | Server-side .docx generation | Field-label/value table layout or prose layout depending on document type |
| Hosting | AWS (credits available) | Provides meaningful infrastructure runway |

### 4.2 Four-Stage AI Pipeline

The AI pipeline runs four sequential, independent stages. Each stage can fail without corrupting upstream data. Each stage is separately auditable and improvable.

| Stage | Name | Input | Output |
|---|---|---|---|
| 1 | Document ingestion | Customer PDF upload | Normalised page images + document type classification |
| 2 | Structured extraction | Page images | JSON field map with per-field confidence scores |
| 3 | Translation rules | Extraction JSON | Translated JSON with field-level rule applied |
| 4 | Output generation | Translated JSON | Formatted .docx translation draft |

> **Why four stages and not one?**
> A single image-to-translation step creates a black box. When output is wrong, you cannot tell whether the model misread the source, mistranslated a field, or applied the wrong rule. Four stages means four independent failure points that can be monitored and improved separately. It also enables the translator review interface to highlight specific flagged fields.

### 4.3 Stage 1 — Document Ingestion

**Input**

Customers submit PDFs only — enforced at upload. PDFs are always treated as images, even if they contain extractable text. This ensures consistent handling across all submissions.

**Page Normalisation**

- Resolution: 300 DPI minimum; below threshold triggers quality warning to customer
- Colour: converted to greyscale before extraction — reduces token cost, improves consistency
- Orientation: auto-corrected via rotation detection; ambiguous orientation flagged
- Multi-page: each page processed independently, results merged into single JSON

**Document Type Detection**

- Signal 1 (primary): customer declaration — customer selects document type from menu at upload; always trusted
- Signal 2: AI visual confirmation — model confirms whether uploaded document matches declared type; mismatch flags job before processing continues

### 4.4 Stage 2 — Structured Extraction

**Output Format**

A JSON field map — one entry per field, each containing a value and a confidence score. Example:

```json
"4c_issuing_authority": { "value": "MIT-UCO", "confidence": 0.91, "flag": "abbreviation" }
```

**Extraction Prompt Requirements**

Each document type requires a dedicated extraction prompt. Each prompt must specify:

- The document type and expected field schema
- Explicit rule per field: extract verbatim, translate, reformat, or flag
- Instructions to declare document structure rather than assume it — the model names each section it finds and extracts fields within sections separately
- Known ambiguities for that document type
- Behaviour for unreadable content: best-guess value with confidence below 0.70, never invent values
- Null response format for genuinely unreadable fields: `{ value: null, confidence: 0, flag: 'unreadable' }`

**Real-World Scan Problems the Prompts Must Handle**

| Problem | Example | Prompt Handling |
|---|---|---|
| Field overflow | Typed content in Latin American grid forms spills beyond field boundaries | Use field label context to assign values, not spatial position |
| Overlapping stamps | Official stamps printed over document text | Best-guess extraction with confidence penalty; flag for translator |
| Diagonal watermarks | EN BLANCO watermarks on Colombian documents | Pre-warn the model; instruct to ignore watermarks |
| Registry codes | Embedded codes (3-3), (8-3) in Spanish civil documents | Carry verbatim; do not treat as natural language |
| Handwritten annotations | Notary notes, dates added by hand | Extract under separate handwritten_annotations key; lower confidence threshold |
| Two-digit years | 25/05/95 on Italian driver's licence | Expand to four digits: 25/05/1995; flag date expansion for translator confirmation |

### 4.5 Stage 3 — Translation Rules

**The Four Field Rules**

| Rule | Applied To | Example |
|---|---|---|
| CARRY VERBATIM | Proper names, ID numbers, licence numbers, registry codes, alphanumeric identifiers | GIANNATTASIO stays GIANNATTASIO. U165X1457N stays U165X1457N. |
| TRANSLATE | Field labels, institutional descriptions, legal prose, status values, nationality values | MASCULINO → MALE. COLOMBIANA → Colombian. |
| REFORMAT | Dates with two-digit years, numbers requiring format standardisation | 25/05/95 → 25/05/1995 |
| FLAG + NOTE | Abbreviations, low-confidence fields, source document errors, fields with no direct Australian equivalent | MIT-UCO flagged with pre-populated translator note expanding the abbreviation |

**Name rule — never deviate from this**

All names are CARRY VERBATIM in their entirety. This includes capitalisation, accents, compound structure, and order. The field label is translated. The value is never touched. An altered name — even a trivial formatting change — can cause a document to be rejected by Home Affairs or fail to match a visa application.

Compound surnames: Spanish-language naming conventions use two surnames. Extract into separate fields — `surname_1` (paternal) and `surname_2` (maternal). Do not merge.

**Field Label Priority Order**

When choosing English field labels, apply in this order:

1. **Priority 1:** Australian receiving authority expectation — what Home Affairs, BDM, and DFAT expect to see
2. **Priority 2:** Source government official English label — where it matches standard Australian usage
3. **Priority 3:** CIEC international civil status convention — canonical labels used across member countries
4. **Priority 4:** Platform glossary — labels agreed by platform translators for fields with no obvious equivalent; grows over time

### 4.6 Confidence Scoring and Flagging

**Confidence Bands**

| Range | Label | Behaviour in Review Interface |
|---|---|---|
| 0.90 – 1.00 | High | No flag. Field shown normally. |
| 0.70 – 0.89 | Medium | Yellow flag. Translator should review but can accept quickly. |
| 0.50 – 0.69 | Low | Orange flag. Translator must verify against source before accepting. |
| Below 0.50 | Very low | Red flag with strong warning. Value should not be accepted without explicit verification. |
| null / 0.00 | Unreadable | Field shown blank. Translator must complete manually. |

> **Day-one threshold**
> Without templates, flag everything below 0.85. More aggressive than the template-backed threshold of 0.70. Appropriate for a system with no prior knowledge of the document variant. Adjust per document type via admin interface after beta data accumulates.

**Automatic Flag Types**

| Flag | Trigger |
|---|---|
| `abbreviation` | Value matches known abbreviation pattern — all-caps short string, periods, or hyphenated codes |
| `verbatim_carry` | Field contains alphanumeric codes that should not be translated |
| `name_accent` | Extracted name contains characters that may have been incorrectly normalised (e.g. e instead of e with accent) |
| `date_expansion` | Two-digit year detected and expanded to four digits |
| `overflow_suspicion` | Spatial analysis suggests field content may have spilled from adjacent field |
| `handwritten_content` | Any field containing extracted handwritten content |
| `null_value` | Field expected by schema is absent from extraction |
| `template_mismatch` | Document matched a template but contains unexpected or missing fields |

### 4.7 Stage 4 — Output Generation

A Word document (.docx) is generated from the translated JSON. The structure is determined by document type — not a fixed template:

- **Structured documents** (driver's licences, standard birth certificates): field-label / field-value table layout
- **Prose documents** (police clearances, Spanish civil registry certificates): flowing paragraphs with section headings
- **Mixed documents** (naturalisation certificates): combination — each section uses the appropriate layout

**Output Layout Rules**

- **Document title:** document type and issuing country in English, bold. E.g. *Driver's Licence — Republic of Italy.*
- **Field labels:** English only, muted styling to distinguish from values
- **Field values:** verbatim values in original case; translated values in standard English
- **Flagged fields:** highlighted in amber; flag reason shown in small text below value
- **Translator's notes:** bordered box below relevant field; pre-populated by AI where applicable, editable
- **Non-text elements:** noted as [Photograph of bearer], [Signed], [Official stamp] — never reproduced
- **NAATI stamp zone:** clearly marked blank area at bottom of final page; translator adds stamp externally after downloading

### 4.8 Template Library

**What a Template Is**

A template is the validated field schema for a specific document variant — saved after real jobs have been completed and confirmed by a NAATI-certified translator. It includes: field IDs, English labels, translation rules, known flag triggers, and translator's notes that recur across jobs.

Templates are stored against a document fingerprint: document type + issuing country + issuing office + approximate year range + format variant.

**Template Match States**

| State | Meaning | Translator Experience |
|---|---|---|
| Confirmed match | Document fingerprint matches known template at high confidence | Clean draft, normal flagging, standard review |
| Partial match | Document resembles known type but has structural differences | Yellow banner: 'Template partially matched — review all flagged fields carefully' |
| No match | Document type recognised but no template exists for this variant | Orange banner: 'No template available — your validated output will create the template for future jobs' |

**Template Promotion Rule**

After three jobs of the same document variant have been completed and validated by a translator without reclassification flags, the system automatically promotes the common field schema to Template v1. Raise threshold to five or ten once volume allows.

> **Day-one reality**
> On day one there are no templates. Every job is a No Match job. The translator receives an orange banner and an honestly flagged draft. This is fine. Templates make the system faster and more accurate over time — they are not what makes it safe. The system is safe on day one through honest flagging and human review.

---

## 5. Customer-Facing Product

### 5.1 Design Principles

- Minimum clicks — customer goes from landing to payment in under 3 minutes
- Progressive commitment — sell first, collect information second, take payment last
- Single purpose per screen — each page has one clear job
- No account required — the flow completes without registration
- Transparent AI use — explicit consent to AI-assisted preparation required in the order flow (AUSIT compliance)

### 5.2 Screen Map

| Screen | URL | Purpose |
|---|---|---|
| 1. Landing page | `/` | Sell the product. Pricing, trust signals, CTA. |
| 2. Order form | `/order` | Progressive intake — category, language, document details, upload. |
| 2b. Language unavailable state | `/order` (inline state) | High-demand message + email capture. Dead end. |
| 3. Checkout | `/checkout` | Email address, order summary, Stripe payment. |
| 4. Confirmation | `/confirmation` | Order received, what happens next, reference number. |

### 5.3 Screen 1 — Landing Page

**Sections**

- **Hero:** one-line value proposition + prominent Get started CTA. No form fields.
- **Pricing tiers:** three tiers shown clearly with fixed prices — visible before any interaction
- **How it works:** three steps in plain language (Upload document / Certified translator reviews it / Receive certified PDF)
- **Trust signals:** NAATI certified badge, translations completed count, delivery guarantee, 2–3 short customer reviews
- **FAQ (optional at MVP):** What is NAATI certification? Is a digital PDF accepted by Home Affairs? How is my document kept secure?
- **Footer CTA:** repeat Get started at bottom for scroll-through users

**Design Rules**

- No form fields on this page — only the CTA button is interactive
- Pricing must be visible without scrolling on desktop
- English only at launch — no multilingual version required for MVP

### 5.4 Screen 2 — Order Form

A single focused screen collecting everything needed to process the order. Fields reveal progressively. A persistent order summary panel shows running total at all times.

**Progressive Sections**

| Section | Input | Behaviour |
|---|---|---|
| A — Document category | Three selectable cards: Identity / Civil & Standard / Complex | Selecting a category immediately updates price in order summary panel |
| B — Language pair | Searchable dropdown: 'What language is the document in?' | Reveals after category selected. If unavailable → show state 2b. If available → reveal C. |
| C — Document details | Specific document type + country of issue (searchable dropdown) | Reveals after language confirmed available. Category 3 adds inline fields: degree, university, program duration, notes. |
| D — Upload | File upload. PDF, JPG, PNG. Single guidance line. | Reveals after C complete. Inline error if file unreadable; allow re-upload. No guidance on how to photograph document. |
| E — AI consent | Single checkbox: 'I understand this translation is AI-assisted and reviewed by a NAATI-certified translator' | Required before Continue button activates. AUSIT Code compliance. |

**Order Summary Panel**

Persistent sidebar (desktop) or sticky bottom bar (mobile). Shows: selected category and price, language pair, document type and country. Continue to checkout button activates only once all sections are complete.

### 5.5 Screen 2b — Language Unavailable

| Element | Content |
|---|---|
| Headline | We're onboarding more translators to meet demand |
| Body | "[Language] is one of our most requested language pairs. We're actively onboarding certified translators and expect to have availability soon. Leave your email and we'll notify you the moment it's ready." |
| Input | Email address field + Notify me button |
| After submission | "You're on the list. We'll be in touch soon." |
| Exit option | Small text link: 'Browse available languages' — returns to Section B |

Do not use words like 'unavailable', 'not supported', or 'sorry'. Email captured here is a qualified lead and directly informs translator onboarding prioritisation.

### 5.6 Screen 3 — Checkout

- **Email address:** single field — 'Where should we send your translation?' Pre-filled if entered earlier.
- **Order summary:** read-only; edit link returns to order form
- **Payment:** Stripe form; invoice auto-generated and emailed on payment
- **Terms checkbox:** 'I confirm the document I have uploaded is the original document requiring translation'
- **CTA:** 'Pay [price] and submit order' — disabled until email and payment complete
- **Payment failure:** inline error + retry without losing order details — no surprise price changes

### 5.7 Screen 4 — Confirmation

- Large clear message: 'Your order has been received.' Prominent order reference number.
- What happens next: (1) A certified NAATI translator has been assigned. (2) Your translation will be reviewed and certified. (3) Certified PDF delivered to your email within 24 hours.
- Show specific delivery time where possible: 'by 3:00 PM tomorrow' rather than generic '24 hours'
- Email reminder: 'A receipt has been sent to [email]. Your translation will be delivered to the same address.'
- Support: 'Questions? Contact us at [email].' No chat widget or phone number at MVP.
- Do not ask for a review on this screen — trigger post-delivery review request by automated email after translation is delivered

---

## 6. Translator-Facing Product

### 6.1 Design Principles

- Translators are credentialed professionals — tone and interface must reflect that
- Everything that can be automated is automated; translator attention reserved for linguistic judgment only
- Simple over sophisticated — where a task can be done adequately externally (e.g. adding stamp in Preview), the platform defers rather than building complex in-app tooling
- Primary notification channel: email. WhatsApp deferred to post-MVP.

### 6.2 Onboarding Flow

| Screen | URL | Purpose |
|---|---|---|
| 1. Sign up | `/translator/signup` | Name, email, phone. No password at this step. |
| 2. NAATI credential | `/translator/signup/credential` | NAATI CPN + language pairs. Submit triggers background verification. |
| 3. Application submitted | `/translator/signup/submitted` | Confirm receipt. Translator can close browser. |
| 4. Pre-activation checklist | `/translator/onboarding/checklist` | Set password / upload stamp sample / connect bank via Stripe Connect / set availability |

**Background Verification**

- Platform checks CPN against NAATI public directory
- If found and active: welcome email sent automatically with link to checklist
- If not found: application enters manual review queue; email within 24 hours
- If credential found but expired: rejection email with link to NAATI recertification page

**Stamp sample at onboarding**

The stamp sample uploaded during onboarding is ONLY for preview purposes — to show the translator what the final document will look like. It is never used to certify documents. A fresh stamp PNG must be downloaded from myNAATI on the day of each translation. This is a NAATI requirement.

### 6.3 Job Notification

- **Trigger:** customer payment confirmed + AI draft generated
- **Channel:** email (primary); WhatsApp deferred to post-MVP
- **Timing:** sent to first available translator immediately; if no confirmation after 20 minutes, sent to next translator
- All previous notifications remain live — any translator can still confirm at any time; first to confirm claims the job
- **Notification model:** sequential (staggered every 5 minutes), not simultaneous broadcast — protects against over-commitment
- **Rotation:** round-robin at MVP. Ranking system is post-MVP.

**Email Content**

- Subject: 'New job available — [Document type] [Language pair] — $[payout]'
- Document type, language pair, estimated review time, payout amount, delivery deadline
- Single large CTA: 'Confirm this job'

### 6.4 Job Confirmation Page

URL: `/translator/jobs/[job-id]/confirm`. Accessed via unique link in notification email.

- Shows job summary — document type, language pair, payout, estimated time, deadline
- Primary CTA: 'Accept job'
- Secondary: 'I can't take this job' — dismisses notification without penalty
- If job already claimed: neutral message 'This job has been taken. Stay available and we'll send you the next one.' No error, no penalty.

### 6.5 Review Workspace

URL: `/translator/jobs/[job-id]/review`. Two-panel layout on desktop.

**Left Panel — Original Document**

- Displays customer's uploaded document as embedded image or PDF viewer
- Scrollable for multi-page documents
- Read-only — no annotations at MVP
- Fixed width — approximately 45% of screen

> **Why the original document on the left — not the AI extraction**
> The translator certifies accuracy against the source document, not the AI's reading of it. If the AI misread a field, the translator catches it by looking at the original. Showing the AI extraction on the left means the translator is certifying against the AI — a compliance problem and quality risk. AUSIT Code T2 requires translators to work from source material directly.

**Right Panel — AI Draft Editor**

Two tabs:

1. **Edit draft (default):** field-label / value pairs, editable. Structured mode for discrete fields; prose mode for documents that don't fit a grid. Mode set automatically; translator can switch if AI classified type incorrectly.
2. **Translator notes:** free-text area for footnotes that appear in the final document

**Confidence Highlighting**

- Fields below 0.85 confidence: yellow background + warning icon
- Tooltip on hover: 'AI confidence is low for this field — please review carefully'
- High-confidence fields: no indicator

**Editing Behaviour**

- Minor edits: directly in text input fields
- Larger rewrites: download draft as .docx, edit externally, paste back or re-upload
- No rich text formatting in editor — plain text only; formatting handled by platform template
- Auto-save every 30 seconds with 'Saved' indicator

**Flag Issue Flow**

- Clicking 'Flag issue' opens a side drawer
- Reason options: Unreadable document / Wrong language / Document doesn't match description / Scope larger than described / Other
- On submission: SLA clock paused; translator sees confirmation message; platform ops team alerted
- Translator ranking is not affected by flagging

### 6.6 Generate Document

Triggered when translator clicks 'Generate document'. Platform produces stamp-ready PDF.

**PDF Structure**

- Pages 1+: original document scan embedded as-is; platform header on each page
- Translation pages: platform header; translated content formatted to mirror source; translator notes as numbered footnotes
- Final page: END OF TRANSLATION header; pre-filled certification statement; blank stamp zone; platform branding line

**Certification Statement (pre-filled)**

> "I, [Translator Full Name], NAATI Certified Translator [Language pair], Practitioner ID No. [CPN], certify that the above is a true and accurate translation of the attached document, to the best of my knowledge. The translator gives no warranty as to the authenticity of the source document. This translation is valid indefinitely."

**Stamp Zone**

- Clearly outlined rectangle, correctly sized to match NAATI digital stamp PNG dimensions
- Inside: light grey placeholder text 'Place your NAATI digital stamp here'
- Positioned in right column of final page next to certification statement — two-column layout

### 6.7 Certify Screen

URL: `/translator/jobs/[job-id]/certify`. Three stepped cards:

1. **Step 1 — Download:** download PDF button; once downloaded, Step 2 unlocks
2. **Step 2 — Add stamp:** instructions to log into myNAATI, download today's stamp PNG, drag onto final page in Preview/Acrobat, save. Expandable help sections for Mac and Windows (collapsed for returning translators, expanded for first-time).
3. **Step 3 — Upload certified PDF:** file upload (PDF only); basic validation — confirms file size is larger than generated version (crude stamp-presence check); preview of final page shown before submit

Error if file fails validation: 'It looks like the stamp may be missing. Please check the final page of your document and re-upload.'

### 6.8 Translator Dashboard

URL: `/translator/dashboard`.

- **Section A (top):** large availability toggle — Available / Unavailable. Most important control on the page.
- **Section B (left):** earnings this month, pending payout, jobs completed this month, all-time jobs
- **Section C (right):** delivery rate, acceptance rate, quality score — displayed as simple stats, no numerical rank shown
- **Active job card:** shown when a job is in progress, above the availability toggle
- Nudges for low indicators shown in amber — e.g. 'Your acceptance rate has dropped. This affects how often you're notified.'
- Translators do not see their ranking position or queue order — nudges communicate impact on job flow without exposing the algorithm

### 6.9 Dispute Handling

| Fault | Resolution | Payout Impact |
|---|---|---|
| Translator error | Translator corrects at no cost to customer within 24 hours. No additional payout. | Quality score affected |
| Customer error (wrong doc uploaded) | Customer pays a correction fee. Translator paid at standard rate. | No impact |
| Platform error (bad AI draft not caught) | Translator receives 50% of original job rate for correction. Customer not charged. | Quality score unaffected |

Disputes not responded to within 24 hours are escalated to ops and a penalty applied to quality score.

---

## 7. Backend Processes and Automation

### 7.1 Post-Payment Automation Sequence

The following runs automatically upon payment confirmation:

1. Generate and email customer invoice
2. Store uploaded document in S3 with 30-day deletion scheduled
3. Run OCR via AWS Textract — every page treated as image
4. Send extraction result to Amazon Bedrock (Claude Sonnet) with document-type-specific prompt
5. Parse extraction JSON; apply translation rules; generate confidence scores and flags
6. Generate .docx draft from translated JSON
7. Identify available translators for the language pair; send job notification email to first in queue
8. If no confirmation after 20 minutes, send to next translator; repeat until confirmed or pool exhausted

### 7.2 SLA and Deadline Tracking

- **Customer SLA:** certified translation delivered within 24 hours of payment
- **Translator deadline:** shown as a specific time, not '24 hours'
- SLA clock paused when translator flags an issue
- If deadline missed: platform ops team alerted immediately; job may be reassigned
- This SLA must be validated in beta before it is published to customers — do not commit until Metric 2 (translator review time) is measured

### 7.3 Document Retention and Privacy

- Customer uploaded documents: S3 with 30-day automatic deletion — hard requirement
- Generated translations: available for download for 30 days from delivery date
- Extraction JSON and confidence logs: retained per job for quality monitoring — retention period to be decided before launch (Privacy Act implications)
- No permanent storage of NAATI stamps — stamps are added externally by translators and submitted as part of the certified PDF only

### 7.4 Edge Cases

| Scenario | Handling |
|---|---|
| AI detects wrong document type at upload | Job flagged before translator notified; customer emailed to re-upload; no charge applied |
| Translator uploads wrong file at certify step (fails size validation) | Inline error: 'It looks like the stamp may be missing. Please check the final page.' Submit button inactive until re-upload. |
| Deadline missed by translator | Ops alerted; job may be reassigned; translator delivery rate affected; deadline-missed email sent |
| Entire translator pool unresponsive | Ops alerted immediately; ops manually sources translator; customer not notified of delay unless SLA cannot be met |
| Multi-page document (Category 3) | Stamp on final page only; covers entire document; no per-page stamping required |
| Document fingerprint has partial template match | Yellow banner in translator interface: 'Template partially matched — review all flagged fields carefully' |

---

## 8. Platform Glossary

The glossary starts empty at launch. Beta translators build it through their corrections and label decisions.

**How It's Populated**

- When a translator makes a label decision, the platform records: source language, document type, source field label, chosen English label, translator ID, date
- For subsequent jobs, the AI uses the platform glossary as its first lookup
- Translator confirms or overrides; overrides are recorded
- Majority-agreed labels become defaults

**Communication to Beta Translators**

Beta translators are not just reviewing jobs — they are establishing the platform standard. This is a genuine differentiator in translator recruitment and must be communicated during onboarding.

---

## 9. Extraction Prompts Required Before Beta

These prompts must be written and tested before the closed beta can begin. Each is a dedicated extraction prompt, not a generic 'translate this' instruction.

| Prompt | Language | Notes |
|---|---|---|
| Driver's licence (EU) | Spanish, Italian | EU Directive 2006/126/EC defines identical field schema across all EU — one prompt covers all |
| Birth certificate — standard | Spanish | Post-2015 digital format; consistent structure |
| Birth certificate — naturalisation | Spanish | Two-section structure; separate prompt from standard |
| Birth certificate — DANE grid | Spanish (Colombia) | Pre-2010 and post-2010 variants are separate entries |
| Birth certificate — standard | Italian | Standard Comune format |
| Marriage certificate — DANE grid | Spanish (Colombia) | |
| Police clearance — generic prose | Spanish, Italian | Prose-heavy; no template; higher translator review time expected |

---

## 10. Beta Validation

Do not commit to public SLAs or scale marketing before these four metrics are validated in the closed beta.

| Metric | What to Measure | Why It Matters |
|---|---|---|
| AI draft accuracy | Percentage of fields extracted correctly at high confidence, measured against translator corrections per document type | Determines how much value the AI is actually adding per job type |
| Translator review time | Actual time from job assignment to completion, measured per document type | The business model requires review time to be significantly less than translating from scratch. This is the core unit economics assumption. |
| Flag false positive rate | How often flags are triggered on fields the translator accepts without changes | Too many false positives trains translators to dismiss flags — destroying the safety mechanism |
| Escalation rate | How often Tier 2 and Tier 3 jobs occur in practice for target document types | Affects capacity planning and pricing model accuracy |

> **Beta is live**
> Pilot is underway with Agustina Pepe (NAATI-certified Spanish translator, Sydney), reviewing a Spanish driver's licence. Martina Battista (Italian, Melbourne) has completed a discovery interview and validated core product assumptions. Both are candidates for formal beta translator roles.

---

## 11. Definition of Done — MVP

The MVP is done when all of the following are true:

**Customer Flow**
- Customer can complete an order (landing page through payment) in under 3 minutes without registering
- AI consent checkbox is present and required before order proceeds
- Payment processed via Stripe; invoice emailed automatically
- Confirmation screen displays specific delivery time (not generic '24 hours')

**AI Pipeline**
- Four-stage pipeline runs end-to-end for all Tier 1 document types in Spanish and Italian
- All six prompts (Section 9) written, tested, and producing structured JSON output
- Confidence scoring and flag types implemented
- Best-guess + flag behaviour implemented (never blank, never invented values)
- Day-one threshold set at 0.85 for no-template jobs

**Translator Flow**
- Onboarding flow complete: signup, NAATI verification, checklist, active status
- Job notification emails sending correctly with 20-minute sequential escalation
- Review workspace functional: split-panel, confidence highlighting, two-tab right panel
- Certify screen complete: download, stamp instructions, upload validation, size check
- Generated PDF matches document output specification (Section 6.6) exactly
- Delivery confirmation screen shows payout and earnings

**Backend and Infrastructure**
- AWS Textract OCR integrated
- Amazon Bedrock (Claude Sonnet) integrated with document-type-specific prompts
- AWS S3 storage with 30-day automatic deletion enforced
- Stripe Connect configured for translator payouts
- Translator NAATI credential verified against NAATI public directory at onboarding

**Compliance**
- Privacy Policy published
- AUSIT AI consent language present in customer order flow
- Contractor Services Agreement drafted and signed by all beta translators
- No modification of certified documents after translator submission — hard constraint enforced technically

**Quality**
- Beta validation running: all four metrics (Section 10) being logged per job
- NSW driver's licence inline notice implemented on order form

---

## 12. Out of Scope — MVP

These are explicitly deferred. Do not build them now.

| Feature | Deferred To |
|---|---|
| Customer accounts / login | Post-MVP |
| WhatsApp job notifications (Business API) | Post-MVP |
| Translator ranking algorithm (weighted scoring) | Post-MVP |
| Availability scheduling (set specific hours) | Post-MVP |
| Automated visual template matching (fingerprinting) | Post-MVP |
| Variant detection in Stage 1 (automated) | Post-MVP — beta uses translator tagging at completion |
| Mandarin → English language pair | Phase 2 |
| Hindi, Nepali, Punjabi | Explicitly deprioritised — translator supply |
| University partnerships | Post-operations proven |
| Migration agent referral portal | Post-MVP — relationships managed manually |
| In-app annotation or markup on original document | Post-MVP |
| Mobile app | Post-MVP — responsive web only at launch |
| Admin dashboard for ops team | MVP uses manual ops; dashboard is Phase 2 |
| Appeal path for offboarded translators | Post-MVP |

---

## 13. Open Questions

These must be resolved before or during build. Each is clearly separated from closed decisions.

| # | Question | Impact | Owner |
|---|---|---|---|
| 1 | Stripe payout schedule — weekly or fortnightly? | Affects delivery confirmation screen and payout history display | Founder |
| 2 | NAATI stamp zone dimensions — exact pixel dimensions of the digital stamp PNG? | Affects stamp zone sizing in document template | Obtain from Agustina Pepe during pilot |
| 3 | NAATI letterhead confirmation — is the digital stamp alone sufficient, or must translator name and contact details appear separately? | Affects final page layout of certified document | Confirm with NAATI directly before finalising template |
| 4 | Audit trail retention period for extraction JSON and confidence logs? | Privacy Act implications; must be decided before launch | Founder + accountant |
| 5 | Correction fee amount when customer error caused rework? | Affects customer-facing correction flow | Founder |
| 6 | Document fingerprinting method beyond beta — when to build automated visual matching? | Template accuracy and ops cost at scale | Post-MVP roadmap decision |
| 7 | Multi-page field conflicts — what happens when page merge produces the same field extracted differently on two pages? | Edge case in pipeline; needs a defined resolution rule | Tech + Founder |
| 8 | Admin interface for adjusting confidence thresholds per document type without code deploys? | Operational flexibility during beta calibration | Tech priority — build in MVP |
| 9 | NSW driver's licence — confirm legally whether platform-certified translations are accepted for any NSW purpose beyond Service NSW? | Affects how the inline notice is worded | Founder + solicitor |
| 10 | Stripe payout schedule decision feeds into contractor agreement terms — resolve before agreement is drafted. | Contractor agreement | Founder + solicitor |

---

## 14. Key Decisions Log

Decisions made during design sessions. Do not re-litigate without good reason.

| Decision | Rationale |
|---|---|
| Four-stage pipeline over single-step | Auditability and independent failure points. Black-box translation cannot be monitored or improved. |
| Structured JSON intermediate | Enables field-level confidence scoring, flagging, translator review interface, and template library. Cannot be achieved with direct image-to-text. |
| Original document on left panel, not AI extraction | AUSIT Code T2 compliance. Translator certifies against source, not against AI reading. Critical for legal validity. |
| Editable right panel, not rigid form | Prose documents (police clearances, civil certificates) do not fit a fixed field grid. A document editor handles all document types; a form does not. |
| PDF-only customer input | Consistent handling. Photo-in-PDF is still a photo — the format wrapper provides no quality benefit. |
| Best-guess + flag over blank on low confidence | Translator time is wasted by blank drafts. A flagged best-guess is faster to verify than starting from nothing. |
| Three-job threshold for template promotion | Low enough to build templates quickly in beta; high enough to catch schema errors before scale. |
| Compound surnames as separate fields | Merging surname_1 and surname_2 risks mismatches across documents. Separation preserves data integrity. |
| Australian Pty Ltd — no offshore structure | Legal exposure from contractor agreements and Privacy Act compliance requires domestic incorporation. |
| Sequential job notifications, not simultaneous broadcast | Prevents over-commitment; protects SLA integrity; first to confirm claims the job. |
| Translator letterhead not required | The NAATI stamp carries all certification authority. Platform uses its own branding with 'Certified via [Platform Name]' line. |
| No AI use language in translator recruitment outreach | Framing AI as reducing workload performs better than leading with the technology. 'You never have to find a client again' is the resonant hook. |
| 70/30 revenue split in favour of translator | Translator effective hourly rate validated against AUSIT fee guide as competitive. Platform reinvests margin into tech and marketing. |

---

## 15. Appendix — AUSIT Compliance Checklist

Use this checklist when reviewing any product change for compliance risk.

| Requirement | Source | Platform Implementation |
|---|---|---|
| AI use requires explicit client consent | AUSIT Code — professional conduct | Checkbox in customer order flow before payment proceeds |
| Translator certifies against source document, not AI output | AUSIT Code T2 | Original document in left panel; AI draft in right panel |
| No modification of certified document after delivery | AUSIT Code T9 | Technical constraint — platform cannot alter file after translator submission |
| Translator must hold current NAATI credential | AUSIT Code — competence | CPN verified against NAATI directory at onboarding; renewal reminders built in |
| Platform glossary decisions are translator-led | AUSIT Code — professional judgment | Glossary built from translator corrections; majority-agreed labels become defaults |
| Document confidentiality | AUSIT Code — confidentiality | S3 with 30-day deletion; Privacy Policy; no third-party data sharing |
| Translator is not responsible for source document authenticity | AUSIT Code — accuracy | Pre-filled in certification statement: 'The translator gives no warranty as to the authenticity of the source document' |

---

*End of PRD · Version 1.0 · June 2026*
