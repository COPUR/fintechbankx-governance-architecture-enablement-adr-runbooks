# ADR-050: Consent Validity Profile per Jurisdiction

## Status

Proposed. This is an owner decision: the option is not chosen until the owner answers it. If option (a) is accepted, this ADR changes the structure of ADR-035 and leaves its UAE value unchanged.

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the Türkiye payment package (design document 08, not in a repository, unverified where it says so). The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting option (a) below, the per-jurisdiction profile, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- The Turkish open-banking standard (ÖHVPS, [specification](https://ohvps.github.io/)), in the version the design read (v1.0.2), limits account-information consent to six months. Corporate consent is 12 months according to BKM's 2025 report. The design did not verify the newer v2.0.1 limits.
- The UAE Open Finance Standards cap consent at one year (ADR-035).
- consent-auth caps validity at 90 days (`Consent.MAX_VALIDITY`, PR #13, head 73d22a1). That is an engineering rule tied to topic retention, not a regulatory limit (ADR-035).
- A single cap cannot satisfy both standards. A cap of 365 days exceeds the Turkish limit. A cap of 180 days shortens the UAE validity that ADR-035 decided.
- Turkish consent has its own status codes and a five-minute response window. The design models the consent lifecycle in the consent domain, not in Camunda.

## Decision (option a, recommended)

1. consent-auth holds a validity profile per jurisdiction, versioned as data and not as a constant:
   - UAE: 365 days (ADR-035, unchanged);
   - Türkiye: 180 days for individual customers and 12 months for corporate customers, per BKM's note. The corporate value is to be checked against ÖHVPS v2.0.1 before the profile is deployed.
2. Turkish consent statuses follow the ÖHVPS codes B, Y, K, E, S and I (design D8-K6). The state machine and its expiry and timeout sweeps are domain logic in the consent service. They are not a BPMN process (design D8-K7, option a; ADR-041).
3. The order of change in ADR-035 still applies. The retention of `evt.of.consent.v1` is at least 366 days before any profile above 90 days is deployed.
4. The Türkiye profile is not deployed before the Türkiye cluster and the Türkiye consent deployment exist (ADR-039).

## Alternatives

- **One cap of 180 days for both jurisdictions** (option b). Compliant with ÖHVPS, but it reverses ADR-035's decision for UAE customers.
- **One cap of 365 days for both jurisdictions** (option c). Rejected: it exceeds the Turkish six-month limit.
- **A separate consent service for Türkiye** (design D8-K6, option b). Not recommended: it duplicates the consent rules.

## Consequences

- consent-auth gains a profile lookup. The parity rules are updated by open finance once the profile lands.
- The Turkish limit is confirmed against v2.0.1 before deployment. Until then, the Turkish profile is a proposal.
- Three numbers must match: the profile, the event retention and the parity rule.

## Related

ADR-019, ADR-035, ADR-039, ADR-041.
