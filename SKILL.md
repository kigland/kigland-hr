# Kigland HR — Resume Screening for 妆造师 (Makeup Artist)

## Overview

This skill automates the initial resume screening workflow for Kigland's 妆造师 (Kigurumi makeup artist) hiring pipeline. It reads incoming BOSS直聘 resume emails via Feishu Mail, cross-references them against documented screening criteria in Feishu Wiki, and produces categorized shortlists.

## Prerequisites

- `lark-cli` installed and authenticated (`lark-cli auth login --domain mail --domain docs`)
- Access to `join@kig.land` mailbox
- Access to the screening criteria wiki: `HZwIwBImJi4EvckYVMAcWTlHnMh`

## Workflow

### Step 1: Load Screening Criteria

```bash
lark-cli docs +fetch --doc "HZwIwBImJi4EvckYVMAcWTlHnMh" --doc-format markdown
```

Key dimensions in priority order:
1. **Commute/Residence** — 花桥/安亭 preferred, 11号线沿线 acceptable, cross-city long commute rejected
2. **Work Stability** — 3-5 years continuous, single job 1-3+ years preferred
3. **Education / Career Background** — 本科/专科 preferred; 幼师/教培/美甲美容美发/手工/美术/客服/行政 are high-match backgrounds
4. **Manual Skill Evidence** — Portfolio, certifications, formal training
5. **Job-Seeking Motivation** — Long-term, stable intent
6. **Job Understanding** — Accepts repetitive work, revisions, SOP, QA
7. **Salary / Availability** — Within range, reasonable start date
8. **Risk Flags** — Frequent job-hopping, competitor conflicts

Refer to `references/screening-criteria.md` for the full criteria matrix.

### Step 2: Fetch Recent Resume Emails

```bash
lark-cli mail +triage --mailbox "join@kig.land" --filter '{"folder":"inbox"}' --max 50 --format json
```

Filter to BOSS直聘 resume emails (sender: `cv@service.bosszhipin.com`, subject contains candidate name).

Batch read resume bodies:

```bash
lark-cli mail +messages --mailbox "join@kig.land" \
  --message-ids "<id1>,<id2>,<id3>" \
  --html=false --format json
```

Each BOSS直聘 email body contains: `姓名 性别 年龄 城市 学历 经验 期望薪资 最近公司 · 最近职位`

### Step 3: Categorize Candidates

Apply the three-tier classification from the criteria:

- **A-tier (Direct In-Person Interview):** 苏州本地 + 本科/大专 + high-match background (幼师/美术教育/美发/长期客服) + reasonable salary
- **B-tier (Online Quick Screen):** Some strengths but gaps — lower education, average background, career switchers, younger candidates with potential
- **C-tier (Pass):** Multiple red flags — commute too far, education too low + no skills, salary mismatch, background completely unrelated, too young with no experience

### Step 4: Output Analysis

Produce a structured shortlist with:
- Candidate summary table (name, age, education, experience, latest job, salary)
- Tier classification with rationale
- Red flag notes
- Recommendations for next steps

## Message Templates

BOSS直聘 communication templates are documented in `references/boss-message-templates.md`.

**Important:** Salary/compensation negotiation must be handled directly by 李明威 (Remi) in BOSS直聘 — do not quote salary in other channels.

## Related References

- `references/screening-criteria.md` — full criteria matrix (Wiki `HZwIwBImJi4EvckYVMAcWTlHnMh`)
- `references/jd.md` — JD for 妆造师/助理, two variants: Kigurumi mask & 玩偶妆造 (Wiki `ExtrwmJFriW1OYk9zizcoIiknje`)
- `references/interview-materials.md` — in-person interview flow, 小测 A/B questions, registration form fields, interview template PDF (`assets/interview-template-2608-01.pdf`)

## Limitations

- Email bodies contain only summary data; full resumes are in PDF attachments
- Work stability (frequent job changes) and manual skill evidence require PDF review
- Red-line behaviors (attitude toward revisions, SOP adherence) require interview verification
