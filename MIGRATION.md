# BehaviorKit → Teammate 遷移指南

本文件提供從 BehaviorKit 遷移到 Teammate 的完整步驟。適用於已經使用 `behavior.xxx` 指令的現有專案。

---

## 指令對照表

| BehaviorKit | Teammate | 語意 |
|---|---|---|
| `/behavior.constitution` | `/teammate.principles` | 定義不可違反的合作原則與邊界 |
| `/behavior.speculate` | `/teammate.align` | 對齊要解決的問題與期待結果 |
| `/behavior.illustrate` | `/teammate.clarify` | 釐清不明確或有歧義的地方 |
| `/behavior.feature` | `/teammate.plan` | 建立可執行的工作計畫（Gherkin） |
| `/behavior.model` | `/teammate.tasks` | 定義 Tasks（Screenplay Pattern） |
| `/behavior.slices` | `/teammate.actions` | 拆解為可驗證的原子 Actions |
| `/behavior.enact` | `/teammate.execute` | 實際動手完成工作（Red-Green Loop） |
| `/behavior.reflect` | `/teammate.review` | 檢視一致性、覆蓋率與風險 |
| `/behavior.verify` | `/teammate.checklist` | 建立驗收與品質檢查清單 |
| `/behavior.dispatch` | `/teammate.assign` | 轉換為 GitHub Issues |
| (無) | `/teammate.kickoff` | **新增** — 初始化專案背景 |

## 階段對照

| BehaviorKit | Teammate |
|---|---|
| Discovery → Definition → Delivery | Foundation → Align → Commit → Deliver |

## 檔案與目錄對照

### 目錄結構

| BehaviorKit | Teammate | 說明 |
|---|---|---|
| `.behavior/` | `.teammate/` | 系統根目錄 |
| `.behavior/config/behaviorkit.yml` | `.teammate/config/teammate.yml` | 設定檔 |
| `specs/[###-feature]/` | `features/[###-feature]/` | Feature 工作目錄 |
| `specs/.../features/*.feature` | `features/.../scenarios/*.feature` | Gherkin 檔案目錄 |

### Memory 檔案

| BehaviorKit | Teammate | 說明 |
|---|---|---|
| `.behavior/memory/constitution.md` | `.teammate/memory/principles.md` | 原則定義 |
| `.behavior/memory/project-context.md` | `.teammate/memory/project-context.md` | 專案背景 |
| `.behavior/memory/activeContext.md` | `.teammate/memory/active-context.md` | 當前工作狀態 |
| `.behavior/memory/progress.md` | `.teammate/memory/progress.md` | 進度追蹤 |
| `.behavior/memory/agent-context.md` | (移除) | Agent 行為改在 principles 定義 |
| `.behavior/memory/design-context.md` | (移除) | Figma 總連結放 project-context，頁面連結在 tasks 階段提供 |

### 指令檔案

| BehaviorKit | Teammate |
|---|---|
| `.cursor/commands/behavior.xxx.md` | `.cursor/commands/teammate.xxx.md` |

### 其他

| BehaviorKit | Teammate | 說明 |
|---|---|---|
| `behavior.refs.yaml` | `teammate.refs.yaml` | Feature 內的 context anchor |
| `SPECIFY_FEATURE` 環境變數 | `TEAMMATE_FEATURE` | Feature 覆寫變數 |
| `@constitution` Gherkin tag | `@principles` | 原則邊界場景標記 |

---

## 遷移步驟

### 前置條件

- 確保目前的工作分支已 commit
- 建議先在新分支上操作

### Step 1：目錄重新命名

```bash
# 系統目錄
mv .behavior .teammate

# 設定檔
mv .teammate/config/behaviorkit.yml .teammate/config/teammate.yml

# Memory 檔案
mv .teammate/memory/constitution.md .teammate/memory/principles.md
mv .teammate/memory/activeContext.md .teammate/memory/active-context.md

# Feature 工作目錄（如果有已產出的 specs/）
mv specs features

# Gherkin 子目錄（每個 feature 下）
for dir in features/*/features; do
  mv "$dir" "$(dirname "$dir")/scenarios"
done

# Context anchor 檔案（每個 feature 下）
for f in features/*/behavior.refs.yaml; do
  mv "$f" "$(dirname "$f")/teammate.refs.yaml"
done
```

### Step 2：移除不再需要的檔案

```bash
# 移除被整合的 context 檔案
rm -f .teammate/memory/agent-context.md
rm -f .teammate/memory/design-context.md
```

### Step 3：替換指令檔案

將舊的 `behavior.xxx.md` 替換為新的 `teammate.xxx.md`。

**方法 A：從 Teammate 倉庫複製**

```bash
# 移除舊指令
rm -f .cursor/commands/behavior.*.md

# 從 Teammate 倉庫複製新指令
# (替換 <teammate-repo> 為實際路徑)
cp <teammate-repo>/.cursor/commands/teammate.*.md .cursor/commands/
cp <teammate-repo>/.cursor/rules/teammate-rules.mdc .cursor/rules/
```

**方法 B：手動替換**

按照上方的指令對照表，逐一建立對應的 `teammate.xxx.md` 檔案。

### Step 4：更新腳本引用

如果你有自訂過 `.teammate/scripts/bash/` 中的腳本，需要手動更新：

- 所有 `.behavior/` 路徑 → `.teammate/`
- 所有 `.specify/` 路徑 → `.teammate/`
- 錯誤訊息中的 `speckit.xxx` / `behavior.xxx` → `teammate.xxx`
- `SPECIFY_FEATURE` 環境變數 → `TEAMMATE_FEATURE`
- Log prefix `[specify]` → `[teammate]`

### Step 5：更新已產出的 feature 檔案

如果 `features/` 目錄下已有之前產出的文件，需要更新內部引用：

```bash
# 批次替換路徑引用（macOS）
find features/ -name "*.md" -exec sed -i '' \
  -e 's|\.behavior/|.teammate/|g' \
  -e 's|/behavior\.|/teammate.|g' \
  -e 's|@constitution|@principles|g' \
  -e 's|constitution\.md|principles.md|g' \
  {} +

# Linux 版本（不需要 -i 後面的 ''）
find features/ -name "*.md" -exec sed -i \
  -e 's|\.behavior/|.teammate/|g' \
  -e 's|/behavior\.|/teammate.|g' \
  -e 's|@constitution|@principles|g' \
  -e 's|constitution\.md|principles.md|g' \
  {} +
```

### Step 6：驗證

```bash
# 確認沒有殘留的舊引用
grep -r "\.behavior/" .teammate/ .cursor/commands/ || echo "OK: 無 .behavior/ 殘留"
grep -r "behavior\." .cursor/commands/teammate.*.md || echo "OK: 無 behavior. 殘留"
grep -r "constitution" .teammate/ .cursor/commands/ || echo "OK: 無 constitution 殘留"
grep -r "specs/" .teammate/ .cursor/commands/ || echo "OK: 無 specs/ 殘留"

# 確認新檔案都在
ls .cursor/commands/teammate.*.md
ls .teammate/memory/
```

---

## 常見問題

### 已經進行中的 feature 怎麼辦？

已經在 `specs/[###-feature]/` 下產出的文件可以繼續使用。遷移後它們會在 `features/[###-feature]/` 下。Teammate 指令會自動找到正確的路徑。

### agent-context.md 的內容去哪了？

如果你之前在 `agent-context.md` 定義了 AI agent 的行為模式和 guardrails，這些應該搬到 `/teammate.principles` 中定義。Agent 行為約束本質上就是 principles。

### design-context.md 的內容去哪了？

- **專案層級的 Figma/Storybook 連結** → 放在 `project-context.md` 的 Design References 區塊
- **Feature 層級的 Figma page 連結** → 在 `/teammate.tasks` 階段提供，寫入 `contracts/ui/`
- **Design tokens / components 細節** → 這些是實作細節，在 `/teammate.tasks` 或 `/teammate.execute` 階段處理

### `/teammate.kickoff` 是什麼？舊專案也要跑嗎？

`/teammate.kickoff` 是新增的指令，用來初始化 `project-context.md`。如果你的舊專案已經填寫了 `project-context.md`，不需要重跑。只要確保檔案中沒有殘留的 `[PLACEHOLDER]` tokens 即可。
