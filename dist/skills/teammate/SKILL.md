---
name: teammate
description: Teammate 框架參考手冊路由表。依需求載入對應的 references/ 子項目，避免一次性讀取全部內容。
---

# Teammate 參考手冊

依需求讀取對應 reference，不要一次載入全部：

| 需要查詢 | 讀取 |
|---------|------|
| 工作流程、指令對照表 | `teammate/references/workflow` |
| `.teammate/` 與 `tasks/` 檔案結構 | `teammate/references/filesystem` |
| 脈絡三層架構（System / Task / User） | `teammate/references/context-layers` |
| `progress.md` 協議、洞察畢業機制 | `teammate/references/memory-protocol` |
| 智慧導航邏輯（狀態偵測、輸出格式） | `teammate/references/navigation` |
| Healthcheck 5 Pass 診斷 | `teammate/references/healthcheck` |
| Consult 問診流程 | `teammate/references/consult` |
| Migrate 版本遷移步驟 | `teammate/references/migrate` |

> 核心行為規則請見 `teammate-rules.mdc`。
