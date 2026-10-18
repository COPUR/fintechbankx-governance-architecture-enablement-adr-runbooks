# ADR-036: Core Banking Accounts Stay in the Accounts Ledger

## Status

Proposed

## Date

2026-10-18. Source: the phase-5 accounts decision in the Camunda and phase-5 design of 2026-10-18 (not in a repository, unverified). The question was asked in the design thread (cmsg_01TVU6MCNctBZbo8MPkX9s1o6vTirNKVVhNQYDvV97fK97, 2026-10-18 01:53:20Z). The user approved the recommended option in that thread (cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz, 2026-10-18 02:31:54Z), after the recommendation post (cmsg_01TVU6MCNctBZbo8MPkX9s1oWD9NAfVp9SXgA3xxD9ogrR, 02:26:06Z). No decision cards were posted in that thread.

## Context

The question was whether core-banking accounts stay in the monolith's API or move to a new accounts service now.

- The accounts ledger already exists: `neo-fintechbankx-corebanking-accounts-ledger-service` (PR #1, not merged). It exposes `GET /api/v1/accounts/{id}` and `POST /api/v1/journal-entries`. ADR-030 fixes the `acc` context code.
- The monolith has no accounts API to keep. Its `bankwide` and `bank-wide-services` folders contain README files only. The real account code is in `amanahfi-platform`, which is being retired.
- Payments and mandates run on an in-memory accounts adapter. Balance, debit and credit, and frozen-account checks have no real owner until the ledger is wired in.
- Process orchestration (ADR-038) sends commands to domain services. Their target has to be an idempotent, outboxed ledger, not the monolith.

## Decision

1. Accounts stay in the extracted accounts ledger (`acc`). No new accounts service is created.
2. No accounts API is written in the monolith. The few remaining account callers move to the ledger and are then retired.
3. Payments, mandates, bulk and loan each reach the ledger through their own HTTP adapter with a dedicated ledger client.
4. Account onboarding for TPPs moves to the ledger later. KYC is read from the customer service and consent from the consent service (ADR-042).
5. Statements and transaction history are read models built from ledger events.

## Alternatives

- **Keep an accounts API in the monolith.** Rejected. It would build an API that has to move again, against the strangler approach.
- **Create a new accounts service.** Rejected. The ledger already exists with the contract the consumers need. The design reports 188 local tests passing and a DevSecOps pass on the outbox and audit rules; those were not re-run for this ADR.

## Consequences

- PR #1 must merge before consumers switch from the in-memory adapter.
- Holds are part of the same ledger (ADR-037).
- Ledger events use the `evt.acc.account.v1` topic (ADR-019).

## Related

ADR-018, ADR-019, ADR-022, ADR-030, ADR-037, ADR-042.
