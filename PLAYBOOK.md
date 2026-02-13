# Teammate Playbook

> Teammate Framework Evolution Playbook — 框架 Owner 的演進主控台

## 閱讀與維護規範

### 文件角色

| 文件 | 對象 | 用途 |
|------|------|------|
| `README.md` | 使用者 | 快速上手、指令說明、專案結構 |
| `PLAYBOOK.md` | 框架 Owner | 決策脈絡、演化軌跡、未來規劃 |
| `CHANGELOG.md` | 版本消費者 | 版本差異、migrate 解析用 |

### 雙軌架構

本文件固定用兩條軌道維護：

1. **歷史修改軌跡**（Section 1）：每筆紀錄保留完整「觸發 → 決策 → 影響 → 成效 → 狀態」，Append-Only
2. **尚未實現**（Section 2）：Roadmap（策略視角）+ Backlog（執行視角），區分「想法」與「承諾」

### 每筆歷史紀錄的固定欄位

| 欄位 | 說明 |
|------|------|
| 日期 | YYYY-MM-DD |
| 類型 | 規則 / 命令 / 架構 / 模板 / 腳本 / 文件 / 技能 |
| 專案 | 觸發該改善的來源專案 |
| 觸發情境 | 為何要改（問題描述） |
| 決策 | 改了什麼（方案描述） |
| 影響範圍 | 受影響的檔案與指令 |
| 成效 | 觀察到的改善（新項目可填「待驗證」） |
| 狀態 | 生效中 / 已被取代（by X）/ 已淘汰 |

### 維護規則

- 歷史軌跡為 **Append-Only**，不得刪除既有紀錄
- 任何流程/命令/artifact/目錄修正，必須同步更新本檔
- 已淘汰的紀錄標記狀態即可，不刪除（保留決策脈絡）

---

## 1. 歷史修改軌跡（Append-Only）

#### 2026-02-08 · 規則 · oReady
**觸發**: AI 跳過規劃直接動手，缺少 spec.md
**決策**: `teammate-rules.mdc` 新增 Simplified Flow 區段（簡化條件 + 最低 artifact 要求 + 使用者確認機制）
**影響**: `teammate-rules.mdc`
**成效**: AI 在小任務時主動詢問是否使用簡化流程
**狀態**: 生效中

#### 2026-02-08 · 命令 · oReady
**觸發**: `/teammate.align update` 完成後缺少合理的下一步選項
**決策**: `teammate.align.md` 新增 3 個 handoffs（Update Tasks / Continue Editing / Skip to Execute）
**影響**: `teammate.align.md`
**成效**: 使用者可從選單直接選擇下一步
**狀態**: 生效中

#### 2026-02-08 · 規則 · oReady
**觸發**: 修改 teammate 規則後忘記同步到 Teammate repo
**決策**: 建立 `teammatesync_rule.mdc`，定義自動同步規則
**影響**: 新增 `teammatesync_rule.mdc`
**成效**: AI 自動提醒同步到 Hub
**狀態**: 生效中

#### 2026-02-08 · 規則 · oReady
**觸發**: 回測後缺少結構化復盤
**決策**: 建立 `backtest_rules.mdc` 提供回測框架
**影響**: 新增 `backtest_rules.mdc`
**成效**: 回測有標準化流程可循
**狀態**: 生效中

#### 2026-02-08 · 文件 · oReady
**觸發**: spec.md 和 tasks.md 的差異不明確，開發者混淆兩者用途
**決策**: README 補充 spec vs tasks 對比表格
**影響**: `README.md`
**成效**: 角色分工一目瞭然
**狀態**: 生效中（已更新為 spec vs plan）

#### 2026-02-08 · 規則 · oReady
**觸發**: 不同專案的改善需要中心化記憶，散落在各專案無法共享
**決策**: `teammatesync_rule.mdc` 加入 PLAYBOOK 回饋機制
**影響**: `teammatesync_rule.mdc`
**成效**: 跨專案教訓自動回饋到 PLAYBOOK
**狀態**: 生效中

#### 2026-02-08 · 規則 · oReady
**觸發**: AI 完成指令後沒有主動提供下一步選項，使用者需要自己記得流程
**決策**: `teammate-rules.mdc` 新增「主動提供下一步選項」規則，以 [A][B][C][D] 格式列出
**影響**: `teammate-rules.mdc`、所有 `teammate.*.md`
**成效**: 每個指令結束自動列出下一步選項
**狀態**: 生效中

#### 2026-02-09 · 規則 · sltung-km
**觸發**: teammate.plan 產出的 .feature 檔案預設全英文，使用者難以閱讀和 review
**決策**: `teammate-rules.mdc` 新增「文件以繁體中文撰寫」規則，允許代號/程式碼/框架名詞/Gherkin 關鍵字保留英文
**影響**: `teammate-rules.mdc`
**成效**: 產出文件開發者可直接閱讀
**狀態**: 生效中

#### 2026-02-09 · 命令 · sltung-km
**觸發**: 使用者完成一個 action 後需手動指定下一個 action ID，流程不流暢
**決策**: `teammate.execute.md` 新增 `next` 參數，自動找到下一個未完成的 action 並執行
**影響**: `teammate.execute.md`
**成效**: 執行流程連貫，不需記 action ID
**狀態**: 生效中

#### 2026-02-09 · 規則 · sltung-km
**觸發**: AI 新增 Svelte 組件時使用自訂 `$:` IIFE reactive 模式，導致 Svelte 響應式追蹤失敗
**決策**: `principles.md` 新增 III-B「Svelte 響應式模式一致性」+ BB-011/BB-012；要求 AI 必須比照兄弟組件的 reactive pattern
**影響**: `principles.md`
**成效**: AI 遵循專案既有 reactive pattern
**狀態**: 生效中

#### 2026-02-09 · 規則 · sltung-km
**觸發**: AI 驗證 i18n 只檢查 `$i18n.t()` 是否使用，不檢查 locale JSON 是否已更新，切換語言時顯示英文
**決策**: `principles.md` INV-006 補充「新增 key MUST 同步加入 en-US + zh-TW translation.json」
**影響**: `principles.md`、`teammatesync_rule.mdc`
**成效**: i18n 完整性在 Principles 層級強制
**狀態**: 生效中

#### 2026-02-09 · 規則 · sltung-km
**觸發**: AI 為同一概念自創新 i18n key（兄弟用 `Updated At`，新組件用 `Time`），且遺漏 key
**決策**: `principles.md` 新增 III-C「同層級術語一致性」：新增 key 前 MUST 先搜尋 locale 確認無既有等義 key
**影響**: `principles.md`
**成效**: i18n key 命名一致性提升
**狀態**: 生效中

#### 2026-02-10 · 架構 · sltung-km
**觸發**: PM/設計端流程過度工程化（11 個指令太多），無法快速語意化驅動需求到交付
**決策**: 提出 P4 指令合成計劃，合併為 `align → plan → execute` 三步流程
**影響**: 全部指令架構
**成效**: 已實施，11 → 5 核心指令
**狀態**: 生效中

#### 2026-02-10 · 命令 · sltung-km
**觸發**: `teammate.review` 不掃描 `contracts/ui/`，組件改名後 UI 規格過期未被偵測
**決策**: `teammate.review` 新增 Pass E「UI Contract Consistency」；update 模式新增 Sync Contracts 步驟
**影響**: `teammate.review.md`
**成效**: UI 規格與實作一致性自動檢查
**狀態**: 生效中

#### 2026-02-10 · 命令 · sltung-km
**觸發**: 診斷指令 `teammate.debug` 會讓使用者誤以為是主流程的一部分
**決策**: 改為 `/teammate.toolkit healthcheck`，明確區分 Workflow 與 Toolkit
**影響**: `teammate.toolkit.md`、`teammate-rules.mdc`
**成效**: 工具指令不再混入主流程
**狀態**: 生效中

#### 2026-02-10 · 架構 · sltung-km
**觸發**: `healthcheck` 掃描 artifact 內容一致性與 `review` 大量重疊；使用者主動提出流程問題時無正式管道
**決策**: 重新定義 healthcheck 為「流程合規檢查」（骨架），review 負責內容品質（血肉）；新增 `consult` 工具
**影響**: `teammate.toolkit.md`
**成效**: 職責邊界清晰，consult 承接問診迴路
**狀態**: 生效中

#### 2026-02-10 · 命令 · sltung-km
**觸發**: execute 完成 Phase 後只更新 actions.md，milestone.md 和 progress.md 未同步，memory 與進度脫節
**決策**: execute 新增「階段完成同步」步驟：Phase 完成時 MUST 更新 milestone.md + progress.md
**影響**: `teammate.execute.md`
**成效**: memory 與執行進度自動同步
**狀態**: 生效中

#### 2026-02-10 · 架構 · Teammate
**觸發**: 框架知識管理靜態，execute 只記位置不記洞察；memory 全量覆寫有 Context Collapse 風險；關鍵 docs 被列為 Optional；execute 缺少風險暫停
**決策**: 提出 P5「ACE 產品開發知識閉環」七項改善（Insights / REFLECT / Smart Loading / Graduation / Memory Delta / HITL Gates / Context Layer）
**影響**: `teammate.execute.md`、`teammate-rules.mdc`、所有 `teammate.*.md`、新增 `insights-template.md`
**成效**: 已全部實施，知識管理從靜態變為閉環
**狀態**: 生效中

#### 2026-02-10 · 命令 · sltung-km
**觸發**: actions 將 RED（測試）和 GREEN（實作）合併為單一 action，導致 execute 跳過測試先行
**決策**: actions 新增 RED/GREEN 強制拆分規則 + tasks 新增 Phase 0 測試基礎設施 + execute 新增實作前測試檢查
**影響**: `teammate.execute.md`（已併入 plan）
**成效**: 測試優先紀律在流程層級強制
**狀態**: 生效中（機制已併入 plan.md）

#### 2026-02-10 · 命令 · sltung-km
**觸發**: execute 的 Red-Green Loop 未區分功能 vs UI 任務。純 UI 組件沒有可自動化的 RED 測試，直接實作會導致視覺產出不符預想
**決策**: execute 新增任務類型分流：`[LOGIC]` → unit test RED；`[UI]` → 展示視覺規格暫停確認；`[LOGIC+UI]` → 兩者兼具
**影響**: `teammate.execute.md`
**成效**: UI 任務不再被強制走 unit test 路線
**狀態**: 生效中

#### 2026-02-10 · 命令 · sltung-km
**觸發**: UI 暫停機制過於頻繁——已有兄弟組件或 Figma link 時 LLM 應能自行推斷，不該每個 UI action 都暫停
**決策**: 修正為智能分流：有參考 → 直接實作；有不確定細節 → 主動列出選項；完全無參考 → 完整暫停
**影響**: `teammate.execute.md`
**成效**: UI 暫停從「全部攔截」變為「按需攔截」
**狀態**: 生效中

#### 2026-02-10 · 命令 · sltung-km
**觸發**: tasks 原始碼結構只列 `[NEW]` 和 `[ENHANCE]`，缺少整合影響分析。新組件建好後沒人掛載到消費者
**決策**: tasks 新增 Integration Impact Analysis + `[INTEGRATE]` 標記；actions 新增 Integration Actions 步驟
**影響**: 已併入 `teammate.plan.md`
**成效**: 新組件的消費者自動被識別和規劃
**狀態**: 生效中（機制已併入 plan.md）

#### 2026-02-11 · 規則 · OpenWebUI_Frontend
**觸發**: AI 整合設計原則時未主動做衝突分析（重試按鈕需不存在的 API、關閉按鈕語意差異、disabled 狀態未列舉）
**決策**: (1) plan 新增 UX Conflict Scan (2) tasks 新增 UI State Machine (3) teammate-rules 新增 UX 灰色地帶主動分析規則
**影響**: `teammate.plan.md`、`teammate-rules.mdc`
**成效**: AI 在規劃階段就主動挑戰 UX 決策
**狀態**: 生效中

#### 2026-02-11 · 架構 · Teammate
**觸發**: `.cursorule` 散文體與 teammate-rules 重複；使用者偏好在框架中無正式位置
**決策**: 提出 P6「User Profile + Profile Evolution」設計
**影響**: 設計階段，尚未實施
**成效**: 待驗證
**狀態**: 待實施（見 Section 2 Roadmap P6）

#### 2026-02-11 · 架構 · Teammate
**觸發**: 框架版本只是 yml 註解，無正式追蹤；migrate 只是佔位；無結構化變更紀錄
**決策**: 完成 P2 版本管理：yml 正式欄位 + CHANGELOG.md + migrate 工具 8 步驟 + merge 策略 + sync 規則
**影響**: `teammate.yml`、`CHANGELOG.md`、`teammate.toolkit.md`、`teammatesync_rule.mdc`
**成效**: 版本可追溯，migrate 可執行
**狀態**: 生效中

#### 2026-02-11 · 技能 · Teammate
**觸發**: `figma-design-audit` skill 引用外部框架的路徑和指令，與 Teammate 架構不一致
**決策**: Cross-Reference 改為 Teammate 路徑（ui-spec.md / align / review / principles）
**影響**: `figma-design-audit/SKILL.md`
**成效**: skill 路徑與框架一致
**狀態**: 生效中

#### 2026-02-11 · 架構 · Teammate
**觸發**: 框架升級整合需求：P5 全部 + P4 指令合成 + 散落教訓需一次性實施
**決策**: Wave 0-4 升級：(1) P5-A~G 全部實施 (2) P4 合併指令 (3) Memory Delta Protocol 套用全部指令 (4) 更新 rules + yml
**影響**: 全部指令、rules、templates、scripts、yml
**成效**: 框架從 11 指令 → 7 指令，知識閉環完成
**狀態**: 生效中

#### 2026-02-11 · 架構 · Teammate
**觸發**: 合併後仍 7 個指令；kickoff/principles 過度引導；teammate.ui 含專案識別度；figma 是工具不是流程；assign 是純機械操作
**決策**: 二次精簡（7→5）：init 合併 kickoff+principles；ui 併入 plan（自動偵測）；figma 降為 skill；assign 降為 toolkit
**影響**: 新增 `teammate.init.md`、`figma-sync/SKILL.md`；刪除 kickoff/principles/ui/figma/assign 5 個指令
**成效**: 核心流程 `init → align → plan → execute → review`
**狀態**: 生效中

#### 2026-02-11 · 架構 · Teammate
**觸發**: feature 產出檔案過多（6 檔），tasks 和 actions 邊界模糊，execute 需同時開兩檔
**決策**: tasks + actions 合併為 `plan.md`（Part 1: Architecture + Part 2: Actions）；screenplay 移除；component-specs + ui-spec 統一為 `ui-spec.md`
**影響**: 3 個 template 合併、5 個指令更新、rules/yml/3 scripts/2 skills 更新
**成效**: 執行時只需開一份 plan.md
**狀態**: 生效中

#### 2026-02-11 · 架構 · Teammate
**觸發**: `features/` 目錄名稱無法涵蓋 bug fix、重構等非 feature 工作；plan.md Part 1 叫 Tasks 和目錄名稱衝突
**決策**: features/ → tasks/；plan.md Part 1 從 Tasks → Architecture；create-new-feature.sh → create-new-task.sh
**影響**: 所有指令、rules、scripts、templates 的路徑引用
**成效**: 目錄語意涵蓋所有工作類型
**狀態**: 生效中

#### 2026-02-11 · 文件 · Teammate
**觸發**: 流程多次合併後 README 仍保留舊指令與舊目錄，新使用者會以錯誤心智模型上手
**決策**: (1) `.cursorule` 升級為角色憲章（Tesler's Law + 降阻指標）(2) README 全面同步到新流程 (3) 同步 README 納入 DoD
**影響**: `.cursorule`、`README.md`
**成效**: 入口文件與實際框架完全一致
**狀態**: 生效中

#### 2026-02-11 · 命令 · Teammate
**觸發**: align update 後不會偵測 plan.md 是否過期；execute 開始時不會檢查 spec 是否比 plan 新
**決策**: align 新增 Phase 6「Downstream Impact Check」；execute 新增 Staleness Check
**影響**: `teammate.align.md`、`teammate.execute.md`
**成效**: 上下游文件不同步時自動警告
**狀態**: 生效中

#### 2026-02-11 · 文件 · Teammate
**觸發**: PLAYBOOK 長期演進後混合「已實現」與「未來規劃」，閱讀成本高；同步規範只要求 README，沒有強制回寫 Owner 記憶
**決策**: (1) PLAYBOOK 改為雙軌結構（歷史軌跡 + 未來規劃）+ 結構化欄位 (2) .cursorule 新增 PLAYBOOK 同步 DoD (3) 未來區拆 Roadmap + Backlog
**影響**: `PLAYBOOK.md`、`.cursorule`、`teammatesync_rule.mdc`
**成效**: 待驗證（本次變更）
**狀態**: 生效中

#### 2026-02-11 · 架構 · Teammate
**觸發**: memory 檔名語意不清：project-context 冗餘前綴、active-context 與 project-context 語意重疊、progress 和 active-context 角色混淆
**決策**: 三檔重命名：project-context.md → context.md、active-context.md → progress.md（動態進度）、progress.md → milestone.md（靜態里程碑）
**影響**: 3 個檔案重命名 + 12 個檔案引用更新（5 指令 + rules + toolkit + yml + README + PLAYBOOK + memory README + figma-index）
**成效**: memory 目錄一眼可辨：context / principles / progress / milestone
**狀態**: 生效中

#### 2026-02-12 · 架構 · Teammate
**觸發**: 全球 A11y 與 AI 法規（EU AI Act 2026/8 生效、EAA、Section 508、加州/科羅拉多 AI 法）要求產品合規，但框架缺乏合規審計機制；designkit 5 個指令的功能需整合
**決策**: (1) 新建 `/teammate.audit`（Sarcasmotron 對抗性審計，4 維度動態啟用）(2) 新建 `ai-compliance` skill（AI 風險規則 + Pass/Fail 代碼範例）(3) `a11y-compliance` skill 補充動態偵測 (4) 全生命週期動態合規介入（plan 提醒 → execute 參考 → review 初檢 → audit 判決）(5) review 新增 Pass G Design System Compliance (6) docs 精簡為 LLM 友善法規背景
**影響**: 新增 `teammate.audit.md` + `ai-compliance/SKILL.md` + `docs/a11y-compliance/` + `docs/ai-compliance/`；修改 plan + execute + review + rules + yml + README + CHANGELOG
**成效**: 待驗證（首次實戰）
**狀態**: 生效中

#### 2026-02-12 · 架構 · Teammate
**觸發**: 設計資產路徑混亂：`docs/design/figma-index.md` 已被刪除但文件仍引用；`docs/llms.txt` 框架預設但多數專案不需要；設計資產應由流程動態產生
**決策**: (1) `.teammate/design/figma-index.md` 由 `/teammate.align` 動態建立（偵測 context.md 有 Figma URL 時觸發）(2) `docs/design/` 移除 (3) `docs/llms.txt` 改為專案選用（不預設存在）(4) plan.md 偵測 `figma-index.md` 存在時才產生 `contracts/ui/ui-spec.md`
**影響**: `teammate.align.md`、`teammate.plan.md`、`teammate-rules.mdc`、`README.md`；刪除 `docs/llms.txt`、`docs/design/`
**成效**: 待驗證
**狀態**: 生效中

#### 2026-02-12 · 規則 · Teammate
**觸發**: 使用者反映 AI 回覆過度冗長，消耗大量 token，要求極簡輸出
**決策**: (1) `teammate-rules.mdc` 新增 Output Mode 區段，定義 Lean / Diagnostic / Blocker 三層輸出契約 (2) 移除 ABCD 多選下一步格式，改為單一推薦 (3) `.cursorule` 新增省 Token 原則
**影響**: `teammate-rules.mdc`、`.cursorule`、`CHANGELOG.md`
**成效**: 待驗證
**狀態**: 生效中

#### 2026-02-13 · 架構 · Teammate
**觸發**: 流程體驗架構師審計發現多項一致性問題：模板角色模糊、phase 名稱過時、腳本 flag 別名冗餘、文件路徑不一致
**決策**: (1) 建立獨立模板 `context-template.md` / `principles-template.md` (2) 更新 phase 名稱 `Commit/Deliver` → `Plan/Execute/Review` (3) 移除 `--actions` 別名統一用 `--plan` (4) 明確 `figma-index.md` 存在必定觸發 UI Deep Analysis (5) 更新 `teammate.yml` docs 區段 (6) Output Mode 允許最多 2 個選項 (7) 加入「測試」類型到 PLAYBOOK (8) 版本升級至 0.1.0
**影響**: `teammate.init.md`、`teammate-rules.mdc`、`teammate.plan.md`、`teammate.execute.md`、`teammate.review.md`、`check-prerequisites.sh`、`teammate.yml`、`teammatesync_rule.mdc`、`example-mapping-template.md`、`CHANGELOG.md`、新增 2 個模板檔案
**成效**: 框架一致性提升，模板角色明確
**狀態**: 生效中

---

## 2. 尚未實現（未來可實現）

### 2-A. Roadmap（策略視角）

| ID | 主題 | 目標 | 成功指標 | 預估成本 | 依賴 | 狀態 |
|----|------|------|---------|---------|------|------|
| P1 | 安裝腳本 install.sh | 一鍵安裝 Teammate 到任何專案 | 新專案安裝後可立即執行 `/teammate.init` | 中 | — | 暫緩 |
| P3 | 多專案同步機制 | 跨專案框架更新不再依賴 AI 記憶 | 自動偵測版本差異並報告 | 中 | P1 | 暫緩 |
| P6 | User Profile Evolution | 持久使用者偏好形式化 + 演化機制 | `.cursorule` 結構化 + Observe-Suggest-Graduate 迴路 | 低 | P1/P3 | 延後 |

### 2-B. Backlog（執行視角）

| 項目 | 優先級 | 依賴 | 風險 | 觸發條件 |
|------|--------|------|------|---------|
| install.sh 核心複製邏輯 | P2 | — | 覆蓋使用者檔案 | 第二個專案採用 Teammate |
| install.sh `--update` 模式 | P2 | P1 核心 | — | 框架版本升級 |
| install.sh `--version` 指定版本 | P3 | P1 + P2 | — | 多版本共存需求 |
| Git tag 版本標記 | P3 | P2 版本管理 | — | 1.0.0 釋出時 |
| Symlink 同步可行性評估 | P3 | — | 跨平台相容性 | 單機多專案需求出現 |
| Git Submodule 評估 | P4 | P3 | 複雜度高 | 多人協作需求 |
| `.cursorule` template 提供 | P3 | P1 | — | P1 完成時 |
| Profile Evolution 規則實作 | P3 | P6 設計確認 | 過度自動化 | 多專案使用回饋累積 |
| `teammate-rules.mdc` 新增 User Profile 載入規則 | P3 | P6 | — | P6 開始實施 |

---

## 附錄 A：已完成方案設計封存

> 以下為已完成方案的原始設計推導，保留供決策回溯。

### P2: 版本管理 ✅（2026-02-11）

**動機**: 不同專案可能需要不同版本的 Teammate

**已完成**:
- `teammate.yml` 新增 `version: "0.0.1"` 正式欄位（從 `# Version: 2.0.0` 註解升級）
- 新建 `CHANGELOG.md`，以 `[0.0.1]` 作為 baseline + `[Unreleased]` 區段
- `teammate.toolkit.md` 實作 `migrate` 工具（8 步驟：Locate Hub → Compare → Parse Changelog → Diff → Report → Confirm → Apply → Update Context）
- `teammatesync_rule.mdc` 新增 Version Tracking sync 規則 + `.cursorule` 不同步
- `teammate-rules.mdc` Key Paths 新增 `CHANGELOG.md`
- 版本語意：0.x.y 快速迭代（未公開），1.0.0 起遵循 semver

**未來延伸**（與 P1 整合時）:
- `install.sh` 支援 `--version v1.2.0`
- Git tag 標記每個穩定版本

---

### P4: 指令合成 ✅（2026-02-11）

**動機**: PM/設計端無法消化 11 個指令的工程流程

**已完成**:

| 合併前 | 合併後 | 產出 |
|--------|--------|------|
| `align` + `clarify` | `/teammate.align` | `spec.md` + `example-mapping.md` |
| `plan` + `tasks` + `actions` | `/teammate.plan` | `.feature` + `plan.md` |
| `review` + `checklist` | `/teammate.review` | 行為覆蓋 + 交付檢核 |

**二次精簡**:
- `kickoff` + `principles` → `/teammate.init`
- `teammate.ui` → 併入 plan（UI Deep Analysis 自動偵測）
- `teammate.figma` → 降為 `figma-sync` skill
- `teammate.assign` → 降為 `/teammate.toolkit assign`

**最終流程**: `init → align → plan → execute → review`

---

### P5: ACE 產品開發知識閉環 ✅（2026-02-11）

**動機**: 框架知識管理靜態，缺乏 ACE 風格閉環

**ACE 原則對應設計**:

| 原則 | Teammate 對應設計 |
|------|-----------------|
| Dynamic Cheatsheet | `tasks/[###-name]/insights.md` |
| Reflector | execute REFLECT 步驟 |
| Curator | Insights Graduation 機制（3+ 次重複 → 提升） |
| Incremental Delta | Memory Delta Protocol（progress.md 分區追加） |
| Combat Brevity Bias | Context Loading Discipline（Required/Recommended/Optional） |
| HITL | Risk-Based Gates（4 個暫停條件） |
| Observability | Decision Trace（insights.md Decision Log） |

**全部 7 項改善已完成**:
- A: 新增 `insights-template.md`
- B: Red-Green Loop → Red-Green-Refactor-Reflect
- C: Context Loading 三層（Required/Recommended/Optional）
- D: Insights Graduation（3+ features → 提升到 context/principles）
- E: Memory Delta Protocol + 全部指令改為分區更新
- F: 4 個 Risk-Based HITL Gates
- G: Context Layer 三層定義（System/Task/User）

---

## 附錄 B：待實施方案設計

> 以下為尚未實施方案的設計細節，供未來啟動時參考。

### P1: install.sh 安裝腳本

**動機**: 讓 Teammate 可以一鍵安裝到任何專案，取代手動複製和 sync rule

**設計**:

```bash
# 在任何專案中安裝 Teammate
~/Developer/Teammate/install.sh

# 或指定路徑
~/Developer/Teammate/install.sh --target /path/to/project
```

**安裝內容**（複製到目標專案）:
- `.teammate/templates/` — 文件模板
- `.teammate/scripts/` — 自動化腳本
- `.teammate/config/` — 設定檔
- `.cursor/commands/teammate.*.md` — Cursor 指令
- `.cursor/rules/teammate-rules.mdc` — AI 工作規範

**不覆蓋**（專案私有）:
- `.teammate/memory/` — 專案上下文、原則、進度
- `.teammate/snapshots/` — 快照
- `tasks/` — 任務工作目錄
- `.cursor/rules/` 中非 teammate 的規則

**更新模式**:
```bash
~/Developer/Teammate/install.sh --update  # 只更新框架檔案，不動專案內容
```

**驗收標準**:
- 新專案安裝後可立即執行 `/teammate.init`
- 已有專案更新後不影響既有 memory 和 tasks
- 安裝後自動印出版本和可用指令清單

---

### P3: 多專案同步機制

**動機**: 在 oReady 實戰中用 `teammatesync_rule.mdc` 讓 AI 同步兩個 repo，但這依賴 AI 記得

**方案評估**:

| 方案 | 即時同步 | 複雜度 | 適合場景 |
|------|---------|--------|---------|
| Sync Rule（目前）| 靠 AI | 低 | 1-2 個專案，單人 |
| Symlink | 即時 | 中 | 單機多專案，不需 git 追蹤 |
| install.sh（P1）| 手動 | 低 | 正式發佈，多人 |
| Git Submodule | 手動 | 高 | 多人協作，版本嚴格控制 |

**建議路線**: Sync Rule → install.sh → Submodule（依使用規模遞進）

---

### P6: User Profile 與 Profile Evolution

**動機**: `.cursorule` 在實戰中扮演「使用者偏好」角色，但 Teammate 架構不承認它的存在

**設計 A: `.cursorule` 定位為 User Profile**

```markdown
# User Profile

## Identity
- Role: [PM, 設計師, 工程師]
- Technical Level: 假設完全不懂技術

## Communication Style
- 用通俗易懂的語言解釋技術術語
- 除錯時解釋「原因」

## Execution Preferences
- 自動執行指令，不需逐一確認
```

**設計 B: Profile Evolution 機制**

- **觀察（Observe）**: AI 留意重複偏好模式
- **建議（Suggest）**: 同一 session 出現 2+ 次時建議加入 Profile
- **畢業（Graduate）**: PLAYBOOK 教訓表跨 3+ 專案出現 → 提升為框架預設行為

**設計 C: Context Layer User Layer 補完**

```
User Layer（使用者層 — 持久 + 即時）:
  - .cursorule              # 持久偏好（User Profile）
  - $ARGUMENTS              # 即時輸入
  - handoffs                # 即時選擇
```

**配套更新**:

| 檔案 | 更新內容 |
|------|---------|
| `teammate-rules.mdc` | 新增 User Profile + Profile Evolution 規則 |
| `teammatesync_rule.mdc` | Do NOT sync 表格新增 `.cursorule` |
| P1 `install.sh` | 安裝時提供 `.cursorule.template` |
| P5-G Context Layer | User Layer 補上 `.cursorule` 持久偏好 |

**狀態**: 延後至 P1/P3 一併實施

---

**Last Updated**: 2026-02-12（設計資產動態建立 + docs 結構精簡）
