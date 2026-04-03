---
name: speckit/references/memory-protocol
description: 記憶差量協議與洞察畢業機制。context.md § Current 更新規則、insights.md 畢業流程。
---

# 記憶差量協議

`context.md` 為唯一溫層檔案。§ Current 區段追蹤工作流程狀態，§ Principles 提供原則快速參考。

## context.md 記憶結構

| 區段 | 用途 | 更新時機 |
|------|------|---------|
| Project Identity ~ Design References | 專案脈絡 | `/speckit.init` 或 Audit Mode |
| § Principles (Quick Reference) | 原則摘要表格（≤10 條） | 僅 `/speckit.init` |
| § Current | 4 行狀態追蹤（不增長） | 每個 `speckit.*` 指令完成時 |

## § Current 更新規則

每個 `speckit.*` 指令完成時，**覆寫**（非追加）以下 4 個欄位：

```markdown
## Current

- **Foundation**: complete
- **Phase**: execute
- **Last**: execute S005 — GREEN
- **Next**: /speckit.execute next
```

- **Foundation**: complete / partial / missing
- **Phase**: init / align / plan / execute / review / idle
- **Last**: 最近完成的動作摘要（≤1 行）
- **Next**: 建議的下一步指令

> 歷史紀錄依賴 `git log`，不在 context.md 中累積。

## 已廢除的檔案

| 舊檔案 | 替代方案 |
|--------|---------|
| `progress.md` | `context.md` § Current + `git log` |
| `milestone.md` | `plan.md` Phase Deliverables + `spec.md` |

## 中途更新

當計畫需要變更（設計修訂、驗證失敗、範疇變動）：

```
/speckit.plan update [變更內容]
```

更新模式保留既有工作、覆寫前建立快照，以 `[UNCHANGED]` / `[NEW]` / `[REVISED]` / `[REMOVED]` 標記變更。已完成的 action 永不丟棄。

# 洞察畢業機制

當某個洞察在 3+ 個功能的 `insights.md` 中重複出現，AI 在 `/speckit.execute` 的 REFLECT 步驟中應建議提升：

| 洞察類型 | 畢業目標 |
|---------|---------|
| 程式碼慣例 / 模式 | 提升到 `context.md` 的架構模式 |
| 踩坑經驗 / 約束 | 提升到 `principles.md` 的新 MUST/MUST NOT 規則 + `context.md` § Principles |
| 技術決策 | 記錄到 `context.md` 的關鍵決策 |

畢業流程：
1. AI 在 REFLECT 中發現重複 insight，建議：「此 insight 已在 3+ features 出現，建議提升到 [target]」
2. 用戶確認後，AI 執行提升（更新目標檔案 + 在 insights.md 標記 `[GRADUATED → target]`）
3. 畢業後的 insight 不從 insights.md 刪除（保留歷史記錄）
