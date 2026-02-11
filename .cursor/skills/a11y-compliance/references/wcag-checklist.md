# WCAG 2.2 AA Compliance Checklist

## 1. Perceivable (可感知)

- [ ] **1.1.1 Non-text Content (A)**: Images, controls have text alternatives
- [ ] **1.2.1 Audio-only/Video-only (A)**: Transcripts provided
- [ ] **1.2.2 Captions Prerecorded (A)**: Captions for audio content
- [ ] **1.2.3 Audio Description (A)**: Audio description for video
- [ ] **1.2.4 Captions Live (AA)**: Captions for live audio
- [ ] **1.2.5 Audio Description Prerecorded (AA)**: Audio description for video
- [ ] **1.3.1 Info and Relationships (A)**: Semantic headings (H1-H6), lists, landmarks
- [ ] **1.3.2 Meaningful Sequence (A)**: DOM order matches visual order
- [ ] **1.3.3 Sensory Characteristics (A)**: Not relying on shape/size/location
- [ ] **1.3.4 Orientation (AA)**: Works in portrait and landscape
- [ ] **1.3.5 Identify Input Purpose (AA)**: Correct `autocomplete` attributes
- [ ] **1.4.1 Use of Color (A)**: Color not sole means of conveying info
- [ ] **1.4.2 Audio Control (A)**: Audio >3s can be paused/stopped
- [ ] **1.4.3 Contrast Minimum (AA)**: 4.5:1 for text, 3:1 for large text
- [ ] **1.4.4 Resize Text (AA)**: 200% zoom without content loss
- [ ] **1.4.5 Images of Text (AA)**: Use actual text, not images
- [ ] **1.4.10 Reflow (AA)**: No horizontal scroll at 320px width
- [ ] **1.4.11 Non-text Contrast (AA)**: 3:1 for UI components/graphics
- [ ] **1.4.12 Text Spacing (AA)**: No content loss with increased spacing
- [ ] **1.4.13 Content on Hover/Focus (AA)**: Dismissible, hoverable, persistent

## 2. Operable (可操作)

- [ ] **2.1.1 Keyboard (A)**: All functionality keyboard accessible
- [ ] **2.1.2 No Keyboard Trap (A)**: Focus can move away from all components
- [ ] **2.1.4 Character Key Shortcuts (A)**: Can disable/remap single-key shortcuts
- [ ] **2.2.1 Timing Adjustable (A)**: Time limits can be adjusted
- [ ] **2.2.2 Pause, Stop, Hide (A)**: Moving content >5s can be paused
- [ ] **2.3.1 Three Flashes (A)**: No content flashes >3 times/second
- [ ] **2.4.1 Bypass Blocks (A)**: Skip link provided
- [ ] **2.4.2 Page Titled (A)**: Unique, descriptive `<title>`
- [ ] **2.4.3 Focus Order (A)**: Logical and intuitive
- [ ] **2.4.4 Link Purpose (A)**: Link text describes purpose
- [ ] **2.4.5 Multiple Ways (AA)**: Multiple ways to locate pages
- [ ] **2.4.6 Headings and Labels (AA)**: Descriptive headings/labels
- [ ] **2.4.7 Focus Visible (AA)**: Visible focus indicator
- [ ] **2.5.1 Pointer Gestures (A)**: No multi-point gestures required
- [ ] **2.5.2 Pointer Cancellation (A)**: Actions trigger on "up" event
- [ ] **2.5.3 Label in Name (A)**: Accessible name matches visible label
- [ ] **2.5.4 Motion Actuation (A)**: Motion features can be disabled
- [ ] **2.5.7 Dragging Movements (AA)**: Single-pointer alternative for drag
- [ ] **2.5.8 Target Size (AA)**: 24×24 CSS pixels minimum

## 3. Understandable (可理解)

- [ ] **3.1.1 Language of Page (A)**: Valid `lang` attribute on `<html>`
- [ ] **3.1.2 Language of Parts (AA)**: Language changes marked with `lang`
- [ ] **3.2.1 On Focus (A)**: Focus doesn't trigger context change
- [ ] **3.2.2 On Input (A)**: Input doesn't trigger unexpected context change
- [ ] **3.2.3 Consistent Navigation (AA)**: Nav in same location/order
- [ ] **3.2.4 Consistent Identification (AA)**: Same functions look same
- [ ] **3.3.1 Error Identification (A)**: Errors described in text
- [ ] **3.3.2 Labels or Instructions (A)**: Clear labels, required fields marked
- [ ] **3.3.3 Error Suggestion (AA)**: Suggestions for fixing errors
- [ ] **3.3.4 Error Prevention (AA)**: Reversible/checked/confirmed for critical actions
- [ ] **3.3.7 Redundant Entry (A)**: Auto-populate previously entered info
- [ ] **3.3.8 Accessible Authentication (AA)**: No cognitive tests without alternative

## 4. Robust (穩健性)

- [ ] **4.1.2 Name, Role, Value (A)**: Correct ARIA roles/states
- [ ] **4.1.3 Status Messages (AA)**: Dynamic updates announced (`aria-live`)

---

## Taiwan MODA Supplement (政府無障礙檢測基準 2.2)

### 核心驗收規則

- [ ] **Mandate 1: 語系設定**: `<html lang="zh-Hant-TW">`
- [ ] **Mandate 2: 脈絡補全**: 禁止「更多」、「詳情」等含糊連結，須補全上下文
- [ ] **Mandate 3: 焦點可視**: 禁止 `outline: none`，須提供高對比 `:focus-visible`
- [ ] **Mandate 4: 頁面結構**: 僅一個 `<h1>`，標題層級不得跳級
- [ ] **Mandate 5: 跳過導覽**: 頁面頂部須提供「跳至主要內容」連結

### 標案驗收檢查要點

- [ ] **200% 縮放**: 文字不重疊、版面不崩潰、無不必要水平捲動
- [ ] **全鍵盤操作**: 所有互動流皆可透過鍵盤完成
- [ ] **表單關聯性**: 所有 `input` 須有對應 `<label>`
- [ ] **文件替代**: 避免純 PDF，應提供 HTML 版本
