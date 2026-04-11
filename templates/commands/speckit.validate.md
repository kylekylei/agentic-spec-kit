---
description: Deep validation — security, architecture, code quality, design compliance, BDD output. Routes directly to Skills, replacing standalone agents.
handoffs:
  - label: Fix gaps
    agent: speckit.plan
    prompt: Update plan to address validate findings
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Outline

- **Deep validation**: code quality, security, architecture compliance, design quality
- Optional BDD Feature File generation
- Routes directly to Skills — no indirection layers

### Division with `/speckit.review`

| | `/speckit.review` | `/speckit.validate` (this command) |
|---|---------|---------------|
| Role | Behavior coverage + readiness gate | Deep quality validation |
| Focus | AC coverage, consistency, traceability matrix | Security, performance, architecture, design, BDD |
| Mutation | Read-only | Read-only |
| Timing | Immediately after execute | After review passes, before merge |
| Required | Mandatory | Recommended (can skip) |

### Argument Parsing

| Argument | Behavior |
|----------|----------|
| _(empty)_ | Full validation (auto-detect applicable dimensions) |
| `security` | Security scan only |
| `architecture` | Architecture compliance only |
| `quality` | Code quality only |
| `design` | Design/UX/A11y only |
| `bdd` | BDD Feature Files generation only |
| `--skip-bdd` | Full validation, skip BDD |

---

## Phase 0: Detection & Routing

### Load Context

Per `speckit/references/command-shared`. Also:
- Read System Scope table from `plan.md`
- Run prerequisites check with `--json --require-plan --include-plan` to get `SPEC_DIR`

### spec-ops Quality Gate

> Cross-system integration: spec-ops → agentic-spec-kit
> Contract: `{product}-spec-contract-v{N}.json` (schema: spec-ops `assets/spec-contract-schema.json`)

Scan for `specs/*/reviews/*-spec-contract-v*.json` (prefer latest version).

**3 框架 gate** (read from `quality_gates`):

| Verdict | Behavior |
| --- | --- |
| **Pass** | Normal flow — proceed to validation |
| **Conditional** | Note risk items from `overall.top_improvements`, flag low-scoring dimensions in report |
| **Fail** | **Block validation** — display failing gate details, recommend PM fixes product-spec first |

**X1–X4 橫切合規 join gate** (read from `crosscutting_compliance`):

| X Item | Triggered | Verdict | Behavior |
| --- | --- | --- | --- |
| X1 無障礙 | true | Fail | Flag A11y gap — Pass 5 Design Quality A11y checks elevated to CRITICAL |
| X2 AI 透明度 | true | Fail | Flag AI transparency gap — note in report |
| X3 AI 可追溯性 | true | Fail | Flag traceability gap — Pass 2 Architecture checks flag missing audit trail |
| X4 資料保護 | true | Fail | Flag data protection gap — Pass 1 Security Scan elevated to CRITICAL |
| Any X | false | N/A | Skip — not triggered by RC context |

**Mandatory Gates — 3 框架（blocking）**:

| Gate | Condition | Trigger |
| --- | --- | --- |
| SQ Required = 0 | 任何 SQ Required sub-char 得分 = 0 | Always |
| SQ1 < 50% | 功能適切性得分率 < 50% | Always |
| SQ5 < 50% | 可靠性得分率 < 50% | Always |
| DQ1–DQ5 Required = 0 | 固有品質任一 Required 得分 = 0 | `frameworks_enabled.dq = true` 且非 PRD-PLAT |
| LQ1 < 50% | 操作品質得分率 < 50% | `frameworks_enabled.lq = true` 且非 PRD-PLAT |

任一 gate fail → 標記為 ship blocker，列入報告。

**Dimension adjustment based on SQ/DQ/LQ scores:**

- `quality_gates.sq` low on `SQ6` → Pass 1 Security Scan elevated to CRITICAL threshold
- `quality_gates.sq` low on `SQ1` → Pass 4 Test Health coverage requirements raised
- `quality_gates.sq` low on `SQ4` → Pass 5 Design Quality UX checks mandatory
- `quality_gates.dq` low on `DQ1–DQ5` → Data validation checks elevated
- `quality_gates.lq` low on `LQ2.3` (幻覺控制) → AI output verification checks elevated

**Enable AC 驗證**（if Own/Enable dual-track active）:

For each triggered X item, verify corresponding Enable ACs (AC-E-NNN) have contract test evidence:
- AC-E exists in spec.md → check test file exists + passes
- AC-E missing for Required Enable sub-char → FAIL

If no `spec-contract.json` found → skip gate, proceed normally (no blocking).

### Model Routing

> Route validation tasks to the most appropriate model based on task complexity.

| Task Type | Recommended Model | Rationale |
| --- | --- | --- |
| Security scan (Pass 1) | Opus / most capable | Security requires deep reasoning, false negatives are costly |
| Architecture compliance (Pass 2) | Opus / most capable | Structural analysis needs broad context understanding |
| Code quality (Pass 3) | Sonnet / balanced | Pattern matching + heuristics, balanced speed/quality |
| Test health (Pass 4) | Sonnet / balanced | Coverage analysis is well-structured |
| Design quality (Pass 5) | Sonnet / balanced | Checklist-driven assessment |
| BDD generation (Pass 6) | Haiku / fast | Mechanical translation from tests to Gherkin |

**Implementation**: When the runtime supports model selection per subtask, route accordingly.
When single-model, use the most capable available model for all passes.
Model routing is advisory — the runtime may override based on availability.

### Dimension Routing

Auto-determine which validation dimensions to activate based on project characteristics:

| Dimension | Skills Loaded | Trigger Condition |
|-----------|--------------|-------------------|
| **Security** | `code-review`, `ai-review-pipeline` | Always |
| **Code Quality** | `code-review`, `code-refactoring` | Always |
| **Testing** | `code-review`, `playwright` | Always |
| **Architecture** | `c4-architecture`, `backend-development`, `postgresql` | Always |
| **Frontend** | `frontend-design` | System Scope Frontend ✅ |
| **Mobile** | _(project-specific skills)_ | System Scope Mobile ✅ |
| **Design/UX** | `frontend-design` | System Scope Frontend ✅ |
| **A11y** | `a11y-compliance` | System Scope Frontend/Mobile ✅ |
| **Design System** | _(project-specific skills)_ | Design tokens or Storybook detected |
| **BDD** | _(built-in)_ | Enabled by default (`--skip-bdd` to skip) |

- Only load installed skills. Mark uninstalled as 'Not enabled (missing [skill-name])'

---

## Pass 1: Security Scan

Scan per OWASP Top 10:

| Severity | Category | Checks |
|----------|----------|--------|
| CRITICAL | Injection | SQL injection, command injection, XSS |
| CRITICAL | Auth/AuthZ | Auth bypass, broken access control, JWT validation flaws |
| CRITICAL | Secret Leakage | Hardcoded API keys / tokens / secrets / passwords |
| HIGH | Cryptography | Weak hashing, plaintext transmission, insecure RNG |
| HIGH | Data Integrity | Unvalidated input, insecure deserialization, SSRF |
| MEDIUM | Security Config | Overly permissive CORS, missing rate limiting, missing CSP header |

## Pass 2: Architecture Compliance

| Severity | Category | Checks |
|----------|----------|--------|
| HIGH | SOLID Principles | SRP violations (God class/function), OCP violations, DIP violations |
| HIGH | Dependency Direction | Inner layer depends on outer, circular deps, cross-layer direct access |
| HIGH | Anti-patterns | Singleton abuse, anemic domain model, shotgun surgery |
| MEDIUM | API Design | Backward-incompatible changes, missing versioning, contract inconsistency |
| MEDIUM | Module Boundaries | Cross-boundary access, unclear responsibilities, insufficient encapsulation |

## Pass 3: Code Quality

| Severity | Category | Checks |
|----------|----------|--------|
| HIGH | Error Handling | Empty catch blocks, unhandled Promise rejections, error swallowing |
| HIGH | Type Safety | `any` overuse, incomplete type coverage, type assertions |
| MEDIUM | DRY Violations | Duplicated logic, copy-paste traces |
| MEDIUM | Naming Quality | Single-letter vars (non-loop index), vague names (`data`, `temp`) |
| MEDIUM | Complexity | Functions > 30 lines, 3+ nesting levels, > 3 parameters |
| LOW | Readability | Magic numbers/strings, inconsistent style |

## Pass 4: Test Health

| Severity | Category | Checks |
|----------|----------|--------|
| HIGH | Coverage Gaps | New/modified code lacks corresponding tests |
| HIGH | Test Quality | Tests verify implementation, not behavior |
| MEDIUM | Edge Cases | Critical logic missing boundary condition tests |
| MEDIUM | Flaky Patterns | `setTimeout` in tests, unresolved async, execution-order dependency |
| LOW | Over-mocking | Mocking the subject under test's own behavior |

## Pass 5: Design Quality (Conditional)

> Triggered only when System Scope Frontend/Mobile ✅.

### UX

| Severity | Category | Checks |
|----------|----------|--------|
| CRITICAL | Accessibility | `color-contrast`, `focus-states`, `aria-labels` |
| CRITICAL | Touch & Interaction | `touch-target-size`, `loading-buttons`, `error-feedback` |
| HIGH | Performance | `image-optimization`, `reduced-motion`, `content-jumping` |
| HIGH | Layout & Responsive | `viewport-meta`, `readable-font-size`, `horizontal-scroll` |
| MEDIUM | Style Consistency | `style-match`, `consistency` |

### A11y Compliance (POUR Principles)

- **Perceivable**: `<img>` missing `alt`, color contrast < 4.5:1, video missing captions
- **Operable**: Interactive elements not keyboard-accessible, missing focus indicator, touch target < 44x44px
- **Understandable**: Missing `<html lang>`, form missing error messages
- **Robust**: Missing semantic HTML, improper ARIA usage

### Design Debt

| Check | Method |
|-------|--------|
| Hardcoded colors | Search `#[0-9a-fA-F]{3,8}` outside token definition files |
| Magic Numbers | Search `margin: Npx`, `padding: Npx`, etc. using non-token spacing |
| Token Coverage | Calculate ratio of design token usage vs hardcoded values |

### AI Risk Compliance (Conditional: LLM ✅)

- AI-001: Chatbot AI disclosure
- AI-002: Periodic reminders in long conversations
- AI-003: AI-generated content labeling + metadata
- AI-004: Consent flow visual prominence
- AI-005: High-risk AI override/stop mechanism

## Pass 6: BDD Feature Files (Optional)

> Enabled by default. Skipped with `--skip-bdd` or user decline.

**Prerequisite**: `/speckit.review` passed (Readiness: Ready).

Prompt user:
```
Generate BDD Feature Files from passing tests? [Y/n]
```

### Generation Flow

1. Scan `SPEC_DIR` Acceptance Criteria (`spec.md`)
2. Scan passing test files (`*.test.ts`, `*.spec.ts`, `*.test.py`, etc.)
3. Map each passing AC to one Scenario
4. Derive Given/When/Then from actual test code (**never fabricate**)
5. `@tag` aligns with plan.md Action ID
6. Write to `SPEC_DIR/scenarios/*.feature`

### Quality Rules

- Scenarios are independently executable; steps are declarative (WHAT, not HOW)
- Tag convention: `@AC-001`, `@happy-path`, `@negative`, `@boundary`, `@principles`
- No implementation details (DB columns, API endpoint paths, etc.)

---

## Severity Scale

- **CRITICAL**: Security vulnerabilities, principle violations, A11y blockers
- **HIGH**: Architecture anti-patterns, performance bottlenecks, test coverage gaps
- **MEDIUM**: DRY violations, design debt, naming quality
- **LOW**: Style improvements, optimization opportunities

## Output Format

```markdown
## Validation Report

### spec-ops Quality Gate
#### 3 框架 Gate
| Framework | Score | Verdict | Blockers |
|-----------|-------|---------|---------|
| SQ (Spec Quality) | [0-100] | [Pass/Conditional/Fail/N/A] | [sub-char IDs or —] |
| DQ (Data Quality) | [0-100 or N/A] | [Pass/Conditional/Fail/N/A] | [sub-char IDs or —] |
| LQ (LLM Quality) | [0-100 or N/A] | [Pass/Conditional/Fail/N/A] | [sub-char IDs or —] |

#### X1–X4 橫切合規 Join Gate
| ID | 面向 | Triggered | Sub-chars | Verdict | Fail Reason |
|----|------|-----------|-----------|---------|------------|
| X1 | 無障礙 | [Yes/No] | SQ4.6 | [Pass/Fail/N/A] | [— or which char = 0] |
| X2 | AI 透明度 | [Yes/No] | SQ4.10, LQ4.1 | [Pass/Fail/N/A] | [—] |
| X3 | AI 可追溯性 | [Yes/No] | SQ6.3, SQ6.4, DQ11, LQ3.4 | [Pass/Fail/N/A] | [—] |
| X4 | 資料保護 | [Yes/No] | SQ6, DQ7, DQ8, LQ3.3 | [Pass/Fail/N/A] | [—] |

**Overall spec-ops Gate: [PASS / CONDITIONAL / FAIL / SKIPPED (no contract found)]**

---

### Code Validation Summary
| Dimension | Checks | Pass | Fail | Score | Status |
|-----------|--------|------|------|-------|--------|
| Security | [N] | [N] | [N] | [%] | [Enabled/Not enabled] |
| Architecture | ... | ... | ... | ... | ... |
| Code Quality | ... | ... | ... | ... | ... |
| Testing | ... | ... | ... | ... | ... |
| Design | ... | ... | ... | ... | ... |
| BDD | [N] scenarios | — | — | — | [Generated/Skipped] |

### Findings
| # | Dimension | Severity | Category | File:Line | Issue | Fix |
|---|-----------|----------|----------|-----------|-------|-----|

### Positive Findings
[Noteworthy good practices]

### BDD Output (if enabled)
| AC | Scenario | Feature File | Source Test |
|----|----------|--------------|------------|

### Conclusion
[PASS / FAIL / PASS WITH CONDITIONS]
```

## Finalize

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: validate
- **Last**: validate — [PASS/FAIL], [N] critical, [N] high
- **Next**: commit + merge | fix findings

## Operating Principles

> Common rules: see `speckit/references/command-shared`.

- Read-only (except BDD output)
- Every finding: issue + rationale + fix recommendation
- Professional tone — also highlight good practices
- Load only installed skills whose triggers are met
