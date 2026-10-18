# ADR-044: Digital Currency Wallet Context (`dcw`)

## Status

Proposed

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the digital dirham and digital TRY wallet design (design document 06, not in a repository, unverified where it says so). The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting the recommended options, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- The bank is a tier-2 intermediary. Issuance and redemption (mint and burn) happen only at the central bank. The bank opens wallets, runs KYC and AML, and distributes the currency.
- The central bank's platform is the system of record for wallet balances. `dcw` keeps a shadow balance that changes only when the platform confirms it. On a conflict the platform wins, and a reconciliation break is opened.
- The UAE and Türkiye have different central-bank rules, and limit values can change by central-bank decision. Limits therefore cannot be constants in code.
- Digital TL is in pilot, and no circulation decision exists. Digital Dirham retail use is not verified.
- The naming standard defines topics as one per aggregate, `evt.<context-code>.<aggregate>.v<major>` (ADR-019). The design read the standard as one topic per event; that reading is wrong, and the aggregate topic it proposes matches the standard.

## Decision

1. Create the bounded context `dcw` (Digital Currency Wallet). Service id `svc-dcw-wallet`, event namespace `evt.dcw`, repository `neo-fintechbankx-digitalcurrency-wallet-service`, wave 6 in the bootstrap manifest. The context code is added to the naming standard.
2. `dcw` owns wallet records and wallet rules: registration, tier, funding and defunding requests, transfer rules, holding limits, freeze, suspension and closure. It holds no money. It grants no credit, pays no interest and applies no fee rules.
3. One codebase with two jurisdiction profiles, AE and TR, and two deployments, one per jurisdiction (D6-K1, option a). Limits are versioned DMN tables per profile.
4. One aggregate topic, `evt.dcw.wallet.v1`, keyed by `walletId`, with the event type in the `eventType` header. Event types are `DigitalCurrency.Wallet.<PastTenseEvent>.v1` (D6-K7, option a). This is the standard as written.
5. The API path is `/api/digital-currency/v1/...`, as the naming standard requires. The ledger's `/api/v1` path is a separate ledger matter and is not changed here.
6. There is no mint or burn command in `dcw`. The bank's acquisition of its own central-bank currency is a treasury operation in `liq` (design P9), not a customer flow.
7. Events carry identifiers and facts only. Platform addresses are masked. No personal data is published.
8. Digital TL has no issuance or circulation decision. Until the central bank opens a project, the design stays in a simulator (design D8-K12, option a).
9. The wave is the last item of D5.7, after the simulator, with prerequisites D5.1 (holds), D5.5 (`liq`) and D5.6b (`bpo` can issue commands). Building in parallel now is not recommended (D6-K10, option a).

## Alternatives

- **Two contexts and repositories, one per jurisdiction** (D6-K1, option b). Not chosen: the rules would be duplicated.
- **One deployment for both jurisdictions** (D6-K1, option c). Rejected: KVKK and central-bank residency rules apply to each jurisdiction's data.
- **Start the wave now, in parallel** (D6-K10, option b). Rejected: the prerequisites do not exist yet.

## Consequences

- The naming standard gains the `dcw` context code in this batch. The repository is opened by the user only after the owner approves this ADR.
- `dcw` consumes the CBDC gateway's events, `evt.psg.cbdc-instruction.v1` (ADR-043), not the design's `evt.psg.cbdc.v1`.
- Ledger postings for the wallet are in ADR-045. The wallet's limits and v1 scope are in ADR-046.

## Related

ADR-019, ADR-036, ADR-037, ADR-041, ADR-043, ADR-045, ADR-046.
