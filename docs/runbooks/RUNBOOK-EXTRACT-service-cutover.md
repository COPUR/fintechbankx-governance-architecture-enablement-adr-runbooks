# Strangler Cut-Over Runbook (Generic, per Context)

> Status: **Proposed**. This is the target-state procedure for moving one bounded-context capability out of `enterprise-loan-management-system` into its fintechbankx service repository. No extraction has been cut over with it yet. Copy it per slice as `RUNBOOK-EXTRACT-<context>-<service>.md` and fill every blank. Shape follows `docs/transformation-outputs/migration-runbook-template.md`; data rules follow ADR-021, events ADR-019 and ADR-024, service tokens ADR-020, cluster layout ADR-023.

## Document Control

- Runbook ID: `RUNBOOK-EXTRACT-<context>-<service>` (for example `RUNBOOK-EXTRACT-ln-loan-lifecycle`)
- Version: `v1.0`
- Owner Squad: (owning squad of the target repo, per ADR-018)
- Change Window:
- Risk Tier: `Low | Medium | High` (money, balances or schedules moved: High)
- Cut-over flag: `cutover.<ctx>.<capability>.enabled` (default `false`)
- Rollback tags: monolith `<tag>`, target `<tag>`

## 1. Objective

State the slice (one aggregate or one use-case family), what moves, what stays in the monolith, and how the monolith calls the new service after cut-over (anti-corruption adapter over the service API or events). List the monolith tables that the new service will own.

## 2. Preconditions (pre-checks)

1. Target repository passes `ci/build`, `ci/test`, `ci/security` for real: modules included in `settings.gradle`, no `.ci/allow-gradle-fail` marker, no unresolved project dependencies.
2. OpenAPI and AsyncAPI contracts for the slice are merged in the target and mirrored into the catalogs (ADR-022); event payload schemas are in the schema registry.
3. Topics `evt.<ctx>.<aggregate>.<event>.v1` and the service's own consumer-owned DLQ `evt.<ctx>.<aggregate>.dlq.v1` (ADR-019) are in the topic catalog and provisioned by the Event Platform Squad (RF 3, `min.insync.replicas=2`); the service's topic-scoped MSK IAM policy (`msk-client-access`) is applied (ADR-019, ADR-024).
4. In the target environment: the service account in its context namespace with an IRSA role trusted only for `system:serviceaccount:<ns>:<sa>`; the ALLOW AuthorizationPolicy listing caller principals `cluster.local/ns/<ns>/sa/<sa>`; the Keycloak client (client id = service id, realm `fintechbankx`, role `service`); and the ExternalSecret for `<env>/<service-slug>/oidc-client` via `ClusterSecretStore` `aws-secrets-manager` (ADR-020, ADR-023).
5. Monolith anti-corruption adapter is merged behind the cut-over flag; monolith tests are green with the flag off and on.
6. Dashboards and alerts for the new service exist (latency, error rate, consumer lag, outbox relay lag; outbox gauge `outbox_pending_events`, a proposed metric name).
7. Rollback tags created in the monolith and target repositories.
8. Change approved by the owning squad and, for High risk, the Architecture Board.

## 3. Change Plan

| Step | Action | Owner | Validation | Rollback Trigger |
| --- | --- | --- | --- | --- |
| 1 | Freeze slice scope; list moved tables and endpoints | Owning squad | Scope checklist approved | Scope drift discovered |
| 2 | Schema provisioning: DBA bootstrap creates `db_<ctx>_<capability>_<env>`, schema `sc_<ctx>_<capability>` and roles; service Flyway migrations run | DBA, owning squad | Flyway history clean; roles least-privilege; monolith has no grant on the schema | Migration fails or grants wrong |
| 3 | Deploy the service dark (no traffic), outbox relay running | Owning squad | Health and readiness green; relay connected | Service unhealthy |
| 4 | Backfill run: versioned backfill script copies monolith rows in reference order (customer, loan, payments, compliance) | Owning squad | Script exit 0; run id recorded | Script error or partial load |
| 5 | Backfill verify: verification job compares row counts, per-column checksums and, for money, balance totals per account and currency | Owning squad, quality engineer | Verification report clean and attached under Evidence | Any mismatch |
| 6 | Dual-run / shadow: monolith remains the writer; requests are mirrored to the service (shadow) or the service consumes monolith events; outputs compared | Owning squad | Diff rate within agreed threshold over the agreed window | Diff above threshold |
| 7 | Traffic switch: enable `cutover.<ctx>.<capability>.enabled` per environment (canary share first if routed by mesh rule); monolith stops writing the moved tables | Owning squad | Smoke tests pass; SLOs hold; `x-fapi-interaction-id` traces end to end | Error budget burn above threshold; reconciliation drift |
| 8 | Hold through a full business cycle (month-end for loans and payments) | Owning squad | Daily reconciliation clean | Any reconciliation break |
| 9 | Decommission: remove dead monolith code, then drop or archive the moved monolith tables | Owning squad, DBA | Monolith build green; no references; archive verified | Not reversible after drop (see section 5) |

## 4. Observability Gate

1. Trace propagation verified (`x-fapi-interaction-id`, `correlationId`, `causationId`).
2. Structured logs for the service in the central sink, with no PII in labels or attributes.
3. Metrics baseline for latency, error rate, throughput, consumer lag, outbox relay lag.
4. Alerts configured for 5xx spikes, latency regressions, DLQ arrivals and reconciliation failures.

## 5. Rollback Plan

Steps 1 to 8 are reversible:

1. Disable `cutover.<ctx>.<capability>.enabled` (or revert the mesh routing rule); traffic returns to the monolith.
2. The monolith resumes writing its tables. Writes made by the service after the switch are replayed into the monolith from the service's outbox events, or reconciled manually, before the flag is turned on again.
3. Revert monolith and target to the rollback tags if code changes are implicated.
4. Re-run smoke tests on the restored path.
5. Publish the incident and corrective actions within 24h.

Step 9 (dropping monolith tables) is **irreversible**. Before it: archive the tables, record the archive location and checksum, and get owning-squad and DBA sign-off.

## 6. Acceptance Checklist

- [ ] Domain and application tests pass in the target
- [ ] Integration tests (Testcontainers) pass in the target
- [ ] Contract compatibility pass (provider and catalog)
- [ ] Security scan pass
- [ ] Backfill verification report clean
- [ ] Shadow diff within threshold
- [ ] SLO/SLA thresholds pass after switch
- [ ] Full business cycle completed before decommission
- [ ] Audit evidence stored

## 7. Evidence Links

- PR links:
- Pipeline runs:
- Backfill and verification reports:
- Shadow diff report:
- Dashboard snapshots:
- Incident/rollback references:
