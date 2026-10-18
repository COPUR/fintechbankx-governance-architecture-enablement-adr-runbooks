# ADR-038: Camunda 8.10 Self-Managed as the Process Orchestrator

## Status

Proposed

## Date

2026-10-18. Source: the Camunda architecture design of 2026-10-18 (not in a repository, unverified; design questions C8-K1, C8-K2, C8-K3, C8-K10, C8-K11, C8-K12). Approval: user message cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz (2026-10-18 02:31:54Z), which approves the recommended options. No decision cards were posted.

## Context

- Money transfer and payment flows need human tasks, timers that run for days, callbacks from payment schemes and compensation.
- The design compared four options with weights: choreography only (outbox and Kafka), Camunda 8 self-managed with a `bpo` service, saga tables in each service, and Camunda 8 SaaS. Self-managed scored highest (144), against 119 for saga tables and 111 for choreography. SaaS was ruled out on residency: Camunda's SaaS regions include no Middle East or Turkey region ([SaaS regions](https://docs.camunda.io/docs/reference/regions/), checked 2026-10-18).
- Camunda 8.10 is the current release. The vendor's support window runs to 2028-04-11 ([release overview](https://docs.camunda.io/docs/reference/announcements-release-notes/overview/), checked 2026-10-18). Production use of a self-managed cluster needs a commercial licence ([licensing update](https://camunda.com/blog/2024/04/licensing-update-camunda-8-self-managed/)). The licence terms are not verified.

## Decision

1. Camunda 8.10 self-managed is the process engine for multi-step business processes. Process state, timers, human tasks and compensation order live there.
2. Licence negotiation starts in phase D5.0. The purchase is the user's.
3. Operate, Tasklist and Admin run with the orchestration cluster. Optimize runs with OpenSearch as its secondary store and is shadow-run from D5.6a.
4. Camunda Connectors stay closed in production. Domain calls go through job workers (ADR-040).
5. Process models are kept in git and reviewed by pull request, with lint. Camunda Hub is for viewing and drafts only.

## Alternatives

- **Camunda 8 SaaS.** Rejected. There is no Middle East or Turkey region ([SaaS regions](https://docs.camunda.io/docs/reference/regions/)).
- **Choreography only.** Rejected. It has no human tasks or days-long timers and does not close the review gap for payments.
- **Saga tables in each service.** Rejected. The same engine would be rewritten in every service.

## Consequences

- A new platform component (Camunda Helm chart 15.x, [8.10 version matrix](https://helm.camunda.io/camunda-platform/version-matrix/camunda-8.10/)). Its values files live in the `bpo` repository (ADR-047), pinned by chart version and sha256. They pass the platform's render guard: images by digest, and no network, mesh, secret-store or alert resources added by our values.
- A commercial licence and an OpenSearch cluster to run ([supported environments](https://docs.camunda.io/docs/reference/supported-environments/)).
- The Camunda client cannot run in the Spring Boot 3.3 services, so it stays in `bpo` (ADR-040).
- The risk of the engine becoming a "god orchestrator" remains. ADR-041 limits what Camunda holds.

## Related

ADR-003, ADR-019, ADR-039, ADR-040, ADR-041, ADR-047.
