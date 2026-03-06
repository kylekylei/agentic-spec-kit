---
name: pencil/references/bind
description: 掃描 Pencil .pen 組件中的 hardcoded 色值與數值，批次替換為 design token 變數引用（$variable）。
---

# Token 綁定

掃描 `.pen` 組件中的 hardcoded 色值與數值，批次替換為 design token 變數引用。

## 輸入格式

```
bind <filePath> [rootNodeId]
```

| 參數 | 必填 | 說明 | 範例 |
|------|------|------|------|
| `filePath` | 是 | .pen 檔案絕對路徑 | `.teammate/design/pencil/components/TaskNotifier.pen` |
| `rootNodeId` | 否 | 限縮範圍的根節點 ID（省略則掃描整個檔案） | `8BV09` |

## 執行流程

### Step 1 — 載入可用 Variables

```
get_variables(filePath)
```

確認 `design-tokens.pen` 已定義的 variables。若 variables 為空，先執行 token 產生與 sync。

### Step 2 — 掃描現有值

```
search_all_unique_properties(
  filePath,
  parents: [rootNodeId],
  properties: ["fillColor", "textColor", "strokeColor", "cornerRadius", "padding", "gap"]
)
```

### Step 3 — 建立映射表

AI 根據 Step 2 結果與 variables 清單建立映射：

#### 顏色映射

| Hex | Token |
|-----|-------|
| `#ffffff` | `$color.bg.surface` |
| `#171717` | `$color.text.primary` |
| `#ececec` | `$color.border.default` |
| `#2563eb` | `$color.status.info` |
| ... | （依 get_variables 結果動態比對） |

**透明色處理**：
- 帶 alpha 的色值（如 `#0000001a`）→ 綁定到最接近的實色 token
- 完全透明（`#00000000`）→ 保留，代表 `fill.enabled: false`

#### 間距映射

| 值 | Token |
|----|-------|
| `4` | `$spacing.1` |
| `8` | `$spacing.2` |
| `12` | `$spacing.3` |
| `16` | `$spacing.4` |
| `20` | `$spacing.5` |
| `24` | `$spacing.6` |

#### 圓角映射

| 值 | Token |
|----|-------|
| `2` | `$radius.sm` |
| `4` | `$radius.DEFAULT` |
| `6` | `$radius.md` |
| `8` | `$radius.lg` |
| `12` | `$radius.xl` |

### Step 4 — 批次替換色彩

```
replace_all_matching_properties(
  filePath,
  parents: [rootNodeId],
  properties: {
    fillColor: [ {from: "#hex", to: "$token"}, ... ],
    textColor: [ ... ],
    strokeColor: [ ... ]
  }
)
```

### Step 5 — 批次替換間距與圓角

使用 `batch_get` 取得需更新的節點 ID，再用 `batch_design` 批次更新：

```
batch_design(filePath, operations: """
U("nodeId", { gap: "$spacing.2", padding: "$spacing.3", cornerRadius: "$radius.xl" })
...
""")
```

每批操作 <= 25 個，避免 timeout。

### Step 6 — 驗證

再次呼叫 `search_all_unique_properties`，確認：
- fillColor / textColor / strokeColor 中無剩餘 hardcoded hex（透明色除外）
- 所有間距與圓角已替換

### Step 7 — 視覺確認

```
get_screenshot(filePath, nodeId: rootNodeId)
```

截圖確認視覺正確，無錯位或顏色異常。

## 規則

- **禁止**直接讀寫 `.pen` 檔（加密格式）
- 執行前必須確認 `design-tokens.pen` variables 已是最新
- 每批 `batch_design` 操作 <= 25 個，避免 MCP timeout
- 透明色（帶 alpha）不強制綁定，由人工判斷或綁定最接近實色 token
- 若 `rootNodeId` 省略，AI 應先詢問確認範圍，避免誤改整個檔案

## Troubleshooting

| 問題 | 解法 |
|------|------|
| `Failed to access file` | 用 `open_document` 先開啟 .pen 檔 |
| MCP timeout | 減少每批操作數量（每批 <= 15） |
| 色值替換後顏色錯誤 | 確認 hex 映射正確，用 `get_screenshot` 驗證 |
| Variables 為空 | 先執行 token 產生與 sync |
| 透明色無法綁定 | 查看 `pencil-rules.mdc` 透明色處理規則，手動選擇最接近 token |
