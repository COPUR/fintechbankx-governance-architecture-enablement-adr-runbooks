# ST-039 Drill B Runbook: Event Lag and Recovery Containment

> Source: `enterprise-loan-management-system` `docs/operations/ST-039_DRILL_B_EVENT_LAG_RUNBOOK.md` (imported 2026-10-08, text unchanged). Script, manifest and document paths below are paths in that monolith repository; they have not been moved to the split repositories yet.

## Objective

Validate that Kafka/event-stream lag in the pilot path is detected, contained, and recovered without violating synchronous service resilience boundaries.

## Preconditions

1. Pilot services publish/consume events under the cell-specific topic namespace.
2. Lag metrics and consumer health dashboards are active.
3. Alerting exists for lag threshold breaches.
4. Backpressure and retry settings are configured.

## Safety Guardrails

1. Do not exceed agreed lag saturation threshold.
2. Keep producer throttling and consumer restart procedures ready.
3. Abort if data loss risk appears in broker/consumer logs.

## Fault Injection Method

Recommended methods (choose one per run):
1. Consumer throttling (reduce consume throughput).
2. Consumer pause/restart window.
3. Broker-side controlled network latency for selected topic traffic.

Automation command (local surrogate mode):

```bash
scripts/operations/st039/run-drill-b-event-lag.sh
```

## Execution Steps

1. Capture baseline for:
   - consumer lag
   - publish latency
   - end-to-end processing delay
2. Apply selected lag injection scenario.
3. Drive steady synthetic traffic.
4. Observe:
   - lag growth curve
   - alert trigger timing
   - service behavior under lag conditions
5. Remove injection and execute recovery action.
6. Verify lag burn-down and processing catch-up.

## Expected Results

1. Lag alerts trigger within defined detection window.
2. API layer remains available with controlled degradation.
3. No cross-cell synchronous fallback is introduced.
4. Lag recovers to baseline within target MTTR.

## Evidence Requirements

Use:
- `docs/operations/ST-039_DRILL_EVIDENCE_TEMPLATE.md`

Attach:
1. Lag dashboard snapshots (baseline, peak, recovery)
2. Alert and incident timeline
3. Post-recovery data consistency verification results
