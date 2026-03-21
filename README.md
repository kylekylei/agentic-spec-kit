# Agentic Spec-Kit


## AI as Teammate
## Compliance as Code
## Design as Code

---


這是一套以「日常協作語言」為核心的 AI 工作系統。它用來回答一個關鍵問題：

> **我們要怎麼把事情交給 AI，還能看得懂、控得住、信得過？**

---

## 安裝

### 前置需求

- [Cursor](https://cursor.com/)（或 Claude Code / Antigravity）
- `git`、`rsync`（macOS / Linux 預設已有）

### 方式一：Script 安裝（推薦）

在你的專案目錄執行：

```bash
# 下載並執行安裝腳本
git clone http://fw_git.phison.com/kyle_lei/agentic-spec-kit.git ~/.speckit-hub
~/.speckit-hub/install.sh /path/to/your-project
```

或者如果你已在目標專案目錄：

```bash
~/.speckit-hub/install.sh .
```

安裝完成後即可使用 `/speckit.init` 開始。

### 方式二：從 Hub 直接同步

若你已有 Hub clone，在目標專案執行：

```bash
SPECKIT_HOME=/path/to/Hub bash /path/to/Hub/dist/skills/speckit/scripts/bash/speckit-sync.sh .
```

### 更新框架

```bash
~/.speckit-hub/install.sh /path/to/your-project --self-update
```

---

## 快速開始

### 1. 初始化與基線檢查

```
/speckit.init
```

建立或補全 `context.md` 與 `principles.md`，並給出優化建議。

### 2. 對齊要做的事

```
/speckit.align 我想要建立一個用戶認證系統
```

透過 Impact Mapping + Example Mapping 對齊 WHO / WHY / HOW / WHAT 與邊界條件。
產出 `spec.md`（模板約束版，精簡段落）與 `example-mapping.md`（P1 完整展開，P2/P3 單行摘要）。

### 3. 建立工作計畫（架構 + 行動）

```
/speckit.plan
```

產生 `scenarios/*.feature`、型別定義（`types.d.ts` / `schema.sql`）與 `plan.md`（Part 1: Architecture、Part 2: Actions，每條單行）。
UI 任務可由系統自動偵測，或使用 `--ui` 觸發深度 UI 規格分析（輸出 `contracts/ui/ui-spec.md`）。

### 4. 動手完成

```
/speckit.execute
```

執行 Red-Green-Refactor-Reflect；AI 僅回傳 Function Body 或指定程式碼片段，嚴格禁止輸出不相關樣板。並包含 plan stale 檢查（若 `spec.md` 較新會警告）。

### 5. 檢視品質與可交付性

```
/speckit.review
```

整合行為覆蓋與需求品質檢查；自動根據 `spec.md` Success Criteria 產生 3–5 個斷言樣本，輸出風險與修正建議。

### 工具指令（隨時可用）

```
/speckit.skills              # 查詢、安裝、更新 Skills
/speckit.sync                # 同步框架到消費專案 / 檢查版本
```

---

## 工作流程

```
Init ──→ Align ──→ Plan ──→ Execute ──→ Review
```

| 階段 | 指令 | 目的 |
|------|------|------|
| **Init** | `/speckit.init` | 初始化與校準專案脈絡與原則 |
| **Align** | `/speckit.align` | 對齊需求、範圍與例外情境 |
| **Plan** | `/speckit.plan` | 產出情境 + 架構 + 可執行 Actions |
| **Execute** | `/speckit.execute` | 依 plan 實作、測試、反思 |
| **Review** | `/speckit.review` | 行為覆蓋 + 需求品質整合審查 |
| **Skills** | `/speckit.skills` | 查詢、安裝、更新 Skills 與 Agents |
| **Sync** | `/speckit.sync` | 同步框架版本到消費專案 |

### 指令銜接與下一步

- 每個指令的完整操作細節都在 `.cursor/commands/speckit.*.md`。
- 指令檔內會明確寫出 **使用時機**、**完成後的下一步指令**，並要求更新 `.specify/memory/progress.md` 以維持可追蹤性。

---

## 核心觀點

### AI 不是工具，而是同事

預設 AI 能理解上下文、能執行任務、也會犯錯。因此它需要的是**清楚的工作語言與回饋機制**，而不是更多 prompt。

### 重點不是規格，而是「我們說好了什麼」

不追求一次寫完的完美文件，而是建立一套可以被執行、可以被檢視、可以被修正的**活體工作描述**。

### 信任是累積來的

信任來自小範圍交辦、明確檢視、持續修正。把這件事設計成一個可重複運作的循環。

---

## 語意結構

```
Plan
 ├─ Part 1: Architecture  ← Why this design works + Type Definitions
 └─ Part 2: Actions       ← How it gets done (single-line per action)
```

- **spec.md**：定義做什麼、為什麼做、成功條件是什麼（精簡模板版，每章節 ≤ 5 條）
- **example-mapping.md**：P1 規則完整展開，P2/P3 僅一行摘要
- **plan.md**：把策略落成可執行設計與行動（Architecture + Actions）
- **types.d.ts / schema.sql**：由 Plan 階段根據 spec 直接生成的型別定義

---

## 精簡產出策略

採「**精簡文件生成規則**」而非廢棄文件——保留可追溯性、降低 token 消耗：

| 手段 | 效果 |
|---|---|
| `spec.md` 模板字數約束 | 每章節 ≤ 5 條，避免段落式展開 |
| P2/P3 rules 單行摘要 | 僅 P1 完整展開，次要規則一行帶過 |
| 200 字 JSON 跨階段摘要 | Align→Plan→Execute 的脈絡錨點（補充用，不取代原文件） |
| Action 描述強制單行 | plan.md Actions 聚焦「做什麼」，不展開實作細節 |
| Execute 僅回傳 Function Body | 禁止輸出整個文件或不相關樣板 |
| Review 斷言自動產生 | 根據 Success Criteria 生成 3–5 個可執行斷言 |

---

## 專案結構

```
Hub/
├── .specify/
│   ├── memory/
│   │   ├── context.md           # 專案背景（含 Figma URL 時觸發設計資產建立）
│   │   ├── principles.md        # 合作原則
│   │   ├── agent-spec.md        # AI Agent 行為規範（角色、安全圍欄、對話策略）
│   │   ├── progress.md          # 當前工作狀態
│   │   └── milestone.md         # 里程碑追蹤
│   ├── design/                  # 設計資產（/speckit.align 偵測到 Figma URL 時建立）
│   │   └── figma-index.md       # Figma 專案與 feature 頁面連結
│   ├── templates/               # 文件模板
│   ├── scripts/bash/            # 輔助腳本
│   ├── config/speckit.yml       # 設定檔
│   └── snapshots/               # 快照
│
├── .cursor/
│   ├── commands/                # 指令（speckit.* 生命週期）
│   │   ├── speckit.init.md
│   │   ├── speckit.align.md
│   │   ├── speckit.plan.md
│   │   ├── speckit.execute.md
│   │   ├── speckit.review.md
│   │   ├── speckit.skills.md
│   │   └── speckit.sync.md
│   ├── agents/                  # AI 角色 / Persona
│   │   ├── designer.md          # UX/UI 首席設計師 + 設計主管 + 設計系統架構師
│   │   ├── design-auditor.md    # 設計品質審查（UX / a11y / AI 風險）
│   │   ├── architect.md         # 資深軟體工程師 + 系統架構師 + 工程主管
│   │   ├── frontend.md          # 資深前端工程師 + 前端架構顧問 + 跨平台工程師
│   │   ├── code-auditor.md     # 程式碼品質審查（安全 / 效能 / 架構 / 品質 / 測試）
│   │   └── ...
│   ├── skills/                  # 領域知識 + 可重用能力（按需載入）
│   │   ├── git-commit/          # Conventional Commits 規範
│   │   └── ...
│   └── rules/
│       └── speckit-rules.mdc    # 共創契約與架構原則（alwaysApply）
│
└── specs/                       # 功能規格工作目錄
    └── [###-spec-name]/
        ├── spec.md              # /speckit.align 產出
        ├── example-mapping.md   # /speckit.align 產出
        ├── scenarios/*.feature  # /speckit.plan 產出
        ├── plan.md              # /speckit.plan 產出（Architecture + Actions）
        ├── contracts/ui/
        │   └── ui-spec.md       # UI 任務時由 /speckit.plan 產出
        └── checklists/          # /speckit.review 相關檢核輸出
```

### spec.md vs plan.md

任務目錄中最重要的兩份文件有本質上的差異：

| | spec.md | plan.md |
|---|---------|----------|
| **回答的問題** | 做什麼？為什麼？給誰用？ | 怎麼做？為何這樣做？先做哪些？ |
| **讀者** | 非技術人員也能看懂 | 開發者 |
| **語言** | 業務語言（使用者故事、驗收標準） | 技術語言（模組、函式、路徑） |
| **可變性** | 除非需求變了，否則不改 | 實作過程中可能調整 |

- **只有 spec，沒有 plan**：知道要做什麼，但不知道怎麼落地，實作容易分歧。
- **只有 plan，沒有 spec**：知道怎麼做，但失去價值判準，難以驗收。
- **兩者都有**：spec 定義完成標準，plan 定義執行路徑。即使換 session 也能接手。

---

## AI 合作角色

AI 不是只會產文件的助手，而是你的流程共創夥伴：

- **產品意圖守門員**：先守住「讓開發者專注策略與體驗」這個核心價值。
- **複雜性搬運工**：遵守 Tesler's Law，主動把複雜性從人搬到系統與自動化。
- **流程體驗設計師**：追求低心智負擔與高品質結果，不用更多步驟換假精準。
- **品質把關者**：簡化不等於草率，必須保留可追溯、可驗證、可維護。

### Definition of Done（流程優化版）

任何流程、命令、artifact、目錄結構或操作方式有修正時：

1. 命令與規則完成更新
2. 相關模板與腳本完成對齊
3. `README.md` 同步完成

缺少第 3 項，視為未完成。

備註：
- `.specify/memory/README.md` 為說明檔，協助理解 memory 內容用途。
- `.specify/design/` 為設計資產目錄，當 `context.md` 包含 Figma URL 時由 `/speckit.align` 自動建立。
- `.cursor/agents/` 為 AI 角色目錄，依使用者選擇按需載入，不佔用常駐 context。
- `.cursor/skills/` 為領域知識與能力模組，由 Agent 依意圖路由載入；可透過 `/speckit.skills` 管理。



---

## 最終目標

> **技術會更新，模型會替換，但良好的合作方式可以長久存在。**

目標不是讓 AI 更聰明，而是讓團隊：

- 看得懂 AI 在做什麼
- 控得住 AI 的行為邊界
- 隨著時間累積對 AI 的信任

