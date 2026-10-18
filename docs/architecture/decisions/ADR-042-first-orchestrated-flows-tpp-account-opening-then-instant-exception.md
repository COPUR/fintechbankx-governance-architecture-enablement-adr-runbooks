# ADR-042: First Orchestrated Flows: TPP Account Opening, Then the Instant-Payment Exception

## Status

Proposed

## Date

2026-10-18. Source: the Camunda architecture and phase-5 designs of 2026-10-18 (not in a repository, unverified; design questions C8-K8 and F5-K14). Approval: user message cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz (2026-10-18 02:31:54Z), which approves the recommended option. No decision cards were posted.

## Context

- The design asks which flow Camunda runs first: TPP account opening, or domestic instant transfer.
- TPP account opening carries little money risk and has a human step (identity and screening). Instant transfer carries high value and depends on a scheme gateway that is not yet built (ADR-043).
- The instant-payment happy path stays outside Camunda: `pay` and `psg` handle it synchronously. Camunda starts only on an exception.

## Decision

1. The first flow is TPP account opening (`acc-tpp-account-opening`). It runs in shadow mode first (phase D5.6a), then goes live behind the flag `ONBOARDING_ORCHESTRATION=legacy|bpo` (D5.6b). The chain is: consent, KYC in the customer service, screening in compliance, account opening in the ledger, then notification.
2. The second flow is the instant-payment exception path (`pay-instant-exception`). It starts after the UAE scheme gateway exists (phase D5.7).
3. The instant-payment happy path never enters Camunda. Only ambiguous states (timeout, pending, unknown response) hand the payment to `bpo`, which moves it to `EXCEPTION_OWNED_BY_BPO`.
4. Rollback: the flag returns to `legacy`. Instances already running finish, or a runbook cancels them and runs compensation.

## Alternatives

- **Instant payment first.** Rejected for the first flow. Its value is higher, and the scheme gateway is not yet built.

## Consequences

- The monolith's `OnboardingService` stays until cut-over. A mesh rule routes the TPP path to the new endpoint.
- The payments side needs a provider change for `Payment.ExceptionRaised` and the `EXCEPTION_OWNED_BY_BPO` state. That is a provider PR, not a separate ADR.

## Related

ADR-019, ADR-025, ADR-036, ADR-040, ADR-041, ADR-043.
