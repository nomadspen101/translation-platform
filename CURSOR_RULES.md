# Cursor Rules — Translation Platform

> This file governs every working session. Read it before writing any code.

---

## 1. Two Modes

### /plan mode

Used at the start of each session or when deciding what to build next.

- Review TASKS.md together and identify the single next task
- Discuss the approach — ask questions, flag risks, surface open questions from PRD.md
- No application code is written in plan mode
- Output: a task ID and agreed approach confirmed by the founder before switching to /build

### /build mode

Used to execute a single, agreed task.

- State the task ID at the top of the session before writing any code
- Code only what the task description requires — nothing adjacent, nothing speculative
- When the task is done: update TASKS.md status to `done`, then stop
- Do not begin the next task until the founder confirms the current one is complete

---

## 2. Hard Rules from ARCHITECTURE.md

These are closed decisions. Do not propose alternatives. Do not work around them.

| Rule | Source |
|---|---|
| Stack is Next.js 14 (App Router), TypeScript strict mode, Tailwind CSS + shadcn/ui only — no other component libraries | ARCH §2 |
| Database is AWS RDS PostgreSQL 15, accessed via Prisma — schema-first, all migrations version-controlled | ARCH §2 |
| Auth is NextAuth.js with email/password, for translators only — no customer accounts, no OAuth | ARCH §3 |
| Customers are anonymous — no User table, no customer login, email stored as plain string on Order record only | ARCH §3 |
| Do not remove or rename Prisma schema fields without founder approval | ARCH §4 |
| The AI produces a draft. The translator certifies. Never conflate these in code, copy, or data models. | ARCH §1 |
| Original document always in the left panel of the review workspace — never the AI extraction | ARCH §10 |
| Certified PDF is write-protected after translator submission — technically enforced, not just policy | ARCH §10 |
| S3 30-day automatic deletion lifecycle policy is a hard requirement — not optional | ARCH §8 |
| NAATI stamps are never stored by the platform under any circumstances | ARCH §8 |
| AI consent checkbox is required before order proceeds — cannot be skipped or pre-checked | ARCH §10 |
| Translator NAATI CPN verified against NAATI public directory at onboarding | ARCH §10 |
| Australian Pty Ltd structure — no offshore alternatives | PRD §2.4 |

### Out of scope — do not build under any circumstances at MVP

- Customer accounts or login
- WhatsApp notifications
- Admin dashboard
- Translator ranking algorithm
- Availability scheduling
- Automated template fingerprinting
- Mandarin, Hindi, Nepali, or Punjabi language pairs
- Mobile app (responsive web only)
- In-app document annotation
- Migration agent referral portal

---

## 3. One Task at a Time

- Never open more than one task in a session
- Never modify files that belong to a different task's scope
- Never refactor, clean up, or "improve" code outside the current task — even if you notice something
- If a blocker or bug is found in code outside the current task's scope, report it to the founder and log it — do not fix it silently
- Commit scope: only files directly required by the current task ID

---

## 4. Before Every Session

1. Read ARCHITECTURE.md fully
2. Read TASKS.md — identify the current task status
3. State the task ID and describe what you will do before writing any code
4. If there is any ambiguity in the task description, ask before proceeding — do not make assumptions

---

## 5. Definition of Done (per task)

A task is done when:

- The specific functionality described in TASKS.md works end-to-end
- No TypeScript strict-mode errors in touched files
- No new console errors introduced
- TASKS.md updated: status changed to `done`
- Founder has reviewed and confirmed before the next task begins

---

## 6. Open Questions Protocol

If a task touches an open question from PRD.md Section 13:

- Do not hard-code a value or make an assumption
- Highlight the open question to the founder before proceeding
- Build with a clearly marked placeholder (e.g. `TODO: Open Question #2 — NAATI stamp dimensions`)
- The task is not done until the open question is resolved or the placeholder is explicitly accepted

---

## 7. Known Compatibility Issues

- **shadcn v4 + Next.js 14 / Tailwind v3:** The shadcn v4 CLI generates Tailwind v4 syntax (`@import "shadcn/tailwind.css"`, opacity modifiers on CSS variables) which is incompatible with Next.js 14 + Tailwind v3. When adding new components via `npx shadcn add <component>`, the generated CSS and Tailwind config may need patching. Always run `npm run build` after adding any shadcn component and fix any PostCSS errors before committing.

---

*CURSOR_RULES.md — MVP v1.0 — June 2026*
