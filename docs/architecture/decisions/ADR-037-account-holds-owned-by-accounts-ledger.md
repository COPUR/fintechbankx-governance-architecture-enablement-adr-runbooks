# ADR-037: Account Holds Move to the Accounts Ledger

## Status

Proposed

## Date

2026-10-18. Source: the phase-5 design of 2026-10-18 (not in a repository, unverified; design question F5-K3). Approval: user message cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz (2026-10-18 02:31:54Z), which approves the recommended option. No decision cards were posted.

## Context

- Holds (reservations) live in payments today, as `FundsReservation`. Payments then checks balances without the owner of those balances.
- Mandates, bulk, loan disbursement and the instant-payment exception flow (ADR-042) all need a hold that the ledger enforces.
- A hold is money state. ADR-041 keeps the process engine away from it.

## Decision

1. The accounts ledger (`acc`) gets a `Hold` aggregate with place, capture and release. Each command carries an idempotency key, using the same `reference` rule as journal entries.
2. Payments, mandates, bulk and the instant-payment exception flow send hold commands. None of them keeps a balance.
3. Migration runs in shadow mode first. Existing `FundsReservation` records are written to ledger holds alongside the current ones, with a reconciliation report. There is no best-effort copy of money. Cut-over follows the phase-5 plan (D5.1).

## Alternatives

- **Keep `FundsReservation` in payments.** Rejected. Two services would own balance state.

## Consequences

- The ledger exposes `POST /api/v1/holds` (planned, not built). Its idempotency follows the journal-entry rule.
- Moving holds is hard to undo once data is moved, so cut-over waits for a clean reconciliation.
- Payments' hold code is replaced by commands to the ledger.

## Related

ADR-018, ADR-022, ADR-036, ADR-041.
