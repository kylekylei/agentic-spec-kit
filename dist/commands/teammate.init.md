---
description: 專案初始化——建立或審計 context.md + principles.md，一鍵就緒。
handoffs: 
  - label: 開始對齊
    agent: teammate.align
    prompt: 基礎已就緒，開始對齊第一個功能…
    send: true
---

## 使用者輸入

```text
$ARGUMENTS
```

在繼續之前，你**必須**考慮使用者輸入（若未空）。

## 大綱

`/teammate.init` 是 Teammate 的**一鍵初始化**指令。它檢查並填寫兩個 Foundation 檔案，確保專案可以開始工作。

- **新專案**：引導使用者輸入，自動偵測 repo 資訊，建立 Foundation
- **既有專案**：檢視檔案完整性，分析是否有優化空間，報告狀態

> 整合原 `/teammate.kickoff` 和 `/teammate.principles` 的功能。

### 模式偵測

| 狀態 | 行為 |
|------|------|
| 兩個檔案都不存在或全是 placeholder | **Init Mode**: 從頭建立 |
| 部分 placeholder 殘留 | **Complete Mode**: 補齊缺漏 |
| 兩個檔案都完整（無 placeholder） | **Audit Mode**: 分析優化建議，報告狀態 |

---

## 階段 1：偵測與報告

執行 `skills/teammate/scripts/bash/check-foundation.sh`並解析 JSON，報告目前狀態：

```
Foundation Status:
- context.md: [complete/partial/template/missing]
- principles.md: [complete/partial/template/missing]
```

**路由至模式**：
- 兩者皆 `missing` 或 `template` → **Init Mode**（從頭建立）
- 部分 `partial` 殘留 → **Complete Mode**（補齊缺漏）
- 兩者皆 `complete` → **Audit Mode**（分析優化）

---

## Init Mode（新專案）

### 步驟 1：蒐集專案脈絡

1. **解析使用者輸入**：從 `$ARGUMENTS` 擷取已提供的資訊

2. **從 repository 自動偵測**：
   - `README.md` → 專案名稱、描述
   - `package.json` / `go.mod` / `Cargo.toml` / `pyproject.toml` → 語言、框架、依賴
   - `tsconfig.json` / `.eslintrc` → 設定
   - `.github/` → 工作流程
   - `docker-compose.yml` → 基礎設施
   - `docs/llms.txt` → 可用外部參考
   - 既有原始碼 → 架構模式

3. **必填欄位缺漏時**：依脈絡推測；僅在無合理預設值時詢問使用者。**最多 5 個問題**。

4. **複製 template 並填寫 `.teammate/memory/context.md`**：
   - 若檔案不存在或為 template：從 `.teammate/templates/context-template.md` 複製
   - 填寫以下區段：
   - Project Identity（名稱、描述、repo URL）
   - Core Behaviors（可觀察、可測試）
   - Target Users（personas、角色、目標）
   - Business Goals（指標、目標、優先序）
   - Technical Context（語言、框架、測試棧）
   - Architecture Patterns（結構、命名慣例）
   - Integration Points（外部系統、協定）
   - Design References（選用：設計系統、Figma URL）

### 步驟 2：定義原則

1. **從專案脈絡推導原則**：
   - 技術約束 → MUST/MUST NOT 陳述
   - 架構模式 → Invariants
   - 安全/合規需求 → 行為邊界

2. **結構化原則**：
   - Core Principles（MUST / MUST NOT / Rationale / Verification）
   - Behavior Boundaries 表格（ID / Forbidden Behavior / Reason / Enforcement）
   - System Invariants（INV-001, INV-002, ...）
   - Governance rules

3. **複製 template 並撰寫 `.teammate/memory/principles.md`**：
   - 若檔案不存在或為 template：從 `.teammate/templates/principles-template.md` 複製
   - 填入推導出的原則

### 步驟 2.5：智慧 Skills 選配

根據專案特徵自動偵測所需 skills 和 agents，引導使用者確認。

**階段 A — 自動偵測**（零互動）：

讀取 `skill-registry.yml`，依各分類的 `detect` 規則掃描專案：

- `package.json` → 比對 `detect.deps`（react, vue, svelte, next, tailwindcss, playwright...）
- `go.mod` / `Cargo.toml` / `pyproject.toml` → 比對 `detect.files`
- `tsconfig.json` → 啟用 `frontend_typescript`
- `Dockerfile` / `docker-compose.yml` / `k8s/` → 啟用 `devops`
- `.pen` 檔案 / README 含 `figma.com` → 啟用 `design`

自動勾選所有匹配的 categories。

**階段 B — 引導確認**（最多 3 題，使用 AskQuestion）：

Q1: 專案類型確認（展示自動偵測結果）

```
已偵測: [React + Next.js + TypeScript]

[A] 正確
[B] 需要調整
```

Q2: 設計工具整合（僅在未自動偵測到時問）

```
[A] 有 Figma 設計稿要整合
[B] 有 Pencil (.pen) 設計檔
[C] 需要從零設計 UI
[D] 不涉及設計工具整合
```

Q3: 額外能力（多選，僅列出未被自動偵測的）

```
[A] DevOps / Kubernetes
[B] 辦公文件（Word/Excel/PPT/PDF）
[C] 瀏覽器自動化測試
[D] AI Agent 開發
[E] 都不需要
```

**階段 C — 展示與確認**：

```
Skills 選配結果：

Core (6): teammate, git-commit, code-review, ...
Frontend Web (9): frontend-design, ui-ux-pro-max, ...
React/Next.js (3): react-best-practices, ...

Agents (4): teammate, designer, design-auditor, architect

Total: 25 skills + 3 agents | 確認? [Y/n]
```

**階段 D — 寫入 manifest**：

產生 `.teammate/config/skills.yml`：

```yaml
version: 1
auto_detected:
  frontend_web: true
  frontend_react: true
  frontend_typescript: true
user_selected:
  design: true
  devops: false
selected_skills:
  - teammate
  - git-commit
  - frontend-design
  # ... 完整清單
selected_agents:
  - teammate
  - designer
```

> 此步驟僅在 Init Mode 執行。Complete/Audit Mode 跳過。  
> 事後管理 skills 請使用 `/teammate.skills` command。

### 步驟 3：環境建置

依 Technical Context 設定專案基礎環境：

1. **依主要語言決定 dependency 檔案**（package.json、requirements.txt 等）
2. **依宣告的 tech stack 填入基礎依賴**（framework、testing、BDD）
3. **建立最小骨架**（src/、tests/），若目錄不存在
4. **建立 `.gitignore`**，若不存在
5. **執行 install 並驗證** — 失敗不阻塞，記錄為 TODO
6. **驗證 test runner** — 確認 BDD/test 工具鏈可用

> 跳過條件：若 dependency 檔案已存在且含宣告的依賴，則跳過 bootstrap。

---

## Complete Mode（補齊缺漏）

1. **識別兩檔中剩餘的 placeholders**
2. **盡可能從 repo 脈絡自動偵測**數值
3. **無法推斷時詢問使用者**（最多 3 個問題）
4. **填入**剩餘 placeholders
5. **驗證**兩檔皆完整

---

## Audit Mode（分析優化）

當兩個檔案都完整時，執行健康分析：

### context.md 分析

- **陳舊偵測**: tech stack 描述是否與實際 package.json/go.mod 一致？
- **缺漏偵測**: 是否有新增的 integration points 未記錄？
- **架構一致性**: Code Organization 是否反映目前的目錄結構？

### principles.md 分析

- **覆蓋度**: 每個 MUST NOT 是否有對應的 enforcement 方式？
- **可測試性**: 每個 principle 是否有 verification criteria？
- **Invariant 完整性**: 是否有明顯缺漏的 invariant？
- **版本一致性**: Version 欄位是否正確？

### 優化建議

產出結構化報告：
```markdown
## Foundation Audit Report

### context.md
- Status: ✅ Complete
- Findings:
  - [SUGGEST] Technical Context 的 framework 版本可更新（package.json 顯示 v5.x，context 記錄 v4.x）
  - [OK] Architecture Patterns 與目錄結構一致

### principles.md
- Status: ✅ Complete
- Findings:
  - [SUGGEST] BB-003 缺少 Enforcement 欄位
  - [SUGGEST] 考慮新增 INV-004: [suggestion based on code patterns]
  - [OK] 所有 MUST NOT 有對應 verification
```

---

## 最後步驟

### Update Active Context

依 **Memory Delta Protocol**（見 `teammate-rules.mdc`）更新 `progress.md`：
- **Current State 專屬欄位**：Foundation Status: [完整/部分/缺失], Phase: Foundation, Last Command: init, Next Action: /teammate.align
- **Session Log**：`| [timestamp] | init | [mode]: context [status], principles [status] | [bootstrap result] |`
- **Blockers**：如有未解決的 placeholder，記錄為 blocker

### 報告

產出：
- Foundation 狀態（兩檔）
- 自動偵測數值摘要
- Bootstrap 結果（若適用）
- 剩餘 placeholders（若有）
- 優化建議（Audit Mode）
- 建議下一步指令：`/teammate.align`

## 行為規則

- **先自動偵測，再詢問** — 減少使用者負擔
- **絕不捏造資訊** — 不確定時標記為 `TODO(<FIELD>): needs clarification`
- **冪等** — 再次執行 init 保留既有值，僅填補缺漏或執行 audit
- **最多 5 問（Init）/ 3 問（Complete）** — 尊重使用者時間
- **Bootstrap 為增量** — 不覆寫既有 dependency 檔案
- **Bootstrap 失敗不阻塞** — 警告、記錄、繼續
- **更新前建立快照** — 若 principles.md 先前已完整且將被修改，先建立快照
