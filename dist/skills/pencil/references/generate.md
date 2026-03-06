---
name: pencil/references/generate
description: 從 Tailwind config 產生 design tokens，並透過 Pencil MCP 注入 design-tokens.pen。
---

# Token 產生與同步

## 執行邏輯

| 輸入 | 動作 |
|------|------|
| 無 / `generate` | Step 1 只：產生 tokens-output.json |
| `sync` | Step 1 + Step 2：產生後立即透過 Pencil MCP 注入 |
| `watch` | 啟動監聽模式（僅產生 JSON，不自動 sync） |

## Step 1 — 產生 Variables JSON

```bash
npm run tokens:generate
```

輸出：`.teammate/design/pencil/tokens-output.json`

腳本位置：`.cursor/skills/design-tokens/scripts/`

```
scripts/
├── generate-design-tokens.js    # CLI 入口：輸出 tokens-output.json
├── tailwind-to-pencil.js        # 核心轉換器（export getVariablesPayload）
├── extractors/
│   ├── colors.js                # 顏色提取（var(), rgb() 解析）
│   └── semantic-tokens.js       # Light/Dark 語意映射
└── mappings/
    └── tailwind-defaults.js     # Tailwind 預設 spacing / radius
```

## Step 2 — 透過 Pencil MCP 注入（sync 模式）

### 2-1. 讀取 JSON

AI 讀取 `tokens-output.json` 的內容（variables 物件）。

### 2-2. 呼叫 Pencil MCP `set_variables`

```
set_variables(
  filePath: ".teammate/design/pencil/design-tokens.pen",
  variables: <tokens-output.json 的全部內容>,
  themes: { Mode: ["Light", "Dark"] }
)
```

### 2-3. 驗證

```
get_variables(filePath: ".teammate/design/pencil/design-tokens.pen")
```

確認 token 數量與內容與 tokens-output.json 一致。

## Watch 模式

```bash
npm run tokens:watch
```

監聽 `tailwind.config.js` 變更，自動重新產生 `tokens-output.json`。每次更新後需手動執行 sync 以同步至 Pencil。

## Token 參考

### Token 數量（約）

| 類別 | 數量 |
|------|------|
| Colors（shadcn `--*` + `color.*`） | 48 |
| Spacing（Tailwind scale 0-96） | 36 |
| Radius（none, sm, DEFAULT, lg, xl…） | 9 |
| 專案特定（`spacing.card-height`） | 1 |

### shadcn-style Tokens（推薦）

| Token | Light | Dark |
|-------|-------|------|
| `$--background` | white | gray-900 |
| `$--foreground` | gray-900 | gray-50 |
| `$--card` / `$--card-foreground` | white / gray-900 | gray-850 / gray-50 |
| `$--primary` / `$--primary-foreground` | gray-900 / gray-50 | gray-50 / gray-900 |
| `$--secondary` / `$--secondary-foreground` | gray-100 / gray-900 | gray-800 / gray-50 |
| `$--destructive` | red-500 | red-600 |
| `$--muted` / `$--muted-foreground` | gray-100 / gray-500 | gray-800 / gray-400 |
| `$--accent` / `$--accent-foreground` | gray-100 / gray-900 | gray-800 / gray-50 |
| `$--border` | gray-200 | gray-800 |
| `$--input` | gray-200 | gray-800 |
| `$--ring` | gray-900 | gray-300 |

### Legacy Semantic Tokens

#### 背景

| Token | Light | Dark | Tailwind |
|-------|-------|------|----------|
| `$color.bg.surface` | `#ffffff` | `#262626` | `bg-white dark:bg-gray-850` |
| `$color.bg.surface.hover` | `#ececec` | `#333333` | `hover:bg-gray-100 dark:hover:bg-gray-800` |
| `$color.bg.canvas` | `#f9f9f9` | `#171717` | `bg-gray-50 dark:bg-gray-900` |

#### 文字

| Token | Light | Dark | Tailwind |
|-------|-------|------|----------|
| `$color.text.primary` | `#171717` | `#ececec` | `text-gray-900 dark:text-gray-100` |
| `$color.text.secondary` | `#676767` | `#b4b4b4` | `text-gray-600 dark:text-gray-400` |
| `$color.text.tertiary` | `#9b9b9b` | `#9b9b9b` | `text-gray-500` |
| `$color.text.disabled` | `#cdcdcd` | `#676767` | `text-gray-300 dark:text-gray-600` |

#### 邊框

| Token | Light | Dark | Tailwind |
|-------|-------|------|----------|
| `$color.border.default` | `#ececec` | `#333333` | `border-gray-100 dark:border-gray-800` |
| `$color.border.strong` | `#e3e3e3` | `#4e4e4e` | `border-gray-200 dark:border-gray-700` |
| `$color.border.subtle` | `#f9f9f9` | `#262626` | `border-gray-50 dark:border-gray-850` |

#### 狀態

| Token | Light | Dark | Tailwind |
|-------|-------|------|----------|
| `$color.status.success` | `#16a34a` | `#4ade80` | `text-green-600 dark:text-green-400` |
| `$color.status.error` | `#dc2626` | `#f87171` | `text-red-600 dark:text-red-400` |
| `$color.status.warning` | `#ca8a04` | `#facc15` | `text-yellow-600 dark:text-yellow-400` |
| `$color.status.info` | `#2563eb` | `#60a5fa` | `text-blue-500 dark:text-blue-400` |

## Pencil.dev Format

**版本**：`version: "2.8"` 必要（否則 Variables 面板不顯示 Light/Dark 雙欄）

```json
{
  "--background": {
    "type": "color",
    "value": [
      { "value": "#ffffff" },
      { "value": "#171717", "theme": { "Mode": "Dark" } }
    ]
  },
  "spacing.4": { "type": "number", "value": 16 },
  "radius.lg": { "type": "number", "value": 8 }
}
```

### 新增 Token

編輯 `scripts/extractors/semantic-tokens.js`，加入新項目後執行 sync。

## Troubleshooting

| 問題 | 解法 |
|------|------|
| Tokens 未更新 | 確認 sync 有執行 |
| Variables 面板無 Dark 欄 | 確認 `version: "2.8"` 且第一個 value 無 theme tag |
| 顏色錯誤 | 確認 `semantic-tokens.js` 映射與 Tailwind 實際用法一致 |
| Import 錯誤 | 從專案根目錄執行，不要 `cd` 進 scripts |
