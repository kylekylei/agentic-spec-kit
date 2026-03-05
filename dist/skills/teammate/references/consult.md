---
name: teammate/references/consult
description: Teammate 流程問診。使用者描述指令異常或流程疑慮，AI 分析根因並產出改善提案，等待確認後執行。
---

# Consult

**定位**：流程問診 —— 使用者帶著問題來，AI 分析根因並給診斷和處方。  
**與 healthcheck 的差異**：healthcheck 是跑固定項目的自動體檢；consult 是使用者主訴的門診問診。  
**操作限制**：唯讀，不主動修改任何檔案；改善提案需使用者確認後才執行。

## 問診輸入範例

```
consult 執行 /teammate.review 後沒有發現 contracts/ui 的組件名稱與 spec 不一致，為什麼漏掉了？
consult tasks update 後 contracts/ui 沒有連帶更新，這是設計缺陷嗎？
consult 這個任務走簡化流程是否正確？
```

## 執行步驟

**Step 1: 載入 Context**
- Foundation：`context.md`、`principles.md`
- `progress.md`（當前階段）
- 當前任務的所有 artifact（如有）
- `PLAYBOOK.md`（歷史教訓）
- 問題涉及的 `teammate.*.md` 指令定義

**Step 2: 分析問題**

分類問題類型：指令設計問題 / 流程順序問題 / 職責邊界問題 / 效率問題 / 其他

**Step 3: 產出問診報告**

```markdown
# 🩺 Consult Report

**主訴**: [使用者的原始問題]
**分類**: [指令設計 / 流程順序 / 職責邊界 / 效率 / 其他]
**日期**: [Date]

## 觀察
[基於 artifact 和框架現狀的事實陳述]

## 診斷
[對照 Teammate 規範的判斷——問題出在哪裡？為什麼會這樣？]

## 處方（改善提案）
| # | 改善項目 | 影響範圍 | 建議動作 |
|---|---------|---------|---------|
| 1 | [具體改善] | [哪些檔案] | [對應命令或手動修改] |

## PLAYBOOK 回饋
[建議記錄到 PLAYBOOK.md 的教訓摘要，格式：日期 | 專案 | 教訓 | 改善]
```

**Step 4: 等待使用者確認**

| 使用者回應 | 行為 |
|-----------|------|
| 確認改善提案 | 執行修改 + 回饋到 `PLAYBOOK.md` |
| 只想記錄 | 僅寫入 `PLAYBOOK.md` |
| 否決 | 結束 |
