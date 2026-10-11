# Migration Granularity Notes

- Repository: `fintechbankx-governance-architecture-adr-runbooks`
- Source monorepo: `enterprise-loan-management-system`
- Sync date: `2026-03-15`
- Sync branch: `chore/granular-source-sync-20260313`

## Applied Rules

- dir: `docs/adr` -> `docs/adr`
- dir: `docs/architecture/adr` -> `docs/architecture/adr`
- dir: `docs/architecture/decisions` -> `docs/architecture/decisions`
- dir: `docs/enterprisearchitecture/compliance-security` -> `docs/compliance-security`
- dir: `docs/enterprisearchitecture/implementation-development/transformation/outputs` -> `docs/transformation-outputs`
- file: `docs/GENERAL_BACKLOG.md` -> `docs/GENERAL_BACKLOG.md`

## Notes

- This is an extraction seed for bounded-context split migration.
- Follow-up refactoring may be needed to remove residual cross-context coupling.
- Build artifacts and local machine files are excluded by policy.
- 2026-10-07: ADRs from `docs/adr` and `docs/architecture/adr` were consolidated into `docs/architecture/decisions` with unique numbers (see its README). A re-sync must map those source folders into `docs/architecture/decisions` and keep the renumbering, or `scripts/ci/check-adr-numbers.sh` will fail.

- 2026-10-08: the monolith's `docs/architecture/decisions/ADR-015-open-finance-bounded-context-eventing-deployment.md` is imported as `ADR-017-open-finance-bounded-context-eventing-deployment.md` (see the renumbering map in `docs/architecture/decisions/README.md`). A re-sync must not copy it back as ADR-015.
- 2026-10-08: runbooks imported into `docs/runbooks/` (each file names its source): `docs/operations/ST-039_DRILL_A_IDENTITY_DEGRADATION_RUNBOOK.md`, `docs/operations/ST-039_DRILL_B_EVENT_LAG_RUNBOOK.md`, `docs/operations/ST-039_DRILL_C_AZ_DISRUPTION_RUNBOOK.md`, `docs/operations/OPEN_FINANCE_OBSERVABILITY_RUNBOOK.md`, `docs/technical/LOCAL_K8S_ISTIO_RUNBOOK.md`.
