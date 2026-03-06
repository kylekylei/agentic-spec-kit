---
name: figma
description: Translates Figma designs into production-ready code with 1:1 visual fidelity using the Figma MCP workflow. Trigger when user provides Figma URLs or node IDs, asks to implement designs/components matching Figma specs, or mentions "implement design", "build Figma design", "figma to code". For low-fidelity / PM sketch inputs, load references/fidelity-adaptive.md.
---

# Figma

Figma 設計到程式碼的完整工作流程。透過 Figma MCP 取得設計上下文、截圖、變數與資產，翻譯為符合專案慣例的生產程式碼。

> **核心原則**：Codebase 是設計系統的權威來源（Source of Truth），Figma 表達的是「設計意圖」而非「實作規格」。

## Prerequisites

- Figma MCP server 必須已連線
- 使用者提供 Figma URL：`https://figma.com/design/:fileKey/:fileName?node-id=1-2`
  - `:fileKey` — file key（`/design/` 之後的段落）
  - `1-2` — node ID（`node-id` query parameter）
- **或**使用 `figma-desktop` MCP：直接選取桌面應用中的 node（無需 URL）
- 專案應有已建立的 design system 或元件庫（推薦）

## Required Workflow

**依序執行，不得跳步。**

### Step 1: Get Node ID

**Option A — 從 Figma URL 解析：**

URL 格式：`https://figma.com/design/:fileKey/:fileName?node-id=1-2`

- File key：`:fileKey`
- Node ID：`1-2`

使用 `figma-desktop` MCP 時，不傳 `fileKey`，server 自動使用當前開啟的檔案。

**Option B — Figma Desktop 當前選取（僅 figma-desktop MCP）：**

工具自動使用桌面應用中選取的 node。需使用者已開啟 Figma 桌面應用並選取目標 node。

### Step 2: Fetch Design Context

```
get_design_context(fileKey=":fileKey", nodeId="1-2")
```

回傳結構化資料：Layout、Typography、Color、Component 結構、Spacing。

若回應過大或截斷：
1. `get_metadata(fileKey=":fileKey", nodeId="1-2")` 取得節點地圖
2. 辨識需要的子節點
3. 逐一 `get_design_context` 取得子節點

### Step 3: Capture Visual Reference

```
get_screenshot(fileKey=":fileKey", nodeId="1-2")
```

此截圖作為視覺驗證的 source of truth，在整個實作過程中保持可存取。

### Step 4: Download Required Assets

下載 Figma MCP server 回傳的資產（圖片、icon、SVG）。

- **IMPORTANT**: 若回傳 `localhost` source，直接使用，不修改
- **IMPORTANT**: 禁止匯入新 icon 套件，所有資產應來自 Figma payload
- **IMPORTANT**: 有 localhost source 時禁止使用或建立 placeholder

### Step 5: Translate to Project Conventions

將 Figma 輸出翻譯為專案的框架、樣式和慣例。

- Figma MCP 輸出（通常 React + Tailwind）是設計和行為的表示，非最終程式碼風格
- 用專案的 design system tokens 替換 Tailwind utility classes
- 複用既有元件（buttons、inputs、typography、icon wrappers），禁止重複實作
- 一致使用專案的 color system、typography scale、spacing tokens
- 遵循專案既有的 routing、state management、data-fetch patterns

### Step 6: Achieve 1:1 Visual Parity

- 優先 Figma 保真度，精確匹配設計
- 避免 hardcoded values — 使用 design tokens
- 當 design system tokens 與 Figma 值衝突時，偏好 design system tokens 但微調 spacing/size 以維持視覺一致
- 遵循 WCAG 無障礙要求

### Step 7: Validate Against Figma

完成前驗證最終 UI 與 Figma 截圖的一致性：

- [ ] Layout 匹配（spacing、alignment、sizing）
- [ ] Typography 匹配（font、size、weight、line height）
- [ ] Colors 精確匹配
- [ ] Interactive states 正常運作（hover、active、disabled）
- [ ] Responsive behavior 符合 Figma constraints
- [ ] Assets 正確渲染
- [ ] Accessibility standards 達標

## Implementation Rules

### Component Organization

- UI 元件放在專案指定的 design system 目錄
- 遵循專案的元件命名慣例
- 避免 inline styles，除非是 dynamic values 真正需要

### Design System Integration

- **ALWAYS** 優先使用專案 design system 的既有元件
- 將 Figma design tokens 映射到專案 design tokens
- 既有元件存在時，擴展它而非新建
- 新增元件時補充文件

### Code Quality

- 避免 hardcoded values — 抽取為 constants 或 design tokens
- 元件保持 composable 和 reusable
- 加入 TypeScript types for component props
- exported 元件加入 JSDoc comments

## Advanced: Fidelity-Adaptive Mode

當輸入來源不確定保真度時（PM 草圖、wireframe、外部設計師的不完整規格），載入 `references/fidelity-adaptive.md` 以啟用：

- **保真度自動偵測**（HIGH-FI / MID-FI / LO-FI）
- **自主決策邊界**（信心分級 + 暫停請示機制）
- **Token 智能映射決策樹**（精確匹配 → 語意近似 → 先例推斷）
- **LO-FI 意圖提取模式**（草圖 → codebase 元件的直覺映射）
- **自我驗證迴圈**（5 維審查 checklist）
- **結構化輸出格式**（映射報告 + 決策點）

## Examples

### Example 1: Implementing a Button Component

User: "Implement this Figma button: https://figma.com/design/kL9xQn2VwM8pYrTb4ZcHjF/DesignSystem?node-id=42-15"

1. Parse URL → fileKey=`kL9xQn2VwM8pYrTb4ZcHjF`, nodeId=`42-15`
2. `get_design_context(fileKey="kL9xQn2VwM8pYrTb4ZcHjF", nodeId="42-15")`
3. `get_screenshot(fileKey="kL9xQn2VwM8pYrTb4ZcHjF", nodeId="42-15")`
4. Download button icons from assets endpoint
5. Check existing button component → extend with new variant or create
6. Map Figma colors to project design tokens
7. Validate against screenshot

### Example 2: Building a Dashboard Layout

User: "Build this dashboard: https://figma.com/design/pR8mNv5KqXzGwY2JtCfL4D/Dashboard?node-id=10-5"

1. Parse URL → fileKey=`pR8mNv5KqXzGwY2JtCfL4D`, nodeId=`10-5`
2. `get_metadata` to understand page structure
3. Identify main sections and their child node IDs
4. `get_design_context` for each major section
5. `get_screenshot` for full page
6. Download all assets
7. Build layout using project's layout primitives
8. Implement each section using existing components
9. Validate responsive behavior

## Best Practices

- **Always Start with Context** — 禁止基於假設實作，必須先 `get_design_context` + `get_screenshot`
- **Incremental Validation** — 實作過程中頻繁驗證，而非最後才驗證
- **Document Deviations** — 因無障礙或技術限制偏離設計時，記錄原因
- **Reuse Over Recreation** — 建新元件前必須先檢查既有元件
- **Design System First** — 不確定時偏好專案 design system patterns

## Common Issues

| 問題 | 原因 | 解法 |
|------|------|------|
| Figma 輸出截斷 | 設計過於複雜 | 用 `get_metadata` 取結構，再逐一 `get_design_context` |
| 實作與設計不匹配 | 視覺差異 | 與 Step 3 截圖逐項比對 spacing、colors、typography |
| Assets 無法載入 | MCP assets endpoint 不可存取 | 確認 `localhost` URL 直接使用，不修改 |
| Design token 值與 Figma 不同 | 專案 tokens 與 Figma 值不一致 | 偏好專案 tokens，微調 spacing/sizing 維持視覺保真 |

## References

- `references/figma-tools-and-prompts.md` — 工具目錄 + prompt 範例
- `references/fidelity-adaptive.md` — 保真度自適應模式（LO-FI 草圖 → 生產程式碼）

## Additional Resources

- [Figma MCP Server Documentation](https://developers.figma.com/docs/figma-mcp-server/)
- [Figma MCP Server Tools and Prompts](https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/)
- [Figma Variables and Design Tokens](https://help.figma.com/hc/en-us/articles/15339657135383-Guide-to-variables-in-Figma)
