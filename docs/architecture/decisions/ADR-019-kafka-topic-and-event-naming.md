# ADR-019: Kafka Topic and Event Naming

## Status

Proposed. One question (section 7) is open and must be decided by the owner before the first lending or payments topic is created on a shared cluster.

## Date

2026-10-08

## Context

Topics in the estate follow at least two schemes. The naming standard (enterprise-architecture repo, `NAMING_CONVENTION_DDD_EDA_BUSINESS_CONTEXT.md`) prescribes `evt.<context-code>.<aggregate>.<event-name>.v<major>`, while `fintechbankx-platform-event-streaming-kafka` `scripts/kafka/create-topics.sh` still creates monolith-style topics such as `customer.events` and `customer.created` unconditionally. The monolith's `DomainEvent` interface (`shared-kernel/src/main/java/com/enterprise/shared/domain/event/DomainEvent.java`) exposes aggregate id, type, version, occurred-at, correlation and causation ids and a `Map<String, Object>` payload, but no event id, producer or event type, so consumers cannot deduplicate or route reliably. As contexts move into their own repositories, each producer must publish to a predictable topic with a predictable envelope.

## Decision

### 1. Topics

- Domain event topics: `evt.<ctx>.<aggregate>.<event>.v<major>`, for example `evt.ln.loan.disbursed.v1`, `evt.pay.payment.settled.v1`. `<ctx>` is the context code, `<aggregate>` and `<event>` are lowercase kebab-case, `<event>` is a past-tense fact.
- Dead-letter topics: `evt.<ctx>.<aggregate>.dlq.v<major>`, that is `<namespace>.dlq.v<major>` where `<namespace>` is the event namespace of the **consuming** service, for example `evt.pay.payment.dlq.v1` for messages that a payments consumer could not process.
- DLQs are consumer-owned (decided 2026-10-08, architecture guild). A consumer that gives up on a record writes it to the DLQ in its own namespace, never to a DLQ in the source topic's namespace. The loan service dead-letters a failed `evt.pay.payment.*` record to `evt.ln.loan.dlq.v1`; an open-finance account-data consumer uses `evt.of.account.dlq.v1`. The source is identified by the `dlq-original-topic`, `dlq-original-partition`, `dlq-original-offset` and `dlq-consumer-group` headers (AsyncAPI catalog `asyncapi/common/event-envelope.yaml`, `DeadLetterHeaders`). Reasons: the team that must fix and replay a failure owns its DLQ, alerts and retention; a service's IAM policy only grants writes to its own namespace (ADR-024), so no service needs write access to another context's topics; failures of different consumers of one topic do not mix. A service that consumes without publishing domain events still gets one namespace for its DLQ, provisioned with its consumer topics.
- Retry topics, where used, follow the same namespace: `<namespace>.retry-<delay>.v1`.
- The owning service is the only producer to its topics. Topics are created by the platform's topic provisioning (Event Platform Squad), never by applications at start-up in shared environments. The topic catalog (names, partitions, retention, producer and consumer identities) lives in `fintechbankx-platform-event-streaming-kafka`, as stated in the platform contract (platform contract, 2026-10-08, owned by the platform pillar).
- Cluster, client authentication and producer defaults are decided in ADR-024.

### 2. Consumer groups

`cg.<service-id>.<purpose>.v<major>`, for example `cg.svc-cmp-evidence.payment-compliance-check.v1`. One group per consuming purpose; a group is never shared between services. Client settings that go with these names (group ids, the `outbox_pending_events` gauge, the W3C `traceparent` header carried through the broker, DLQ headers) are in `docs/guides/SERVICE_CLIENT_CONFIGURATION.md` of `fintechbankx-platform-event-streaming-kafka`.

### 3. Record key

The record key is the `aggregateId`. This keeps all events of one aggregate in one partition and therefore in order.

### 4. Envelope

Every event value is a JSON object with this envelope:

| Field | Type | Meaning |
|---|---|---|
| `eventId` | UUID | Unique per event; consumers deduplicate on it (inbox). |
| `eventType` | string | `<Context>.<Aggregate>.<PastTenseEvent>.v<major>`, for example `Payments.Payment.Settled.v1`. |
| `occurredAt` | RFC 3339 UTC timestamp | When the fact happened in the producer. |
| `aggregateId` | string | Same value as the record key. |
| `aggregateVersion` | integer | Aggregate version after the change; consumers detect gaps and reordering with it. |
| `correlationId` | string | Business flow id, propagated end to end (with `x-fapi-interaction-id` at the edge). |
| `causationId` | string | `eventId` or command id that caused this event. |
| `producer` | string | Service id of the producer, for example `svc-pay-initiation-settlement`. |
| `data` | object | Event payload, described by a JSON Schema in the schema registry (ADR-022). |

Events are published from the transactional outbox (ADR-021), never by a direct dual write.

### 5. Versioning and breaking changes

Additive, optional fields are non-breaking and stay on the same topic. A breaking change creates a new major topic (`.v2`); the producer dual-publishes to `.v1` and `.v2` until every consumer has moved. The source of truth for consumers is the AsyncAPI catalog: each consuming service declares a `receive` operation on the topic in its own spec and lists the topic under `consumes` in `catalog/index.json`, and `check-asyncapi-catalog.mjs` cross-checks the two, then retires `.v1` with an announced end date.

### 6. Legacy topics

Monolith-style topics (`customer.events`, `loan.created`, ...) are created only when `CREATE_LEGACY_TOPICS=true` is set for the topic provisioning script, default false. They exist only to serve monolith consumers during strangler cut-over and are deleted with the monolith code that uses them. This is not implemented yet: `scripts/kafka/create-topics.sh` on `fintechbankx-platform-event-streaming-kafka` `main` creates them unconditionally.

### 7. Open question for the owner

**One topic per event type, or one topic per aggregate?** Section 1 follows the naming standard (one topic per event type). With one topic per event type, Kafka orders events of one aggregate only within one topic, so a saga consumer that needs `LoanApproved` before `LoanDisbursed` must reorder using `aggregateVersion`. With one topic per aggregate (`evt.<ctx>.<aggregate>.v1`, event type in the envelope), ordering per aggregate is guaranteed by the partition, at the cost of consumers filtering events they do not need. This matters for the loan origination and repayment sagas (ADR-003). Not decided by this ADR.

## Alternatives

- **Keep monolith topic names.** Rejected: not machine-parseable, no owner or version in the name.
- **Avro envelope with Confluent wire format.** Not chosen now: the schema-registry repository holds JSON Schemas (ADR-022); can be revisited (reversible before first production topic).

## Consequences

- Topic ACLs can be derived from the name (producer = owner of `evt.<ctx>.<aggregate>`).
- Every producer needs an envelope builder and every consumer an inbox keyed on `eventId`; the monolith `DomainEvent` must gain `eventId`, `eventType` and `producer` in the anti-corruption adapters.
- Topic creation becomes a platform change, not an application side effect.
- Topic names are effectively irreversible once consumers exist; renames go through the v2 dual-publish path.
- Related: ADR-003 (Saga), ADR-017 (Open Finance eventing), ADR-021, ADR-022, ADR-024. Aligned with the platform contract (platform contract, 2026-10-08, owned by the platform pillar), which fixes the same topic and DLQ patterns.
