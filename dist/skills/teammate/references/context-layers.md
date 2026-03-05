---
name: teammate/references/context-layers
description: Teammate 三層脈絡架構。System / Task / User 各層的內容、優先級與載入規則。
---

# 脈絡層級

每個指令載入 context 時，遵循三層架構。衝突時上層優先。

```
System Layer（系統層 — 跨 task 不變）:
  - principles.md          # 不可違反的原則
  - context.md             # 專案身份、技術棧、架構慣例
  - llm/agent-spec.md      # 產品 LLM Agent 規格（如有：角色定義、安全圍欄、System Prompt 邏輯）

Task Layer（任務層 — per task）:
  - spec.md                # WHAT: 要做什麼
  - plan.md                # HOW + STEPS: 技術架構 + 執行清單
  - scenarios/*.feature    # VERIFY: 驗證條件
  - insights.md            # LEARNED: 執行中學到的
  - contracts/ui/ui-spec.md  # UI: 組件規格（如有）

User Layer（使用者層 — 持久 + 即時）:
  - .cursorule             # 持久偏好（如存在）
  - $ARGUMENTS             # 即時輸入
  - handoffs               # 使用者選擇的下一步
```

> 載入優先級：System > Task > User。User Layer 影響 AI 的**溝通方式**，不影響**決策邏輯**。
