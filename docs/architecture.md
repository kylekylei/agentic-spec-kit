# Architecture

## Source / Consumer 分發模型

```
Source (agentic-spec-kit)              Consumer Project
├── templates/                      ├── .cursor/ | .claude/ | .agent/
│   ├── commands/  ──sync──→        │   ├── commands/
│   ├── rules/     ──sync──→        │   ├── rules/
│   ├── skills/    ──sync──→        │   ├── skills/
│   └── agents/    ──sync──→        │   └── agents/
├── scripts/bash/  ──sync──→        │   └── skills/speckit/scripts/bash/
├── templates/*.md ──sync──→        ├── .specify/templates/
└── speckit-sync.sh                 └── .specify/
                                        └── config/speckit.yml
```

## 四層架構

| 層 | 位置 | 用途 | 載入時機 |
|----|------|------|---------|
| **Rules** | `templates/rules/*.mdc` | 永遠生效的約束 | 熱層（alwaysApply: true）或動態觸發 |
| **Commands** | `templates/commands/speckit.*.md` | 生命週期 SOP | 使用者明確呼叫 |
| **Skills** | `templates/skills/*/SKILL.md` | 領域知識 | 按需載入（溫層） |
| **Agents** | `templates/agents/*.md` | AI 角色 | 路由意圖時載入 |

## 三層記憶體

| 層 | 內容 | 載入方式 |
|----|------|---------|
| 熱層 | `speckit-rules.mdc`（≤80 行） | 每次對話自動載入 |
| 溫層 | SKILL.md、Agent files | 按觸發條件載入 |
| 冷層 | `references/`、`templates/` | 僅在 skill 內引用時讀取 |

## LLM 指令預算

前沿 LLM 穩定遵循 ~150 條指令。System prompt ~50 條，剩餘 ~100 條由 rules + skills + 使用者訊息共享。Context 使用率達 20-40% 即開始性能衰退。

設計原則：**最少 token、最高密度上下文。**
