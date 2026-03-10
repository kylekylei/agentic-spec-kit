# Feature Readiness Report Format

> **何時載入**：當 `teammate.review.md` Pass F 觸發時，AI 依此格式產出 `TASK_DIR/checklists/feature-readiness.md`。

## 格式規範

```markdown
# Feature Readiness Report: [Feature Name]

**Generated**: [Date]
**Status**: [Ready/Not Ready/Partial]

## Executive Summary
[2-3 sentence overview]

## Behavioral Coverage
[Scenario distribution + coverage by story]

## Requirements Quality
| Dimension    | Score | Issues |
|--------------|-------|--------|
| Completeness | [%]   | [N]    |
| Clarity      | [%]   | [N]    |
| Consistency  | [%]   | [N]    |
| Coverage     | [%]   | [N]    |

## Findings
| ID | Category | Severity | Location | Finding | Recommendation |
|----|----------|----------|----------|---------|----------------|

## Traceability Summary
[Matrix from Pass E]

## Principles Compliance
| Principle | Coverage | Status |
|-----------|----------|--------|

## Metrics
- Total Scenarios: [N]
- Total Actions: [N]
- Scenario Coverage: [%]
- Principles Coverage: [%]
- Critical Issues: [N]

## Recommendation
[Ready to proceed / Needs attention / Blocked]
```
