---
name: teammate/references/memory-protocol
description: Teammate 記憶差量協議與洞察畢業機制。progress.md 分區更新規則、各指令專屬欄位、insights.md 畢業流程。
---

# 記憶差量協議

`progress.md` 採用**分區更新模式**。

## 分區結構

```markdown
# Active Context

## Current State
<!-- 此區塊由最近一個指令覆寫 -->

## Session Log
<!-- 此區塊為 append-only，每個指令完成時追加一行 -->

## Blockers
<!-- 有 blocker 時記錄，解決後標記 [RESOLVED] 而非刪除 -->
```

## 更新規則

每個 `teammate.*` 指令完成時：
1. **覆寫** `## Current State`：Phase、Last Command、Next Action（僅此區塊）
2. **追加** `## Session Log`：新增一行，格式為 `| Timestamp | Command | Key Output | Notes |`。**禁止修改或刪除既有行**
3. **更新** `## Blockers`：有新 blocker 時追加；解決時標記 `[RESOLVED]`，不刪除

> 即使 LLM 在覆寫 Current State 時簡化內容，Session Log 中的歷史細節仍完整保留。

## 各指令專屬欄位

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

更新模式保留既有工作、覆寫前建立快照，以 `[UNCHANGED]` / `[NEW]` / `[REVISED]` / `[REMOVED]` 標記變更。已完成的 action 永不丟棄。

# 洞察畢業機制

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
