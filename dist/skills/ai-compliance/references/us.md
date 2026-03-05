# US State AI Laws

No federal AI law. Compliance driven by state-level legislation. Key states: California, Colorado, Texas.

## California

### SB 243 — AI Chatbot Disclosure
- **Effective**: Various dates
- **Penalty**: $1,000/violation (private right of action)
- **Requirement**: Chatbot MUST disclose AI nature at first interaction. Long sessions (>3hr) require periodic reminders.
- **Maps to**: AI-001, AI-002

### AB 853 / CAITA — AI Content Labeling
- **Requirement**: AI-generated content must be labeled with visible indication and machine-readable metadata.
- **Maps to**: AI-003

### CCPA / CPRA — Privacy & AI Consent
- **Penalty**: $2,500/violation (unintentional), $7,500/violation (intentional)
- **Requirement**: Consumers can opt out of automated decision-making. Must honor Global Privacy Control (GPC) signals.
- **Maps to**: AI-008

## Colorado

### AI Act (SB 24-205)
- **Effective**: 2026.2
- **Penalty**: $20,000/violation (enforced by AG)
- **Scope**: "High-risk AI systems" making consequential decisions (employment, education, financial services, healthcare, housing, insurance, legal services)
- **Requirements**:
  - Deployers must conduct impact assessment before deployment
  - Notify consumers when high-risk AI makes consequential decisions
  - Provide explanation of AI decision and appeal mechanism
  - Disclose AI use in consumer-facing interactions
- **Maps to**: AI-001, AI-005, AI-007

## Texas

### HB 149 — AI Disclosure
- **Requirement**: Entities using AI chatbots must disclose non-human nature of the interaction.
- **Maps to**: AI-001

## Cross-State Compliance Summary

| Requirement | CA | CO | TX | Maps to |
|-------------|----|----|-----|---------|
| Chatbot AI disclosure | SB243 | SB24-205 | HB149 | AI-001 |
| Periodic reminder (3hr) | SB243 | — | — | AI-002 |
| Content labeling | AB853 | — | — | AI-003 |
| Consent / opt-out | CCPA | SB24-205 | — | AI-008 |
| Impact assessment | — | SB24-205 | — | (pre-deploy) |
| Explanation + appeal | — | SB24-205 | — | AI-007 |
| Override mechanism | — | SB24-205 | — | AI-005 |

## References

- [CA SB243](https://leginfo.legislature.ca.gov/faces/billNavClient.xhtml?bill_id=202520260SB243)
- [CO AI Act SB24-205](https://leg.colorado.gov/bills/sb24-205)
