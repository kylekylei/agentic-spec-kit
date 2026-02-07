# Memory 檔案修改時機對照表

這個目錄存放專案層級的共用記憶。每個檔案有明確的擁有者和修改時機。

| 檔案 | 用途 | 誰來改 | 什麼時候改 |
|------|------|--------|-----------|
| `project-context.md` | 專案身份、使用者、目標、技術堆疊 | 人類 | 專案啟動時（`/teammate.kickoff`）；技術堆疊或目標變更時手動更新 |
| `principles.md` | 不可違反的原則（MUST / MUST NOT） | 人類 | 專案啟動時（`/teammate.principles`）；原則需要修訂時（應建立 snapshot） |
| `active-context.md` | 當前工作狀態、進行中的 feature | AI 自動 | 每個指令完成後自動更新；人類不需要手動編輯 |
| `progress.md` | 各 feature 的完成進度 | AI 自動 | Feature 階段完成時自動更新；人類不需要手動編輯 |

## 修改原則

- **`project-context.md` 和 `principles.md` 是人類的文件。** AI 只在指令執行時協助填寫，但最終內容由人類決定。
- **`active-context.md` 和 `progress.md` 是 AI 的工作筆記。** 人類可以閱讀，但不需要手動維護。
- **任何對 `principles.md` 的修改都應該先建立 snapshot**，記錄修改原因。原則的變更會影響所有後續工作。
- **`project-context.md` 中不應出現 feature 級別的細節。** Feature 相關的資訊屬於 `features/[###-feature]/` 目錄。
