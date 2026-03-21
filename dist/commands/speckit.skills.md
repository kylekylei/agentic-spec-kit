---
description: 管理專案已安裝的 Skills 與 Agents — 查看、追加、移除、同步更新、重新偵測。
---

## User Input

```text
$ARGUMENTS
```

若使用者輸入非空，**必須**先考量後再繼續。

## 子指令路由

| $ARGUMENTS | 動作 |
|------------|------|
| （空）/ `list` | 列出已安裝 vs 可用的 skills 和 agents |
| `add <category\|skill>` | 追加分類或單一 skill |
| `remove <category\|skill>` | 移除分類或單一 skill |
| `sync` | 依 skills.yml 重新同步 |
| `detect` | 重新掃描專案，比對 skills.yml，提示缺漏 |

---

## list（預設）

讀取 `.specify/config/skills.yml` 和 `skill-registry.yml`，展示：

```
已安裝 Skills (25/52):
  Core (6):     speckit, git-commit, code-review, ...
  Frontend (9): frontend-design, ui-ux-pro-max, ...
  React (3):    react-best-practices, ...
  Design (6):   figma, ...

已安裝 Agents (5/7):
  speckit, designer, design-auditor, architect, code-auditor

未安裝的分類:
  - DevOps (5 skills, 1 agent): k8s-manifest-generator, ...
  - Documents (6 skills): docx, xlsx, ...
  - Mobile (2 skills): react-native-architecture, ...
```

---

## add

流程：

1. 讀取 `skill-registry.yml` 查詢分類內容
2. 若為分類名稱 → 展示該分類的所有 skills + agents
3. 若為單一 skill 名稱 → 展示該 skill 資訊
4. 使用 AskQuestion 確認
5. 更新 `.specify/config/skills.yml`
6. 執行 `speckit-sync.sh`（selective mode）同步新增的資源
7. 更新 `progress.md` Session Log

範例：

```
/speckit.skills add devops
→ 追加 DevOps 分類：5 skills + kubernetes agent
  Skills: k8s-manifest-generator, k8s-security-policies, helm-chart-scaffolding, gitops-workflow, ai-compliance
  Agent: kubernetes
  確認? [A] 是 / [B] 否
```

---

## remove

流程：

1. 讀取 `.specify/config/skills.yml` 確認已安裝
2. 檢查是否有 agent 依賴此 skill（透過 agent frontmatter 的 `skills:` 宣告）
3. 若有依賴 → 警告並使用 AskQuestion 確認是否一併移除 agent
4. 更新 `skills.yml`
5. 執行 sync（會自動清除不在 manifest 中的 skills）
6. 更新 `progress.md` Session Log

### 限制

- **Core 分類不可移除**（speckit, git-commit, code-review 等永遠必裝）

---

## sync

```
/speckit.skills sync         → 依 skills.yml 重新同步
/speckit.skills sync --check  → 檢查是否有新版本可用
```

---

## detect

重新掃描專案的 `package.json`、`go.mod`、`tsconfig.json` 等，比對 `skill-registry.yml` 的偵測規則：

1. 找出已在 `skills.yml` 中但專案已不使用的 skills → 提示移除
2. 找出專案新增的依賴但尚未安裝的 skills → 提示追加

使用 AskQuestion 展示發現並讓使用者選擇。

---

## 行為規則

- Core 分類不可移除
- 追加/移除後自動執行 selective sync
- 所有操作記錄至 `progress.md` Session Log
- 不修改 Hub 端（`dist/`），僅操作消費端（`.cursor/` `.claude/` `.agent/`）
