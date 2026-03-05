# Taiwan AI Fundamental Act (AI 基本法)

Enacted 2026.1.14 | 20 articles | Principle-oriented basic law | No direct penalties (sub-regulations due by 2028.1)

## Seven Core Principles (§4)

| # | Principle | Software Impact |
|---|-----------|----------------|
| 1 | Sustainable development | Consider AI model carbon footprint |
| 2 | **Human autonomy** | Design override/exit mechanisms (→ AI-005) |
| 3 | Privacy & data governance | Data minimization, Privacy by Design (→ AI-008) |
| 4 | Security | Security testing, defense-in-depth |
| 5 | **Transparency & explainability** | Disclosure labels, explanation UI (→ AI-003, AI-007) |
| 6 | **Fairness & non-discrimination** | Bias detection in CI/CD |
| 7 | Accountability | Audit trail (→ AI-010) |

## Taiwan-Specific Requirements

### Innovation Priority (§11)
When AI regulations conflict with other laws, promoting innovation takes precedence. Unique to Taiwan — provides more regulatory flexibility than EU.

### R&D Exemption (§17-2)
Pre-deployment R&D exempt from high-risk obligations. Use sandbox mechanisms to balance compliance and experimentation.

### Children's Best Interest (§5)
High-risk AI MUST consider child protection. Requires age verification, guardian consent, restricted behavioral profiling for minors (→ AI-008 minors clause).

### Digital Equity (§1, §5)
All persons — including indigenous peoples, persons with disabilities, vulnerable groups — MUST have equal AI access. Taiwan requires **special protections**, not just "accessible" (stronger than EU Art.50(5)).

**Implementation:**
- All AI interfaces WCAG 2.2 AA
- Chatbot: keyboard nav + screen reader support
- Confidence scores: never color-only (→ AI-009)
- Taiwan market: Traditional Chinese required
- Consider indigenous language needs in sensitive domains

### Cultural Values (§13)
AI training data and outputs must reflect Taiwan's multicultural values. Maintain IP rights.

### Risk Classification (§16)
MODA (Digital Ministry) to publish risk classification framework by 2026 Q1, referencing international standards. Sub-regulations by each ministry due 2028.1.

## Key Articles for Software Dev

| Article | Topic | Maps to Rule |
|---------|-------|-------------|
| §4(2) | Human autonomy | AI-005 |
| §4(5) | Transparency, AI output labeling | AI-001, AI-003 |
| §4(7) | Accountability | AI-010 |
| §5(2) | High-risk labeling & warnings | AI-003 |
| §14 | Data minimization, Privacy by Design | AI-008 |
| §19 | Government AI traceability | AI-010 |

## Implementation Timeline

| Deadline | Milestone |
|----------|-----------|
| 2026.4 | Children/human rights/gender impact assessments |
| 2026.7 | Government AI risk assessment of existing systems |
| 2026 Q1 | MODA risk classification framework target |
| 2027.1 | Government AI usage norms and internal controls |
| 2028.1 | All ministries complete sub-regulation drafting |

## References

- [Full analysis](../../../doc/ai-fundamental-act.md)
