# ADR-043: One Payment-Scheme Gateway per Rail Family

## Status

Proposed

## Date

2026-10-18. Source: the phase-5 design of 2026-10-18 (not in a repository, unverified; design question F5-K4). Approval: user message cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz (2026-10-18 02:31:54Z), which approves the recommended option. No decision cards were posted.

## Context

- Each payment rail has its own scheme rules, certification, cut-off times and callback behaviour. A shared gateway would share certification and failure domains.
- Payments (`pay`) must not hold scheme details. A gateway conforms to its scheme and gives `pay` a canonical instruction.
- The design lists four families: UAE (UAEFTS and IPP/Aani), Türkiye (FAST, EFT, BKM), SWIFT (gpi, ISO 20022) and CBDC (mBridge, Digital Dirham; pilot last).

## Decision

1. One gateway repository per rail family, opened when that family's wave arrives: `psg-ae`, `psg-tr`, `psg-swift` and `psg-cbdc`. `psg-ae` comes first. The user opens each repository, with the `neo-` prefix.
2. Each gateway is an anti-corruption layer. It speaks the scheme's protocol and publishes scheme events to `evt.psg.<family>`.
3. Each gateway has its own timeouts, derived from the scheme's SLA, its own thread pool and pod set (bulkhead), and its own certification.
4. A scheme call is retried only after a status inquiry, so one payment is never sent twice.
5. The CBDC gateway is only named here. Its design (the digital wallet context and the CBDC rail) is still being written and gets its own ADR when delivered.

## Alternatives

- **One gateway with rail plug-ins.** Rejected. Certification and failure domains would be shared.

## Consequences

- Four new repositories, each opened when its wave comes. Scheme certification, participant codes and certificates are outside prerequisites owned by the user.
- The UAE gateway is the first real rail. Until it exists, payments have no production path.

## Related

ADR-019, ADR-022, ADR-041, ADR-042.
