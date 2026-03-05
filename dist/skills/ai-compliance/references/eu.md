# EU AI Act

Regulation (EU) 2024/1689 | Mandatory | Phased enforcement 2025.2 — 2027.8 | Max penalty €35M or 7% global revenue

## Key Articles for Software Dev

| Article | Topic | Maps to Rule | Penalty |
|---------|-------|-------------|---------|
| Art.5 | Prohibited practices (social scoring, subliminal manipulation) | Do not build | €35M / 7% |
| Art.5(1)(a) | Manipulative UI / dark patterns | AI-004 | €35M / 7% |
| Art.12 | Automatic logging for high-risk AI | AI-010 | €15M / 3% |
| Art.13 | Transparency: accuracy, robustness, cybersecurity levels | AI-009 | €15M / 3% |
| Art.14(4) | Human oversight: understand, interpret, override, stop | AI-005 | €15M / 3% |
| Art.50(1) | Chatbot disclosure: inform user of AI interaction | AI-001 | €7.5M / 1% |
| Art.50(2) | AI-generated content: machine-readable marking (C2PA) | AI-003, AI-011 | €7.5M / 1% |
| Art.50(4) | Deep fake disclosure | AI-003 | €7.5M / 1% |
| Art.50(5) | Accessible disclosure | AI-003 a11y | €7.5M / 1% |
| Art.86 | Right to explanation for high-risk AI decisions | AI-007 | GDPR penalties |
| DSA Art.27 | Recommendation transparency | AI-006 | DSA penalties |
| DSA Art.38 | Non-personalized alternative | AI-006 | DSA penalties |
| GDPR Art.7 | Consent requirements | AI-008 | GDPR penalties |
| GDPR Art.22 | Automated decision-making rights | AI-007 | GDPR penalties |
| GDPR Art.25 | Privacy by Design / Default | AI-008 | GDPR penalties |

## Prohibited Practices (Art.5) — Effective 2025.2

Do NOT build:
- Social scoring systems
- Real-time remote biometric identification in public spaces (law enforcement exceptions)
- Subliminal manipulation techniques
- Exploitation of vulnerabilities (age, disability, social/economic situation)
- Emotion inference in workplace/education (with exceptions)
- Untargeted facial image scraping
- Biometric categorization for sensitive attributes

## High-Risk Categories (Annex III)

1. Biometric identification and categorization
2. Critical infrastructure management
3. Education and vocational training (access, assessment)
4. Employment (recruitment, task allocation, termination)
5. Essential services access (credit scoring, insurance, social benefits)
6. Law enforcement
7. Migration, asylum, border control
8. Administration of justice

## Human Oversight Requirements (Art.14)

High-risk AI supervisors MUST be able to:
- (a) Understand system capabilities and limitations
- (b) Stay aware of automation bias
- (c) Correctly interpret system output
- (d) Override or reverse output at any time
- (e) Halt system via "stop button"

## Documentation Requirements (Annex IV)

Technical documentation for high-risk systems:
- System description: intended purpose, version, architecture
- Development process: design specs, algorithm logic, training methods
- Validation/testing: test data, accuracy/robustness metrics, dated test logs
- Monitoring: performance limits, foreseeable risks, human oversight specs
- Risk management system description (Art.9)
- Post-market monitoring system (Art.72)

## Audit Log Requirements (Art.12)

- Append-only, tamper-proof
- Record: period of use, reference DB, input data, persons verifying results
- **Retention: 10 years** for high-risk systems
- Serious incident report to AI Office within **72 hours**

## Enforcement Timeline

| Date | Milestone |
|------|-----------|
| 2025.2 | Prohibited practices in effect |
| 2025.8 | GPAI obligations in effect |
| 2025.2 | AI literacy training mandatory |
| 2026.8 | **High-risk rules + transparency obligations** |
| 2027.8 | Product-embedded AI rules |

## Conformity Assessment (Art.43)

- Most high-risk: self-assessment (Annex VI)
- Biometric systems: third-party assessment (Annex VII)
- CE marking + EU Declaration of Conformity required
- Register high-risk systems in EU database

## References

- [EU AI Act full text](https://eur-lex.europa.eu/eli/reg/2024/1689/oj)
- [NIST AI RMF](https://www.nist.gov/artificial-intelligence/risk-management-framework)
- [C2PA v2.2](https://c2pa.org/specifications/specifications/2.2/specs/)
