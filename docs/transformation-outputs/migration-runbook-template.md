# Migration Runbook Template (Non-Disruptive Extraction)

## Document Control

- Runbook ID: `RUNBOOK-EXTRACT-<context>-<service>`
- Version: `v1.0`
- Owner Squad:
- Change Window:
- Risk Tier: `Low | Medium | High`

## 1. Objective

Describe the bounded context extraction objective and what is explicitly in/out of scope for this run.

## 2. Preconditions

1. Source and target repositories exist and are accessible.
2. Target repo has `main/dev/staging` protections enabled.
3. Required CI checks are green (`ci/build`, `ci/test`, `ci/security`).
4. OpenAPI/AsyncAPI contract version is pinned and reviewed.
5. Rollback branch/tag created from source and target.

## 3. Change Plan

| Step | Action | Owner | Validation | Rollback Trigger |
| --- | --- | --- | --- | --- |
| 1 | Freeze extraction scope | | Scope checklist approved | Scope drift discovered |
| 2 | Move contracts first | | Contract tests pass | Contract mismatch |
| 3 | Move domain/application modules | | Unit and architecture tests pass | Dependency cycle introduced |
| 4 | Move infrastructure adapters | | Integration tests pass | Adapter fails against baseline |
| 5 | Enable routing/cutover flag | | Smoke and SLO checks pass | Error budget burn > threshold |

## 4. Observability Gate

1. Trace propagation verified (`x-fapi-interaction-id` and correlation IDs).
2. Structured logs available in central sink.
3. Metrics baseline available for latency/error/throughput.
4. Alerts configured for 5xx spikes and latency regressions.

## 5. Rollback Plan

1. Disable cutover flag / routing rule.
2. Repoint traffic to previous stable deployment.
3. Revert source/target repos to rollback tag.
4. Re-run smoke tests on restored path.
5. Publish incident and corrective actions within 24h.

## 6. Acceptance Checklist

- [ ] Domain tests pass
- [ ] Integration tests pass
- [ ] Contract compatibility pass
- [ ] Security scan pass
- [ ] SLO/SLA thresholds pass
- [ ] Audit evidence stored

## 7. Evidence Links

- PR links:
- Pipeline runs:
- Dashboard snapshots:
- Incident/rollback references:

