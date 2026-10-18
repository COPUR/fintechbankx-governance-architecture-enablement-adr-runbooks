# ADR-033: The PSU Authorises VRP and Bulk Payments

## Status

Proposed

## Date

2026-10-18. Answer recorded 2026-10-18 01:45Z to the 2026-10-08 card "VRP and bulk" (cmsg_01TVU6MCNctBZbo8MPkX9s1oBwPpLoLn3iwts6UmtHZRHM, posted 2026-10-08 16:23:11Z). The option chosen was "PSU authorises both".

## Context

Today the consent carries only scopes, selected accounts and expiry. Recurring mandates enforce the limits the TPP sends when it creates a mandate. Bulk payments enforce one file per consent, but the consent does not record which file was authorised. The card states that UAE Open Finance VRP requires PSU-authorised limits, and that limits or files set only by the TPP are not consent.

## Decision

1. **The PSU authorises both.** VRP limits and the bulk payment file are authorised by the PSU on the consent. Limits or files set only by the TPP are not consent.
2. **The consent gains optional VRP control parameters:** the maximum per payment, periodic limits with period type and alignment, the currency, and valid from and to. Mandates enforce only what the PSU authorised.
3. **The consent gains an immutable bulk file object.** It is shown to the PSU at authorisation and locked afterwards. It declares the SHA-256 hash, the file type, the number of transactions, the control sum and the currency. Bulk payments enforce only the authorised file.
4. Both objects are additive and optional on the consent, and they are built together.

## Open

- The VRP monthly limit reset timezone (UTC or Asia/Dubai) and the UAE VRP limit types are not decided here.
- Whether the bulk file object also declares the debtor account was raised separately. The card does not list it, so it is not decided here.

## Alternatives

- **The TPP sets the VRP limits and the bulk file (the card's first option).** Not chosen. The PSU then has no direct control over the amounts it approves.
- **The PSU authorises VRP limits only (the card's third option).** Not chosen. The bulk file stays unrecorded, and bulk keeps its one-file-per-consent rule without the consent knowing the file.

## Consequences

- Open finance changes the consent contract (OpenAPI and AsyncAPI) in its own provider PR before mandates and bulk consume it (ADR-022, provider first).
- Bulk cut-over waits until the bulk file object is exposed.
- Matrix rows LP-08, LP-09 and OF-01 carry Proposed notes pointing here (`monolith-to-repo-alignment.csv`).

## Related

ADR-018, ADR-019, ADR-022, ADR-029.
