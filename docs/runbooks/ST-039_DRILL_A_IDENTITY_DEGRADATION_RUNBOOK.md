# ST-039 Drill A Runbook: Identity Degradation and Timeout Containment

> Source: `enterprise-loan-management-system` `docs/operations/ST-039_DRILL_A_IDENTITY_DEGRADATION_RUNBOOK.md` (imported 2026-10-08, text unchanged). Script, manifest and document paths below are paths in that monolith repository; they have not been moved to the split repositories yet.

## Objective

Validate that identity dependency degradation (Keycloak/JWKS/token introspection latency) is contained within the pilot cell and does not trigger uncontrolled cross-cell cascading failures.

## Preconditions

1. Pilot namespaces are deployed with strict mTLS and deny-by-default policies.
2. Cell traffic is routed to `cell-a` for consent and payment initiation services.
3. Monitoring dashboards and alerts are active for:
   - token validation latency
   - API p95 latency
   - 4xx/5xx rates
4. Change window and rollback owner are assigned.

## Safety Guardrails

1. Abort drill if global authentication error rate exceeds approved threshold.
2. Keep a rollback command prepared before fault injection.
3. Limit injection duration to max 15 minutes in first run.

## Fault Injection Method

Recommended method:
- Inject latency and/or aborts for calls from consent/payment services to identity dependency using Istio VirtualService fault settings.

Automation command:

```bash
scripts/operations/st039/run-drill-a-identity-degradation.sh
```

Example command pattern:

```bash
kubectl apply -f <identity-fault-policy.yaml>
```

Rollback:

```bash
kubectl delete -f <identity-fault-policy.yaml>
```

## Execution Steps

1. Capture pre-injection baseline metrics and traces.
2. Apply fault injection policy.
3. Run synthetic traffic for consent and payment initiation flows.
4. Monitor:
   - timeout behavior
   - retry behavior
   - circuit breaking events
5. Remove fault injection.
6. Confirm system stabilization and recovery.

## Expected Results

1. Requests degrade in a controlled manner (no thread exhaustion storm).
2. Circuit breaker and timeout policies activate as designed.
3. No synchronous cross-cell call explosion is observed.
4. Non-pilot domains remain within normal error budget.

## Evidence Requirements

Use:
- `docs/operations/ST-039_DRILL_EVIDENCE_TEMPLATE.md`

Attach:
1. Before/after dashboards
2. Sample traces showing timeout/circuit behavior
3. Alert timeline and recovery proof
