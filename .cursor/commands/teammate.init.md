---
description: Initialize or audit project foundation — check/fill context.md and principles.md, bootstrap environment. Combines kickoff + principles into one command.
handoffs: 
  - label: Start Alignment
    agent: teammate.align
    prompt: Foundation is ready. Let's align on the first feature...
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

`/teammate.init` 是 Teammate 的**一鍵初始化**指令。它檢查並填寫兩個 Foundation 檔案，確保專案可以開始工作。

- **新專案**：引導使用者輸入，自動偵測 repo 資訊，建立 Foundation
- **既有專案**：檢視檔案完整性，分析是否有優化空間，報告狀態

> 整合原 `/teammate.kickoff` 和 `/teammate.principles` 的功能。

### Mode Detection

| 狀態 | 行為 |
|------|------|
| 兩個檔案都不存在或全是 placeholder | **Init Mode**: 從頭建立 |
| 部分 placeholder 殘留 | **Complete Mode**: 補齊缺漏 |
| 兩個檔案都完整（無 placeholder） | **Audit Mode**: 分析優化建議，報告狀態 |

---

## Phase 1: Detect & Report

1. **Read `.teammate/memory/context.md`**
   - Scan for `[ALL_CAPS_IDENTIFIER]` placeholder tokens
   - Classify: Template / Partial / Complete

2. **Read `.teammate/memory/principles.md`**
   - Scan for `[ALL_CAPS_IDENTIFIER]` placeholder tokens
   - Classify: Template / Partial / Complete

3. **Report current status**:
   ```
   Foundation Status:
   - context.md: [Template/Partial/Complete] ([N] placeholders remaining)
   - principles.md: [Template/Partial/Complete] ([N] placeholders remaining)
   ```

4. **Route to mode**: Init / Complete / Audit

---

## Init Mode（新專案）

### Step 1: Collect Project Context

1. **Parse user input** from `$ARGUMENTS` for any provided information

2. **Auto-detect from repository**:
   - `README.md` → Project name, description
   - `package.json` / `go.mod` / `Cargo.toml` / `pyproject.toml` → Language, framework, dependencies
   - `tsconfig.json` / `.eslintrc` → Configuration
   - `.github/` → Workflows
   - `docker-compose.yml` → Infrastructure
   - `docs/llms.txt` → Available external references
   - Existing source code → Architecture patterns

3. **For missing required fields**: make informed guesses; only ask user if no reasonable default exists. **Maximum 5 questions**.

4. **Copy template and fill `.teammate/memory/context.md`**:
   - If file doesn't exist or is template: copy from `.teammate/templates/context-template.md`
   - Fill the following sections:
   - Project Identity (name, description, repo URL)
   - Core Behaviors (observable, testable)
   - Target Users (personas, roles, goals)
   - Business Goals (metrics, targets, priorities)
   - Technical Context (language, framework, testing stack)
   - Architecture Patterns (structure, naming conventions)
   - Integration Points (external systems, protocols)
   - Design References (optional: design system, Figma URL)

### Step 2: Define Principles

1. **Derive principles from project context**:
   - Technical constraints → MUST/MUST NOT statements
   - Architecture patterns → Invariants
   - Security/compliance needs → Behavior boundaries

2. **Structure principles**:
   - Core Principles with MUST / MUST NOT / Rationale / Verification
   - Behavior Boundaries table (ID / Forbidden Behavior / Reason / Enforcement)
   - System Invariants (INV-001, INV-002, ...)
   - Governance rules

3. **Copy template and write `.teammate/memory/principles.md`**:
   - If file doesn't exist or is template: copy from `.teammate/templates/principles-template.md`
   - Fill with derived principles

### Step 3: Environment Bootstrap

Based on Technical Context, set up the project's base environment:

1. **Determine dependency file** from primary language (package.json, requirements.txt, etc.)
2. **Populate base dependencies** from declared tech stack (framework, testing, BDD)
3. **Create minimal skeleton** (src/, tests/) if directories don't exist
4. **Create `.gitignore`** if not exists
5. **Run install and verify** — failure is non-blocking, logged as TODO
6. **Verify test runner** — confirm BDD/test toolchain works

> Skip condition: If dependency file already exists AND contains declared dependencies, skip bootstrap.

---

## Complete Mode（補齊缺漏）

1. **Identify remaining placeholders** in both files
2. **Auto-detect** values from repo context where possible
3. **Ask user** for values that can't be inferred (max 3 questions)
4. **Fill in** remaining placeholders
5. **Validate** both files are complete

---

## Audit Mode（分析優化）

當兩個檔案都完整時，執行健康分析：

### context.md 分析

- **陳舊偵測**: tech stack 描述是否與實際 package.json/go.mod 一致？
- **缺漏偵測**: 是否有新增的 integration points 未記錄？
- **架構一致性**: Code Organization 是否反映目前的目錄結構？

### principles.md 分析

- **覆蓋度**: 每個 MUST NOT 是否有對應的 enforcement 方式？
- **可測試性**: 每個 principle 是否有 verification criteria？
- **Invariant 完整性**: 是否有明顯缺漏的 invariant？
- **版本一致性**: Version 欄位是否正確？

### 優化建議

Output a structured report:
```markdown
## Foundation Audit Report

### context.md
- Status: ✅ Complete
- Findings:
  - [SUGGEST] Technical Context 的 framework 版本可更新（package.json 顯示 v5.x，context 記錄 v4.x）
  - [OK] Architecture Patterns 與目錄結構一致

### principles.md
- Status: ✅ Complete
- Findings:
  - [SUGGEST] BB-003 缺少 Enforcement 欄位
  - [SUGGEST] 考慮新增 INV-004: [suggestion based on code patterns]
  - [OK] 所有 MUST NOT 有對應 verification
```

---

## Final Steps

### Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/progress.md` using delta mode:
- **覆寫 `## Current State`**：Phase: Foundation, Last Command: init, Next Action: /teammate.align
- **追加 `## Session Log`**：`| [timestamp] | init | [mode]: context [status], principles [status] | [bootstrap result] |`
- **更新 `## Blockers`**：如有未解決的 placeholder，記錄為 blocker

### Report

Output:
- Foundation status (both files)
- Auto-detected values summary
- Bootstrap result (if applicable)
- Remaining placeholders (if any)
- Optimization suggestions (Audit Mode)
- Suggested next command: `/teammate.align`

## Behavior Rules

- **Auto-detect first, ask second** — minimize user effort
- **Never fabricate information** — if unsure, mark as `TODO(<FIELD>): needs clarification`
- **Idempotent** — running init again preserves existing values, only fills gaps or audits
- **Maximum 5 questions (Init) / 3 questions (Complete)** — respect user's time
- **Bootstrap is additive** — never overwrite existing dependency files
- **Bootstrap failure is non-blocking** — warn, log, continue
- **Snapshot on update** — if principles.md was previously complete and is being modified, snapshot first
