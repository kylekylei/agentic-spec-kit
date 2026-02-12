---
description: Teammate utility toolkit — healthcheck (workflow health), consult (process diagnosis), migrate (version migration).
handoffs:
  - label: Run Foundation
    agent: teammate.init
    prompt: "healthcheck found missing or incomplete Foundation artifacts"
    send: true
  - label: Fix with Plan Update
    agent: teammate.plan
    prompt: "update — healthcheck found phase compliance issues"
    send: true
  - label: Run Full Review
    agent: teammate.review
    prompt: Run behavioral coverage analysis (artifact content quality check)
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

`/teammate.toolkit` 是 Teammate 的**工具箱**，提供不屬於主流程（align → plan → execute → review）但對專案維護至關重要的輔助功能。

### Parameter Routing

解析 `$ARGUMENTS` 的第一個詞決定執行哪個工具：

| 參數 | 功能 | 狀態 |
|------|------|------|
| `healthcheck` | 工作流程健康診斷（Foundation、階段合規、追溯骨架、Hub 同步） | ✅ 可用 |
| `consult [問題]` | 流程問診（使用者提問 → 分析 → 改善提案） | ✅ 可用 |
| `migrate` | 版本遷移工具（比對 Hub 版本、產出遷移計畫、套用更新） | ✅ 可用 |
| `assign` | 將 plan.md Actions 轉為 GitHub Issues（需 GitHub MCP） | ✅ 可用 |
| （空或無法辨識） | 顯示可用工具清單 | ✅ 可用 |

若 `$ARGUMENTS` 為空或無法辨識，輸出可用工具清單並結束：

```markdown
## 🧰 Teammate Toolkit

可用工具：

| 指令 | 說明 |
|------|------|
| `/teammate.toolkit healthcheck` | 工作流程健康診斷 |
| `/teammate.toolkit consult [問題]` | 流程問診 |
| `/teammate.toolkit migrate` | 版本遷移 |
| `/teammate.toolkit assign` | actions → GitHub Issues |
```

---

## Tool: healthcheck

**定位**：「工作流程健康檢查」—— 驗證 Teammate 流程是否被正確遵循（Foundation 完整性、階段順序、artifact 是否到齊、Active Context 準確性）。

### Operating Constraints

**STRICTLY READ-ONLY**: 不修改任何檔案。僅產出診斷報告。

### Phase 0: Locate Feature

1. Run `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root
2. Parse `FEATURE_DIR`
3. If no feature found → scan `features/` for the most recent feature directory
4. If no feature found at all → 只執行 Pass 1（Foundation）和 Pass 5（Hub Sync）

### Execution Steps

#### Pass 1: Foundation Integrity

檢查 Teammate Foundation 是否正確初始化：

**1a. project-context.md**
- 檔案是否存在？
- 掃描 `[ALL_CAPS_IDENTIFIER]` placeholder tokens → 若有則 CRITICAL
- 必要欄位是否填寫？（專案名稱、技術棧、使用者角色）

**1b. principles.md**
- 檔案是否存在？
- 掃描 `[ALL_CAPS_IDENTIFIER]` placeholder tokens → 若有則 CRITICAL
- 是否包含至少一條核心原則（MUST / MUST NOT）？

**1c. active-context.md**
- 檔案是否存在？
- 是否記載了當前階段和下一步動作？

**1d. teammate.yml**
- 檔案是否存在？
- 設定是否完整？

#### Pass 2: Phase-Aware Artifact Inventory

根據 `active-context.md` 記載的**當前階段**，判斷哪些 artifact 應該存在、哪些還不需要：

```
Teammate 流程：Foundation → Align → Commit → Deliver

Foundation 階段產物：project-context.md, principles.md
Align 階段產物：spec.md, example-mapping.md（簡化流程可省略 example-mapping）
Commit 階段產物：scenarios/*.feature, plan.md, contracts/ui/ui-spec.md
Deliver 階段產物：checklists/*.md, 實作程式碼
```

產出 Phase-Aware Inventory 表格：

| Artifact | 所屬階段 | 當前階段應存在？ | 實際存在？ | Status |
|----------|---------|---------------|----------|--------|
| project-context.md | Foundation | ✅ | ✅/❌ | OK / MISSING |
| principles.md | Foundation | ✅ | ✅/❌ | OK / MISSING |
| spec.md | Align | ✅/— | ✅/❌ | OK / MISSING / NOT YET |
| example-mapping.md | Align | ✅/— | ✅/❌ | OK / MISSING / NOT YET / SKIPPED (simplified) |
| scenarios/*.feature | Commit | ✅/— | ✅/❌ | OK / MISSING / NOT YET |
| plan.md | Commit | ✅/— | ✅/❌ | OK / MISSING / NOT YET |
| ... | | | | |

Status 定義：
- **OK**: 應該存在且存在
- **MISSING**: 應該存在但不存在 → HIGH 或 CRITICAL
- **NOT YET**: 尚未到達該階段，不存在是正常的
- **SKIPPED (simplified)**: 簡化流程中合法省略的 artifact

#### Pass 3: Phase Order Compliance

驗證 artifact 的建立順序是否符合 Teammate 流程規範：

**3a. 建立時間序列**
- 讀取每個 artifact 的建立/修改時間
- 檢查時間順序是否符合：`spec.md` ≤ `scenarios/*.feature` ≤ `plan.md`
- 異常：如果 `plan.md` 的時間比 `spec.md` 早 → 可能跳過了 Align 階段

**3b. Active Context 一致性**
- `active-context.md` 標記的「當前階段」是否與實際存在的 artifact 吻合？
- 例如：active-context 說在 `Deliver`，但 `plan.md` 不存在 → CRITICAL
- 例如：active-context 說在 `Align`，但 `plan.md` 已存在 → 可能忘記更新 active-context

**3c. Simplified Flow 合規**（若走簡化流程）
- 簡化流程最低要求：`spec.md` + `plan.md` 必須存在
- 是否滿足簡化條件？（單一模組、非行為變更、不涉及 Principles）
- 是否有遺漏測試？（簡化流程仍需至少 unit test）

#### Pass 4: Traceability Chain（快速檢查）

僅檢查追溯鏈的**結構是否存在**，不深入語意分析（語意完整性是 `review` 的職責）：

```
spec.md (FR-xxx) → scenarios/*.feature (@tag) → plan.md Part 2 (Sxxx [Verifies: @tag]) → plan.md Part 1 (architecture)
```

快速檢查項目：
- 每個 FR-xxx 是否至少有一個對應的 `@tag` 出現在 `.feature` 中？
- 每個 `.feature` 的 `@tag` 是否至少有一個 `[Verifies: @tag]` 出現在 `plan.md` Part 2 中？
- `plan.md` Part 2 中的 action 是否都引用了存在的 scenario tag？

> **注意**：healthcheck 只確認「鏈的骨架存在」，不深入語意分析。

#### Pass 5: Hub Sync Status（如果 `teammatesync_rule.mdc` 存在）

讀取 `teammatesync_rule.mdc` 中的 Teammate Hub 路徑，檢查：
- Hub 路徑是否存在且可讀？
- 本專案的 `teammate-rules.mdc` 與 Hub 版本是否一致？
- 本專案的 `teammate.*.md` commands 與 Hub 版本是否一致？
- 差異清單（如果有）

### Severity Assignment

- **CRITICAL**: Foundation 不完整（有 placeholder 或缺失）、Active Context 與實際狀態嚴重矛盾（聲稱在 Deliver 但缺少 Commit 產物）
- **HIGH**: 階段順序違反（跳過必要階段）、當前階段的必要 artifact 缺失、追溯鏈骨架斷裂
- **MEDIUM**: Active Context 未更新（狀態落後但 artifact 存在）、Simplified Flow 未滿足最低要求
- **LOW**: Artifact 建立時間異常但內容存在、Hub 微小差異

### Output: Diagnostic Report

```markdown
# 🔍 Healthcheck Report

**Feature**: [Name]
**Scanned**: [Date]
**Current Phase**: [Foundation / Align / Commit / Deliver]（依 active-context.md）
**Health**: [Healthy 🟢 / Needs Attention 🟡 / Issues Found 🔴]

## Foundation Status

| Item | Status | Detail |
|------|--------|--------|
| project-context.md | ✅/❌ | [OK / Has placeholders / Missing] |
| principles.md | ✅/❌ | [OK / Has placeholders / Missing] |
| active-context.md | ✅/❌ | [OK / Stale / Missing] |
| teammate.yml | ✅/❌ | [OK / Incomplete / Missing] |

## Phase-Aware Inventory

| Artifact | Phase | Required? | Exists? | Status |
|----------|-------|-----------|---------|--------|
| spec.md | Align | ✅ | ✅/❌ | OK / MISSING / NOT YET |
| ... | | | | |

## Phase Compliance

| Check | Result | Detail |
|-------|--------|--------|
| 階段順序 | ✅/⚠️/❌ | [artifact 建立時間序列] |
| Active Context 一致性 | ✅/⚠️/❌ | [聲稱階段 vs 實際狀態] |
| Simplified Flow 合規 | ✅/⚠️/N/A | [是否滿足最低要求] |

## Traceability Chain（骨架）

| From | To | Linked? |
|------|----|---------|
| FR-001 → @tag | spec → feature | ✅/❌ |
| @tag → [Verifies] | feature → actions | ✅/❌ |

## Hub Sync Status

| File | In Sync | Diff |
|------|---------|------|

## Summary

- Critical: [N]
- High: [N]
- Medium: [N]
- Low: [N]
- Hub Sync: [OK / Out of Sync]

## Recommended Actions

1. [Prioritized fix actions with corresponding `/teammate.*` commands]
```

---

## Tool: consult

**定位**：「流程問診」—— 使用者發現 Teammate 指令未達預期或流程有疑慮時，提出問題讓 AI 分析根因並給出改善提案。

與 `healthcheck` 的差異：`healthcheck` 是自動體檢（跑固定項目），`consult` 是門診問診（使用者帶著問題來，AI 分析後給診斷和處方）。

### Operating Constraints

**READ-ONLY**: 不主動修改任何檔案。產出改善提案供使用者確認後才執行。

### Input

使用者在 `consult` 後的自由文字即為問題，例如：

```
/teammate.toolkit consult 執行 /teammate.review 後沒有發現 contracts/ui 的組件名稱與 spec 不一致，為什麼漏掉了？
/teammate.toolkit consult tasks update 後 contracts/ui 沒有連帶更新，這是設計缺陷嗎？
/teammate.toolkit consult 這個 feature 走簡化流程是否正確？
```

### Execution Steps

1. **載入 Context**
   - 讀取 Foundation：`project-context.md`、`principles.md`
   - 讀取 `active-context.md`（當前階段）
   - 讀取當前 feature 的所有 artifact（如有）
   - 讀取 `PLAYBOOK.md`（歷史教訓）
   - 讀取相關的 `teammate.*.md` 指令定義（如果問題涉及特定指令）

2. **分析使用者問題**
   - 分類問題類型：指令設計問題 / 流程順序問題 / 職責邊界問題 / 效率問題 / 其他
   - 定位相關的 Teammate 規範和 artifact

3. **產出問診報告**

```markdown
# 🩺 Consult Report

**主訴**: [使用者的原始問題]
**分類**: [指令設計 / 流程順序 / 職責邊界 / 效率 / 其他]
**日期**: [Date]

## 觀察

[基於 artifact 和框架現狀的事實陳述]

## 診斷

[對照 Teammate 規範的判斷——問題出在哪裡？為什麼會這樣？]

## 處方（改善提案）

| # | 改善項目 | 影響範圍 | 建議動作 |
|---|---------|---------|---------|
| 1 | [具體改善] | [哪些檔案需修改] | [對應的 `/teammate.*` 指令或手動修改] |

## PLAYBOOK 回饋

[建議記錄到 PLAYBOOK.md 的教訓摘要，格式：日期 | 專案 | 教訓 | 改善]
```

4. **等待使用者確認**
   - 若使用者確認改善提案 → 執行修改並回饋到 `PLAYBOOK.md`
   - 若使用者只想記錄 → 僅寫入 `PLAYBOOK.md`
   - 若使用者否決 → 結束

---

## Tool: migrate

**定位**：「版本遷移」—— 比對專案的 Teammate 框架版本與 Hub 最新版本，產出遷移計畫並套用更新。

### Parameter Variants

| 用法 | 行為 |
|------|------|
| `migrate` | 產出遷移報告（預設，不修改檔案） |
| `migrate apply` | 產出報告後直接套用全部變更 |
| `migrate pick` | 產出報告後逐檔詢問是否套用 |

### Framework Files（遷移範圍）

遷移只操作 **Hub 管理的框架檔案**，不碰專案私有內容：

```
可遷移（Hub 管理）:
  .cursor/rules/teammate-rules.mdc
  .cursor/rules/teammatesync_rule.mdc
  .cursor/commands/teammate.*.md
  .teammate/templates/*
  .teammate/scripts/*
  .teammate/config/teammate.yml（merge 策略，見下方）

不可遷移（專案私有）:
  .teammate/memory/*
  .teammate/snapshots/*
  features/*
  .cursor/rules/*（非 teammate 的規則）
  .cursorule（User Profile）
  docs/*（專案文件）
  PLAYBOOK.md（Hub 專屬）
  CHANGELOG.md（Hub 專屬）
```

### Execution Steps

#### Step 1: Locate Hub

1. 讀取專案的 `.cursor/rules/teammatesync_rule.mdc`
2. 提取 `**Teammate Hub**: \`[PATH]\`` 中的路徑
3. 驗證路徑存在且可讀
4. 若路徑為 placeholder `[TEAMMATE_HUB_PATH]` 或不存在 → 報錯：

```markdown
## ❌ 無法定位 Teammate Hub

`teammatesync_rule.mdc` 中的 Hub 路徑未設定或無法存取。
請確認 `[TEAMMATE_HUB_PATH]` 已替換為實際路徑（例如 `D:\Teammate`）。
```

#### Step 2: Compare Versions

1. 讀取**專案** `.teammate/config/teammate.yml` 的 `version` 欄位
   - 若欄位不存在 → 視為 `"pre-tracking"`
2. 讀取 **Hub** `.teammate/config/teammate.yml` 的 `version` 欄位
3. 比較版本：
   - 相同 → 輸出「已是最新版本 (vX.Y.Z)」並結束
   - 專案版本較舊（或 pre-tracking）→ 繼續遷移流程
   - 專案版本較新 → 異常，警告使用者（專案超前 Hub，可能是 Hub 未更新）

#### Step 3: Parse Changelog

1. 讀取 Hub 根目錄的 `CHANGELOG.md`
2. 提取從專案版本到 Hub 版本之間的所有版本區段
   - pre-tracking → 取所有版本（完整歷史）
3. 彙整各版本的 Summary、Added、Changed、Removed、Breaking、Migration Notes

#### Step 4: Framework File Diff

對每個「可遷移」範圍內的檔案，逐一比對 Hub vs 專案：

| 比對結果 | 標記 | 說明 |
|---------|------|------|
| Hub 有，專案無 | `[NEW]` | 新增檔案 |
| 兩邊內容相同 | `[UP-TO-DATE]` | 無需更新 |
| Hub 與專案不同 | `[MODIFIED]` | 需更新 |
| Hub 無，專案有 | `[ORPHAN]` | Hub 已移除或專案自建，標記提醒 |

**`teammate.yml` 特殊處理**（merge 策略）：

`teammate.yml` 同時包含框架結構和專案配置，不能直接覆寫：

- **Hub 新增的 key** → 加入專案（使用 Hub 預設值）
- **Hub 刪除的 key** → 保留但加 `# [DEPRECATED by Hub vX.Y.Z]` 註解
- **Hub 修改結構但專案有自訂值** → 保留專案值，只更新結構
- **專案獨有的 key** → 保留不動
- **`version` 欄位** → 遷移完成後更新為 Hub 版本

#### Step 5: Generate Migration Report

產出報告（無論是否套用都先顯示）：

```markdown
# 🔄 Migration Report

**專案版本**: [project_version]
**Hub 版本**: [hub_version]
**跨越版本數**: [count]

## 版本摘要

（列出每個跨越版本的 Summary，最新在前）

- **[hub_version]**: [summary]
- ...

## 檔案變更計畫

| # | 檔案 | 狀態 | 動作 |
|---|------|------|------|
| 1 | `teammate-rules.mdc` | [MODIFIED] | 覆寫 |
| 2 | `some-template.md` | [NEW] | 新增 |
| ... | | | |

## Breaking Changes

（列出所有跨越版本的 Breaking 項目，若無則顯示「無」）

## 注意事項

（彙整所有跨越版本的 Migration Notes）

## teammate.yml Merge 計畫

| 變更 | 動作 |
|------|------|
| 新增 `version` 欄位 | 加入，值為 [hub_version] |
| ... | |
```

#### Step 6: User Confirmation

根據 `$ARGUMENTS` 的第二個詞決定行為：

- **`apply`** → 跳過確認，直接執行 Step 7
- **`pick`** → 對每個 `[NEW]` 和 `[MODIFIED]` 檔案逐一詢問：「套用此檔案？[Y/N]」
- **（預設，無第二參數）** → 使用 AskQuestion 詢問：
  - [A] 全部套用（等同 `apply`）
  - [B] 逐檔選擇（等同 `pick`）
  - [C] 只看報告，不執行

#### Step 7: Apply Migration

依確認結果執行：

1. **新增檔案** (`[NEW]`)：從 Hub 複製到專案對應路徑
2. **更新檔案** (`[MODIFIED]`)：用 Hub 版本覆寫專案版本
3. **teammate.yml**：執行 merge 策略（Step 4 描述）
4. **更新 `version`**：將專案 `teammate.yml` 的 `version` 設為 Hub 版本
5. **`[ORPHAN]` 檔案**：不自動刪除，僅在報告中提醒

產出遷移完成摘要：

```markdown
## ✅ 遷移完成

**版本**: [project_version] → [hub_version]
**新增**: N 個檔案
**更新**: N 個檔案
**跳過**: N 個檔案

### 已套用的檔案
- [列表]

### 需要手動處理
- [ORPHAN 檔案或 Breaking Changes 需要的手動操作]
```

#### Step 8: Update Active Context

若專案有 `.teammate/memory/active-context.md`：
- 追加 Session Log：`migrate | [project_version] → [hub_version], N files updated`

---

---

## Tool 4: `assign`

**定位**：將 `plan.md` Part 2 (Actions) 轉為 GitHub Issues，用於專案管理和團隊協作。

### Operating Constraints

- **需要 GitHub MCP**：`github/github-mcp-server/issue_write`
- **只在 GitHub repo 中運行**：檢查 remote URL 是否為 GitHub

### Execution Steps

1. **Load** `FEATURE_DIR/plan.md` Part 2 (Actions)，解析所有 actions（ID、phase、story、tags、dependencies）
2. **Verify** Git remote 是 GitHub URL
3. **For each action** 建立 GitHub Issue：
   - Title: `[ActionID] [Story] Description`
   - Body: Action details、acceptance criteria、related scenarios、dependencies
   - Labels: `action`, `phase-N`, `story-USN`, `parallel`（if [P]）, `priority-P1/P2/P3`
4. **Update** `plan.md` Part 2：在每個 action 後附加 Issue number（如 `(#123)`）
5. **Update Active Context**（Memory Delta Protocol）：追加 Session Log

### Error Handling

- Remote 非 GitHub → 報告並結束
- MCP 不可用 → 報告錯誤，附手動建立說明
- Issue 建立失敗 → 記錄錯誤，繼續其他 actions

---

## Key Rules

- **healthcheck = 體檢，consult = 問診，migrate = 升級，assign = 發派** — 四種不同的維護場景
- **READ-ONLY（healthcheck / consult）** — 不主動修改檔案（consult 的改善提案需使用者確認）
- **WRITE-ON-CONFIRM（migrate）** — migrate 預設只產出報告，需使用者確認才寫入（`apply` 除外）
- **Fast** — healthcheck 優先掃描 Foundation 完整性和階段合規性
- **Actionable** — 每個 finding / 改善提案都附帶建議的修正指令
- **Non-blocking** — 不需要所有 artifact 都存在才能執行
- **Extensible** — 新工具只需在 Parameter Routing 表格新增一行 + 在下方新增對應區段
- **遵循 teammatesync_rule** — 改善確認後回饋到 Hub 的 PLAYBOOK.md
- **migrate 不碰專案私有檔案** — `.teammate/memory/`、`features/`、`.cursorule`、`docs/` 永遠不被遷移覆寫
- **teammate.yml 用 merge 不用覆寫** — 保留專案自訂值，只新增 Hub 的新欄位