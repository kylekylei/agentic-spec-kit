---
name: speckit/references/filesystem
description: 關鍵路徑與檔案結構。.specify/ 目錄樹、specs/ 產物結構、docs/ 慣例。
---

# 關鍵路徑

```
.specify/
├── memory/
│   ├── context.md            # 唯一溫層：專案身份、技術棧 + § Principles + § Current
│   └── principles.md         # 冷層：完整版原則（MUST / MUST NOT），僅 init/review 讀取
├── llm/                      # LLM 系統層（跨角色：PM / 設計師 / 開發者共同維護）
│   ├── agent-spec.md         # 產品 LLM Agent 規格（角色定義、安全圍欄、System Prompt 邏輯）
│   └── README.md             # LLM 層說明與邊界定義
├── design/                   # 視覺設計資產（設計師控管）
│   ├── figma-index.md        # Figma 專案與功能頁面連結
│   └── pencil/               # Pencil 設計稿（.pen 文件）
├── snapshots/                # 決策與計畫變更快照
├── templates/                # 文件模板
└── config/speckit.yml        # 生命週期設定（含版本欄位）

skills/speckit/scripts/bash/  # 自動化腳本（由 Source 同步）
├── check-foundation.sh       # Foundation 驗證
���── check-prerequisites.sh    # Spec prerequisites 檢查
├── create-new-spec.sh        # Spec 目錄建立
├── detect-system-scope.sh    # System scope 偵測
├── load-execution-context.sh # 執行脈絡載入
└── common.sh                 # 共用函式

CHANGELOG.md                  # 版本發行紀錄（供 /speckit.sync 遷移模式解析）

docs/                         # 外部參考知識庫（選用）
├── llms.txt                  # 參考索引（llms.txt 標準）
└── [library-name]/
    ├── llms.txt
    └── api-reference.md

specs/[###-spec-name]/        # 各任務產物
├── spec.md                   # /speckit.align 產出（規格）
├── example-mapping.md        # /speckit.align 產出（範例）
├── scenarios/*.feature       # /speckit.plan 產出（場景）
├── plan.md                   # /speckit.plan 產出（Part 1: 架構 + Part 2: 行動）
├── insights.md               # /speckit.execute REFLECT 產出（動態知識）
├── contracts/ui/ui-spec.md   # /speckit.plan 產出（UI 規格，自動觸發）
└── checklists/               # /speckit.review 產出（就緒報告）
```
