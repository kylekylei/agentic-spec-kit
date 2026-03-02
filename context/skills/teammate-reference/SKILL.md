---
name: teammate-reference
description: Teammate 工作流程、檔案結構、記憶機制參考手冊。當需要查詢指令產物對應、檔案路徑、洞察畢業、progress.md 更新規則時使用。
---

# Teammate 參考手冊

此 skill 提供 Teammate 框架的參考資訊。核心行為規則請見 `teammate-rules.mdc`。

## 工作流程

指令必須依序執行，除非使用者明確要求跳過。

```
Init → Align → Plan → Execute → Review
```

### 基礎設定（每個專案執行一次）

| 指令 | 用途 |
|------|------|
| `/teammate.init` | 初始化或審計專案基礎（`context.md` + `principles.md`） |

### 每個功能

| 指令 | 用途 |
|------|------|
| `/teammate.align` | 定義要做什麼（Impact Mapping + Example Mapping）→ `spec.md` + `example-mapping.md` |
| `/teammate.plan` | 產生驗證場景與統一實作計畫 → `.feature` + `plan.md` + `contracts/ui/ui-spec.md`（UI 深度分析自動觸發） |
| `/teammate.execute` | Red-Green-Verify-Reflect-Dialogue 迴圈實作 |
| `/teammate.review` | 行為覆蓋率 + 需求品質 + 功能交付就緒度 |

### 品質關卡（Review 之後）

| 指令 | 用途 |
|------|------|
| `/teammate.audit` | 世界級產品體驗大師品質審計（安全 + 設計債 + 動態 A11y + 動態 AI 風險）|

### 幫助與工具（隨時可用 — 非主流程）

| 指令 | 用途 |
|------|------|
| `/teammate.helpme` | 🧭 智慧導航 — 偵測專案狀態，推薦最適合的下一步（首次使用者的最佳起點） |
| `/teammate.helpme healthcheck` | 工作流程健康診斷 |
| `/teammate.helpme consult [問題]` | 流程問診 |
| `/teammate.helpme migrate` | 版本遷移 |
| `/teammate.helpme assign` | 將 actions 轉為 GitHub Issues |

## 關鍵路徑

完整檔案結構與用途說明：

```
.teammate/
├── memory/
│   ├── context.md            # 專案身份、使用者、目標、技術棧
│   ├── principles.md         # 不可違反的原則（MUST / MUST NOT）
│   ├── progress.md           # 當前 session 狀態（每個指令自動更新）
│   └── milestone.md          # 里程碑追蹤（每個階段完成時更新）
├── llm/                      # LLM 系統層（跨角色：PM / 設計師 / 開發者共同維護）
│   ├── agent-spec.md         # 產品 LLM Agent 規格（角色定義、安全圍欄、System Prompt 邏輯）
│   └── README.md             # LLM 層說明與邊界定義
├── design/                   # 視覺設計資產（設計師控管）
│   └── figma-index.md        # Figma 專案與功能頁面連結
├── snapshots/                # 決策與計畫變更快照
├── templates/                # 文件模板
├── scripts/bash/             # 自動化腳本
│   └── check-foundation.sh   # Foundation 檢查（context.md + principles.md 驗證）
└── config/teammate.yml       # 生命週期設定（含版本欄位）

CHANGELOG.md                  # 版本發行紀錄（供 /teammate.helpme migrate 解析）

docs/                         # 外部參考知識庫（選用）
├── llms.txt                  # 參考索引（llms.txt 標準）
└── [library-name]/           # 各函式庫 API 文件
    ├── llms.txt
    └── api-reference.md

tasks/[###-task-name]/        # 各任務產物
├── spec.md                   # /teammate.align 產出（規格）
├── example-mapping.md        # /teammate.align 產出（範例）
├── scenarios/*.feature       # /teammate.plan 產出（場景）
├── plan.md                   # /teammate.plan 產出（Part 1: 架構 + Part 2: 行動）
├── insights.md               # /teammate.execute REFLECT 產出（動態知識）
├── contracts/ui/ui-spec.md   # /teammate.plan 產出（UI 規格，自動觸發）
└── checklists/               # /teammate.review 產出（就緒報告）
```

## 脈絡層級

每個指令載入 context 時，遵循三層架構。衝突時上層優先。

```
System Layer（系統層 — 跨 task 不變）:
  - principles.md          # 不可違反的原則
  - context.md             # 專案身份、技術棧、架構慣例
  - llm/agent-spec.md      # 產品 LLM Agent 規格（如有：角色定義、安全圍欄、System Prompt 邏輯）

Task Layer（任務層 — per task）:
  - spec.md                # WHAT: 要做什麼
  - plan.md                # HOW + STEPS: 技術架構 + 執行清單
  - scenarios/*.feature    # VERIFY: 驗證條件
  - insights.md            # LEARNED: 執行中學到的
  - contracts/ui/ui-spec.md  # UI: 組件規格（如有）

User Layer（使用者層 — 持久 + 即時）:
  - .cursorule             # 持久偏好（如存在）
  - $ARGUMENTS             # 即時輸入
  - handoffs               # 使用者選擇的下一步
```

> 載入優先級：System > Task > User。User Layer 影響 AI 的**溝通方式**，不影響**決策邏輯**。

## 洞察畢業機制

當某個洞察在 3+ 個功能的 `insights.md` 中重複出現，AI 在 `/teammate.execute` 的 REFLECT 步驟中應建議提升：

| 洞察類型 | 畢業目標 |
|---------|---------|
| 程式碼慣例 / 模式 | 提升到 `context.md` 的架構模式 |
| 踩坑經驗 / 約束 | 提升到 `principles.md` 的新 MUST/MUST NOT 規則 |
| 技術決策 | 記錄到 `context.md` 的關鍵決策 |

畢業流程：
1. AI 在 REFLECT 中發現重複 insight，建議：「此 insight 已在 3+ features 出現，建議提升到 [target]」
2. 用戶確認後，AI 執行提升（更新目標檔案 + 在 insights.md 標記 `[GRADUATED → target]`）
3. 畢業後的 insight 不從 insights.md 刪除（保留歷史記錄）

## 記憶差量協議

`progress.md` 採用**分區更新模式**。

### 分區結構

```markdown
# Active Context

## Current State
<!-- 此區塊由最近一個指令覆寫 -->

## Session Log
<!-- 此區塊為 append-only，每個指令完成時追加一行 -->

## Blockers
<!-- 有 blocker 時記錄，解決後標記 [RESOLVED] 而非刪除 -->
```

### 更新規則

每個 `teammate.*` 指令完成時：
1. **覆寫** `## Current State`：Phase、Last Command、Next Action（僅此區塊）
2. **追加** `## Session Log`：新增一行，格式為 `| Timestamp | Command | Key Output | Notes |`。**禁止修改或刪除既有行**
3. **更新** `## Blockers`：有新 blocker 時追加；解決時標記 `[RESOLVED]`，不刪除

> 這樣即使 LLM 在覆寫 Current State 時簡化內容，Session Log 中的歷史細節仍完整保留。

## Memory Delta Protocol 實作規範

每個 `teammate.*` 指令完成時，MUST 以下列格式更新 `progress.md`：

### 標準更新流程

1. **覆寫 `## Current State`**（僅此區塊）：
   ```markdown
   Phase: [階段名稱]
   Last Command: [指令名稱]
   Next Action: [建議下一步指令]
   [指令專屬欄位]
   ```

2. **追加 `## Session Log`**（append-only，禁止修改既有行）：
   ```markdown
   | [ISO timestamp] | [command] | [key output summary] | [notes] |
   ```

3. **更新 `## Blockers`**（有新 blocker 追加，解決時標記 `[RESOLVED]`）

### 各指令專屬欄位

| 指令 | Current State 額外欄位 | Session Log Key Output | Notes 範例 |
|------|---------------------|---------------------|-----------|
| init | Foundation Status: [完整/部分/缺失] | context [status], principles [status] | [bootstrap result] |
| align | Active Task: [name], Branch: [branch] | Task: [name], spec.md + example-mapping.md | [rules/examples count, open questions] |
| plan | Active Task: [name] | [N] scenarios, plan.md ([N] actions, [coverage]%) | [key decisions] |
| execute | Phase: [current phase], Task: [name] | [GREEN/RED], [action ID description] | [insights discovered] |
| review | Readiness: [status] | [N] critical, [N] high, Readiness: [status] | [recommendation] |
| audit | Audit Result: [FAIL/PASS/CONDITIONS] | [N] critical, [N] high, Score: [%] | [dimensions activated] |

**範例 Session Log 行**：
```markdown
| 2026-02-25 14:32 | align | Task: 003-refine, spec.md + example-mapping.md | 3 rules, 2 open questions |
```

## 中途更新

當計畫需要變更（設計修訂、驗證失敗、範疇變動）：

```
/teammate.plan update [變更內容]
```

更新模式會保留既有工作、覆寫前建立快照，並以 `[UNCHANGED]` / `[NEW]` / `[REVISED]` / `[REMOVED]` 標記變更。已完成的 action 永不丟棄。
