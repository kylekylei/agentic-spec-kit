# A11y Regulatory Framework

> 法規背景與罰則速查。實作規則與代碼範例見 `.cursor/skills/a11y-compliance/SKILL.md`。

## 適用法規

| 法規 | 管轄權 | 生效日 | 標準 | 罰則 |
|------|--------|--------|------|------|
| Section 508 | 美國聯邦 | 已生效 | WCAG 2.1 AA | 聯邦採購禁止 + 訴訟 |
| ADA Title II | 美國 | 2026-04-24 | WCAG 2.1 AA | 私人訴訟 + DOJ 執法 |
| EAA (EN 301 549) | 歐盟 | 2025-06-28 | WCAG 2.1 AA | 罰款 + 市場限制 |
| EU AI Act Art. 50(5) | 歐盟 | 2026-08-02 | AI 揭露標籤須無障礙 | 同 AI Act 罰則 |

## 最嚴格共同基準

**WCAG 2.2 Level AA**（涵蓋所有上述法規要求）

### POUR 四原則摘要

**Perceivable（可感知）**
- 圖片必須有替代文字（alt text）
- 色彩對比：正常文字 4.5:1、大字 3:1、UI 元件 3:1
- 影片須有字幕與口述影像

**Operable（可操作）**
- 所有功能支援鍵盤操作
- 觸控目標：≥24x24px (AA)、≥44x44px (AAA)
- 可見焦點指示器（禁止 outline: none）

**Understandable（可理解）**
- 頁面語言標記（`<html lang="...">`）
- 表單有清晰提示與錯誤訊息
- 介面行為一致可預期

**Robust（穩健）**
- 使用語意化 HTML 標籤
- 螢幕閱讀器可正確解析

## 測試工具

| 類型 | 工具 |
|------|------|
| 自動化 | axe-core / axe DevTools / WAVE |
| 螢幕閱讀器 | NVDA (Win) / VoiceOver (Mac/iOS) / TalkBack (Android) |
| 合規報告 | VPAT (Voluntary Product Accessibility Template) |
