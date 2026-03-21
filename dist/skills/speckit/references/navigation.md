---
name: speckit/references/navigation
description: 智慧導航邏輯。偵測專案狀態（Foundation / 進度）、首次引導模式、進度偵測模式、輸出格式與核心規則。被 speckit agent 使用。
---

# 智慧導航

## Step 1: 偵測專案狀態

按順序檢查，**遇到第一個未通過的就停下來**：

**1a. Foundation 是否存在？**  
檢查 `.specify/memory/context.md` 和 `.specify/memory/principles.md`。  
兩者都不存在 → 全新專案，進入 Step 2A（首次引導）。

**1b. Foundation 是否完整？**  
掃描兩檔是否含 `[PLACEHOLDER]` 或 `[ALL_CAPS_IDENTIFIER]`。  
有 placeholder → 引導使用者填寫後執行 `/speckit.init`。

**1c. 是否有進行中的 task？**
- `specs/` 不存在或為空 → 建議 `/speckit.align`
- 有 spec 目錄 → 進入 Step 2B（進度偵測）

## Step 2A: 首次引導模式

```markdown
# 👋 Welcome!

我會陪你從需求釐清到產品交付，一步步把想法變成可靠的軟體。

## 快速上手（3 步驟）

**Step 1**: 編輯 `.specify/memory/context.md`（專案名稱、描述、目標使用者、技術棧）
**Step 2**: 編輯 `.specify/memory/principles.md`（MUST / MUST NOT 原則，1-2 條即可）
**Step 3**: 執行 → [A] 下一步 → /speckit.init
```

若模板存在（`.specify/templates/context-template.md`）且 memory 檔案尚未建立，先從模板複製。

## Step 2B: 進度偵測模式

讀取 `.specify/memory/progress.md`，掃描最近的 spec 目錄：

| 偵測到的狀態 | 判斷依據 | 建議 |
|------------|---------|------|
| Foundation 完成，無 spec | `context.md` + `principles.md` 完整，`specs/` 為空 | → `/speckit.align` |
| Align 進行中 | `spec.md` 存在但無 `plan.md` | → `/speckit.plan` |
| Plan 完成 | `plan.md` 存在，actions 均未完成 | → `/speckit.execute` |
| Execute 進行中 | `plan.md` 有部分 actions 已完成 | → `/speckit.execute next` |
| Execute 完成 | 所有 actions 標記完成 | → `/speckit.review` |
| Review 完成 | `checklists/` 有報告且 Readiness: Ready | → commit → checkout main → merge |

## 輸出格式

```markdown
# 🧭 專案導航

**專案**: [從 context.md 讀取]
**目前階段**: [Phase]
**最近任務**: [spec 目錄名稱]

## 目前狀態
[一句話描述]

## 建議下一步
[A] 下一步 → /speckit.[command]
```

有注意事項時附上：
```markdown
> 💡 小提醒：[問題描述]。可用 `@speckit healthcheck` 做完整健康檢查。
```

## 核心規則

- **唯讀（healthcheck / consult）** — 不主動修改檔案
- **確認後寫入（migrate）** — 預設只產出報告，需確認才寫入（`apply` 除外）
- **非阻塞** — 不需所有 artifact 都存在才能執行
- **migrate 不碰私有檔案** — `.specify/memory/`、`specs/`、`docs/` 永遠不被覆寫
- **speckit.yml 用 merge** — 保留專案自訂值，只新增 Hub 的新欄位
