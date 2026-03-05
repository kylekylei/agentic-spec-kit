---
name: teammate/references/assign
description: 將 plan.md Part 2 的 Actions 轉為 GitHub Issues，自動設定 labels、dependencies，並更新 plan.md 與 progress.md。
---

# Assign

**定位**：將 `plan.md` Part 2 (Actions) 轉為 GitHub Issues，用於專案管理和團隊協作。

## 前置條件

- **需要 GitHub MCP**：`github/github-mcp-server/issue_write`
- **只在 GitHub repo 中運行**：檢查 remote URL 是否為 GitHub

## 執行步驟

1. **載入** `TASK_DIR/plan.md` Part 2，解析所有 actions（ID、phase、story、tags、dependencies）
2. **驗證** Git remote 是 GitHub URL
3. **對每個 action** 建立 GitHub Issue：
   - **Title**：`[ActionID] [Story] Description`
   - **Body**：Action details、acceptance criteria、related scenarios、dependencies
   - **Labels**：`action`、`phase-N`、`story-USN`、`parallel`（if [P]）、`priority-P1/P2/P3`
4. **更新** `plan.md` Part 2：每個 action 後附加 Issue number（如 `(#123)`）
5. **追加** `progress.md` Session Log（記憶差量協議）

## 錯誤處理

| 情況 | 行為 |
|------|------|
| Remote 非 GitHub | 報告並結束 |
| MCP 不可用 | 報告錯誤，附手動建立說明 |
| Issue 建立失敗 | 記錄錯誤，繼續其他 actions |
