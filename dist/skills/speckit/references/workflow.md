---
name: speckit/references/workflow
description: 工作流程與指令對照表。Init → Align → Plan → Execute → Review 的執行順序與各指令的產出物。
---

# 工作流程

指令必須依序執行，除非使用者明確要求跳過。

```
Init → Align → Plan → Execute → Review
```

## 基礎設定（每個專案執行一次）

| 指令 | 用途 |
|------|------|
| `/speckit.init` | 初始化或審計專案基礎（`context.md` + `principles.md`） |

## 每個功能

| 指令 | 用途 |
|------|------|
| `/speckit.align` | 定義要做什麼（Impact Mapping + Example Mapping）→ `spec.md` + `example-mapping.md` |
| `/speckit.plan` | 產生驗證場景與統一實作計畫 → `.feature` + `plan.md` + `contracts/ui/ui-spec.md`（UI 深度分析自動觸發） |
| `/speckit.execute` | Red-Green-Verify-Reflect-Dialogue 迴圈實作（含程式碼與設計稿修改） |
| `/speckit.review` | 行為覆蓋率 + 需求品質 + 功能交付就緒度 |

## 幫助與工具（隨時可用 — 非主流程）

| 指令 | 用途 |
|------|------|
| `/speckit.sync` | 框架同步與版本遷移 |
| `/speckit.skills` | Skills/Agents 管理（list/add/remove/sync/detect） |
| `@speckit` | 🧭 智慧導航 — 偵測專案狀態，推薦最適合的下一步 |
| `@speckit healthcheck` | 工作流程健康診斷 |
| `@speckit consult [問題]` | 流程問診 |
| `@design-auditor` | 設計品質審查（可被 review 委派或獨立觸發） |
