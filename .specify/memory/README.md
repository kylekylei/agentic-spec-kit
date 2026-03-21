# Memory 檔案修改時機對照表

這個目錄存放專案層級的共用記憶。每個檔案有明確的擁有者和修改時機。

| 檔案 | 用途 | 誰來改 | 什麼時候改 |
|------|------|--------|-----------|
| `context.md` | 專案身份、使用者、目標、技術堆疊 | 人類 | 專案啟動時（`/speckit.init`）；技術堆疊或目標變更時手動更新 |
| `principles.md` | 不可違反的原則（MUST / MUST NOT） | 人類 | 專案啟動時（`/speckit.init`）；原則需要修訂時（應建立 snapshot） |
| `agent-spec.md` | AI Agent 行為規範（角色、安全圍欄、對話策略）| 人類 | 專案啟動時或 Agent 角色定義變更時；適用於有明確 AI Agent 的專案 |
| `progress.md` | 當前工作狀態、進行中的 task | AI 自動 | 每個指令完成後自動更新；人類不需要手動編輯 |
| `milestone.md` | 各 task 的完成進度與里程碑 | AI 自動 | Task 階段完成時自動更新；人類不需要手動編輯 |

## 修改原則

- **`context.md`、`principles.md` 和 `agent-spec.md` 是人類的文件。** AI 只在指令執行時協助填寫，但最終內容由人類決定。
- **`progress.md` 和 `milestone.md` 是 AI 的工作筆記。** 人類可以閱讀，但不需要手動維護。
- **任何對 `principles.md` 的修改都應該先建立 snapshot**，記錄修改原因。原則的變更會影響所有後續工作。
- **`context.md` 中不應出現 task 級別的細節。** Task 相關的資訊屬於 `specs/[###-spec-name]/` 目錄。
- **`agent-spec.md` 是可選檔案**，僅適用於有明確 AI Agent 角色的專案（如 chatbot、conversational AI）。
