# Runbooks

Operational and migration runbooks for the FinTechBankX estate. Imported runbooks name their source path in `enterprise-loan-management-system`; the scripts and manifests they call still live there. Target-state material is **Proposed** until an owning squad has run it and attached evidence.

| Runbook | Purpose | Origin |
|---|---|---|
| [RUNBOOK-EXTRACT-service-cutover](RUNBOOK-EXTRACT-service-cutover.md) | Generic strangler cut-over for one context: pre-checks, schema provisioning, backfill and verify, shadow, flag switch, rollback, decommission | New, Proposed |
| [ST-039 Drill A: Identity Degradation](ST-039_DRILL_A_IDENTITY_DEGRADATION_RUNBOOK.md) | Contain Keycloak/JWKS degradation within the pilot cell | Monolith `docs/operations/` |
| [ST-039 Drill B: Event Lag](ST-039_DRILL_B_EVENT_LAG_RUNBOOK.md) | Detect and recover Kafka consumer lag in the pilot path | Monolith `docs/operations/` |
| [ST-039 Drill C: AZ Disruption](ST-039_DRILL_C_AZ_DISRUPTION_RUNBOOK.md) | Single-AZ disruption and cell containment | Monolith `docs/operations/` |
| [Open Finance Observability](OPEN_FINANCE_OBSERVABILITY_RUNBOOK.md) | Alerts, trace continuity and reconciliation for the Open Finance outbox event path | Monolith `docs/operations/` |
| [Local Kubernetes + Istio](LOCAL_K8S_ISTIO_RUNBOOK.md) | Local kind cluster with Istio strict mTLS | Monolith `docs/technical/` |

Related: [migration runbook template](../transformation-outputs/migration-runbook-template.md), [ADR index](../architecture/decisions/README.md).
