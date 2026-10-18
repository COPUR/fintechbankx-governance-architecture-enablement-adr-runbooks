# ADR-040: Camunda Workers and Process API in a Separate `bpo` Service

## Status

Proposed

## Date

2026-10-18. Source: the Camunda architecture design of 2026-10-18 (not in a repository, unverified; design questions C8-K5, C8-K6, C8-K7 and F5-K6). Approval: user message cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz (2026-10-18 02:31:54Z), which approves the recommended options. No decision cards were posted.

## Context

- The Camunda client starter supports Spring Boot 3.5.x and 4.1.x. Our services run on Boot 3.3, which is outside that range.
- Domain services must not depend on the process engine (F5-K6).
- Human tasks need one controlled entry point for the staff web.

## Decision

1. A new repository, context code `bpo`, holds the Camunda client and every job worker. It contains:
   - `bpo-process-api`: start and status queries, and the human-task entry point that the staff web uses. Personal data stays out of Camunda.
   - `bpo-worker-<family>`: job workers per family (payments, lending, onboarding, compliance). Each family has its own deployment and its own Keycloak client (ADR-020).
   - `bpo-event-bridge`: Kafka messages in, Camunda messages out, and process milestones published to `evt.bpo.process.v1`.
2. Workers call domain services through their published APIs, as an anti-corruption layer, using mTLS and client credentials. They never read another service's tables.
3. `bpo` runs on Spring Boot 4.1.x.
4. Human tasks reach the staff web through `bpo-process-api`, and four-eyes checks are enforced in that API. Camunda Tasklist is used only for operational tasks that hold no personal data.
5. Domain services carry no Camunda dependency. An ArchUnit rule enforces this.

## Alternatives

- **Each domain service runs its own worker.** Rejected. The engine client would spread into domain services, and each one would hit the Boot version mismatch.
- **Camunda Connectors in production.** Rejected (ADR-038).

## Consequences

- A new repository and deployments under the platform chart rules.
- The ledger's caller list (`SERVICE_CALLERS`) must include each worker's client id. This is a provider change, not a separate ADR.
- Worker code is owned by the squad that owns the flow, through code owners.

## Related

ADR-002, ADR-020, ADR-028, ADR-038, ADR-041.
