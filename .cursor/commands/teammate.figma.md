---
description: Sync implemented UI components to Figma via cursor-talk-to-figma-mcp — creates visual specs, state variants, and design documentation.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

`/teammate.figma` 將已實作的 UI 組件寫入 Figma，建立視覺規格文件。使用 `cursor-talk-to-figma-mcp` 的寫入工具（create_frame、create_text、set_fill_color 等）。

### Prerequisites

1. **Figma 桌面版**已開啟，且 **Cursor Talk To Figma** plugin 正在運行
2. 使用者提供 **channel name**（plugin 顯示的頻道名稱）
3. 使用者提供 **target node ID**（要寫入的 Figma frame，可從 URL 的 `node-id` 參數取得）

### Argument Parsing

| 參數模式 | 行為 |
|---------|------|
| `[channel] [nodeId]` | 加入頻道，在指定 node 建立設計 |
| `[channel] [nodeId] [component]` | 只產出指定組件（如 `TaskNotifier`） |
| `[figma-url]` | 從 URL 擷取 nodeId（`?node-id=79-98` → `79:98`） |
| _(empty)_ | 提示使用者提供 channel 和目標 |

### Execution Steps

#### Step 0: Connect to Figma

1. Parse channel name from arguments
2. Call `join_channel(channel)`
3. Call `get_document_info()` to verify connection
4. If connection fails → **ERROR**: 提示使用者確認 plugin 是否運行

#### Step 1: Load Design Context

Required:
- `contracts/ui/component-specs.md` — 組件清單、Props、樣式規範
- `principles.md` — 設計系統參考（色彩 tokens、圓角、間距）
- 實際的 `.svelte` 組件原始碼（推斷 UI 結構）

Optional:
- `spec.md` — 使用者情境描述
- `tasks.md` — IMP 規格中的視覺描述

#### Step 2: Determine Scope

If specific component name provided → only that component
Otherwise → scan `contracts/ui/component-specs.md` for all components marked `[NEW]` or `[ENHANCE]`

For each component, identify:
- **States**: 從組件原始碼的 `{#if}` / `{:else}` 推斷所有視覺狀態
- **Props variants**: 從 `export let` props 推斷關鍵變體
- **Responsive**: 是否有 compact/full 模式

#### Step 3: Prepare Target Frame

1. Call `get_node_info(nodeId)` to check target frame
2. If frame is empty → use it directly
3. If frame has content → ask user: "Frame has existing content. Append or replace?"

#### Step 4: Create Design for Each Component

For each component in scope:

##### 4a. Create Component Section

```
[Component Title — Label]
├── [State: Default]         ← 主要狀態的完整 frame
├── [State: Variant 1]       ← 其他狀態變體
├── [State: Variant N]
├── [Props/Tokens 規格]      ← 色彩、間距、圓角等文字說明
└── [Behavior Notes]         ← 互動行為（動畫、計時、條件）
```

##### 4b. Build Each State Frame

使用 TalkToFigma 工具：

| 工具 | 用途 |
|------|------|
| `create_frame` | 建立容器（auto-layout、padding、spacing） |
| `create_text` | 標籤、內容文字、規格說明 |
| `create_rectangle` | 色塊、進度條、分隔線 |
| `set_fill_color` | 設定背景/填充色 |
| `set_stroke_color` | 設定邊框色 |
| `set_corner_radius` | 設定圓角 |
| `set_layout_mode` | 設定 auto-layout（HORIZONTAL / VERTICAL） |
| `set_padding` | 設定內距 |
| `set_item_spacing` | 設定元素間距 |
| `set_layout_sizing` | 設定 FILL / HUG / FIXED |

##### 4c. Color Mapping

從 `principles.md` 設計系統參考和 Tailwind tokens 映射到 Figma RGB：

| Tailwind Token | 用途 | RGB (0-1) |
|---------------|------|-----------|
| `gray-50` | 淺色背景 | (0.976, 0.976, 0.976) |
| `gray-100` | 邊框（淺色） | (0.925, 0.925, 0.925) |
| `gray-400` | 次要文字 | (0.706, 0.706, 0.706) |
| `gray-500` | 描述文字 | (0.608, 0.608, 0.608) |
| `gray-800` | 邊框（深色） | (0.2, 0.2, 0.2) |
| `gray-850` | 深色背景 | (0.149, 0.149, 0.149) |
| `gray-900` | 主要文字 | (0.09, 0.09, 0.09) |
| `blue-500/20` | Processing badge | (0.23, 0.51, 0.96, 0.2) |
| `green-500/20` | Complete badge | (0.13, 0.77, 0.37, 0.2) |
| `yellow-500/20` | Pending badge | (0.92, 0.78, 0.03, 0.2) |
| `red-500/20` | Failed badge | (0.94, 0.27, 0.27, 0.2) |

##### 4d. Add Annotations

For each component section, add text annotations:
- **規格說明**：定位、尺寸、圓角、邊框、陰影
- **行為說明**：動畫、計時、條件渲染、SSE 連結
- **Props**：關鍵 props 和預設值
- **掛載點**：在哪個頁面/layout 掛載

#### Step 5: Add Overview

在目標 frame 頂部建立概覽：
- Feature 名稱
- 組件清單
- 總體設計語言說明（引用 principles.md 設計系統）

#### Step 6: Report

Output:
- 建立了哪些組件的設計
- 每個組件的狀態數量
- Figma node IDs（供後續引用）
- 建議：更新 `contracts/ui/component-specs.md` 加入 Figma link

### Design Principles (for Figma output)

1. **Auto-layout first** — 所有 frame 使用 auto-layout，不手動定位子元素
2. **Tokens over hardcode** — 色彩使用 Tailwind token 對應值，不自創色碼
3. **State completeness** — 每個組件至少呈現所有可見狀態（default, hover 可省略, error, empty, loading）
4. **Light mode only** — Figma 中只呈現淺色模式（深色模式由 Tailwind `dark:` 自動處理，Figma 中以文字標註）
5. **Annotate behavior** — 無法在 Figma 中呈現的動態行為（fade、transition、timer）以文字說明

### Dark Mode Handling

Figma 靜態設計無法呈現 Tailwind `dark:` 動態切換。處理方式：
- 主要設計以**淺色模式**呈現
- 在規格說明中標註深色模式的色彩映射
- 如果使用者明確要求，可以建立獨立的深色模式 frame

### Key Rules

- **Read implementation first** — 從實際 `.svelte` 原始碼推斷 UI 結構，不憑空設計
- **Faithful to code** — Figma 設計必須反映已實作的程式碼，不是理想化的 mockup
- **Annotate what Figma can't show** — 動畫、SSE 驅動更新、條件渲染等用文字標註
- **Use auto-layout** — 所有容器使用 auto-layout 以確保 Figma 可維護
- **One frame per component** — 每個組件獨立一個 section frame，方便移動和引用
- **Channel must be active** — 每次執行前驗證 Figma plugin 連線
