# ADR-049: Card Processing Through a Certified Processor Behind a Thin `crd` Context

## Status

Proposed. This is an owner decision: the option is not chosen until the owner answers it.

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the Türkiye payment package (design document 08, not in a repository, unverified where it says so). The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting option (a) below, the certified processor, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- Card authorisation is an ISO 8583 message exchange with a response deadline. It needs a hardware security module, PIN handling and PCI DSS v4 controls. Those are specialist services, and a certified processor provides them.
- The Türkiye design needs card roles (issuing, and later acquiring) that the bank has no context for today. The bank has no card product, card account or card limit model.
- The design's own risk register rates building card processing in-house as high likelihood and high impact (design risk R8-6).
- The card-data segment must stay in its own PCI scope, outside the rest of the estate.

## Decision (option a, recommended)

1. Buy card authorisation, the hardware security module and PCI card processing from a certified card processor.
2. Keep a thin `crd` context (bounded context code `crd`) that owns the card product, the card account, card limits, the link to the customer, and the issuance lifecycle. For acquiring, it owns the merchant and terminal records.
3. The processor is reached through an anti-corruption layer in the Türkiye scheme gateway (ADR-051). Card-processor behaviour does not leak into `crd`.
4. Card numbers (PAN) stay in the processor and the card-data segment. They never reach Camunda (ADR-041), the ledger or events.
5. The card fraud score for authorisation stays in risk (`rsk`).
6. If the owner accepts this option, the `crd` code is added to the naming standard, and the repository is named and opened then. The example name in the design is `neo-fintechbankx-cards-issuing-acquiring-service`, and Governance confirms the name at that time.

## Alternatives

- **Build card authorisation in-house** (D8-K2, option b). Not recommended: PCI DSS scope, hardware security module operation and the response-time budget would all sit with the bank.
- **Keep card fields inside `pay`** (D8-K3, option b). Not recommended: payments would own card products and PCI-scoped data.

## Consequences

- The processor contract and certification are the user's responsibility, and are prerequisites for any card role.
- Card roles follow ADR-051 scope: first issuing with the international co-badge, acquiring last.
- The card work does not start until the owner accepts this option.

## Related

ADR-041, ADR-051.
