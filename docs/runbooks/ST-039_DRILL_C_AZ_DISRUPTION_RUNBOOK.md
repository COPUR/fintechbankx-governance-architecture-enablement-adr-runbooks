# ST-039 Drill C Runbook: Single-AZ Disruption and Cell Containment

> Source: `enterprise-loan-management-system` `docs/operations/ST-039_DRILL_C_AZ_DISRUPTION_RUNBOOK.md` (imported 2026-10-08, text unchanged). Script, manifest and document paths below are paths in that monolith repository; they have not been moved to the split repositories yet.

## Objective

Validate that a single availability zone disruption in the pilot cell does not cause uncontrolled outage propagation beyond defined blast-radius boundaries.

## Preconditions

1. Pilot services run with multi-AZ replica spread policy.
2. PodDisruptionBudget and autoscale settings are active.
3. Service mesh routing and health probes are verified.
4. SRE incident channel and rollback owner are assigned.

## Safety Guardrails

1. Limit disruption to one AZ at a time.
2. Keep rollback and re-scheduling procedures ready.
3. Abort if global availability SLO risk is exceeded.

## Fault Injection Method

Recommended methods:
1. Cordoning and draining pilot-node pool segment mapped to one AZ.
2. Controlled network partition simulation for one AZ segment.

Automation command (local disruption surrogate mode):

```bash
scripts/operations/st039/run-drill-c-az-disruption.sh
```

## Execution Steps

1. Capture pre-drill baseline:
   - request success rate
   - latency p95
   - pod spread across AZs
2. Trigger AZ disruption scenario.
3. Observe re-scheduling and traffic rerouting behavior.
4. Verify:
   - pilot path continuity
   - impact containment outside pilot path
5. Restore normal AZ capacity.
6. Confirm post-recovery baseline convergence.

## Expected Results

1. Service continuity maintained within agreed degraded threshold.
2. Load is shifted to healthy AZs without global cascading failures.
3. Recovery completes within approved RTO.
4. Data consistency and event ordering checks pass post-recovery.

## Evidence Requirements

Use:
- `docs/operations/ST-039_DRILL_EVIDENCE_TEMPLATE.md`

Attach:
1. AZ-level node/pod distribution snapshots
2. Traffic rerouting evidence (mesh telemetry)
3. Recovery timeline and RTO confirmation
