# Kigland HR — Resume Screening

## Overview

This skill automates the initial resume screening workflow for Kigland hiring pipelines across multiple positions (岗位). Each position owns one set of screening criteria, JD, greetings, and interview materials under `positions/<岗位>/`; the workflow below is shared. The position registry is `registry.md`.

## Prerequisites

- `lark-cli` installed and authenticated (`lark-cli auth login --domain mail --domain docs`)
- Access to `join@kig.land` mailbox
- Access to the screening criteria wiki of the target position (e.g. 妆造师: `HZwIwBImJi4EvckYVMAcWTlHnMh`)

## Workflow

### Step 0: Select Position

Read `registry.md` and resolve the target position directory `positions/<岗位>/` (via `position.md` for status, Bitable 应聘部门 value, and channels). If the user did not specify a position, ask before screening. All per-position paths below are relative to this directory.

### Step 1: Load Screening Criteria

```bash
lark-cli docs +fetch --doc "<position wiki token from positions/<岗位>/position.md>" --doc-format markdown
```

Then load `positions/<岗位>/screening-criteria.md` for the full criteria matrix. Example — 妆造师 priority order:

1. **Commute/Residence** — 花桥/安亭 preferred, 11号线沿线 acceptable, cross-city long commute rejected
2. **Work Stability** — 3-5 years continuous, single job 1-3+ years preferred
3. **Education / Career Background** — 本科/专科 preferred; 幼师/教培/美甲美容美发/手工/美术/客服/行政 are high-match backgrounds
4. **Manual Skill Evidence** — Portfolio, certifications, formal training
5. **Job-Seeking Motivation** — Long-term, stable intent
6. **Job Understanding** — Accepts repetitive work, revisions, SOP, QA
7. **Salary / Availability** — Within range, reasonable start date
8. **Risk Flags** — Frequent job-hopping, competitor conflicts

### Step 2: Fetch Recent Resume Emails

```bash
lark-cli mail +triage --mailbox "join@kig.land" --filter '{"folder":"inbox"}' --max 50 --format json
```

Filter to BOSS直聘 resume emails (sender: `cv@service.bosszhipin.com`, subject contains candidate name). Positions whose channels differ (直聊, 内推, …) declare this in `position.md`; the email pipeline above applies to all BOSS邮箱简历 positions.

Batch read resume bodies:

```bash
lark-cli mail +messages --mailbox "join@kig.land" \
  --message-ids "<id1>,<id2>,<id3>" \
  --html=false --format json
```

Each BOSS直聘 email body contains: `姓名 性别 年龄 城市 学历 经验 期望薪资 最近公司 · 最近职位`

### Step 3: Categorize Candidates

Apply the three-tier classification from the position's `screening-criteria.md`. Example — 妆造师 tiers:

- **A-tier (Direct In-Person Interview):** 苏州本地 + 本科/大专 + high-match background (幼师/美术教育/美发/长期客服) + reasonable salary
- **B-tier (Online Quick Screen):** Some strengths but gaps — lower education, average background, career switchers, younger candidates with potential
- **C-tier (Pass):** Multiple red flags — commute too far, education too low + no skills, salary mismatch, background completely unrelated, too young with no experience

### Step 4: Output Analysis

Write the structured shortlist to `positions/<岗位>/analysis/YYYY-MM-DD-screening.md` with:
- Candidate summary table (name, age, education, experience, latest job, salary)
- Tier classification with rationale
- Red flag notes
- Recommendations for next steps

## Message Templates

- Shared templates (repeat inquiry, interview invitations, calendar notes, communication questions): `references/shared/boss-message-templates.md`
- Position-specific greetings and interview instructions: `positions/<岗位>/boss-greetings.md`

**Important:** Salary/compensation negotiation must be handled directly by 李明威 (Remi) in BOSS直聘 — do not quote salary in other channels.

## Related References

- `registry.md` — position list and status
- `positions/<岗位>/position.md` — position profile: channels, wiki tokens, material pointers
- `positions/<岗位>/screening-criteria.md` — per-position criteria matrix (妆造师: Wiki `HZwIwBImJi4EvckYVMAcWTlHnMh`)
- `positions/<岗位>/jd.md` — per-position JD (妆造师: Kigurumi mask & 玩偶妆造 variants, Wiki `ExtrwmJFriW1OYk9zizcoIiknje`)
- `positions/<岗位>/interview-notes.md` — position-specific interview content (妆造师: 小测 B, 水贴实践)
- `references/shared/interview-process.md` — generic in-person interview flow
- `references/shared/aptitude-test-a.md` — general aptitude test (8 questions)
- `references/shared/registration-form.md` — on-site registration form fields
- `positions/_template/` — copy to onboard a new position

## Talent Pool Database (人才资源库)

Feishu Bitable: Wiki `JFcNwXg8ViiFYbkhBlwcoNSBnAg` (base_token `WUkHb3FdJaAUhYszhwGcZffnn5f`), table `候选人库` (`tblX1YWWNVL46xul`).

Single-table design covering all departments and channels (lean, decision-first field order):

- **Decision:** 姓名, 初筛档位 (A-直接线下面试 / B-线上快筛 / C-不投入 / 待定), 当前状态 (新投递 → 已打招呼 → 待补充材料 → 线上快筛中 → 已约线下面试 → 已完成面试 → 已发offer → 已入职 / 已淘汰 / 人才储备), 下一步行动
- **Match signals:** 职业背景 (幼师/教培, 美术/设计, 美甲美容美发, 化妆/造型, 手工制作, 客服/行政, ...), 最近职位, 学历, 工作年限, 年龄, 现居城市, 期望薪资, 风险标记 (multi), 初筛备注
- **Archive:** 应聘部门 (妆造/研发/设计/市场/运营/职能/其他), 来源渠道 (BOSS直聘-邮箱简历, BOSS直聘-直聊, 内推, 主动投递, 猎头, 社交媒体, 招聘会, 其他), 投递日期, 简历附件, 邮件原文

Views: `A档-待约线下面试`, `B档-线上快筛`, `人才储备`, `全部候选人`.

Every screened candidate should be recorded here (including C-tier, as 人才储备/已淘汰); the mailbox remains only an ingestion channel, this Base is the source of truth for candidate status.

Multiple positions share this one table — distinguish them via the `应聘部门` field (filter as needed); create position-specific views only when actually required.

## Limitations

- Email bodies contain only summary data; full resumes are in PDF attachments
- Work stability (frequent job changes) and manual skill evidence require PDF review
- Red-line behaviors (attitude toward revisions, SOP adherence) require interview verification
