---
description: 框架同步與版本遷移 — 檢查更新、預覽差異、套用同步，或跨版本遷移（含 Breaking Changes 處理）。
---

## User Input

```text
$ARGUMENTS
```

若使用者輸入非空，**必須**先考量後再繼續。

## 概述

`/teammate.sync` 是 Teammate 框架的統一同步指令，合併了日常同步和跨版本遷移功能。系統自動偵測版本差異，選擇適當的同步模式。

## 參數對照

| 使用者說 | 對應參數 | 行為 |
|---------|---------|------|
| 「有沒有新版本」 | `--check` | 查版本差異，不寫入 |
| 「預覽一下」「先不要真的同步」 | `--dry-run` | 列變更清單，不寫入 |
| 「幫我同步」「套用」 | （無旗標） | 自動偵測模式後執行 |
| 「連 Hub 一起更新」 | `--self-update` | 先 pull Hub 再同步 |
| 「逐檔選擇」 | `--pick` | 遷移模式：逐檔詢問 Y/N |

---

## 同步模式自動偵測

### Step 1：定位 Hub

1. 讀取 `.teammate/config/teammate.yml` 的 `hub.url`（優先）
2. 若無，讀取 `{ide}/rules/teammatesync_rule.mdc` 的 `**Teammate Hub**: \`[PATH]\``
3. 若為 URL：clone 至 `.teammate/hub-cache/teammate`；若為本機路徑：驗證存在且可讀

### Step 2：比對版本

1. 讀取專案 `teammate.yml` 的 `version`（不存在 → `"pre-tracking"`）
2. 讀取 Hub `teammate.yml` 的 `version`
3. 相同 → 結束（已是最新）；專案舊 → 繼續

### Step 3：判斷模式

| 版本差異 | 模式 | 行為 |
|---------|------|------|
| 無差異 | — | 報告已是最新 |
| Patch/Minor，無 Breaking Changes | **簡易同步** | 直接執行 `teammate-sync.sh` |
| Major，或有 Breaking Changes | **遷移模式** | 完整遷移流程（見下方） |

---

## 簡易同步模式

1. 執行 `teammate-sync.sh <target> [--dry-run]`
2. 報告同步結果
3. 更新 `progress.md` Session Log

### 腳本路徑（依 IDE）

| 情境 | 路徑 |
|------|------|
| Cursor（已部署） | `.cursor/skills/teammate/scripts/bash/teammate-sync.sh` |
| Claude（已部署） | `.claude/skills/teammate/scripts/bash/teammate-sync.sh` |
| Hub 直執行 | `dist/skills/teammate/scripts/bash/teammate-sync.sh` |

**平台**自動偵測（`.cursor/` / `.claude/` / `.agent/`）；偵測不到時詢問。
**預設保守** — 意圖不明先 dry-run，展示變更後再確認 apply。

---

## 遷移模式

當偵測到重大版本差異時，執行完整遷移流程。

詳細步驟載入 `teammate/references/migrate` skill。

### 流程摘要

1. **解析 Changelog** — 提取從專案版本到 Hub 版本的所有區段
2. **框架檔案差異比對** — `[NEW]` / `[UP-TO-DATE]` / `[MODIFIED]` / `[ORPHAN]` 標記
3. **teammate.yml merge 策略** — 保留專案自訂值，新增 Hub 新欄位，deprecated 標記
4. **產出 Migration Report**
5. **使用者確認** — `apply`（全部套用）/ `pick`（逐檔選擇）/ 只看報告
6. **套用遷移** — 複製/覆寫/merge
7. **更新 progress.md**

### 遷移範圍

```
可遷移（Hub 管理）:
  {ide}/rules/*.mdc
  {ide}/commands/teammate.*.md
  {ide}/skills/teammate/
  .teammate/templates/*
  .teammate/config/teammate.yml（merge 策略）

不可遷移（專案私有）:
  .teammate/memory/*  |  tasks/*  |  docs/*
  .cursorule（User Profile）
  PLAYBOOK.md / CHANGELOG.md（Hub 專屬）
```

---

## 操作限制

- **預設保守** — 意圖不明先 dry-run
- **migrate 不碰私有檔案** — `.teammate/memory/`、`tasks/`、`docs/` 永遠不被覆寫
- **teammate.yml 用 merge** — 保留專案自訂值，只新增 Hub 的新欄位

---

## Update Active Context

依 **Memory Delta Protocol**（見 `teammate-rules.mdc`）更新 `progress.md`：
- **Session Log**：`| [timestamp] | sync | [mode]: [result] | [files updated] |`
