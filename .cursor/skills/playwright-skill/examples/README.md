# Playwright Skill - Test Examples

這個目錄包含預建的測試腳本，用於 生成工作流程的驗證階段。

## 📋 可用的測試腳本

### 1. 無障礙測試 (a11y-test.js)

使用 **@axe-core/playwright** 進行 WCAG 2.0/2.2 合規性檢查。

**用途：**
- 檢測無障礙違規項目
- 驗證 WCAG 2.0 Level A/AA 標準
- 驗證 WCAG 2.2 Level AA 標準
- 提供詳細的違規報告和修復建議

**執行：**

```bash
# 基本用法
cd .cursor/skills/playwright-skill && node run.js examples/a11y-test.js

# 使用環境變數
TARGET_URL=http://localhost:5173 BEAD_ID=bead-001 \
  cd .cursor/skills/playwright-skill && node run.js examples/a11y-test.js
```

**環境變數：**
- `TARGET_URL` - 要測試的 URL（預設：http://localhost:5173）
- `BEAD_ID` - 當前 Bead ID，用於報告（預設：unknown）

**輸出：**
- ✅ 通過的規則數量
- ⚠️ 需要人工確認的項目
- ❌ 違規項目的詳細列表，包括：
  - 影響等級（critical, serious, moderate, minor）
  - 規則 ID 和說明
  - 受影響的 DOM 元素
  - 修復建議的連結

**退出碼：**
- `0` - 無違規，測試通過
- `1` - 有違規或發生錯誤

---

### 2. 視覺回歸測試 (screenshot-test.js)

捕獲全頁截圖並進行基線比對，同時測試響應式設計。

**用途：**
- 捕獲不同視窗大小的截圖
- 建立和比對視覺基線
- 檢測意外的視覺變化
- 測試響應式設計（mobile, tablet, desktop）

**執行：**

```bash
# 基本用法
cd .cursor/skills/playwright-skill && node run.js examples/screenshot-test.js

# 使用環境變數
TARGET_URL=http://localhost:5173 BEAD_ID=bead-001 \
  cd .cursor/skills/playwright-skill && node run.js examples/screenshot-test.js
```

**環境變數：**
- `TARGET_URL` - 要測試的 URL（預設：http://localhost:5173）
- `BEAD_ID` - Bead ID，用於檔案命名（預設：bead-unknown）
- `SNAPSHOT_DIR` - 截圖儲存目錄（預設：.teammate/snapshots）

**輸出檔案：**
```
.teammate/snapshots/
├── bead-001-baseline.png    # 基線截圖（首次自動建立）
├── bead-001-current.png     # 當前截圖
├── bead-001-mobile.png      # 行動裝置視圖 (375x667)
├── bead-001-tablet.png      # 平板視圖 (768x1024)
└── bead-001-desktop.png     # 桌面視圖 (1920x1080)
```

**首次執行：**
- 自動建立 `baseline.png` 作為基準
- 顯示訊息：「FIRST RUN - BASELINE CREATED」

**後續執行：**
- 比對 `current.png` 與 `baseline.png`
- 顯示檔案大小差異百分比
- 如果差異 > 10%，顯示警告

**退出碼：**
- `0` - 截圖成功
- `1` - 發生錯誤

---

## 🔧 設置

**首次使用需要安裝依賴：**

```bash
cd .cursor/skills/playwright-skill
npm install
```

這將安裝：
- `playwright` - 瀏覽器自動化框架
- `@axe-core/playwright` - 無障礙測試集成

**安裝瀏覽器：**

```bash
cd .cursor/skills/playwright-skill
npm run setup
```

這將安裝 Chromium 瀏覽器。

---

## 📖 在 生成工作流程中使用

這些腳本已整合到 `/code validate` 命令中。參見 `.cursor/commands/code.md` 的「Phase 2: 驗證」部分。

**典型的驗證流程：**

```bash
# 1. 啟動開發伺服器
npm run dev

# 2. 執行 TypeScript 檢查
npm run check

# 3. 執行無障礙測試
TARGET_URL=http://localhost:5173 BEAD_ID=bead-001 \
  cd .cursor/skills/playwright-skill && node run.js examples/a11y-test.js

# 4. 執行視覺回歸測試
TARGET_URL=http://localhost:5173 BEAD_ID=bead-001 \
  cd .cursor/skills/playwright-skill && node run.js examples/screenshot-test.js
```

---

## 🎯 最佳實踐

1. **使用環境變數** - 讓腳本可重用，避免硬編碼
2. **保持基線更新** - 當有意圖的視覺變更時，更新基線截圖
3. **檢視違規詳情** - 無障礙測試提供的連結包含修復指南
4. **響應式測試** - 確保在所有視窗大小下都能正常運作
5. **可見模式** - 預設使用 `headless: false` 方便除錯

---

## 🔍 自定義測試

如果需要更複雜的測試場景，可以：

1. 複製現有的範例腳本
2. 修改以符合您的需求
3. 儲存到 `/tmp/` 目錄
4. 使用 `node run.js /tmp/your-script.js` 執行

參見 `SKILL.md` 和 `API_REFERENCE.md` 了解更多 Playwright API 用法。

---

## 📚 相關文件

- [SKILL.md](../SKILL.md) - Playwright Skill 完整使用指南
- [API_REFERENCE.md](../API_REFERENCE.md) - Playwright API 參考
- [code.md](../../commands/code.md) - 生成工作流程文件
- [@axe-core/playwright 文件](https://github.com/dequelabs/axe-core-npm/tree/develop/packages/playwright)
- [Playwright 官方文件](https://playwright.dev/)
