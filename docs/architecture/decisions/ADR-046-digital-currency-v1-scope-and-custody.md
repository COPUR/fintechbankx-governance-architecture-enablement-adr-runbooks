# ADR-046: Digital Currency v1 Scope, Key Custody and Limits

## Status

Proposed

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the digital dirham and digital TRY wallet design (design document 06, not in a repository, unverified where it says so). The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting the recommended options, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- Central-bank platforms differ in what they offer: atomic splits, batch limit checks, offline tokens and smart contracts. Some of these are not yet specified.
- The design recommends a narrow v1 and leaves the rest to v2.
- Legal questions (seizure, escrow addresses) are open and need an opinion.

## Decision

1. **v1 scope** (D6-K6, option a): onboarding and tier, funding and defunding, person-to-person and person-to-merchant transfers, waterfall sweep, freeze and unfreeze, closure, and reporting. Offline wallets, sub-wallets, conditional payments and request-to-pay are v2.
2. **Keys** (D6-K3, option a): in v1 the bank holds the keys, in a hardware security module of the jurisdiction or a key managed by the platform. A customer key exists only on a platform-supported offline device.
3. **Offline** (D6-K11, option a): the bank writes no offline token of its own. It waits for the platform specification.
4. **Conditional payments and escrow** (D6-K12, option a): only through the platform's own smart contract. The bank holds no escrow address until a legal opinion allows one.
5. **Open-finance access** (D6-K8, option a): with consent, the open-finance interface gives read access only (balance and transactions). Payment initiation is not offered. Whether open finance covers digital currency is not verified.
6. **Holding limits** (D6-K4, option a): the platform's batch limit check, plus a local pre-check in `dcw`. A bank-only check cannot see wallets held with other providers.
7. **Waterfall** (D6-K5, option a): an atomic split when the platform offers one; otherwise an instant sweep with an end-of-day sweep as backup (design P17).
8. **Failed bridge transfer** (D6-K16, option a): if the defunding is final and the fast-payment leg is rejected, the money stays in the deposit. The customer is told and offered a new funding. There is no automatic re-funding.
9. **Seizure and garnishment** (D6-K17, option a): freeze only, until a legal opinion says otherwise. The money is not withdrawn from the wallet.
10. **Card linked to digital TL** (D6-K14, option a): not in the pilot. A separate pilot may follow under the card-scheme rules, if the platform can hold the funds for the authorisation window, or if defunding is final inside it.
11. **Aliases** (D6-K15, option a): an alias stays bound to the deposit IBAN. Incoming digital currency is funded into the wallet by the customer's choice.
12. Limits are versioned DMN tables per jurisdiction profile, and the central bank's limit notices change the tables, not the code (design principle I6).

## Alternatives

- **v1 includes offline, sub-wallets and conditional payments** (D6-K6, option b). Rejected: the platform specifications are not yet available.
- **Bank-held escrow addresses now** (D6-K12, option b). Rejected: no legal opinion.

## Consequences

- Several items depend on the central-bank platform's specifications. Until they arrive, the simulator carries these flows.
- Each recommended option becomes a condition on the `dcw` build. Changing one needs a new decision in the design thread, and this ADR is updated.

## Related

ADR-037, ADR-041, ADR-044, ADR-045.
