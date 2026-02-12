# Teammate

> **把 AI 當成真正的同事，一起把事做完。**

Teammate 是一套以「日常協作語言」為核心的 AI 工作系統。它用來回答一個關鍵問題：

> **我們要怎麼把事情交給 AI，還能看得懂、控得住、信得過？**

---

## 快速開始

### 1. 初始化與基線檢查

```
/teammate.init
```

建立或補全 `context.md` 與 `principles.md`，並給出優化建議。

### 2. 對齊要做的事

```
/teammate.align 我想要建立一個用戶認證系統
```

透過 Impact Mapping + Example Mapping 對齊 WHO / WHY / HOW / WHAT 與邊界條件。

### 3. 建立工作計畫（架構 + 行動）

```
/teammate.plan
```

產生 `scenarios/*.feature` 與 `plan.md`（Part 1: Architecture、Part 2: Actions）。  
UI 任務可由系統自動偵測，或使用 `--ui` 觸發深度 UI 規格分析（輸出 `contracts/ui/ui-spec.md`）。

### 4. 動手完成

```
/teammate.execute
```

執行 Red-Green-Refactor-Reflect；並包含 plan stale 檢查（若 `spec.md` 較新會警告）。

### 5. 檢視品質與可交付性

```
/teammate.review
```

整合行為覆蓋與需求品質檢查，輸出風險與修正建議。

### Toolkit（隨時可用）

```
/teammate.toolkit healthcheck
/teammate.toolkit consult [問題]
/teammate.toolkit assign
/teammate.toolkit migrate
```

---

## 工作流程

```
Init ──→ Align ──→ Plan ──→ Execute ──→ Review ──→ Audit
```

| 階段 | 指令 | 目的 |
|------|------|------|
| **Init** | `/teammate.init` | 初始化與校準專案脈絡與原則 |
| **Align** | `/teammate.align` | 對齊需求、範圍與例外情境 |
| **Plan** | `/teammate.plan` | 產出情境 + 架構 + 可執行 Actions |
| **Execute** | `/teammate.execute` | 依 plan 實作、測試、反思 |
| **Review** | `/teammate.review` | 行為覆蓋 + 需求品質整合審查 |
| **Audit** | `/teammate.audit` | Sarcasmotron 對抗性合規審計（產品交付最終把關）|
| **Toolkit** | `/teammate.toolkit *` | 健康檢查、流程問診、Issue 指派、遷移 |

### 指令銜接與下一步

- 每個指令的完整操作細節都在 `.cursor/commands/teammate.*.md`。
- 指令檔內會明確寫出 **使用時機**、**完成後的下一步指令**，並要求更新 `.teammate/memory/progress.md` 以維持可追蹤性。

---

## 核心觀點

### AI 不是工具，而是同事

Teammate 預設 AI 能理解上下文、能執行任務、也會犯錯。因此它需要的是**清楚的工作語言與回饋機制**，而不是更多 prompt。

### 重點不是規格，而是「我們說好了什麼」

不追求一次寫完的完美文件，而是建立一套可以被執行、可以被檢視、可以被修正的**活體工作描述**。

### 信任是累積來的

信任來自小範圍交辦、明確檢視、持續修正。Teammate 把這件事設計成一個可重複運作的循環。

---

## 語意結構

```
Plan
 ├─ Part 1: Architecture  ← Why this design works
 └─ Part 2: Actions       ← How it gets done
```

- **spec.md**：定義做什麼、為什麼做、成功條件是什麼  
- **plan.md**：把策略落成可執行設計與行動（Architecture + Actions）

---

## 專案結構

```
Teammate/
├── .teammate/
│   ├── memory/
│   │   ├── context.md   # 專案背景
│   │   ├── principles.md        # 合作原則
│   │   ├── progress.md          # 當前工作狀態
│   │   └── milestone.md         # 里程碑追蹤
│   ├── templates/               # 文件模板
│   ├── scripts/bash/            # 輔助腳本
│   ├── config/teammate.yml      # 設定檔
│   └── snapshots/               # 快照
│
├── docs/                        # 外部參考知識庫
│   ├── llms.txt                 # 參考資料索引（llms.txt 標準）
│   ├── [library-name]/          # 第三方 API/SDK 文件
│   │   ├── llms.txt             # 該函式庫的 LLM 友善摘要
│   │   └── api-reference.md     # 完整 API 參考
│   └── design/                  # 設計系統文件與 Figma 索引
│       └── figma-index.md
│
├── .cursor/
│   ├── commands/                # Teammate 指令
│   │   ├── teammate.init.md
│   │   ├── teammate.align.md
│   │   ├── teammate.plan.md
│   │   ├── teammate.execute.md
│   │   ├── teammate.review.md
│   │   └── teammate.toolkit.md
│   └── rules/
│       └── teammate-rules.mdc   # AI 工作規範
│
└── tasks/                       # 任務工作目錄
    └── [###-task-name]/
        ├── spec.md              # /teammate.align 產出
        ├── example-mapping.md   # /teammate.align 產出
        ├── scenarios/*.feature  # /teammate.plan 產出
        ├── plan.md              # /teammate.plan 產出（Architecture + Actions）
        ├── contracts/ui/
        │   └── ui-spec.md       # UI 任務時由 /teammate.plan 產出
        └── checklists/          # /teammate.review 相關檢核輸出
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

## AI 合作角色（Teammate 優化時）

Teammate 的 AI 不是只會產文件的助手，而是你的流程共創夥伴：

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
- `.teammate/memory/README.md` 為說明檔，協助理解 memory 內容用途。
- `.cursor/skills/` 為可選的技能擴充目錄，若未使用可忽略。
- `docs/` 遵循 [llms.txt 標準](https://llmstxt.org/)，讓 AI 能快速索引外部參考資料。



---

## 最終目標

> **技術會更新，模型會替換，但良好的合作方式可以長久存在。**

Teammate 的目標不是讓 AI 更聰明，而是讓團隊：

- 看得懂 AI 在做什麼
- 控得住 AI 的行為邊界
- 隨著時間累積對 AI 的信任

---

## License

MIT
