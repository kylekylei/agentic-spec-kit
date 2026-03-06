---
name: pencil
description: Pencil 設計工具整合 — Design Token 產生/同步/綁定、.pen 檔案操作（透過 Pencil MCP）。Use when generating, syncing, or binding design tokens with Pencil, or operating on .pen files.
---

# Pencil

Pencil 設計工具整合，透過 Pencil MCP 操作 `.pen` 檔案。目前支援 Design Token 管理，未來可擴展至 component 操作、theme 管理等。

> **核心規則**：`.pen` 檔案為加密格式 — **禁止**直接讀寫，必須透過 Pencil MCP 工具操作。

## 操作路由

| 使用者意圖 | 載入的 reference |
|-----------|----------------|
| 產生 tokens / 同步 tokens 到 .pen | `references/generate.md` |
| 綁定 tokens / 替換 hardcoded 值 | `references/bind.md` |

## 共用規則

- **禁止**直接讀寫 `.pen` 檔（加密格式），必須透過 Pencil MCP 工具操作
- tokens 更新後，若組件已有變數綁定，Pencil 會自動以新數值解析，無需重新綁定
- 若失敗，檢查 `tailwind.config.js` 格式與 Pencil MCP 連線狀態
- 詳細規則見 `.cursor/rules/pencil-rules.mdc`

## References

- `references/generate.md` — Token 產生與同步（Tailwind → .pen）
- `references/bind.md` — Token 綁定（hardcoded → $variable）
- [.pen Format Reference](https://docs.pencil.dev/for-developers/the-pen-format) — .pen 底層格式（僅 debug 用）
