# ADR-039: One Camunda Cluster per Jurisdiction, No Tenants

## Status

Proposed

## Date

2026-10-18. Source: the Camunda architecture design of 2026-10-18 (not in a repository, unverified; design question C8-K4). Approval: user message cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz (2026-10-18 02:31:54Z), which approves the recommended option. No decision cards were posted.

## Context

- Customer data for the UAE must stay in the UAE, and Turkish data in Türkiye (design quality attribute Q3).
- Camunda's SaaS has no region for either jurisdiction (ADR-038).
- A shared cluster with tenants would hold both jurisdictions' process data in one store. The design expects a review under the Turkish outsourcing and data-transfer rules (KVKK and BDDK). That legal opinion is not in hand.

## Decision

1. Two self-managed Camunda clusters: one for the UAE and one for Türkiye. No cluster serves both jurisdictions.
2. The Türkiye cluster runs in a Turkish data centre or local cloud. Its exact location waits for the legal opinion.
3. Tenant mode is not used.
4. Each cluster has its own backup and restore. Recovery stays inside a region: replication factor 3 gives RPO 0 within the region, with an RTO target of 30 minutes. Cross-region disaster recovery is not built.

## Alternatives

- **One shared cluster with tenants.** Rejected. Process data from both jurisdictions would sit in one store.
- **One UAE cluster for Türkiye too.** Rejected. Cross-border transfer rules apply to Turkish data.

## Consequences

- Two installations, two sets of runbooks and two upgrade windows.
- Cross-region disaster recovery is unavailable. Regional recovery depends on restore drills.
- Each BPMN deployment goes to both clusters. The release pipeline must handle both.

## Related

ADR-011, ADR-012, ADR-038.
