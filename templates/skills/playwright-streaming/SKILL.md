---
name: "playwright-streaming"
description: "Use when the task requires capturing real-time streaming data flows — SSE, WebSocket, streaming UI mutations, or progressive rendering. Typical use cases: AI chat UI analysis, real-time dashboard inspection, live-updating feed recording."
---

# Streaming Capture Skill

Capture and reconstruct time-series data from streaming UIs (AI chat, real-time dashboards, live feeds) using Playwright. Produces structured timeline artifacts that screenshots alone cannot provide.

**This skill focuses on the data layer (network payloads + DOM timeline + derived metrics).** For visual-layer video recording, use the `playwright-recording` skill — the two are complementary and can run simultaneously.

```
playwright              (CLI foundation)
  ├── playwright-recording  (visual layer — .webm video)
  └── playwright-streaming   (data layer — SSE/WS/DOM timeline) ← you are here
```

## When to use

- Target UI uses **SSE / WebSocket / long-polling / fetch ReadableStream** for data transfer
- Need to capture **progressive rendering** (token-by-token, chunk-by-chunk)
- Need to measure **temporal metrics** (TTFT, TPS, render latency)
- Need to record **intermediate states** (thinking indicators, tool-use cards, loading skeletons)
- Need to reverse-engineer **streaming protocol format** (OpenAI-compatible, Anthropic, custom)

## Prerequisites

> **Skill dependency**: Load `playwright` skill first for `$PWCLI` setup.
> **Optional**: Load `playwright-recording` skill for simultaneous video capture.

```bash
export CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
export PWCLI="$CODEX_HOME/skills/playwright/scripts/playwright_cli.sh"
```

## Output structure

```
{capture_dir}/
├── streams/
│   ├── {session_id}-sse.jsonl          # SSE / fetch-stream payloads (line-delimited JSON)
│   └── {session_id}-ws.jsonl           # WebSocket frame payloads
├── mutations/
│   └── {session_id}-dom.jsonl          # DOM mutation timeline
├── screenshots/
│   └── frame-{NN}-{label}.png         # Key-frame snapshots (compatible with other commands)
├── metrics/
│   └── {session_id}-timing.json        # Derived temporal metrics
└── recordings/                         # (optional, via playwright-recording skill)
    └── {session_id}.webm
```

## Core workflow

### Step 1 — Initialize capture session

```bash
SESSION="{slug}-streaming"
mkdir -p "{capture_dir}/{streams,mutations,screenshots,metrics}"
```

**CRITICAL — injection timing決定成敗：**

| 框架類型 | fetch capture 方式 | 原因 |
|----------|-------------------|------|
| 傳統 MPA / jQuery | `eval` 在 page load 後注入 ✅ | fetch 在 global scope，可被覆寫 |
| **Vite / SvelteKit / Next.js / Nuxt** | **`addInitScript` 在 page load 前注入** ✅ | module scope 在 load 時已 capture fetch reference，事後 monkey-patch 無效 |

**判斷規則**：目標頁面有 `<script type="module">`、`_app.js`、`__next`、`__sveltekit` 任一特徵 → 必須用 `addInitScript`。

**`addInitScript` 方式**（scripted Playwright）：

```typescript
// 在 browser.newContext() 或 page.goto() 之前執行
await page.addInitScript(() => {
  // 所有攔截器在此注入 — 在任何 JS module 執行前已就位
  window.__streamLog = [];
  window.__wsLog = [];
  window.__domTimeline = [];

  // fetch monkey-patch（此時 module 尚未 capture reference）
  const origFetch = window.fetch;
  window.fetch = async function(...args) { /* ... */ };

  // WebSocket monkey-patch
  const OrigWS = window.WebSocket;
  window.WebSocket = function(url, protocols) { /* ... */ };
});

await page.goto(URL);  // 此後 module 載入時拿到的 fetch/WebSocket 已是被 patch 的版本
```

**`$PWCLI` CLI 模式**：CLI 不支援 `addInitScript`。對 Vite/SvelteKit 目標，需改用 scripted 模式（`npx tsx`）執行注入，或在 `page.goto()` 前透過 CDP `Page.addScriptToEvaluateOnNewDocument` 注入。

```bash
# CDP 方式（CLI session 內）
"$PWCLI" --session $SESSION cdp Page.addScriptToEvaluateOnNewDocument \
  '{"source": "window.__streamLog=[];const o=window.fetch;window.fetch=async(...a)=>{...};"}'
```

Open page（攔截器注入後再 open）:

```bash
"$PWCLI" --session $SESSION open "$URL" --headed
```

> **With video**: If `playwright-recording` skill is loaded, follow its `recordVideo` setup to capture `.webm` simultaneously. This skill does not manage video — it only manages data streams.

### Step 2 — Inject network interceptors

> **If target is Vite/SvelteKit/Next.js**: Use `addInitScript` from Step 1 above instead of `eval` here. Skip to Step 3.

Use `eval` for traditional MPAs to set up SSE and fetch stream interception at the page level:

```javascript
// Intercept SSE via EventSource monkey-patch
(() => {
  window.__streamLog = [];
  const OrigES = window.EventSource;
  window.EventSource = function(url, opts) {
    const es = new OrigES(url, opts);
    const origAddEL = es.addEventListener.bind(es);
    es.addEventListener = (type, fn, opts2) => {
      origAddEL(type, (event) => {
        window.__streamLog.push({
          t: Date.now(), source: 'sse', type,
          url, data: event.data?.slice(0, 4096)
        });
        fn(event);
      }, opts2);
    };
    es.onmessage = new Proxy(es.onmessage || (() => {}), {
      set(target, prop, value) {
        const orig = value;
        es['_onmessage'] = (event) => {
          window.__streamLog.push({
            t: Date.now(), source: 'sse', type: 'message',
            url, data: event.data?.slice(0, 4096)
          });
          orig(event);
        };
        return true;
      }
    });
    return es;
  };
})();
```

For `fetch` streaming (ReadableStream — most common in modern AI chat UIs):

```javascript
(() => {
  const origFetch = window.fetch;
  window.fetch = async function(...args) {
    const response = await origFetch.apply(this, args);
    const url = typeof args[0] === 'string' ? args[0] : args[0]?.url || '';
    const ct = response.headers.get('content-type') || '';

    // Only intercept streaming responses
    if (!ct.includes('text/event-stream') && !ct.includes('ndjson') && !ct.includes('stream'))
      return response;

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let chunks = [];

    const stream = new ReadableStream({
      async start(controller) {
        while (true) {
          const { done, value } = await reader.read();
          if (done) { controller.close(); break; }
          const text = decoder.decode(value, { stream: true });
          window.__streamLog.push({
            t: Date.now(), source: 'fetch-stream',
            url, chunk: text.slice(0, 4096)
          });
          chunks.push(text);
          controller.enqueue(value);
        }
      }
    });

    return new Response(stream, {
      headers: response.headers,
      status: response.status,
      statusText: response.statusText,
    });
  };
})();
```

### Step 3 — Inject WebSocket interceptor (via CDP)

When the target page uses WebSocket instead of SSE:

```javascript
// CDP-based WebSocket frame capture
// Execute via Playwright eval or CDP session
(() => {
  window.__wsLog = [];
  const OrigWS = window.WebSocket;
  window.WebSocket = function(url, protocols) {
    const ws = protocols ? new OrigWS(url, protocols) : new OrigWS(url);
    ws.addEventListener('message', (event) => {
      window.__wsLog.push({
        t: Date.now(), direction: 'recv',
        url, data: typeof event.data === 'string'
          ? event.data.slice(0, 4096) : '[binary]'
      });
    });
    const origSend = ws.send.bind(ws);
    ws.send = (data) => {
      window.__wsLog.push({
        t: Date.now(), direction: 'send',
        url, data: typeof data === 'string'
          ? data.slice(0, 4096) : '[binary]'
      });
      origSend(data);
    };
    return ws;
  };
})();
```

### Step 4 — Inject DOM mutation observer

```javascript
(() => {
  window.__domTimeline = [];
  const observer = new MutationObserver((mutations) => {
    for (const m of mutations) {
      if (m.type === 'childList' && m.addedNodes.length) {
        const added = [...m.addedNodes]
          .filter(n => n.nodeType === 1)
          .map(n => ({
            tag: n.tagName,
            cls: n.className?.toString().slice(0, 100),
            text: n.textContent?.slice(0, 200)
          }));
        if (added.length) {
          window.__domTimeline.push({
            t: Date.now(),
            target: m.target.className?.toString().slice(0, 80) || m.target.tagName,
            added
          });
        }
      }
      if (m.type === 'characterData') {
        window.__domTimeline.push({
          t: Date.now(),
          type: 'text_change',
          target: m.target.parentElement?.className?.toString().slice(0, 80),
          text: m.target.textContent?.slice(0, 200)
        });
      }
    }
  });

  // Auto-detect streaming container
  const candidates = [
    '[role="main"]', '.chat-container', '.messages', '.conversation',
    'main', '#app', '#root', '.content'
  ];
  let root = null;
  for (const sel of candidates) {
    root = document.querySelector(sel);
    if (root) break;
  }
  if (root) {
    observer.observe(root, { childList: true, subtree: true, characterData: true });
  }
})();
```

### Step 5 — Execute interaction & capture

Trigger the streaming interaction (e.g., send a chat message), then wait for completion:

```bash
# Interact
"$PWCLI" --session $SESSION snapshot
"$PWCLI" --session $SESSION fill {input_ref} "test prompt"
"$PWCLI" --session $SESSION click {send_ref}

# Wait for streaming to complete (poll DOM stability)
# Screenshot key frames during streaming
"$PWCLI" --session $SESSION screenshot --output "{capture_dir}/screenshots/frame-01-streaming.png"
sleep 2
"$PWCLI" --session $SESSION screenshot --output "{capture_dir}/screenshots/frame-02-mid.png"
# ... continue until response completes
"$PWCLI" --session $SESSION screenshot --output "{capture_dir}/screenshots/frame-03-complete.png"
```

### Step 6 — Harvest captured data

```javascript
// Harvest all captured data
const result = {
  streams: window.__streamLog || [],
  websockets: window.__wsLog || [],
  mutations: window.__domTimeline || [],
  harvested_at: Date.now()
};
JSON.stringify(result);
```

Write each category to its respective `.jsonl` file:

```bash
# Write to files — one JSON object per line
# streams → {capture_dir}/streams/{session_id}-sse.jsonl
# websockets → {capture_dir}/streams/{session_id}-ws.jsonl
# mutations → {capture_dir}/mutations/{session_id}-dom.jsonl
```

### Step 7 — Derive metrics

Parse the harvested data to compute:

```yaml
timing_metrics:
  session_id: "{session_id}"
  captured_at: "YYYY-MM-DDTHH:mm:ss"
  request:
    sent_at: "{timestamp}"            # User action timestamp
    url: "{endpoint}"
    method: "POST"
  response:
    ttft_ms: 0                        # Time to First Token (first stream chunk - request sent)
    ttlt_ms: 0                        # Time to Last Token (last chunk - request sent)
    total_chunks: 0                   # Number of SSE/WS frames received
    total_tokens_est: 0               # Estimated token count (chars / 4)
    tps: 0.0                          # Tokens per second
  phases:                             # Reconstructed from stream data
    - name: "thinking"
      start_ms: 0
      end_ms: 0
      duration_ms: 0
      content_preview: ""
    - name: "tool_use"
      start_ms: 0
      end_ms: 0
      duration_ms: 0
      tool_calls:
        - name: ""
          duration_ms: 0
    - name: "streaming"
      start_ms: 0
      end_ms: 0
      duration_ms: 0
      token_count_est: 0
  rendering:
    first_dom_mutation_ms: 0          # First DOM change - request sent
    mutation_count: 0                 # Total DOM mutations during response
    avg_mutation_interval_ms: 0       # Average gap between mutations
    render_lag_ms: 0                  # DOM mutation time - corresponding stream chunk time
  protocol:
    type: "sse | websocket | fetch-stream"
    endpoint: ""
    format: "openai-compatible | anthropic | custom"
    features:
      - "thinking_exposed"            # Thinking/reasoning visible in stream
      - "tool_use_inline"             # Tool calls sent as stream events
      - "citations"                   # Source references in stream
```

## Capture patterns

### Pattern A: AI Chat completion

```text
1. Inject all interceptors (Steps 2-4)
2. Locate input field + send button via snapshot
3. Fill prompt → click send
4. Poll: screenshot every 2s until DOM stabilizes (no new mutations for 3s)
5. Harvest → derive metrics
```

### Pattern B: Real-time dashboard / live feed

```text
1. Inject WS + DOM interceptors (Steps 3-4)
2. Open page → let data flow for observation window (30-60s)
3. Screenshot at intervals (every 5s)
4. Harvest → analyze update frequency + data volume
```

### Pattern C: Multi-turn conversation

```text
1. Inject all interceptors
2. For each turn:
   a. Send message → wait for response completion
   b. Screenshot final state
   c. Harvest turn data (append to cumulative log)
3. Derive per-turn metrics + cross-turn comparison
```

## Phase detection heuristics

When parsing SSE/fetch-stream payloads, detect AI response phases:

| Signal | Phase |
|--------|-------|
| `"type": "thinking"` or `<think>` tag in chunk | **thinking** |
| `"type": "tool_use"` or `function_call` in chunk | **tool_use** |
| `"type": "content_block_delta"` or `"choices"[0].delta.content` | **streaming** |
| `"type": "message_stop"` or `[DONE]` | **complete** |
| `data: {"thinking": ...}` | **thinking** (Anthropic format) |
| `data: {"content": ""}` with no text for > 500ms | **pause** (possible rate limit) |

## Guardrails

- **Payload truncation**: All captured data capped at 4096 chars per event to prevent memory overflow
- **Binary data**: WebSocket binary frames logged as `[binary]` with byte length, not decoded
- **Sensitive data**: Stream payloads may contain user-submitted prompts or personal data. Do not commit raw `.jsonl` to shared repos without review
- **Session isolation**: Each capture session gets a unique `{session_id}` to prevent file collision
- **Memory limit**: If `__streamLog` exceeds 10,000 entries, flush to file and reset
- **No mutation on target**: Interceptors are read-only observers. Never modify request/response payloads
