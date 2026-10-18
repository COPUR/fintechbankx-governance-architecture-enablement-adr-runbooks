# ADR-032: Compliance Reason Codes and Screening Facts

## Status

Proposed

## Date

2026-10-18. Answers recorded 2026-10-18 01:45Z to two 2026-10-08 cards: "compliance reason codes" (cmsg_01TVU6MCNctBZbo8MPkX9s1oG6sDwwFSLakjScjHRKPoRe, posted 2026-10-08 11:59:04Z) and the screening-facts question (cmsg_01TVU6MCNctBZbo8MPkX9s1o5PJDFhYjQdqWmAKtEsQHNi, posted 2026-10-08 17:15:15Z).

## Context

The reason-codes card asked: "Who may read the sanctions and PEP reason codes that compliance screening events carry?" Its options were "Compliance and audit only", where events keep only the outcome, and "Any subscribed service". The question is about events, and the answer was "Compliance and audit only".

The card's own consequence text says the codes stay in the evidence record, "readable through the compliance API by compliance officers and auditors". The card does not decide synchronous responses. On compliance PR #13 (head 8af246d), `POST /api/v1/compliance/screen` and `GET /api/v1/compliance/screenings/{transactionId}` return `reasons` in the response body. The screen admits compliance officers, admins and listed services; the lookup also admits auditors. Listed services include payments. That conflicts with the card's stated consequence and is not resolved by the card.

The screening-facts card asked how payments should obtain the sanctions, PEP, high-risk-country and velocity facts it sends to screening. The recommended option, "Owners compute them", was answered.

## Decision

1. **Screening events carry the outcome only.** Sanctions and PEP reason codes do not travel on compliance screening events, so event consumers receive none. Compliance and audit read the codes from the evidence record.
2. **Synchronous responses are open.** The screen and lookup responses still return `reasons` to listed services. This ADR does not decide that. Removing `reasons` from listed-service responses, or narrowing the listed services, is a breaking API change. Compliance decides it in its own thread and records it as follow-up work.
3. **Owners compute the screening facts.** Payments sends only ids and amounts; the caller attests nothing. Per the card:
   - Compliance owns the sanctions and PEP facts.
   - Risk owns the high-risk country and velocity facts.
   - The constants payments sends today stay for parity and test only, marked unsourced, until cut-over.
   - Planned, not on main yet: compliance reads the name and KYC status from the customer service and matches the normalised name against `sanctions_list_entry` and `pep_register_entry`, loaded by operator scripts. Risk resolves the counterparty's country (an IBAN prefix after its checksum; an internal account to the home country; anything else unknown and treated as high risk) and computes velocity from its own assessments. Source: customer-risk-compliance squad plan, 2026-10-18, not in a repository (unverified).
4. **Screening fails closed.** An empty or stale list (`RISK_COUNTRY_LIST_MAX_AGE` and `COMPLIANCE_LIST_MAX_AGE`, planned) or an unreachable source answers 503 (`RISK_SOURCE_UNAVAILABLE`, `SCREENING_SOURCE_UNAVAILABLE`). Screening never passes by default. The evidence record stores the computed facts, the list versions and the reason codes.
5. **Planned v2 operations.** Each service adds a v2 operation (`POST /api/v2/risk/assess`, `POST /api/v2/compliance/screen`) and marks v1 `deprecated: true`. A flag, off by default, keeps v1 answering until payments moves. Cutover precondition: the v1 flag is off, callers use v2, and the real lists are loaded and fresh. Neither v2 operation is on main; the source is the customer-risk-compliance squad plan, 2026-10-18, not in a repository (unverified).
6. **Owning threads update their drafts.** Once accepted, this ADR supersedes the caller-attested position in compliance, payments and risk ADR 0001 (all Proposed); each owner adds a back-link. The three records are listed under Related.

## Alternatives

- **Any subscribed service reads the reason codes on events.** Not chosen (the card's second option).
- **Caller-attested facts (the default).** Not chosen. The caller would decide a screening input it does not own, and the constant "clean" values hide a missing fact.

## Consequences

- Screening events carry no reason codes. Consumers of screening events get the outcome only.
- Listed services keep receiving `reasons` on synchronous responses until compliance decides the follow-up. This is recorded as open and is not closed by this ADR.
- A failed lookup fails the screening. It is not replaced by an attested value.
- The customer service must allow the compliance and risk clients on `GET /api/v1/customers/{id}` (planned). Scopes and the identity client belong to the platform repository.
- Loading real lists, and keeping them fresh, is a cutover precondition for compliance and risk.
- The OpenAPI catalog is synced after the provider PRs merge. This ADR does not change the catalog.
- Matrix rows CR-04 and CR-08 carry Proposed notes pointing here (`monolith-to-repo-alignment.csv`).

## Related

ADR-019, ADR-020, ADR-022, ADR-031.

Caller-attested ADR 0001 records, superseded for screening facts once this ADR is accepted (all Proposed):
- compliance-evidence-core `docs/architecture/decisions/0001-screening-facts-are-caller-attested.md` on PR #13 (head 8af246d; dated 2026-10-08; owned by the Risk and Compliance Decisioning Squad)
- payments repository `docs/architecture/decisions/0001-payments-attests-default-screening-and-risk-facts.md`
- risk repository `docs/architecture/decisions/0001-risk-facts-are-caller-attested.md`
