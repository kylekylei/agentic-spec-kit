---
name: ai-review-pipeline
description: AI-powered multi-layered code review combining static analysis tools (SonarQube, CodeQL, Semgrep) with LLM-assisted contextual review. Use when setting up automated code review pipelines, performing comprehensive security/performance/architecture reviews, or integrating AI review into CI/CD.
---

# AI Review Pipeline

Comprehensive AI-powered code review combining automated static analysis, intelligent pattern recognition, and CI/CD integration.

## Review Workflow

### Initial Triage

1. Parse diff to determine modified files and affected components
2. Match file types to optimal static analysis tools
3. Scale analysis based on PR size (superficial >1000 lines, deep <200 lines)
4. Classify change type: feature, bug fix, refactoring, or breaking change

### Multi-Tool Static Analysis (Parallel)

- **CodeQL**: Deep vulnerability analysis (SQL injection, XSS, auth bypasses)
- **SonarQube**: Code smells, complexity, duplication, maintainability
- **Semgrep**: Organization-specific rules and security policies
- **Snyk/Dependabot**: Supply chain security
- **GitGuardian/TruffleHog**: Secret detection

### AI-Assisted Review

Context-aware review focusing on:
1. Security vulnerabilities missed by static tools
2. Performance implications at scale
3. Edge cases and error handling gaps
4. API contract compatibility
5. Testability and missing coverage
6. Architectural alignment

For each issue: file path, line numbers, severity (CRITICAL/HIGH/MEDIUM/LOW), explanation, concrete fix example, relevant documentation.

### Model Selection

- **Fast reviews (<200 lines)**: Lightweight model
- **Deep reasoning**: Full-capability model (200K+ tokens)
- **Multi-language**: Polyglot-capable model (30+ languages)

## Architecture Analysis

### Architectural Coherence

1. **Dependency Direction**: Inner layers don't depend on outer layers
2. **SOLID Principles**: SRP, OCP, LSP, ISP, DIP
3. **Anti-patterns**: Singleton abuse, God objects, anemic models, shotgun surgery

### Microservices Review

- Service cohesion (single capability per service)
- Data ownership (database per service)
- API versioning and backward compatibility
- Circuit breakers and resilience patterns
- Idempotency for duplicate event handling

## Security Vulnerability Detection

### Multi-Layered Security

**SAST Layer**: CodeQL, Semgrep, language-specific analyzers

**AI-Enhanced Threat Modeling**: Authentication bypass, broken access control, JWT validation flaws, session management, rate limiting, credential storage

**Secret Scanning**: Detect hardcoded API keys, tokens, passwords

### OWASP Top 10 Coverage

A01-Broken Access Control, A02-Cryptographic Failures, A03-Injection, A04-Insecure Design, A05-Security Misconfiguration, A06-Vulnerable Components, A07-Authentication Failures, A08-Data Integrity Failures, A09-Logging Failures, A10-SSRF

## Performance Review

### Scalability Red Flags

- N+1 Queries
- Missing Indexes
- Synchronous External Calls
- In-Memory State
- Unbounded Collections
- Missing Pagination
- No Connection Pooling
- No Rate Limiting

## Review Comment Format

```typescript
interface ReviewComment {
  path: string;
  line: number;
  severity: "CRITICAL" | "HIGH" | "MEDIUM" | "LOW" | "INFO";
  category: "Security" | "Performance" | "Bug" | "Maintainability";
  title: string;
  description: string;
  codeExample?: string;
  references?: string[];
  autoFixable: boolean;
  effort: "trivial" | "easy" | "medium" | "hard";
}
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: AI Code Review
on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Static Analysis
        run: |
          sonar-scanner -Dsonar.pullrequest.key=${{ github.event.number }}
          semgrep scan --config=auto --sarif --output=semgrep.sarif
      - name: AI-Enhanced Review
        run: python scripts/ai_review.py --pr-number ${{ github.event.number }}
      - name: Quality Gate
        run: |
          CRITICAL=$(jq '[.[] | select(.severity == "CRITICAL")] | length' review-comments.json)
          if [ $CRITICAL -gt 0 ]; then exit 1; fi
```

## Quality Gate

Block merge when:
- Any CRITICAL severity issues
- Security vulnerabilities with CVSS >= 7.0
- Test coverage drops below threshold
