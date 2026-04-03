# UI Spec Format Reference

> **何時載入**：當 `speckit.plan.md` 階段 2.5 觸發 UI 深度分析時，AI 依此格式產出 `contracts/ui/ui-spec.md`。

## 觸發條件（任一）

- `.specify/design/figma-index.md` 存在
- UI 組件 ≥ 3 個
- `--ui` flag

## 產出格式：`contracts/ui/ui-spec.md`

### 1. 組件清單

| 組件名稱 | 類型 | 狀態數 | 父組件 |
|---------|------|--------|--------|
| `Button` | 原生 | 4 | `Form` |

### 2. 屬性與介面

```ts
// Props、匯出介面、事件、slot
interface ButtonProps {
  label: string;
  onClick: () => void;
  disabled?: boolean;
}
```

### 3. 狀態矩陣

每個組件 **≥ 3 狀態**：預設 + 主要 + 邊界。
`Loading` / `Error` / `Empty` 狀態 **MUST** 說明：顯示內容 + 使用者動作。

| 組件 | 預設 | 載入中 | 錯誤 | 空 |
|------|------|--------|------|-----|
| `List` | 顯示項目 | Spinner | 錯誤訊息 + 重試 | 空狀態圖示 |

### 4. 互動流程

核心路徑（happy path + error path），以步驟序列描述：

```
1. 使用者點擊「送出」
2. 顯示 Loading 狀態
3a. 成功 → 跳轉確認頁
3b. 失敗 → 顯示 Error + 重試按鈕
```

### 5. 互動狀態機

每個可互動元素 **MUST** 具備 `enabled` + `disabled` 狀態。
引用外部設計 **MUST** 標註語意差異（若有）。

### 6. 設計系統合規

- **Tokens**：color tokens、spacing、typography（不得 hardcode 數值）
- **i18n**：所有文字使用 i18n key
- **A11y**：`aria-label`、鍵盤導航、色彩對比 ≥ 4.5:1（WCAG 2.2 AA）
