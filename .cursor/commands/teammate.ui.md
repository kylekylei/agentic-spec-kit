---
description: UI-focused workflow for component states, interaction flows, and design system compliance. Produces UI specs, interaction maps, and a11y/i18n checklists.
handoffs: 
  - label: Execute UI Actions
    agent: teammate.execute
    prompt: Start implementing UI components
    send: true
  - label: Review UI Coverage
    agent: teammate.review
    prompt: Run a behavioral coverage analysis including UI contracts
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Define **UI-specific requirements** that complement the behavioral spec. This command focuses on visual states, interaction flows, and design system compliance — areas where behavioral scenarios alone are insufficient.

> 此指令用於 UI 密集的 feature。對於純後端或邏輯 feature，直接使用 `/teammate.plan`。

### When to Use

- Feature involves 3+ UI components
- Feature has complex interaction states (Loading/Empty/Error/Success)
- Feature needs design system compliance verification
- Feature involves i18n or a11y requirements

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.kickoff` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Principles not defined. Run `/teammate.principles` first."

### Setup

Run `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root. Parse for `FEATURE_DIR`.

Load:
- `FEATURE_DIR/spec.md` — Required
- `FEATURE_DIR/tasks.md` — Required (if exists)
- `FEATURE_DIR/contracts/ui/` — Optional (if exists, use as baseline)
- `.teammate/memory/principles.md` — Required (for design system constraints)
- `docs/design/` — Optional (design system docs)

---

## Stage 1: Component Inventory

掃描 spec.md 和 tasks.md，列出所有 UI 組件：

```markdown
## Component Inventory

| 組件 | 類型 | 狀態數 | 父組件 | 備註 |
|------|------|--------|--------|------|
| TaskNotifier | Panel | 4 | +layout.svelte | 全域可見 |
| TaskCard | Card | 3 | TaskNotifier | 可展開 |
| ProgressBar | Indicator | 2 | TaskCard | 動畫 |
```

對每個組件標記：
- `[NEW]` — 全新組件
- `[ENHANCE]` — 既有組件需修改
- `[INTEGRATE]` — 需掛載到的消費者

---

## Stage 2: State Matrix

對每個組件定義完整的視覺狀態：

```markdown
## State Matrix

### TaskNotifier

| 狀態 | 觸發條件 | 外觀描述 | 互動行為 |
|------|----------|----------|----------|
| Empty | 無 active tasks | 隱藏（不渲染） | — |
| Active | 有 processing tasks | 展開面板，顯示 task 列表 | 可最小化 |
| Minimized | 使用者點擊最小化 | 收合為 badge，顯示數量 | 點擊展開 |
| All Complete | 全部 tasks 完成/失敗 | 面板可關閉 | ×按鈕 enabled |
```

規則：
- 每個組件 MUST 至少定義 3 種狀態（預設 + 主要 + 邊界）
- Loading 狀態 MUST 說明 loading 的內容和預估時間
- Error 狀態 MUST 說明可能的錯誤類型和使用者動作
- Empty 狀態 MUST 說明何時出現和顯示內容

---

## Stage 3: Interaction Flow

定義核心互動路徑（happy path + error path）：

```markdown
## Interaction Flows

### Flow 1: 新 Task 觸發通知

1. 使用者上傳檔案 → 後端回傳 task_id
2. SSE 推送 `processing` 事件 → TaskNotifier 出現（Active 狀態）
3. TaskCard 顯示進度條 + 描述
4. SSE 推送 `completed` 事件 → TaskCard 更新為完成狀態
5. 全部完成 → × 按鈕 enabled → 使用者可 dismiss

### Flow 2: 錯誤處理

1. SSE 推送 `failed` 事件 → TaskCard 顯示錯誤訊息
2. 無重試按鈕（後端無 API）→ 顯示「請重新上傳」提示
```

---

## Stage 4: Interactive State Machine

對每個互動元素產出狀態機表格：

```markdown
## Interactive State Machine

| 元素 | 觸發條件 | 狀態 | 行為 |
|------|----------|------|------|
| × 關閉按鈕 | 有 processing tasks | disabled | 灰色，不可點擊 |
| × 關閉按鈕 | 全部 completed/failed | enabled | 點擊 dismiss 全部 |
| 最小化按鈕 | 任何時候 | enabled | 收合為 badge |
| TaskCard 展開 | 點擊 card | toggle | 展開/收合詳細資訊 |
```

驗證規則：
- 每個互動元素 MUST 有 enabled 和 disabled 兩種狀態
- 每個 disabled MUST 說明原因
- 若引用外部設計（如 Google Drive），MUST 標註語意差異

---

## Stage 5: Design System Compliance

```markdown
## Design System Checklist

### UI Compliance
- [ ] 使用專案定義的 color tokens（不使用 raw hex/rgb）
- [ ] 間距遵循 spacing scale（4px/8px/12px/16px/24px/32px）
- [ ] 字型遵循 typography scale
- [ ] 響應式斷點符合專案定義
- [ ] 動畫遵循 motion guidelines（如有）

### i18n Compliance
- [ ] 所有使用者可見文字使用 i18n key
- [ ] 新增 key 已同步到所有 locale（en-US + zh-TW 等）
- [ ] 日期/數字格式使用 locale-aware formatter
- [ ] RTL 佈局已考慮（如適用）

### a11y Compliance
- [ ] 互動元素有 aria-label 或 aria-labelledby
- [ ] 鍵盤導覽可操作（Tab / Enter / Escape）
- [ ] 焦點管理正確（modal 開啟時 trap focus）
- [ ] 色彩對比度 ≥ 4.5:1（WCAG AA）
- [ ] Screen reader 可正確朗讀狀態變化
```

---

## Stage 6: Generate UI Spec

Write comprehensive UI spec to `FEATURE_DIR/contracts/ui/ui-spec.md`:

```markdown
# UI Specification: [Feature Name]

## Component Inventory
[From Stage 1]

## State Matrix
[From Stage 2]

## Interaction Flows
[From Stage 3]

## Interactive State Machine
[From Stage 4]

## Design System Compliance
[From Stage 5]

## Corresponding Spec/Tasks

| UI 組件 | 對應 spec.md User Story | 對應 tasks.md IMP |
|---------|------------------------|-------------------|
| TaskNotifier | US2: 任務通知 | IMP: TaskNotifier.svelte [NEW] |
```

---

## Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/active-context.md` using delta mode:
- **覆寫 `## Current State`**：Phase: Commit, Last Command: ui, Next Action: /teammate.execute
- **追加 `## Session Log`**：`| [timestamp] | ui | [N] components, [N] states, [N] flows | [compliance status] |`

## Report Completion

Output:
- Path to `contracts/ui/ui-spec.md`
- Component count and state coverage
- Interaction flows defined
- Design system compliance score
- i18n/a11y checklist status
- Suggested next command: `/teammate.execute`
