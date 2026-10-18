# ADR-017: Open Finance Bounded-Context Eventing and Portable Deployment

> Imported on 2026-10-08 from the source monolith `enterprise-loan-management-system`, where it is `docs/architecture/decisions/ADR-015-open-finance-bounded-context-eventing-deployment.md` (ADR-015 there). Renumbered to ADR-017 because ADR-015 in this repository is Open Finance Source of Truth. The text below is unchanged apart from this note, the heading and the source note in the Compliance section. The Status records the decision as accepted in the monolith; adoption in the split fintechbankx repositories is not evidenced here and is tracked by ADR-018 to ADR-024.

## Status

Accepted - 2026-08-02

## Context

Open Finance capabilities must preserve independent domain models while integrating through reliable asynchronous flows. Database/Kafka dual writes, shared schemas, framework leakage into domain code, Redis-based correctness, and platform-specific manifests would weaken reliability and portability.

## Decision

1. Model Open Finance capabilities as bounded contexts with explicit input/output ports and Anti-Corruption Layers.
2. Keep aggregate mutations within one local PostgreSQL transaction and publish external facts through a dedicated transactional outbox.
3. Capture committed outbox inserts with Debezium and apply fail-closed contract and privacy SMTs before Kafka serialization.
4. Consume with at-least-once semantics, a database inbox, bounded retry topics, and a restricted DLT.
5. Keep Redis cache-aside and outside correctness and readiness boundaries.
6. Package each production capability as an independently executable workload. The Payment Initiation vertical slice is the first executable provider.
7. Use a shared Helm deployment contract for Kubernetes and OpenShift. Deploy stateless application and Connect workers; bind to operator-managed or managed PostgreSQL, Kafka, Redis, identity, secret, and telemetry services.
8. Enforce architecture in tests and deployment posture in rendering/security gates.

## Consequences

Positive:

- Business and messaging boundaries remain explicit.
- Kafka outages do not break committed API mutations.
- Kubernetes and OpenShift use the same workload definition and separate edge adapters.
- OpenShift arbitrary-UID security is supported without privileged SCCs.
- Schema, privacy, replay, and deployment controls produce reviewable evidence.

Costs:

- Delivery is eventually consistent and consumers must handle duplicates.
- Each bounded context owns migrations, contracts, inbox retention, and operational SLOs.
- PostgreSQL replication slots and Kafka lag require active capacity management.
- Production deployment requires managed dependencies, TLS material, workload credentials, and Kafka ACL provisioning.

Rejected alternatives:

- Direct database and Kafka dual writes.
- Shared database tables across bounded contexts.
- Redis-only idempotency.
- One chart that embeds single-node PostgreSQL, Kafka, and Redis for production.
- Separate Kubernetes and OpenShift forks that drift over time.
- Exactly-once claims spanning external systems.

## Compliance

The mandatory implementation rules are defined in `OPEN_FINANCE_DDD_EVENTING_PRINCIPLES.md`. Exceptions require an owner, compensating control, expiry date, and Architecture Review Board approval.

> Source note: `OPEN_FINANCE_DDD_EVENTING_PRINCIPLES.md` lives in the monolith at `docs/architecture/OPEN_FINANCE_DDD_EVENTING_PRINCIPLES.md`; it has not been imported into this repository.
