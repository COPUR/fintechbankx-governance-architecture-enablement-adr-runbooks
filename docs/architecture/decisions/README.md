# Architecture Decision Records

All ADRs live in this folder, one number per decision. `scripts/ci/check-adr-numbers.sh` enforces this in `ci/test`. New ADRs take the next free number (currently ADR-030). Before taking a number, also check the source monolith's ADR folders so an import cannot collide again.

| ADR | Decision |
|---|---|
| [ADR-001](ADR-001-domain-driven-design.md) | Domain-Driven Design |
| [ADR-002](ADR-002-hexagonal-architecture.md) | Hexagonal Architecture |
| [ADR-003](ADR-003-saga-pattern.md) | Saga Pattern |
| [ADR-004](ADR-004-oauth21-authentication.md) | OAuth 2.1 Authentication |
| [ADR-005](ADR-005-istio-service-mesh.md) | Istio Service Mesh |
| [ADR-006](ADR-006-zero-trust-security.md) | Zero Trust Security |
| [ADR-007](ADR-007-docker-multi-stage-architecture.md) | Docker Multi-Stage Architecture |
| [ADR-008](ADR-008-kubernetes-production-deployment.md) | Kubernetes Production Deployment |
| [ADR-009](ADR-009-aws-eks-infrastructure-design.md) | AWS EKS Infrastructure Design |
| [ADR-010](ADR-010-active-active-architecture.md) | Active-Active Architecture |
| [ADR-011](ADR-011-multi-entity-banking-architecture.md) | Multi-Entity Banking Architecture |
| [ADR-012](ADR-012-international-compliance-framework.md) | International Banking Compliance Framework |
| [ADR-013](ADR-013-non-functional-requirements-architecture.md) | Non-Functional Requirements Architecture |
| [ADR-014](ADR-014-ai-ml-architecture.md) | AI/ML Architecture |
| [ADR-015](ADR-015-open-finance-source-of-truth.md) | Open Finance Source of Truth (was ADR-007 in `docs/architecture/adr/`) |
| [ADR-016](ADR-016-open-finance-integration.md) | Open Finance Integration Architecture (was ADR-012 in `docs/adr/`) |
| [ADR-017](ADR-017-open-finance-bounded-context-eventing-deployment.md) | Open Finance Bounded-Context Eventing and Portable Deployment (was ADR-015 in the monolith's `docs/architecture/decisions/`) |
| [ADR-018](ADR-018-repository-taxonomy-and-monolith-alignment.md) | Repository Taxonomy and Monolith Alignment (Proposed) |
| [ADR-019](ADR-019-kafka-topic-and-event-naming.md) | Kafka Topic and Event Naming (Proposed) |
| [ADR-020](ADR-020-service-to-service-token-policy.md) | Service-to-Service Token Policy (Proposed) |
| [ADR-021](ADR-021-database-per-service-and-data-migration.md) | Database per Service and Data Migration (Proposed) |
| [ADR-022](ADR-022-contract-catalogs-ownership.md) | Contract Catalogs Ownership (Proposed) |
| [ADR-023](ADR-023-kubernetes-namespace-per-bounded-context.md) | Kubernetes Namespace per Bounded Context with Mesh Default-Deny and IRSA (Proposed) |
| [ADR-024](ADR-024-kafka-runtime-msk-iam-and-producer-defaults.md) | Kafka Runtime: Amazon MSK with IAM Auth and Producer Defaults (Proposed) |
| [ADR-025](ADR-025-resource-server-token-validation.md) | Resource-Server Token Validation: Issuer, Audience, DPoP (Proposed) |
| [ADR-026](ADR-026-incremental-backfill-before-cutover.md) | Incremental (Upsert) Backfill Until Cut-Over (Proposed) |
| [ADR-027](ADR-027-ci-runs-check-with-coverage-gate.md) | CI Runs `check` So Quality Gates Are Enforced (Proposed) |
| [ADR-028](ADR-028-hexagonal-guardrails-profile-for-split-repositories.md) | Hexagonal Guardrails Profile for the Split Repositories (Proposed) |
| [ADR-029](ADR-029-test-first-and-monolith-regression-parity.md) | Test-First Delivery and Regression Parity with the Monolith as Fitness Functions (Proposed) |

## Superseded texts

ADR-009 and ADR-010 each existed twice: a December 2024 text and a 2025-01-08 revision. The revision is current; the older texts are kept in [superseded/](superseded/).

## Renumbering map

Numbers changed when ADRs from several monolith folders were brought into this one folder. Source paths are in `enterprise-loan-management-system`.

| Here | Monolith source | Reason |
|---|---|---|
| ADR-015 | `docs/architecture/adr/ADR-007-open-finance-source-of-truth.md` | ADR-007 is Docker Multi-Stage Architecture |
| ADR-016 | `docs/adr/ADR-012-open-finance-integration.md` | ADR-012 is International Banking Compliance Framework |
| ADR-017 | `docs/architecture/decisions/ADR-015-open-finance-bounded-context-eventing-deployment.md` | ADR-015 is Open Finance Source of Truth |
