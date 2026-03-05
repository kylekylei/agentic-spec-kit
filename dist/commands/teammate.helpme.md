---
description: 你的 AI 隊友導航員 — 即時取得下一步建議，或使用內建工具（healthcheck、consult、migrate、assign）。
handoffs:
  - label: 執行 Foundation
    agent: teammate.init
    prompt: "helpme 偵測到 Foundation 產物缺失或不完整"
    send: true
  - label: 開始 Align
    agent: teammate.align
    prompt: "helpme 建議開始功能對齊"
    send: true
  - label: 執行 Plan
    agent: teammate.plan
    prompt: "helpme 建議產生計畫"
    send: true
  - label: 開始 Execute
    agent: teammate.execute
    prompt: "helpme 建議開始實作"
    send: true
  - label: 執行 Review
    agent: teammate.review
    prompt: "helpme 建議執行審查"
    send: true
---

## 使用者輸入

```text
$ARGUMENTS
```

若使用者輸入非空，**必須**先考量其內容再繼續。

## Parameter Routing

解析 `$ARGUMENTS` 的第一個詞：

| 參數 | 功能 | 執行方式 |
|------|------|---------|
| （空）| 🧭 智慧導航 | 讀取 `teammate/references/navigation` skill 並執行 |
| `healthcheck` | 工作流程健康診斷 | 讀取 `teammate/references/healthcheck` skill 並執行 |
| `consult [問題]` | 流程問診 | 讀取 `teammate/references/consult` skill 並執行 |
| `migrate` | 版本遷移 | 讀取 `teammate/references/migrate` skill 並執行 |
| `assign` | 將 Actions 轉為 GitHub Issues | 讀取 `teammate/references/assign` skill 並執行 |
