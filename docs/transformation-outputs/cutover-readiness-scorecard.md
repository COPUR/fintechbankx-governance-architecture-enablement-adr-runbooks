# Cutover Readiness Scorecard

## Purpose

Standard readiness gate for promoting a newly extracted repository from bootstrap to active delivery.

## Scoring Model

- `2` = Fully met
- `1` = Partially met
- `0` = Not met

Release is eligible only when:

1. No `0` in any P0 criterion
2. Total score >= 85%

## Readiness Criteria

| Category | Priority | Criterion | Score (0-2) | Evidence |
| --- | --- | --- | ---: | --- |
| Architecture | P0 | Domain layer free from framework/persistence imports | | |
| Architecture | P0 | Ports/adapters boundaries documented and tested | | |
| Security | P0 | mTLS + OAuth/FAPI controls validated in test env | | |
| Security | P0 | DPoP validation path covered by tests (if applicable) | | |
| API Governance | P0 | OpenAPI/AsyncAPI published and contract checks green | | |
| API Governance | P1 | Error model and pagination standards aligned | | |
| CI/CD | P0 | Blocking quality gates enabled (`build/test/security`) | | |
| CI/CD | P1 | Semantic versioning check and compatibility diff enabled | | |
| Operations | P0 | Trace, metrics, structured logs live and searchable | | |
| Operations | P1 | Dashboards and alert thresholds tuned | | |
| Data | P0 | Service data ownership and migration scripts validated | | |
| Data | P1 | Backup/restore drill executed and documented | | |
| Reliability | P0 | Rollback tested (blue/green or canary) | | |
| Reliability | P1 | Load test baseline captured for autoscaling | | |
| Governance | P1 | ADRs and runbooks updated and approved | | |

## Decision

- Total Score:
- P0 Failures:
- Decision: `Go | Conditional Go | No-Go`
- Approvers:
  - Architecture:
  - Security:
  - SRE:
  - Product:

