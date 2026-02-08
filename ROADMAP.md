# Teammate Roadmap

> 從 oReady 專案實戰驗證中萃取的改善計劃

---

## 已完成

### Simplified Flow 規則 (2026-02-08)

**來源**: oReady Feature 003 實作時發現 AI 跳過規劃直接動手

**改善**: 在 `teammate-rules.mdc` 新增 Simplified Flow 區段，定義：
- 簡化條件（單一模組、非行為變更、< 2 小時、不涉及 Principles）
- 最低要求（spec.md + tasks.md 必須存在）
- AI 必須明確告知使用者並等待確認

**狀態**: 已同步到 oReady 和 Teammate

### Handoffs 擴充 (2026-02-08)

**來源**: `/teammate.align update` 完成後缺少合理的下一步選項

**改善**: `teammate.align.md` 新增 3 個 handoffs：
- Update Tasks — 跳到 `/teammate.tasks update`
- Continue Editing Spec — 繼續修改 spec
- Skip to Execute — 簡化流程直接執行

**狀態**: 已同步到 oReady 和 Teammate

---

## 計劃中

### P1: install.sh 安裝腳本

**動機**: 讓 Teammate 可以一鍵安裝到任何專案，取代手動複製和 sync rule

**設計**:

```bash
# 在任何專案中安裝 Teammate
~/Developer/Teammate/install.sh

# 或指定路徑
~/Developer/Teammate/install.sh --target /path/to/project
```

**安裝內容** (複製到目標專案):
- `.teammate/templates/` — 文件模板
- `.teammate/scripts/` — 自動化腳本
- `.teammate/config/` — 設定檔
- `.cursor/commands/teammate.*.md` — Cursor 指令
- `.cursor/rules/teammate-rules.mdc` — AI 工作規範

**不覆蓋** (專案私有):
- `.teammate/memory/` — 專案上下文、原則、進度
- `.teammate/snapshots/` — 快照
- `features/` — Feature 工作目錄
- `.cursor/rules/` 中非 teammate 的規則

**更新模式**:
```bash
~/Developer/Teammate/install.sh --update  # 只更新框架檔案，不動專案內容
```

**驗收標準**:
- 新專案安裝後可立即執行 `/teammate.kickoff`
- 已有專案更新後不影響既有 memory 和 features
- 安裝後自動印出版本和可用指令清單

---

### P2: 版本管理

**動機**: 不同專案可能需要不同版本的 Teammate

**設計**:
- `teammate.yml` 加入 `version` 欄位
- `install.sh` 支援 `--version v1.2.0`
- Git tag 標記每個穩定版本

---

### P3: Backtest Report 標準化

**動機**: 從 oReady 的回測流程中發現，每次回測後的復盤報告應該是框架級功能，不只是單一專案的 rule

**設計**:
- 在 `.teammate/templates/` 加入 `backtest-report-template.md`
- 讓回測報告模板可跨專案複用
- 報告結構：數據來源 → 策略說明 → 結果 → 復盤 → 改善計劃

**考量**: 目前是 oReady 的 `.cursor/rules/backtest_rules.mdc`，如果其他專案也需要類似的「迭代報告」機制，可以泛化為 Teammate 的 iteration-report 模板

---

### P4: 多專案同步機制

**動機**: 在 oReady 實戰中用 `teammatesync_rule.mdc` 讓 AI 同步兩個 repo，但這依賴 AI 記得

**方案評估**:

| 方案 | 即時同步 | 複雜度 | 適合場景 |
|------|---------|--------|---------|
| Sync Rule (目前) | 靠 AI | 低 | 1-2 個專案，單人 |
| Symlink | 即時 | 中 | 單機多專案，不需 git 追蹤 |
| install.sh (P1) | 手動 | 低 | 正式發佈，多人 |
| Git Submodule | 手動 | 高 | 多人協作，版本嚴格控制 |

**建議路線**: Sync Rule → install.sh → Submodule（依使用規模遞進）

---

## 從實戰中學到的教訓

> 所有使用 Teammate 的專案都會將學到的教訓回饋到此表。這是跨專案的中心化記憶。

| 日期 | 專案 | 教訓 | 改善 |
|------|------|------|------|
| 2026-02-08 | oReady | AI 跳過規劃直接動手，缺少 spec.md | 新增 Simplified Flow 規則 |
| 2026-02-08 | oReady | `/teammate.align update` 完成後沒有合理的下一步選項 | 擴充 handoffs |
| 2026-02-08 | oReady | 修改 teammate 規則後忘記同步到 Teammate repo | 建立 `teammatesync_rule.mdc` |
| 2026-02-08 | oReady | 回測後缺少結構化復盤 | 建立 `backtest_rules.mdc` |
| 2026-02-08 | oReady | spec.md 和 tasks.md 的差異不明確 | README 補充說明表格 |
| 2026-02-08 | oReady | 不同專案的改善需要中心化記憶 | `teammatesync_rule.mdc` 加入 ROADMAP 回饋機制 |
| 2026-02-08 | oReady | AI 完成指令後沒有主動提供下一步選項，使用者需要自己記得流程 | `teammate-rules.mdc` 新增「主動提供下一步選項」規則，以 [A][B][C][D] 格式列出 |

---

**Last Updated**: 2026-02-08
