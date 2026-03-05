---
name: teammate/references/migrate
description: Teammate 框架版本遷移。比對 Hub 與專案版本，產出遷移報告，確認後套用更新。不碰專案私有檔案。
---

# Migrate

**定位**：版本遷移 —— 比對專案的 Teammate 框架版本與 Hub 最新版本，產出遷移計畫並套用更新。

## 參數變體

| 用法 | 行為 |
|------|------|
| `migrate` | 產出遷移報告（預設，不修改檔案） |
| `migrate apply` | 產出報告後直接套用全部變更 |
| `migrate pick` | 產出報告後逐檔詢問是否套用 |

## 遷移範圍

```
可遷移（Hub 管理）:
  {ide}/rules/teammate-rules.mdc
  {ide}/rules/teammatesync_rule.mdc
  {ide}/commands/teammate.*.md
  {ide}/skills/teammate/
  .teammate/templates/*
  .teammate/config/teammate.yml（merge 策略，見下）

不可遷移（專案私有）:
  .teammate/memory/*  |  tasks/*  |  docs/*
  .cursorule（User Profile）
  PLAYBOOK.md / CHANGELOG.md（Hub 專屬）
```

## 執行步驟

**Step 1: 定位 Hub**
1. 讀取 `.teammate/config/teammate.yml` 的 `hub.url`（優先）
2. 若無，讀取 `{ide}/rules/teammatesync_rule.mdc` 的 `**Teammate Hub**: \`[PATH]\``（本機路徑）
3. 若為 URL：clone 至 `.teammate/hub-cache/teammate` 後使用；若為本機路徑：驗證存在且可讀
4. placeholder 未替換 → 報錯

**Step 2: 比對版本**
1. 讀取專案 `teammate.yml` 的 `version`（不存在 → `"pre-tracking"`）
2. 讀取 Hub `teammate.yml` 的 `version`
3. 相同 → 結束；專案舊 → 繼續；專案新 → 警告（Hub 可能未更新）

**Step 3: 解析 Changelog**
- 讀取 Hub 的 `CHANGELOG.md`，提取從專案版本到 Hub 版本的所有區段
- 彙整：Summary、Added、Changed、Removed、Breaking、Migration Notes

**Step 4: 框架檔案差異比對**

| 比對結果 | 標記 | 說明 |
|---------|------|------|
| Hub 有，專案無 | `[NEW]` | 新增 |
| 兩邊相同 | `[UP-TO-DATE]` | 無需更新 |
| Hub 與專案不同 | `[MODIFIED]` | 需更新 |
| Hub 無，專案有 | `[ORPHAN]` | 標記提醒，不自動刪除 |

**`teammate.yml` merge 策略**（不直接覆寫）：
- Hub 新增的 key → 加入（使用 Hub 預設值）
- Hub 刪除的 key → 保留並加 `# [DEPRECATED by Hub vX.Y.Z]`
- Hub 修改但專案有自訂值 → 保留專案值，只更新結構
- 專案獨有的 key → 保留不動
- `version` 欄位 → 遷移完成後更新為 Hub 版本

**Step 5: 產出遷移報告**

```markdown
# 🔄 Migration Report

**專案版本**: [project_version]
**Hub 版本**: [hub_version]
**跨越版本數**: [count]

## 版本摘要
- **[hub_version]**: [summary]

## 檔案變更計畫
| # | 檔案 | 狀態 | 動作 |

## Breaking Changes
## 注意事項
## teammate.yml Merge 計畫
```

**Step 6: 使用者確認**

| 參數 | 行為 |
|------|------|
| `apply` | 跳過確認，直接執行 |
| `pick` | 逐檔詢問 Y/N |
| （無）| AskQuestion：[A] 全部套用 / [B] 逐檔選擇 / [C] 只看報告 |

**Step 7: 套用遷移**
1. `[NEW]` → 從 Hub 複製到對應路徑
2. `[MODIFIED]` → Hub 版本覆寫專案版本
3. `teammate.yml` → 執行 merge 策略
4. 更新 `version` 為 Hub 版本
5. `[ORPHAN]` → 僅報告，不自動刪除

**Step 8: 更新 Active Context**

追加 `progress.md` Session Log：`migrate | [project_version] → [hub_version], N files updated`
