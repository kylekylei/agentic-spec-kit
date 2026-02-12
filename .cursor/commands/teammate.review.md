---
description: Perform behavioral coverage analysis and feature readiness validation. Combines review + checklist into one comprehensive quality gate.
handoffs:
  - label: Create Issues
    agent: teammate.toolkit
    prompt: assign — Convert actions to GitHub Issues
    prompt: Convert tasks to GitHub issues
    send: true
  - label: Fix Gaps
    agent: teammate.plan
    prompt: Update plan to address review findings
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Perform a **professional, neutral** analysis of behavioral coverage, artifact consistency, and feature readiness. This is the final verification gate — combining behavioral review and requirements quality validation into one pass.

### Operating Constraints

**STRICTLY READ-ONLY**: Do **not** modify any files. Output a structured analysis report.

**Principles Authority**: The project principles (`.teammate/memory/principles.md`) are **non-negotiable**. Principles conflicts are automatically CRITICAL.

**Professional Tone**: Objective, constructive language suitable for team review. No sarcasm or inflammatory language.

### Phase 0: Foundation Check

1. **Read `.teammate/memory/context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.init` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Principles not defined. Run `/teammate.init` first."

### Setup

Run `.teammate/scripts/bash/check-prerequisites.sh --json --require-actions --include-actions` from repo root and parse:
- `FEATURE_DIR`, `AVAILABLE_DOCS`

Derive paths:
   - SPEC = `FEATURE_DIR/spec.md`
   - PLAN = `FEATURE_DIR/plan.md` (Part 1: Tasks + Part 2: Actions)
   - FEATURES = `FEATURE_DIR/scenarios/*.feature`
   - EXAMPLE_MAPPING = `FEATURE_DIR/example-mapping.md`
   - UI_SPEC = `FEATURE_DIR/contracts/ui/ui-spec.md` (if exists)
   - INSIGHTS = `FEATURE_DIR/insights.md` (if exists)

Abort if required files missing.

### Load Artifacts

   From spec.md: User stories, functional requirements, success criteria
   From plan.md Part 1 (Architecture): Technical decisions, project structure, constraints
   From plan.md Part 2 (Actions): Actions with [Verifies: @tag] markers, phase structure
   From scenarios/*.feature: All scenarios with tags, step definitions
   From principles: Principles and boundaries

---

## Pass A: Behavioral Coverage Analysis

#### Scenario Type Distribution

| Type | Count | Percentage | Target |
|------|-------|------------|--------|
| @happy-path | [N] | [%] | 30-40% |
| @alternative | [N] | [%] | 20-30% |
| @negative | [N] | [%] | 20-30% |
| @boundary | [N] | [%] | 10-15% |
| @principles | [N] | [%] | 5-10% |

#### Coverage by User Story

| Story | Scenarios | Happy | Negative | Principles | Status |
|-------|-----------|-------|----------|------------|--------|
| US1 | [N] | [N] | [N] | [N] | [Complete/Gaps] |

#### Behavior Quality Checks

- Are scenarios testing BEHAVIOR (what) or IMPLEMENTATION (how)?
- Are steps declarative or imperative?
- Are scenarios independent (can run in isolation)?

## Pass B: Consistency Analysis

#### B1. Traceability Verification
- Every requirement → scenarios → actions → [Verifies: @tag]
- Report gaps: requirements without scenarios, scenarios without actions, orphan actions

#### B2. Terminology Consistency
- Same concepts named differently across files?
- Entity names match between spec, model, and scenarios?

#### B3. Principles Alignment
- Every MUST NOT has a @principles scenario?
- Plan decisions align with principles?

#### B4. Example Mapping Coverage
- Every rule from example-mapping has scenarios?
- Questions all resolved?

#### B5. UI Contract Consistency (if CONTRACTS exist)
- Component names in `contracts/ui/` match spec and tasks?
- Props, routes, and enhanced components match plan.md architecture?
- Report terminology drift

## Pass C: Detection Passes

#### Duplication Detection
- Similar scenarios testing same behavior? Redundant step definitions?

#### Ambiguity Detection
- Vague scenario names? Unclear step language?

#### Underspecification
- Scenarios missing Then assertions? Steps with unclear outcomes?

#### Implementation Leakage
- Scenarios that describe HOW instead of WHAT? Technical terms in business scenarios?

## Pass D: Requirements Quality Validation

> 整合原 `/teammate.checklist` 的需求品質檢核功能。

#### Completeness
- Are all necessary requirements documented?
- Are error handling requirements defined for all failure modes?
- Are accessibility requirements specified?

#### Clarity
- Are requirements specific and unambiguous?
- Are vague terms quantified with specific criteria?
- Are success metrics measurable?

#### Consistency
- Do requirements align without conflicts?
- Are patterns consistent across the feature?

#### Coverage
- Are all scenarios/edge cases addressed?
- Are boundary conditions defined?
- Are negative paths specified?

#### Compliance Coverage（動態，偵測到才執行）

掃描 `context.md` tech stack + codebase 偵測前端/AI 特性：

**A11y**（偵測到前端 UI 時）:
- 所有互動 UI 元件是否有適當的 aria 屬性？
- 鍵盤導航是否覆蓋所有功能？
- 色彩對比是否達 WCAG 2.2 AA 標準？
- 表單是否有錯誤提示與 `aria-invalid`？

**AI Risk**（偵測到 LLM/AI 時）:
- AI 互動是否有首次揭露機制？
- AI 生成內容是否有標示（可見 + 機器可讀）？
- 同意流程是否具同等視覺顯著性？
- 高風險決策是否有人類覆寫機制？

> 此為初步檢查。完整對抗性審計請執行 `/teammate.audit`。

## Pass E: Traceability Matrix

Build traceability from behaviors to implementation:

| Scenario | Rule | Action(s) | Status |
|----------|------|-----------|--------|
| @us1-login-success | Rule 1 | S012-S015 | [Pass/Fail/Pending] |

Identify gaps: Scenarios without actions, actions without scenarios, rules without examples.

## Pass F: Living Documentation

Generate `FEATURE_DIR/checklists/feature-readiness.md`:

```markdown
# Feature Readiness Report: [Feature Name]

**Generated**: [Date]
**Status**: [Ready/Not Ready/Partial]

## Executive Summary
[2-3 sentence overview]

## Behavioral Coverage
[Scenario distribution + coverage by story]

## Requirements Quality
| Dimension | Score | Issues |
|-----------|-------|--------|
| Completeness | [%] | [N] |
| Clarity | [%] | [N] |
| Consistency | [%] | [N] |
| Coverage | [%] | [N] |

## Findings
| ID | Category | Severity | Location | Finding | Recommendation |
|----|----------|----------|----------|---------|----------------|

## Traceability Summary
[Matrix from Pass E]

## Principles Compliance
| Principle | Coverage | Status |
|-----------|----------|--------|

## Metrics
- Total Scenarios: [N]
- Total Actions: [N]
- Scenario Coverage: [%]
- Principles Coverage: [%]
- Critical Issues: [N]

## Recommendation
[Ready to proceed / Needs attention / Blocked]
```

---

## Severity Assignment

- **CRITICAL**: Principles violations, missing coverage for P1 scenarios, requirements quality < 60%
- **HIGH**: Duplicate scenarios, ambiguous requirements, P2 coverage gaps
- **MEDIUM**: Terminology drift, minor coverage gaps, unclear steps
- **LOW**: Style improvements, optimization opportunities

## Feature Readiness Gates

| Gate | Criteria | Blocking? |
|------|----------|-----------|
| Requirements Quality | All dimensions > 80% | Yes |
| Happy Path Coverage | 100% of P1 stories | Yes |
| Negative Coverage | At least 1 per story | Yes |
| Principles Coverage | At least 1 boundary | Yes |
| Traceability | All scenarios linked to actions | No |
| Open Issues | No critical/high issues | Yes |

## Next Actions

Based on findings:
- If CRITICAL: Must resolve before proceeding → suggest `/teammate.plan update`
- If HIGH: Should address for quality → suggest specific fixes
- If only LOW/MEDIUM: Can proceed → suggest `/teammate.toolkit assign`

## Pass G: Design System Compliance（偵測到前端才啟用）

若 Phase 1 偵測到前端 UI 代碼，執行以下檢查：

#### Token 合規
- 搜尋硬編碼顏色值（`#[0-9a-fA-F]{3,8}` 且非在 token 定義檔中）
- 搜尋硬編碼間距值（`margin: Npx`、`padding: Npx` 等非 token 值）
- 統計 Token 覆蓋率：使用 design token 的樣式 vs 硬編碼值

#### 視覺一致性
- 偵測非 Token 樣式（原生 px 值、inline style）
- 品牌調性一致性（字體、圓角、陰影是否使用統一 token）

#### 輸出

```markdown
### Design System Compliance

| 檢查項 | 狀態 | 數量 |
|--------|------|------|
| 硬編碼顏色值 | [PASS/FAIL] | [N] |
| 硬編碼間距值 | [PASS/FAIL] | [N] |
| Token 覆蓋率 | [%] | — |
```

> 完整 Design Debt 審計請執行 `/teammate.audit design-debt`。

## Update Progress

Update `.teammate/memory/milestone.md`: Feature verification status, coverage metrics, readiness assessment.

## Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/progress.md` using delta mode:
- **覆寫 `## Current State`**：Phase: Deliver, Last Command: review, Next Action: [recommended command]
- **追加 `## Session Log`**：`| [timestamp] | review | [N] critical, [N] high, Readiness: [status] | [recommendation] |`
- **更新 `## Blockers`**：如有 CRITICAL findings，記錄為 blocker

## Report Completion

Output:
- Path to `feature-readiness.md`
- Executive summary (2-3 sentences)
- Critical/High findings count
- Readiness status
- Recommended next steps
- Suggested next command

## Analysis Guidelines

### Behavior vs Implementation

**Good**: "User sees confirmation message", "Order is placed successfully"
**Bad**: "API returns 200 status", "Database record is created"

### Professional Language

**Use**: "This scenario could be enhanced with...", "Consider adding coverage for..."
**Avoid**: "This is wrong", "You forgot to..."

### Coverage Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| P1 Happy Path | 100% | 100% |
| P1 Negative | 50%+ | 25% |
| Principles | 100% | 80% |
| Overall | 80%+ | 60% |

## Operating Principles

- **NEVER modify files** (read-only analysis)
- **NEVER hallucinate** (report only what's found)
- **Prioritize principles** (violations are always CRITICAL)
- **Be constructive** (every finding has a recommendation)
- **Be specific** (cite exact locations and issues)
