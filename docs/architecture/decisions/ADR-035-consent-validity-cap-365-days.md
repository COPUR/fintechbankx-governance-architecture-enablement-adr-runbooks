# ADR-035: Consent Validity Capped at 365 Days

## Status

Proposed

## Date

2026-10-18. Answer recorded 2026-10-18 01:45Z to the 2026-10-08 card "consent validity" (cmsg_01TVU6MCNctBZbo8MPkX9s1oThBP41pWZebSdRBRoS5hr7, posted 2026-10-08 16:51:42Z). The option chosen was "Cap at 365 days".

## Context

The UAE Open Finance Standards v1.2, Limits and Constants, set the maximum consent validity (constant A1) at one year. They set the authorisation window (A2) at 30 days and the submitter window (A3) at two hours.

The implementations differ today:

- consent-auth (PR #13, head 73d22a1) caps validity at 90 days. `Consent.MAX_VALIDITY` is 90 days, and a later expiry is rejected. The consent aggregate topic, `evt.of.consent.v1`, has 90-day retention.
- The monolith's consent REST endpoint passes the requested expiry straight into consent creation with no cap, so it accepts expiry dates beyond 90 days. A separate monolith application service, `DistributedConsentService`, clamps requested validity to 90 days.

The 90-day cap in consent-auth is an engineering rule, not a regulatory limit. Governance does not record it as standard-backed (parity rule INT-OF-CONSENT-MAX-VALIDITY-90D).

## Decision

1. **Consent validity is capped at 365 days**, the A1 limit. This replaces consent-auth's 90-day cap. The parity rule INT-OF-CONSENT-MAX-VALIDITY-90D is replaced by a 365-day rule.
2. **A2 and A3 are not changed here.** Open finance confirms the 30-day and 2-hour windows against the standard in its own change.

## Order of change

1. Platform raises the retention of `evt.of.consent.v1` to at least 366 days. This happens before any cap above 90 days deploys. Platform owns the change in the event-streaming repository.
2. Open finance changes consent-auth's `MAX_VALIDITY` and its error message, in its own provider PR.
3. The parity rule is replaced.

## Alternatives

- **Keep 90 days as bank policy with a named approver (the card's second option).** Not chosen. The card's reason is that 90 days is an engineering choice tied to topic retention, not a regulatory limit.

## Consequences

- `evt.of.consent.v1` keeps 90 days of retention until platform changes it. The 365-day cap must not deploy before that change.
- Governance records no 90-day approval as standard-backed.
- Matrix row OF-01 carries a Proposed note pointing here (`monolith-to-repo-alignment.csv`).

## Related

ADR-019, ADR-024, ADR-029.
