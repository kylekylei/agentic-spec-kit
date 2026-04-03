# Agentic Spec-Kit

這是一套以「日常協作語言」為核心的 AI 工作系統。它用來回答一個關鍵問題：

> **我們要怎麼把事情交給 AI，還能看得懂、控得住、信得過？**

---

## 安裝

### 前置需求

- [Cursor](https://cursor.com/)（或 Claude Code / Antigravity）
- `git`、`rsync`（macOS / Linux 預設已有）

### 方式一：Script 安裝（推薦）

```bash
# Phison 內部
git clone http://fw_git.phison.com/kyle_lei/agentic-spec-kit.git ~/.speckit
~/.speckit/install.sh /path/to/your-project
```

或者如果你已在目標專案目錄：

```bash
~/.speckit/install.sh .
```

安裝完成後即可使用 `/speckit.init` 開始。

### 方式二：從 Source 直接同步

```bash
SPECKIT_HOME=/path/to/Source bash /path/to/Source/scripts/bash/speckit-sync.sh .
```

### 更新框架

```bash
~/.speckit/install.sh /path/to/your-project --self-update
```

---

## 快速開始

### 1. 初始化

```
/speckit.init
```

建立或補全 `context.md` 與 `principles.md`，智慧選配 Skills。

### 2. 對齊需求

```
/speckit.align 我想要建立一個用戶認證系統
```

透過 Impact Mapping + Example Mapping 對齊 WHO / WHY / HOW / WHAT。
產出 `spec.md` 與 `example-mapping.md`。

### 3. 建立計畫

```
/speckit.plan
```

產出 `plan.md`（Part 1: Architecture、Part 2: Actions），每條 Action 對齊 Acceptance Criteria。

### 4. 執行實作

```
/speckit.execute
```

依 Test-First 迴圈執行：RED → GREEN → VERIFY → REFACTOR → REFLECT → DIALOGUE。

### 5. 品質審查

```
/speckit.review
```

AC 覆蓋分析、一致性檢查、功能就緒關卡。

### 6. 深度驗證（可選）

```
/speckit.validate
```

安全、架構、程式碼品質、設計合規深度驗證。

---

## 工作流程

```
Init ──→ Align ──→ Plan ──→ Execute ──→ Review ─ ─→ (Validate)
```

| 階段 | 指令 | 目的 |
|------|------|------|
| **Init** | `/speckit.init` | 初始化專案脈絡與原則 |
| **Align** | `/speckit.align` | 對齊需求、範圍與例外情境 |
| **Plan** | `/speckit.plan` | 架構 + 可執行 Actions |
| **Execute** | `/speckit.execute` | 依 plan 實作、測試、反思 |
| **Review** | `/speckit.review` | AC 覆蓋 + 就緒關卡 |
| **Validate** | `/speckit.validate` | 深度品質驗證 |

---

## 專案結構

```
Source (agentic-spec-kit)/
├── templates/                     # 分發源（sync 到消費端）
│   ├── commands/                  # speckit.* 生命週期指令
│   │   ├── speckit.init.md
│   │   ├── speckit.align.md
│   │   ├── speckit.plan.md
│   │   ├── speckit.execute.md
│   │   ├── speckit.review.md
│   │   └── speckit.validate.md
│   ├── rules/                     # 常駐約束
│   │   ├── speckit-rules.mdc      # 協作框架（≤80 行）
│   │   ├── clean-code.mdc
│   │   ├── codequality.mdc
│   │   └── git-conventions.mdc
│   ├── skills/                    # 領域知識（按需載入，見 skill-registry.yml）
│   ├── agents/                    # AI 角色
│   │   └── speckit_helper.md
│   ├── hooks/                     # 自動化 hooks
│   │   ├── pre-command-foundation.sh
│   │   ├── post-edit-check.sh
│   │   └── settings.json
│   ├── context-template.md        # spec 模板
│   ├── principles-template.md
│   ├── spec-template.md
│   ├── plan-template.md
│   ├── example-mapping-template.md
│   ├── insights-template.md
│   └── feature-template.feature
│
├── scripts/bash/                  # Source 腳本
│   ├── speckit-sync.sh            # 主同步引擎
│   ├── speckit-skills.sh          # Skills 管理
│   ├── check-foundation.sh
│   ├── check-prerequisites.sh
│   └── ...
│
├── install.sh                     # 一鍵安裝
└── CLAUDE.md                      # Claude Code 參考
```

### 消費端結構

```
Consumer Project/
├── .cursor/ (or .claude/ or .agent/)
│   ├── commands/speckit.*.md
│   ├── rules/*.mdc
│   ├── skills/                    # 依 skills.yml 按需安裝
│   └── agents/speckit_helper.md
├── hooks/
│   ├── pre-command-foundation.sh
│   ├── post-edit-check.sh
│   └── settings.json
├── .specify/
│   ├── memory/
│   │   ├── context.md             # 溫層（§ Principles + § Current）
│   │   └── principles.md          # 冷層（完整版原則）
│   ├── config/
│   │   ├── speckit.yml
│   │   └── skills.yml
│   └── templates/
└── specs/
    └── [###-spec-name]/
        ├── spec.md
        ├── plan.md
        ├── insights.md
        └── checklists/
```

---

## 最終目標

> **技術會更新，模型會替換，但良好的合作方式可以長久存在。**

目標不是讓 AI 更聰明，而是讓團隊：

- 看得懂 AI 在做什麼
- 控得住 AI 的行為邊界
- 隨著時間累積對 AI 的信任
