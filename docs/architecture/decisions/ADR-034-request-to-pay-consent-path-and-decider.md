# ADR-034: Request-to-Pay Consent Path and Decider

## Status

Proposed

## Date

2026-10-18. Answers recorded 2026-10-18 01:45Z to two 2026-10-08 request-to-pay cards: "RtP consent name" (cmsg_01TVU6MCNctBZbo8MPkX9s1oACx5e9mTg1cDrBDyndJNPR, posted 2026-10-08 16:51:38Z) and "RtP decider" (cmsg_01TVU6MCNctBZbo8MPkX9s1oAi7cbHE6shohj6SdNDFkMb, posted 2026-10-08 16:51:34Z). Both were answered with the recommended option.

## Context

Request to pay (RtP) stores its own payment consents today. They use `CONS-RTP2-` ids on `/payment-consents`. Open finance's consent-auth uses `CONSENT-` ids on `/consents`, so the two do not collide. The RtP store sits outside consent-auth, which open finance noted as a second consent store.

The decider card asked who may accept or reject a request to pay. The creating TPP does so today, ownership is checked by the caller's client id, and the decision records the TPP and the reason. A PSU-bound decision token matters only if a PSU path is chosen, so it is not decided here.

## Decision

1. **Keep `/payment-consents` with `CONS-RTP2-` ids.** No rename to `/rtp-consents` and no move into consent-auth in this decision. The move into consent-auth is a later option, not a decision.
2. **The creating TPP decides.** The TPP that created the request accepts or rejects it. Ownership is checked by the caller's client id, and the decision records the TPP and the reason.
3. **Accepted is a status, not a payment authorisation.** A request-to-pay status of Accepted reports the TPP's decision on the request. It does not authorise a payment, and under this option the service does not prove the payer's own approval.
4. **Ownership failures follow ADR-025, item 5:** an unknown path id, or another TPP's, gets a fixed 404; an id that only a request body references gets one uniform 403.

## Alternatives

- **The debtor PSU decides through its own TPP (the card's second option).** Not chosen for this version. It needs open finance's consent model first, and it changes the OpenAPI contract and parity.
- **Both, with the PSU path later (the card's third option).** Not chosen as a decision. The PSU path is a later decision and this ADR does not record it.
- **Rename to `/rtp-consents`, or move into consent-auth.** Not chosen. Each creates a parity difference and a cross-pillar change.

## Consequences

- RtP keeps a second consent store beside consent-auth. Any later consolidation is a separate decision with parity rows.
- The payer's own approval is not proven by the service.
- The card's "ADR-030" reference for a later move into consent-auth points to the lending repository's RtP proposal. This repository's ADR-030 is the monolith-homes decision, so the two must not be confused.
- Matrix row LP-10 carries a Proposed note pointing here (`monolith-to-repo-alignment.csv`).

## Related

ADR-018, ADR-020, ADR-025, ADR-029.
