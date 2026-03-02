---
name: ai-compliance
description: AI Risk Compliance Expert for EU AI Act, US state AI laws, and South Korea AI Basic Act. Use when (1) building chatbot or conversational AI interfaces, (2) displaying AI-generated content, (3) implementing recommendation systems, (4) designing AI consent/opt-out flows, (5) adding human oversight controls to AI decisions, or (6) auditing AI-driven UI for regulatory compliance. Dynamically loaded — only active when project involves LLM/AI features.
---

# AI Risk Compliance Expert

Act as a Senior Product Compliance Specialist. Philosophy: "Transparency is not a burden — it's a trust infrastructure."

## Dynamic Detection

This skill is loaded **conditionally** based on project characteristics.

### Detection Signals

**Primary (context.md tech stack):**
- Keywords: AI, LLM, OpenAI, Anthropic, ChatBot, RAG, GPT, Claude, Gemini, conversational AI

**Secondary (codebase auto-detect):**
- Imports: `openai`, `anthropic`, `@ai-sdk`, `langchain`, `llamaindex`
- API routes: `/chat`, `/completion`, `/generate`, `/stream`
- UI patterns: chat components, streaming response displays, AI disclosure labels
- Config: system prompts, model configuration, AI feature flags
- Dependencies in package.json: `ai`, `openai`, `@anthropic-ai/sdk`, `@langchain/*`

**Result:**
- context.md has AI markers → load silently
- context.md missing but codebase detected → load + suggest: "偵測到 AI/LLM 相關代碼，已自動載入 ai-compliance skill。建議更新 context.md 標記。"
- Neither detected → do not load

## Quick Decision Guide

| Task | Action |
|------|--------|
| Building chatbot UI | Add AI disclosure label at first interaction |
| Displaying AI output | Add visible "AI Generated" label + machine-readable metadata |
| Long conversation (>3hr) | Add periodic AI reminder (CA SB 243) |
| AI-powered recommendation | Add "Why am I seeing this?" + non-personalized alternative |
| Consent for AI features | Equal visual prominence for Accept/Reject; granular per-feature |
| High-risk AI decision | Add override/stop button + confidence indicator |
| AI explains a decision | Design layered explanation (summary + expandable detail) |
| Generating synthetic media | Embed C2PA watermark + visible label |

## Compliance Rules with Code Examples

### RULE AI-001: Chatbot AI Disclosure
**法規**: EU AI Act Art. 50(1) | CA SB 243 | CO AI Act | TX HB 149
**嚴重度**: CRITICAL
**罰則**: CA $1,000/次私人訴訟 | EU AI Act 罰則

```tsx
// PASS: Clear AI disclosure at first interaction
<div className="chat-header">
  <span className="ai-badge" role="status" aria-label="AI assistant">
    🤖 AI 助手
  </span>
  <p className="ai-disclosure">
    您正在與 AI 系統互動，非真人客服。
    <button aria-expanded={showDetails} onClick={toggleDetails}>
      了解更多
    </button>
  </p>
</div>
```

```tsx
// FAIL: No disclosure — user assumes human
<div className="chat-header">
  <span>客服助手</span>  {/* No AI indication */}
</div>
```

**判定**: 首次互動前必須有清晰、不可遺漏的 AI 性質揭露。使用「AI」或「人工智慧」等明確用語。

---

### RULE AI-002: Periodic AI Reminder (Long Sessions)
**法規**: CA SB 243
**嚴重度**: HIGH
**罰則**: $1,000/次法定損害賠償

```tsx
// PASS: Reminder every 3 hours
const AI_REMINDER_INTERVAL = 3 * 60 * 60 * 1000; // 3 hours

useEffect(() => {
  const timer = setInterval(() => {
    showSystemMessage("提醒：您正在與 AI 系統互動，非真人。");
  }, AI_REMINDER_INTERVAL);
  return () => clearInterval(timer);
}, []);
```

```tsx
// FAIL: No reminder mechanism for long conversations
// (Users in 8-hour sessions never see another disclosure)
```

**判定**: 對話超過 3 小時必須自動插入 AI 性質提醒。

---

### RULE AI-003: AI-Generated Content Label
**法規**: EU AI Act Art. 50(2)(4) | CA AB 853/CAITA
**嚴重度**: CRITICAL
**罰則**: EU AI Act 罰則 | CA 執法

```tsx
// PASS: Visible label + machine-readable metadata
<article
  data-ai-generated="true"
  data-ai-model="gpt-4"
  data-ai-timestamp={new Date().toISOString()}
>
  <div className="ai-content-label" aria-label="AI generated content">
    <AiIcon aria-hidden="true" />
    <span>AI 生成內容</span>
    <Tooltip>此內容由 AI 模型生成，可能包含錯誤。</Tooltip>
  </div>
  <p>{generatedContent}</p>
</article>
```

```tsx
// FAIL: AI content displayed without any indication
<article>
  <p>{generatedContent}</p>  {/* No AI label, no metadata */}
</article>
```

**判定**: AI 產出內容必須同時具備 (1) 使用者可見標籤 (2) 機器可讀屬性標記。

---

### RULE AI-004: Consent Equal Prominence
**法規**: EU AI Act Art. 5(1)(a) | DSA Art. 25 | CCPA/CPRA
**嚴重度**: CRITICAL
**罰則**: €3,500 萬或全球營收 7%（操縱性設計）

```tsx
// PASS: Equal visual weight for Accept and Reject
<div className="consent-actions flex gap-4">
  <button className="btn btn-primary px-6 py-3">接受 AI 個人化</button>
  <button className="btn btn-primary px-6 py-3">拒絕 AI 個人化</button>
</div>
```

```tsx
// FAIL: Dark pattern — Accept is prominent, Reject is hidden
<div className="consent-actions">
  <button className="btn btn-primary btn-lg">接受</button>
  <a href="#" className="text-xs text-gray-400 underline">稍後再說</a>
</div>
```

**判定**: 同意與拒絕選項必須具有相同的視覺大小、顏色、位置顯著性。不得使用縮小、淡化、隱藏等手段弱化拒絕選項。

---

### RULE AI-005: Human Override for High-Risk AI
**法規**: EU AI Act Art. 14(4)
**嚴重度**: CRITICAL（高風險系統）
**罰則**: €1,500 萬或全球營收 3%

```tsx
// PASS: Override + stop + confidence indicator
<div className="ai-decision-panel">
  <div className="confidence-bar" aria-label={`AI confidence: ${confidence}%`}>
    <meter value={confidence} min={0} max={100} />
    <span>{confidence}% 信心度</span>
  </div>
  <p className="ai-recommendation">{recommendation}</p>
  <div className="human-controls flex gap-2">
    <button className="btn btn-warning" onClick={overrideDecision}>
      覆寫 AI 決策
    </button>
    <button className="btn btn-danger" onClick={emergencyStop}>
      緊急停止
    </button>
  </div>
  <p className="bias-warning" role="alert">
    ⚠️ 請獨立驗證此 AI 建議，避免自動化偏見。
  </p>
</div>
```

```tsx
// FAIL: AI decision with no override mechanism
<div className="ai-decision-panel">
  <p>系統已自動核准此申請。</p>
  {/* No override, no stop, no confidence indicator */}
</div>
```

**判定**: 高風險 AI 決策介面必須包含 (1) 覆寫按鈕 (2) 停止按鈕 (3) 信心指標 (4) 偏見警告。

---

### RULE AI-006: Recommendation Transparency
**法規**: EU DSA Art. 27, 38
**嚴重度**: HIGH
**罰則**: DSA 罰則

```tsx
// PASS: Explainable recommendation with non-personalized alternative
<div className="recommendation-item">
  <article>{recommendedContent}</article>
  <button
    aria-expanded={showExplanation}
    onClick={() => setShowExplanation(!showExplanation)}
  >
    為什麼看到這個？
  </button>
  {showExplanation && (
    <div className="explanation-panel">
      <p>此推薦基於：您的瀏覽歷史、類似使用者偏好。</p>
      <a href="/settings/recommendations">管理推薦設定</a>
    </div>
  )}
</div>

{/* Non-personalized alternative toggle */}
<label className="flex items-center gap-2">
  <input
    type="checkbox"
    checked={useChronological}
    onChange={togglePersonalization}
  />
  使用時間排序（非個人化）
</label>
```

```tsx
// FAIL: Black-box recommendation with no explanation or alternative
<div className="feed">
  {recommendations.map(item => <Card key={item.id} {...item} />)}
  {/* No "why", no settings, no non-personalized option */}
</div>
```

**判定**: 推薦系統必須 (1) 以通俗語言說明推薦參數 (2) 提供使用者調整控制 (3) 提供至少一個非個人化替代。

---

### RULE AI-007: Explainability Interface
**法規**: EU AI Act Art. 86 | GDPR Art. 22
**嚴重度**: HIGH（高風險系統）
**罰則**: GDPR 罰則

```tsx
// PASS: Layered explanation with appeal mechanism
<div className="ai-explanation">
  <h3>AI 決策說明</h3>
  <p className="summary">
    此決定基於您提供的收入資料與信用歷史。
  </p>
  <details>
    <summary>查看詳細因素</summary>
    <ul>
      <li>年收入：權重 40%</li>
      <li>信用分數：權重 30%</li>
      <li>還款歷史：權重 30%</li>
    </ul>
    <p>若您的信用分數高於 700，結果可能不同。</p>
  </details>
  <div className="appeal-actions">
    <button onClick={requestHumanReview}>申請人工審核</button>
    <button onClick={viewInputData}>查看 AI 使用的資料</button>
  </div>
</div>
```

```tsx
// FAIL: Opaque AI decision with no explanation
<div className="decision">
  <p>您的申請已被拒絕。</p>  {/* No why, no appeal */}
</div>
```

**判定**: 受 AI 決策影響的使用者有權獲得 (1) 簡短摘要 (2) 可展開的詳細因素 (3) 質疑/申訴機制 (4) 資料審查權。

---

### RULE AI-008: Granular AI Consent
**法規**: GDPR Art. 7 | CO AI Act | CA CCPA/CPRA
**嚴重度**: HIGH
**罰則**: GDPR 罰則 | CO $20,000/次

```tsx
// PASS: Per-feature consent with easy withdrawal
<div className="ai-consent-panel">
  <h3>AI 功能設定</h3>
  {aiFeatures.map(feature => (
    <label key={feature.id} className="flex items-center justify-between p-3">
      <div>
        <span className="font-medium">{feature.name}</span>
        <p className="text-sm text-gray-500">{feature.description}</p>
      </div>
      <input
        type="checkbox"
        checked={feature.enabled}
        onChange={() => toggleFeature(feature.id)}
        role="switch"
        aria-label={`${feature.enabled ? '停用' : '啟用'} ${feature.name}`}
      />
    </label>
  ))}
  <button onClick={disableAll} className="btn btn-secondary mt-4">
    全部停用
  </button>
</div>
```

```tsx
// FAIL: All-or-nothing AI consent buried in onboarding
<div className="onboarding-step-7">
  <input type="checkbox" checked={true} /> {/* Pre-checked! */}
  <span className="text-xs">我同意使用 AI 功能改善體驗</span>
</div>
```

**判定**: AI 同意必須 (1) 按功能粒度控制 (2) 不得預勾選 (3) 撤回與給予同等容易 (4) 尊重 Global Privacy Control 訊號。

## Lifecycle Integration Points

This skill provides compliance knowledge at different stages:

| Stage | Role | What to do |
|-------|------|------------|
| `/teammate.plan` | Remind | Flag AI compliance requirements in Architecture section |
| `/teammate.execute` | Guide | Load as Recommended context for AI-related actions |
| `/teammate.review` | Check | Verify compliance coverage in Pass D2 |
| `/teammate.audit` | Judge | 世界級產品體驗大師逐條 Pass/Fail 審計 |

## References

- [EU AI Act Full Text](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
- [Colorado AI Act (SB 24-205)](https://leg.colorado.gov/bills/sb24-205)
- [California SB 243](https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=202520260SB243)
- [NIST AI RMF](https://www.nist.gov/artificial-intelligence/risk-management-framework)
- Regulatory background: `docs/ai-compliance/regulations.md`
