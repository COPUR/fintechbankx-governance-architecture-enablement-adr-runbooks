# Architecture Decision Records

All ADRs live in this folder, one number per decision. `scripts/ci/check-adr-numbers.sh` enforces this in `ci/test`. New ADRs take the next free number (currently ADR-017).

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

## Superseded texts

ADR-009 and ADR-010 each existed twice: a December 2024 text and a 2025-01-08 revision. The revision is current; the older texts are kept in [superseded/](superseded/).
