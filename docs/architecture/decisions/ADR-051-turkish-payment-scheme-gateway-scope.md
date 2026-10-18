# ADR-051: Turkish Payment-Scheme Gateway (`psg-tr`): One Service, Three Deployments, First Scope

## Status

Proposed. Owner decisions: the option is not chosen until the owner answers it.

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the Türkiye payment package (design document 08, not in a repository, unverified where it says so). The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting the recommended options, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- Türkiye has several rails with separate rules: the central bank's fast payment system (FAST), the central bank's EFT and cheque system (PÖS and EFT), the card scheme (BKM, with switch, clearing and chargeback), and the request-to-pay and secure-payment services that run on FAST.
- ADR-043 gives each rail family its own gateway. The design puts all Turkish rails in one repository.
- Membership and certification for FAST, BKM and the Turkish open-banking service are the user's responsibility, and they take time.

## Decision

1. One service and one repository, `neo-fintechbankx-paymentschemes-tr-fast-bkm-gateway-service`, service id `svc-psg-tr` (D8-K1, option a). Its aggregate topic is `evt.psg.tr-instruction.v1` (ADR-043).
2. Three deployments, each with its own timeouts, thread pool, pods and certification (ADR-043, bulkhead):
   - `psg-tr-fast`: FAST outbound and inbound, the alias service (KOLAS), FAST-TR QR, request-to-pay client, secure-payment client and the security layer service;
   - `psg-tr-eft`: EFT and PÖS messages, and the central bank's calendar. Cut-off times belong to `pay`;
   - `psg-tr-bkm`: the card switch interface (it may run through the card processor, ADR-049), clearing files, the QR routing system, the card-scheme directory, chargeback documents and the card-scheme web services.
3. First scope (D8-K4, option a): FAST as a direct participant, and the Turkish open-banking service as the account-holding provider. Then the card issuing role with the international co-badge. Acquiring comes last.
4. Applications to the central bank and to BKM start in phase D5.0, together with legal and compliance work. Development runs against the simulator in parallel (D8-K5, option a).
5. No production traffic before the membership, certification and acceptance tests are passed. Those items are the user's.
6. Rail rules that choose or limit a route (for example, sending an amount above the FAST limit to EFT during business hours, D8-K10) belong to `pay`'s decision tables, not to this gateway.

## Alternatives

- **Three repositories, one per rail** (D8-K1, option b). Not chosen: the rails share the same protocol family and the same team. The three deployments keep the failure domains apart.
- **One deployment for all rails** (D8-K1, option c). Rejected: the bulkhead rule in ADR-043 requires separate deployments.
- **Card role first** (D8-K4, option c). Not chosen: the card role depends on ADR-049, which is still open.

## Consequences

- The design's topic names `evt.psg.tr.v1` and `evt.psg.ae.v1` are replaced by the aggregate topics in ADR-043.
- The service's other aggregates (card transactions, clearing files, settlement cycles) get their own aggregate topics in the same namespace, `evt.psg.tr-<aggregate>.v1`, by the same rule.
- The Türkiye deployments run in Türkiye (ADR-039) and follow the card-data segmentation in ADR-049.
- Chargeback temporary receivables (design D8-K11) and the MASAK purpose field (design D8-K9) are rules of the owning services, not decisions of this ADR.

## Related

ADR-039, ADR-043, ADR-049, ADR-050.
