---
name: speckit/references/healthcheck
description: 工作流程健康診斷。執行 5 個 Pass 掃描 Foundation 完整性、階段合規、artifact 庫存、追溯骨架、Source 同步狀態，產出 Healthcheck Report。
---

# Healthcheck

**定位**：工作流程健康檢查 —— 驗證流程是否被正確遵循。  
**操作限制**：嚴格唯讀，不修改任何檔案。

## 階段 0：定位任務

1. 從 repo 根目錄執行 `check-prerequisites.sh --json --paths-only`，解析 `SPEC_DIR`
2. 若找不到 spec → 掃描 `specs/` 取得最近一個 spec 目錄
3. 若完全找不到任務 → 只執行 Pass 1（Foundation）和 Pass 5（Source Sync）

## Pass 1: Foundation Integrity

| 項目 | 檢查內容 |
|------|---------|
| `context.md` | 存在？有 `[ALL_CAPS_IDENTIFIER]` placeholder → CRITICAL；必要欄位（名稱/技術棧/使用者角色）是否填寫？§ Current 是否有值？ |
| `principles.md` | 存在？有 placeholder → CRITICAL；是否含至少一條 MUST/MUST NOT？ |
| `speckit.yml` | 存在？設定是否完整？ |

## Pass 2: Phase-Aware Artifact Inventory

依 `context.md` § Current 的 Phase 判斷哪些 artifact 應存在：

```
Foundation：context.md, principles.md
Align：     spec.md, example-mapping.md（簡化流程可省略）
Plan：      scenarios/*.feature, plan.md, contracts/ui/ui-spec.md
Execute：   checklists/*.md, 實作程式碼
```

Status 定義：`OK` / `MISSING`（HIGH/CRITICAL）/ `NOT YET`（尚未到該階段）/ `SKIPPED (simplified)`

## Pass 3: Phase Order Compliance

**3a. 建立時間序列** — 確認 `spec.md` ≤ `scenarios/*.feature` ≤ `plan.md`；`plan.md` 早於 `spec.md` → 可能跳過 Align

**3b. Active Context 一致性** — `context.md` § Current Phase 是否與實際 artifact 吻合？
- Phase: execute 但 `plan.md` 不存在 → CRITICAL
- Phase: align 但 `plan.md` 已存在 → 可能未更新 § Current

**3c. Simplified Flow 合規** — 最低要求：`spec.md` + `plan.md` 存在；仍需至少 unit test

## Pass 4: Traceability Chain（骨架）

追溯鏈：`spec.md (FR-xxx)` → `scenarios/*.feature (@tag)` → `plan.md Part 2 ([Verifies: @tag])`

快速檢查：
- 每個 FR-xxx 是否有對應 `@tag` 在 `.feature`？
- 每個 `.feature` 的 `@tag` 是否有 `[Verifies: @tag]` 在 `plan.md` Part 2？
- `plan.md` Part 2 的 action 是否都引用存在的 scenario tag？

> **分界**：Healthcheck 確認骨架存在；Review（Pass B1+E）負責語意完整性。

## Pass 5: Source Sync Status

若 `speckit.yml` 有 `source.url` 或 `speckitsync_rule.mdc` 存在，讀取 Source 來源，檢查：
- Source 路徑是否可讀？
- `speckit-rules.mdc` 與 Source 版本是否一致？
- `speckit.*.md` commands 與 Source 版本是否一致？

## 嚴重度分級

| 等級 | 條件 |
|------|------|
| CRITICAL | Foundation 有 placeholder 或缺失；Active Context 與實際狀態嚴重矛盾 |
| HIGH | 階段順序違反；當前階段必要 artifact 缺失；追溯鏈骨架斷裂 |
| MEDIUM | Active Context 未更新；Simplified Flow 未滿足最低要求 |
| LOW | Artifact 建立時間異常但內容存在；Source 微小差異 |

## 輸出格式

```markdown
# 🔍 Healthcheck Report

**Feature**: [Name]
**Scanned**: [Date]
**Current Phase**: [Foundation / Align / Plan / Execute / Review]
**Health**: [Healthy 🟢 / Needs Attention 🟡 / Issues Found 🔴]

## Foundation Status
| Item | Status | Detail |
|------|--------|--------|
| context.md | ✅/❌ | [OK / Has placeholders / Missing / § Current missing] |
| principles.md | ✅/❌ | ... |
| speckit.yml | ✅/❌ | ... |

## Phase-Aware Inventory
| Artifact | Phase | Required? | Exists? | Status |

## Phase Compliance
| Check | Result | Detail |
| 階段順序 | ✅/⚠️/❌ | ... |
| Active Context 一致性 | ✅/⚠️/❌ | ... |
| Simplified Flow 合規 | ✅/⚠️/N/A | ... |

## Traceability Chain（骨架）
| From | To | Linked? |

## Source Sync Status
| File | In Sync | Diff |

## Summary
- Critical: [N] / High: [N] / Medium: [N] / Low: [N]
- Source Sync: [OK / Out of Sync]

## Recommended Actions
1. [Prioritized fix actions]
```
