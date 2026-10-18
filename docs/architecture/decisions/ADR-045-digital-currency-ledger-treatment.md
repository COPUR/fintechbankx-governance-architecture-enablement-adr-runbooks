# ADR-045: Digital Currency in the Accounts Ledger: Deposit Leg and Inventory Control Account

## Status

Proposed

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the digital dirham and digital TRY wallet design (design document 06, not in a repository, unverified where it says so). The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting the recommended options, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- A customer's digital currency balance is held on the central-bank platform. It is not the bank's liability. Posting it to the ledger as a deposit would make it one.
- The bank's own central-bank currency inventory is an asset, equivalent to a reserve.
- A conversion between a deposit and digital currency has two legs: the customer's deposit leg in the ledger, and the bank's inventory movement.
- The design treats digital currency as a separate value type, `CbdcAmount`, that cannot be added to `Money` (design principle I5).
- The launch design pays no interest on digital currency balances (D6-K9).

## Decision

1. The ledger (`acc`) holds two kinds of balance for digital currency, and only these:
   - the customer's deposit leg of a conversion, in the deposit's own currency;
   - the bank's CBDC inventory control account, an internal account denominated in the digital currency unit (`DDH` or `DTL`). It mirrors the balance the platform holds for the bank and is never netted against fiat accounts.
2. Customer digital currency balances are not posted to the ledger. They are off the bank's balance sheet. The platform holds them, and `dcw` keeps a shadow balance (ADR-044).
3. A conversion is one journal entry with a deterministic `reference`. Posting the same reference again returns the original journal, and a different body with the same reference is refused, as the ledger already does for its other postings.
4. No interest is paid on any digital currency balance in any profile (D6-K9, option a). Interest, if the regulator requires it later, is a separate product and needs its own ADR.
5. Funding and defunding in progress hold the deposit leg with a ledger hold (ADR-037) until the platform confirms.
6. A platform-to-ledger inventory difference opens a reconciliation break in `dcw`. The ledger is not adjusted to match the platform without a journal reviewed under the reconciliation runbook.
7. The ledger contract change (new internal account type, digital currency unit, conversion journal type) is a provider change in the accounts ledger repository, not a separate ADR.

## Alternatives

- **Post customer balances to the ledger as deposits.** Rejected: it makes the balances a bank liability, contrary to design principle I3.
- **Interest-bearing wallets at launch** (D6-K9, option b). Rejected: a product decision with its own regulatory case.

## Consequences

- The ledger change follows ADR-037 (holds) and comes before the `dcw` wave (ADR-044).
- Reports of the CBDC inventory are a separate `reg` definition.
- Customer digital currency balances do not appear in ledger reports. They are reported from the platform and `dcw`.

## Related

ADR-019, ADR-036, ADR-037, ADR-044, ADR-046.
