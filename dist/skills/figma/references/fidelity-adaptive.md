# Fidelity-Adaptive Mode（保真度自適應模式）

Figma 輸入不一定來自專業設計師。PM 草圖、wireframe、不完整的設計稿，只要專案有完善的 codebase，Agent 就應該能轉換為生產品質的輸出。Agent 的價值不在於「照抄設計」，而在於**理解意圖 + 補齊 codebase 知識**。

---

## 保真度偵測

在開始設計解讀前，**MUST** 先判斷輸入的保真度等級：

| 信號 | 判定為 |
|------|--------|
| 完整的 Figma Variables / Design Tokens 綁定 | `HIGH-FI`（高保真：設計師精稿） |
| 使用 Figma Component Instances + Auto Layout，但未綁 Variables | `MID-FI`（中保真：有設計意識但非完整規格） |
| Default 命名（Frame 1, Rectangle 3）、無 Auto Layout、manual positioning、無 Component 使用、顏色/間距不在任何標準 scale 上 | `LO-FI`（低保真：草圖/Wireframe） |

## 不同保真度的行為策略

```
HIGH-FI（設計師精稿）
┌─────────────────────────────────────────────────────────┐
│ 提取: 精確到每個 px 和 hex 值                             │
│ 映射: 精確匹配 → 近似吸收（嚴格決策樹）                    │
│ 自主: 標準自主邊界（HIGH/MEDIUM/LOW 信心分級）              │
│ 驗證: Pixel-level 精準度驗證                              │
│ 態度: 「設計師已做過決策，我忠實翻譯」                       │
└─────────────────────────────────────────────────────────┘

MID-FI（有設計意識但不完整）
┌─────────────────────────────────────────────────────────┐
│ 提取: 結構和佈局意圖 + 關鍵視覺方向                        │
│ 映射: 結構忠實 + 視覺值全面吸收到 codebase token            │
│ 自主: 擴大自主範圍（更多 HIGH 信心，減少暫停）               │
│ 驗證: 結構和佈局精準度，視覺細節以 codebase 為準             │
│ 態度: 「設計方向已定，我用 codebase 語言精修」               │
└─────────────────────────────────────────────────────────┘

LO-FI（PM 草圖 / Wireframe）
┌─────────────────────────────────────────────────────────┐
│ 提取: 佈局意圖 · 內容結構 · 元素種類 · 資訊層級            │
│ 映射: 完全由 codebase design system 驅動                  │
│ 自主: 最大自主權（幾乎全 HIGH 信心）                       │
│ 驗證: 功能和結構正確性，視覺品質由 codebase 保證             │
│ 態度: 「你告訴我要什麼，我用 codebase 的最佳實踐來實現」      │
└─────────────────────────────────────────────────────────┘
```

---

## LO-FI 意圖提取模式

當偵測到低保真輸入時，切換到意圖提取模式：

### 1. 提取意圖（Extract Intent）

忽略 Figma 精確數值，改為提取：

| 提取目標 | 從草圖中看 | 範例 |
|----------|-----------|------|
| **佈局結構** | 元素的空間關係和排列方式 | 「上方 header + 左側 sidebar + 主內容區」 |
| **內容層級** | 什麼是標題、描述、次要 | 「大字 = heading，小字 = body，灰字 = muted」 |
| **元素類型** | 矩形 = 卡片？按鈕？輸入框？ | 「有圓角矩形 + 文字 = Button」 |
| **重複模式** | 多個相似元素 = 列表/Grid？ | 「3 個平行的矩形 = 卡片列表」 |
| **互動暗示** | 文字內容暗示互動 | 「寫著 Submit 的矩形 = Submit Button」 |
| **資訊流向** | 從上到下？從左到右？ | 「表單 → 按鈕 = 填完提交的流程」 |

### 2. 映射到 Codebase（Map to Codebase）

```
草圖意圖                  →  Codebase 實作
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
矩形 + 「Submit」文字       →  <Button variant="primary">Submit</Button>
矩形 + 輸入提示文字         →  <Input placeholder="..." />
大矩形 + 內部有小元素       →  <Card><CardHeader>...<CardContent>...</Card>
多個平行矩形              →  Grid/Flex + map() 渲染既有 Card 元件
頁面頂部長條              →  既有 Header/Navbar 元件
左側窄長條                →  既有 Sidebar 元件
圓形 + 文字               →  <Avatar /> + <span>
小矩形 + 短文字            →  <Badge variant="...">
```

### 3. 全面套用 Codebase 風格

在 LO-FI 模式下，**所有視覺決策皆由 codebase 驅動**：

- **顏色**：完全使用 codebase 語意 token（primary、secondary、muted、destructive）
- **間距**：完全使用 codebase spacing scale（草圖中的間距只看「大/中/小」概念）
- **字體**：完全使用 codebase typography scale（草圖中的字體大小只看「標題/內文/輔助」層級）
- **圓角 / 陰影 / 邊框**：完全使用 codebase 既有元件的預設值
- **互動狀態**：完全沿用 codebase 既有元件的所有狀態

### 4. LO-FI 輸出報告

```
## 🎯 意圖解讀

輸入保真度: LO-FI（草圖/Wireframe）
策略: 提取佈局意圖 + 全面套用 codebase design system

### 意圖 → 實作映射
| 草圖元素 | 解讀意圖 | → Codebase 實作 |
|----------|---------|----------------|
| 頂部長條 + Logo 文字 | 導航列 | <Navbar /> (既有) |
| 3x 矩形 grid | 卡片列表 | <Card /> x3 in grid-cols-3 |
| 矩形 + 「Save」 | 儲存按鈕 | <Button variant="primary">Save</Button> |

### 設計決策（Agent 自主，by codebase）
- 顏色: 全部使用 codebase token（primary, muted, destructive）
- 間距: 全部使用 codebase spacing（gap-4, p-6, space-y-4）
- 圓角: 元件預設值（rounded-lg from Card, rounded-md from Button）

### 💬 意圖確認
- [若有不確定的意圖解讀，列出請使用者確認]
```

---

## 自主決策邊界（Autonomy Levels）

根據**信心等級**決定「自主執行」或「暫停請示」。信心閾值隨保真度動態調整。

### 自主執行（不暫停）

| 場景 | 條件 | HIGH-FI | MID-FI | LO-FI |
|------|------|---------|--------|-------|
| Token 精確匹配 | Figma 值 = Codebase token | `HIGH` | `HIGH` | — |
| Token 近似吸收 | 差距 ≤ 2px 或 ΔE ≤ 3 | `HIGH` | `HIGH` | — |
| 元件精確複用 | Figma 元素 = Codebase 既有元件 | `HIGH` | `HIGH` | `HIGH` |
| 兄弟元件先例 | 相同模式在 codebase 中已有 3+ 實例 | `HIGH` | `HIGH` | `HIGH` |
| 缺失的互動狀態 | Figma 未定義但 codebase 元件已有 | `HIGH` | `HIGH` | `HIGH` |
| 非 4 倍數間距 | 吸收到最近 scale 點 | `MEDIUM` | `HIGH` | — |
| 所有視覺值 | 全面套用 codebase token（LO-FI 專屬） | — | — | `HIGH` |
| 元素類型推斷 | 從草圖形狀推斷元件類型（LO-FI 專屬） | — | — | `HIGH` |

### 暫停請示（需使用者確認）

| 場景 | HIGH-FI | MID-FI | LO-FI |
|------|---------|--------|-------|
| 元件歧義（類似但不完全匹配） | `LOW` 暫停 | `LOW` 暫停 | `MEDIUM` 自主選最近 |
| 設計意圖衝突（Figma vs codebase 慣例） | `LOW` 暫停 | `MEDIUM` 偏 codebase | `HIGH` 用 codebase |
| 需新增元件（codebase 不存在） | `LOW` 暫停 | `LOW` 暫停 | `LOW` 暫停 |
| Token 大幅偏離（> 4px / ΔE > 5） | `LOW` 暫停 | `MEDIUM` 吸收 | — |
| 佈局意圖不明（無法判斷要什麼結構） | — | — | `LOW` 暫停 |
| 功能意圖不明（不確定元素要做什麼） | — | — | `LOW` 暫停 |

### 暫停請示格式

```
⚠️ 設計決策點 [#N]
━━━━━━━━━━━━━━━━
問題: [具體描述衝突或歧義]
Figma 意圖: [Figma 中的設計值/結構]
Codebase 慣例: [codebase 中的做法]
信心: LOW
建議:
  [A] [方案 A] — [一句話優缺點]
  [B] [方案 B] — [一句話優缺點]
```

---

## 設計解讀四層（Design Perception）

### 結構層

| 項目 | 必須確認 |
|------|----------|
| **佈局方向** | Auto Layout 方向（horizontal / vertical）、wrap 行為 |
| **間距** | Gap、Padding（上右下左分別多少？是否對稱？） |
| **對齊** | 主軸對齊（start / center / space-between）、交叉軸對齊 |
| **尺寸行為** | 每個子元素是 Hug / Fill / Fixed？寬高具體數值？ |
| **約束** | Min-width、Max-width、Aspect ratio |
| **層級** | 嵌套深度、層級結構是否對應 DOM 結構 |

### 視覺層（Pixel-Level Perception）

| 屬性 | 提取要點 |
|------|----------|
| **顏色** | 背景色、文字色、邊框色 — 精確到 hex/rgba |
| **字體** | font-family、font-size、font-weight、line-height、letter-spacing |
| **圓角** | border-radius — 每個角是否相同？ |
| **陰影** | box-shadow — x、y、blur、spread、color 精確值 |
| **邊框** | border-width、border-style、border-color |
| **透明度** | opacity、backdrop-filter |
| **間距** | margin、padding 精確到 px |
| **圖標** | 尺寸、顏色、stroke-width |

### 狀態層

對每個互動元素，確認 Figma 中定義了哪些狀態：

- Default / Hover / Active / Focus / Disabled / Loading / Error / Empty

若 Figma 缺少某些狀態：codebase 既有元件已有 → 直接沿用（`HIGH` 信心）；需全新設計 → 暫停請示。

### 響應式層

- 檢查 Figma 中是否有多個螢幕尺寸的設計
- 若無，從 codebase 既有響應式模式推斷適配方案（`MEDIUM` 信心，輸出中說明推斷依據）

---

## Token 智能映射決策樹

對每個 Figma 設計值，按優先順序決策：

```
精確匹配 → 語意近似（≤2px/ΔE≤3） → 組合表達 → 先例推斷 → 設計意圖判斷
```

- **語意優先**：Figma「主要按鈕藍」→ `primary`（不湊 hex）
- **近似吸收**：非 4 倍數間距（13px、15px）→ 吸收到最近 scale
- **禁止 hardcode**：codebase 有 token 時，禁止 raw hex/px

信心分級：
- `HIGH`：精確匹配、近似吸收、元件複用
- `MEDIUM`：組合表達、先例推斷
- `LOW`：需新建元件、token 大幅偏離（暫停請示）

## 元件智能映射

映射優先順序（對任何 Figma UI 元素）：

```
1. Codebase 既有元件（精確匹配 variant + props）     → 信心 HIGH
2. Codebase 既有元件（需新增 variant 或微調）          → 信心 MEDIUM
3. UI 庫元件（shadcn/ui、Radix 等，專案已安裝）       → 信心 MEDIUM
4. Composition（組合多個既有元件）                     → 信心 MEDIUM
5. 新建元件（確認 codebase 完全不存在）                → 信心 LOW，暫停請示
```

**禁止**：
- ❌ 用 `<div>` + 手寫樣式重建既有元件
- ❌ 忽略既有元件 variant，用 className 覆寫
- ❌ 複製元件程式碼而非 import

## 佈局映射

```
Figma Auto Layout     →  CSS
──────────────────────────────────
Horizontal + Gap 16   →  flex gap-4
Vertical + Gap 8      →  flex flex-col gap-2
Fill Container        →  flex-1 / w-full
Hug Contents          →  w-fit / w-auto
Space Between         →  justify-between
Wrap                  →  flex-wrap
```

---

## 自我驗證迴圈（Self-Verification）

### 寫碼前：映射完整性檢查

- [ ] 每個 Figma 視覺元素都有對應的 codebase token/元件映射
- [ ] 所有 `LOW` 信心決策已向使用者請示並獲得確認
- [ ] 互動狀態清單完整（缺失的已標註處理方式）

### 寫碼後：逐項自我審查

**Token 合規**：
- [ ] 零 hardcoded 顏色值
- [ ] 零 arbitrary spacing（除已標註的設計意圖例外）
- [ ] 零 arbitrary font-size / border-radius

**元件合規**：
- [ ] 未重複實作任何既有元件
- [ ] 使用正確的 variant 和 props
- [ ] import 路徑遵循專案慣例

**視覺精準度**：
- [ ] 間距、顏色、字體、圓角、陰影與 Figma 意圖一致
- [ ] 所有近似吸收的決策已在映射表中說明

**互動完整性**：
- [ ] Hover / Focus / Disabled 狀態已實作
- [ ] Transition 使用 150-300ms
- [ ] 可點擊元素有 cursor-pointer

**無障礙基線**：
- [ ] 語意化 HTML 標籤
- [ ] 圖片 alt text、表單 label、ARIA 屬性
- [ ] 鍵盤可操作

### 視覺驗證（當有 Browser 工具時）

若環境中可用 browser 工具，SHOULD 主動：

1. 在瀏覽器中載入實作結果
2. 截圖並與 Figma 設計做視覺比對
3. 檢查關鍵視覺指標（間距、對齊、顏色）
4. 若發現偏差 > 2px，自動修正

---

## Design System 回饋迴圈

發現設計系統缺口時，主動回饋改善建議：

| Gap 類型 | 行動 |
|----------|------|
| **缺失 Token** | Figma 反覆使用某值但 codebase 無對應 token → 建議新增 |
| **元件缺口** | Figma 需要的 UI 模式 codebase 沒有且預期會複用 → 建議建立 |
| **Variant 不足** | 既有元件缺少 Figma 需要的 variant → 建議擴展 API |

```
💡 發現 [數量] 個設計系統改善點
- 建議新增 token: [token 名稱] （原因：[出現次數/用途]）
- 建議擴展元件: [元件名稱].[variant] （原因：[需求]）
```

---

## 設計意圖不明時的處理協議

### 主動提出

1. **缺失狀態**：說明將沿用 codebase 既有狀態（`HIGH` 信心）或需要新設計（`LOW` → 暫停）
2. **Token 近似吸收**：主動報告所有非精確匹配的映射決策和理由
3. **色彩語意映射**：說明 Figma hex → codebase 語意 token 的推理過程
4. **元件歧義**：暫停請示，提供 [A]/[B] 選項
5. **響應式缺失**：說明從 codebase 推斷的適配方案
6. **互動行為不明**：暫停請示預期行為
7. **Figma 值與 codebase 衝突**：暫停請示，提供 [A]/[B] 選項

### 禁止行為

- ❌ 默默猜測設計意圖而不說明
- ❌ 忽略視覺差異而不在映射表記錄
- ❌ 用「差不多」心態跳過精確比對
- ❌ 未檢查 codebase 就新建元件
- ❌ 假設 Figma 設計錯誤而自行「修正」
- ❌ 照搬 Figma 原始 hex/px 值而不查看 codebase token
- ❌ 因為 Figma 值不在 scale 上就直接 arbitrary value

---

## 結構化輸出格式

啟用 Fidelity-Adaptive Mode 時，**必須**按以下結構報告：

```
## 🔍 Codebase 感知結果

**Design System**: [UI 庫名稱] | **Token 體系**: [顏色/間距/字體概要]
**可複用元件**: [元件列表 + 來源路徑]

## 🎯 設計映射

### Token 映射
| Figma 值 | → Token | 類型 | 信心 |
|----------|---------|------|------|
| ... | ... | 精確/近似/吸收 | HIGH/MEDIUM |

### 元件映射
| Figma 元素 | → Codebase 元件 | 信心 |
|-----------|----------------|------|
| ... | ... | HIGH/MEDIUM/LOW |

### 狀態覆蓋
| 元素 | Default | Hover | Focus | Disabled | 備註 |
|------|---------|-------|-------|----------|------|

## ⚠️ 設計決策點 [需確認]
[只在有 LOW 信心決策時出現]

## 💡 Design System 回饋
[只在發現 gap 時出現]
```

---

## Figma 設計品質檢查（前置）

在讀取 Figma 設計前，若設計來源為外部或未經驗證，可執行品質檢查（使用 `get_design_context` + `get_variable_defs`）：

### Critical 檢查項（必須 PASS）

- [ ] 所有顏色/間距使用 Variables（無 raw hex/hard-coded px）
- [ ] Frame 使用 Auto Layout（無無理由絕對定位）
- [ ] 互動元素為 Component + Variants（無 Detached Instance）

### 判定標準

- **READY**: 0 Critical → 繼續實作
- **NOT READY**: 任何 Critical → 回報設計師修正
- **NEEDS CLARIFICATION**: UNCLEAR INTENT → 列出不明確項
