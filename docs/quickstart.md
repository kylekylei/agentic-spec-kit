# Quick Start

## 1. 安裝

```bash
git clone <source-url> ~/.speckit
~/.speckit/install.sh /path/to/your-project
```

## 2. 初始化

在 IDE 中開啟專案，執行：

```
/speckit.init
```

自動偵測專案技術棧、建立 Foundation 檔案（`state.md`）、選配 Skills。

## 3. 對齊需求

```
/speckit.align 使用者登入功能
```

產出 `spec.md`（含 Acceptance Criteria）。

## 4. 規劃

```
/speckit.plan
```

產出 `plan.md`（Architecture + Actions）。

## 5. 執行

```
/speckit.execute next
```

依 Actions 順序走 Test-First 實作迴圈。

## 6. 審查

```
/speckit.review
```

行為覆蓋分析 + 功能就緒關卡。可選產出 BDD Feature Files。
