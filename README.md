# Teammate

> **把 AI 當成真正的同事，一起把事做完。**

Teammate 是一套以「日常協作語言」為核心的 AI 工作系統。它用來回答一個關鍵問題：

> **我們要怎麼把事情交給 AI，還能看得懂、控得住、信得過？**

---

## 快速開始

### 1. 初始化專案背景

```
/teammate.kickoff
```

建立專案的基本資訊——名稱、目標使用者、商業目標、技術堆疊。

### 2. 定義合作原則

```
/teammate.principles
```

定義不可違反的原則與邊界（MUST / MUST NOT）。

### 3. 對齊要做的事

```
/teammate.align 我想要建立一個用戶認證系統
```

透過 Impact Mapping 確認 WHO / WHY / HOW / WHAT。

### 4. 釐清模糊地帶

```
/teammate.clarify
```

用具體的例子和規則消除歧義。

### 5. 建立工作計畫

```
/teammate.plan
```

產生 Gherkin `.feature` 檔案作為行為的單一真實來源。

### 6. 定義技術方案

```
/teammate.tasks
```

用 Screenplay Pattern 定義角色、能力與技術計畫。

### 7. 拆解為可執行的 Actions

```
/teammate.actions
```

將計畫切分為原子化、可驗證的 Actions。

### 8. 動手完成

```
/teammate.execute
```

執行 Red-Green Loop——先寫測試（RED），再實作（GREEN）。

### 9. 檢視品質

```
/teammate.review
```

分析行為覆蓋率、一致性與風險。

### 10. 驗收

```
/teammate.checklist
```

產出 Feature Readiness 報告，確認是否達到驗收標準。

---

## 工作流程

```
Foundation ──→ Align ──→ Commit ──→ Deliver
```

| 階段 | 指令 | 目的 |
|------|------|------|
| **Foundation** | `/teammate.kickoff` | 初始化專案背景 |
| | `/teammate.principles` | 定義不可違反的原則 |
| **Align** | `/teammate.align` | 對齊問題與期待結果 |
| | `/teammate.clarify` | 釐清不明確的地方 |
| **Commit** | `/teammate.plan` | 建立可執行的計畫 |
| | `/teammate.tasks` | 定義 Tasks |
| | `/teammate.actions` | 拆解為 Actions |
| **Deliver** | `/teammate.execute` | 實際執行工作 |
| | `/teammate.review` | 檢視覆蓋率與風險 |
| | `/teammate.checklist` | 驗收品質檢查 |
| | `/teammate.assign` | 轉為 GitHub Issues |

### 指令銜接與下一步

- 每個指令的完整操作細節都在 `.cursor/commands/teammate.*.md`。
- 指令檔內會明確寫出 **使用時機**、**完成後的下一步指令**，並要求更新 `.teammate/memory/active-context.md` 以維持可追蹤性。

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
 ├─ Task    ← What must be completed
 │   ├─ Action  ← How it gets done
 │   └─ Action
 └─ Task
     └─ Action
```

- **Plan**：我們打算完成什麼
- **Tasks**：必須完成的工作項目
- **Actions**：為了完成 Tasks 所採取的具體行為

---

## 專案結構

```
Teammate/
├── .teammate/
│   ├── memory/
│   │   ├── project-context.md   # 專案背景
│   │   ├── principles.md        # 合作原則
│   │   ├── active-context.md    # 當前工作狀態
│   │   └── progress.md          # 進度追蹤
│   ├── templates/               # 文件模板
│   ├── scripts/bash/            # 輔助腳本
│   ├── config/teammate.yml      # 設定檔
│   └── snapshots/               # 快照
│
├── .cursor/
│   ├── commands/                # Teammate 指令
│   │   ├── teammate.kickoff.md
│   │   ├── teammate.principles.md
│   │   ├── teammate.align.md
│   │   ├── teammate.clarify.md
│   │   ├── teammate.plan.md
│   │   ├── teammate.tasks.md
│   │   ├── teammate.actions.md
│   │   ├── teammate.execute.md
│   │   ├── teammate.review.md
│   │   ├── teammate.checklist.md
│   │   └── teammate.assign.md
│   └── rules/
│       └── teammate-rules.mdc   # AI 工作規範
│
└── features/                    # Feature 工作目錄
    └── [###-feature-name]/
        ├── spec.md              # /teammate.align 產出
        ├── example-mapping.md   # /teammate.clarify 產出
        ├── scenarios/*.feature  # /teammate.plan 產出
        ├── screenplay.md        # /teammate.tasks 產出
        ├── tasks.md             # /teammate.tasks 產出
        ├── actions.md           # /teammate.actions 產出
        ├── contracts/ui/        # Figma page 連結
        └── checklists/          # /teammate.checklist 產出
```

備註：
- `.teammate/memory/README.md` 為說明檔，協助理解 memory 內容用途。
- `.cursor/skills/` 為可選的技能擴充目錄，若未使用可忽略。



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
