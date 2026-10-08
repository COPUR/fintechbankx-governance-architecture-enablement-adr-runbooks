# Open Finance Provider Observability Runbook

> Source: `enterprise-loan-management-system` `docs/operations/OPEN_FINANCE_OBSERVABILITY_RUNBOOK.md` (imported 2026-10-08, text unchanged). Script, manifest and document paths below are paths in that monolith repository; they have not been moved to the split repositories yet.

## Purpose

This runbook covers the live, near-real-time, and post-live evidence for the Open Finance provider event path:

`HTTP -> PostgreSQL aggregate + outbox -> Debezium -> Kafka -> payment consumer + inbox`

Operational telemetry is not the statutory audit record. Traces and logs can be sampled, delayed, or unavailable. PostgreSQL aggregate state, outbox rows, inbox rows, DLT audit rows, Kafka offsets, and the governed audit archive are the reconciliation evidence.

## Signal Boundaries

| Signal | Store | Purpose | Default local retention |
|---|---|---|---|
| Metrics | Prometheus | Health, SLOs, lag, saturation, alerting | 15 days |
| Traces | Tempo | Request and asynchronous causality | 7 days |
| Logs | Loki | Triage and operational history | 30 days |
| Provider facts | PostgreSQL outbox and Kafka | Durable state-change evidence and replay | Domain policy |
| Consumer success | PostgreSQL inbox | Committed idempotent processing evidence | Compliance policy |
| Dead letters | Kafka DLT and `event_dlt_audit` | Failed-delivery evidence and replay control | Compliance policy |

Raw customer IDs, account IDs, IBANs, national identifiers, and payment payloads are forbidden in metric labels and trace attributes. The OTel Collector removes known forbidden attributes as a second control. The application emits ECS JSON and limits DLT logs to event and Kafka transport coordinates.

## Local Endpoints

| Component | URL |
|---|---|
| Grafana | `http://localhost:3000` |
| Prometheus | `http://localhost:9090` |
| Alertmanager | `http://localhost:9093` |
| Tempo API | `http://localhost:3200` |
| Loki API | `http://localhost:3100` |
| Alloy UI | `http://localhost:12345` |
| OTel HTTP receiver | `http://localhost:4318` |

The provisioned Grafana dashboard is **Open Finance / Open Finance Unified Observability**. Grafana links a trace ID found in an ECS JSON log to Tempo. Tempo links a selected span back to Loki logs for the same trace.

## Trace Continuity

1. Spring MVC creates or resumes a W3C trace and places `traceId` and `spanId` in logging context.
2. `MdcOutboxEventMetadataProvider` serializes the active span as W3C `traceparent` in the same database transaction as the payment aggregate and outbox row.
3. Debezium EventRouter promotes the outbox `traceparent` column to a native Kafka record header.
4. Spring Kafka listener observations extract that header and create the consumer span on a Java 21 virtual thread.
5. Boot exports spans over OTLP to the Collector. The Collector deletes forbidden identity attributes before sending traces to Tempo.

Debezium capture delay and Kafka queue delay are metrics, not synthetic spans. Do not infer a CDC span where none exists.

## Alert Procedures

### Provider Down

1. Check the application health endpoint and container status.
2. Check PostgreSQL and identity-provider reachability.
3. Confirm Kafka unavailability has not been placed on the synchronous payment transaction path.
4. Search Loki for `service_name="loan-management"` and the deployment time window.

### API Errors

1. Open the API error-ratio panel and isolate the failing route and status.
2. Select an ECS log with a `traceId`, then open the linked Tempo trace.
3. Check Hikari pending connections, Redis latency, and downstream HTTP spans.
4. Escalate security failures without logging bearer tokens or request payloads.

### Payment Latency

1. Compare payment queue delay with Kafka consumer lag.
2. Check active virtual threads and Hikari pending connections. Virtual threads do not increase the database connection limit.
3. Check retry-topic lag separately from the primary command topic.
4. Use the trace to distinguish consumer execution time from time spent waiting in Kafka.

### Consumer Lag

1. Identify whether lag is on the primary, 1-minute retry, or 15-minute retry topic.
2. Confirm consumer group membership and partition assignment.
3. Check database saturation before increasing listener concurrency.
4. Scale only up to the topic partition count and the database capacity envelope.

### Kafka Replication

1. Check `UnderReplicatedPartitions`, `UnderMinIsrPartitionCount`, and offline partitions.
2. Restore broker and storage health before changing acknowledgements or ISR controls.
3. Never weaken `acks=all`, idempotence, or minimum ISR to clear the alert.

### Debezium Lag

1. Check connector task state through Kafka Connect REST.
2. Inspect `MilliSecondsBehindSource`, erroneous events, and queue remaining capacity.
3. Confirm the custom contract and privacy SMT did not fail closed on a contract violation.
4. Check PostgreSQL logical slot WAL retention before restarting or resnapshotting.

### WAL Retention

1. Check whether `open_finance_outbox_v1` is active and whether `confirmed_flush_lsn` advances.
2. Correlate retained WAL growth with Debezium source lag and connector task state.
3. Restore CDC before pruning any outbox data. Table cleanup does not release WAL retained by a stalled slot.
4. Never drop the production replication slot without an approved recovery and resnapshot plan.

### Database Pool

1. Check active, idle, pending, timeout, and acquisition-time Hikari metrics.
2. Correlate pending connections with command concurrency and slow PostgreSQL queries.
3. Reduce listener concurrency or repair slow queries before increasing the pool.

### DLT Triage

1. Query `open_finance.event_dlt_audit` by `event_id` or time range.
2. Search Loki for the same `event_id`; use the associated `traceId` to open Tempo.
3. Inspect the DLT record headers and raw bytes in the restricted operations tool. Do not paste payloads into tickets or chat.
4. Correct the contract, dependency, or data issue.
5. Replay using the original `event_id` and key. The inbox primary key makes an already committed replay a successful no-op.
6. Record operator identity, reason, approval, replay time, and outcome in the governed audit system.

## Reconciliation

Successful command processing evidence:

```sql
SELECT consumer_group, date_trunc('hour', received_at) AS hour, count(*) AS committed_events
FROM open_finance.event_inbox
WHERE received_at >= :from AND received_at < :to
GROUP BY consumer_group, date_trunc('hour', received_at)
ORDER BY hour;
```

Dead-letter evidence:

```sql
SELECT event_id, consumer_group, original_topic, original_partition,
       original_offset, exception_type, traceparent, observed_at
FROM open_finance.event_dlt_audit
WHERE observed_at >= :from AND observed_at < :to
ORDER BY observed_at;
```

Provider event evidence:

```sql
SELECT id, contract_name, contract_version, aggregate_type,
       correlation_id, traceparent, occurred_at
FROM open_finance.event_outbox
WHERE occurred_at >= :from AND occurred_at < :to
ORDER BY occurred_at, id;
```

Do not compare the three row counts as if they represented the same event population. Reconciliation joins require a defined event lineage and consumer contract. Kafka offset evidence and DLT state must be included before declaring a gap or a duplicate.

## Production Controls

- Replace the empty local Alertmanager receiver with the approved on-call integration and load its secret from the platform secret store.
- Run Grafana, Prometheus, Tempo, Loki, and Alertmanager behind SSO, RBAC, TLS, encrypted storage, immutable retention, and access auditing.
- The local Alloy container reads the Docker socket and is for developer use only. Production collectors must use restricted service accounts and platform-native discovery.
- Keep telemetry in a separate security zone from statutory audit storage. Access to one must not imply access to the other.
- Apply deletion holds, legal retention, tenant isolation, and regional residency independently to logs, traces, metrics, and audit records.
