# ADR-019: Kafka Topic and Event Naming

## Status

Proposed. Section 7's question (one topic per event type or per aggregate) was decided by the owner on 2026-10-08: one topic per aggregate. Sections 1, 3, 5 and 8 carry that decision.

## Date

2026-10-08

## Context

Topics in the estate follow at least two schemes. The naming standard (enterprise-architecture repo, `NAMING_CONVENTION_DDD_EDA_BUSINESS_CONTEXT.md`) prescribes `evt.<context-code>.<aggregate>.<event-name>.v<major>`, while `fintechbankx-platform-event-streaming-kafka` `scripts/kafka/create-topics.sh` still creates monolith-style topics such as `customer.events` and `customer.created` unconditionally. The monolith's `DomainEvent` interface (`shared-kernel/src/main/java/com/enterprise/shared/domain/event/DomainEvent.java`) exposes aggregate id, type, version, occurred-at, correlation and causation ids and a `Map<String, Object>` payload, but no event id, producer or event type, so consumers cannot deduplicate or route reliably. As contexts move into their own repositories, each producer must publish to a predictable topic with a predictable envelope.

## Decision

### 1. Topics

- Domain event topics: one topic per aggregate, `evt.<ctx>.<aggregate>.v<major>`, for example `evt.ln.loan.v1` and `evt.pay.payment.v1`. `<ctx>` is the context code and `<aggregate>` is the namespace's short aggregate name in lowercase kebab-case, as fixed for the service in the repository bootstrap manifest. It need not spell the aggregate's class name: `Risk.RiskAssessment.*` is published on `evt.rsk.risk.v1`, `Payments.PayRequest.*` on `evt.pay.rtp.v1` and `Payments.BulkFile.*` on `evt.pay.bulk.v1`. `evt.<ctx>.<aggregate>` is the event namespace of the producing service (one namespace per aggregate). Every event of the aggregate goes to that topic, so all events of one aggregate instance stay in one partition and in order. The event is named by its `eventType` (section 4), carried in the envelope and in the `eventType` record header, not by the topic.
- Event type to topic: `<Context>.<Aggregate>.<PastTenseEvent>.v<major>` is published on `evt.<ctx>.<aggregate>.v<topic major>`, where `evt.<ctx>.<aggregate>` is the producing service's namespace, for example `Lending.Loan.Disbursed.v1` on `evt.ln.loan.v1`. The event's major and the topic's major are independent (section 5).
- Dead-letter topics: `evt.<ctx>.<aggregate>.dlq.v<major>`, that is `<namespace>.dlq.v<major>` where `<namespace>` is the event namespace of the **consuming** service, for example `evt.pay.payment.dlq.v1` for messages that a payments consumer could not process.
- DLQs are consumer-owned (decided 2026-10-08, architecture guild). A consumer that gives up on a record writes it to the DLQ in its own namespace, never to a DLQ in the source topic's namespace. The loan service dead-letters a failed `evt.pay.payment.v1` record to `evt.ln.loan.dlq.v1`; an open-finance account-data consumer uses `evt.of.account.dlq.v1`. The source is identified by the `dlq-original-topic`, `dlq-original-partition`, `dlq-original-offset` and `dlq-consumer-group` headers (AsyncAPI catalog `asyncapi/common/event-envelope.yaml`, `DeadLetterHeaders`). Reasons: the team that must fix and replay a failure owns its DLQ, alerts and retention; a service's IAM policy only grants writes to its own namespace (ADR-024), so no service needs write access to another context's topics; failures of different consumers of one topic do not mix. A service that consumes without publishing domain events still gets one namespace for its DLQ, provisioned with its consumer topics.
- Retry topics, where used, follow the same namespace: `<namespace>.retry-<delay>.v1`.
- The owning service is the only producer to its topics. Topics are created by the platform's topic provisioning (Event Platform Squad), never by applications at start-up in shared environments. The topic catalog (names, partitions, retention, producer and consumer identities) lives in `fintechbankx-platform-event-streaming-kafka`, as stated in the platform contract (platform contract, 2026-10-08, owned by the platform pillar).
- Cluster, client authentication and producer defaults are decided in ADR-024.

### 2. Consumer groups

`cg.<service-id>.<purpose>.v<major>`, for example `cg.svc-cmp-evidence.payment-compliance-check.v1`. One group per consuming purpose; a group is never shared between services. Client settings that go with these names (group ids, the outbox relay metrics such as `outbox.oldest.pending.age.seconds`, the W3C `traceparent` header carried through the broker, DLQ headers) are in `docs/guides/SERVICE_CLIENT_CONFIGURATION.md` of `fintechbankx-platform-event-streaming-kafka`.

### 3. Record key and headers

The record key is the `aggregateId`, as UTF-8 text. With one topic per aggregate this keeps every event of one aggregate instance in one partition and therefore in order, which the loan origination and repayment sagas rely on (ADR-003). The partition count of an aggregate topic is fixed once a consumer exists: changing it moves keys between partitions and breaks ordering, so it is a breaking change (section 5).

Every record carries these headers, as UTF-8 text (AsyncAPI catalog `common/event-envelope.yaml`, `EventHeaders`):

| Header | Required | Value |
|---|---|---|
| `eventType` | yes | Same value as the envelope `eventType`, for example `Lending.Loan.Disbursed.v1`. Consumers route on it without parsing the value. |
| `eventId` | yes | Same value as the envelope `eventId`. |
| `correlationId` | yes | Same value as the envelope `correlationId`. |
| `traceparent` | when tracing | W3C trace context. |
| `x-fapi-interaction-id` | when the flow started at a FAPI API | The interaction id. |

A consumer reads the `eventType` header first. It handles the types it subscribes to and skips any other type: it commits the offset without processing, never fails and never dead-letters it. A record with no `eventType` header is unroutable: the consumer counts it and logs a warning, commits the offset and does not dead-letter it. A record whose header and envelope `eventType` differ is a poison record and goes to the consumer's DLQ. A new event type on a topic is therefore additive.

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

Additive, optional fields are non-breaking and keep the event's major. Adding a new event type to an aggregate topic is non-breaking, because consumers skip types they do not handle (section 3). A breaking change to one event creates a new event major on the same topic: the producer publishes both `...Disbursed.v1` and `...Disbursed.v2` (two records, same key, in that order) until every consumer of v1 has moved, then stops v1 with an announced end date. Removing an event type from a topic is breaking and follows the same path. The topic's own major (`evt.ln.loan.v2`) changes only when the topic contract itself breaks: the record key, the partition count or the cleanup policy. Then the producer dual-publishes to both topics until every consumer has moved. The source of truth for consumers is the AsyncAPI catalog: each consuming service declares a `receive` operation on the topic in its own spec and lists the topic under `consumes` in `catalog/index.json`, and `check-asyncapi-catalog.mjs` cross-checks the two, then retires the old event major or topic with an announced end date.

Each producer repository gates its own AsyncAPI file in its required `ci/test` check, so a breaking change fails where it is made rather than when it is mirrored: `asyncapi validate` on the spec and the catalog's breaking check (`asyncapi-breaking.mjs` with its rules, compared with `origin/main`) run on every PR. Versions count from the first time a spec lands on the catalog's `main`; before that a spec is pre-release and stays `1.0.0` (asyncapi-catalog README, "Change rules"). The shared CI template carries the step (with `ASYNCAPI_DIR` naming the provider's spec directory); until it does, providers copy the catalog's script unchanged. The provider gate compares with the provider's own `main` and stays strict there: a breaking change to a spec that is on the provider's `main` but not yet on the catalog's `main` is accepted with a waiver line marked `pre-release: not on catalog main`, the spec keeps `1.0.0`, and the waiver goes stale once the change is on `main`. A provider opts in with `publishes-events: true`; the template keeps opt-in as its default, because many repositories publish no events, and the catalog index's owner field names the repositories that must opt in.

### 6. Legacy topics

Monolith-style topics (`customer.events`, `loan.created`, ...) are created only when `CREATE_LEGACY_TOPICS=true` is set for the topic provisioning script, default false. They exist only to serve monolith consumers during strangler cut-over and are deleted with the monolith code that uses them. This is not implemented yet: `scripts/kafka/create-topics.sh` on `fintechbankx-platform-event-streaming-kafka` `main` creates them unconditionally.

### 7. Open question for the owner

**One topic per event type, or one topic per aggregate?** Decided by the owner on 2026-10-08 (decision card in the project, option "Per aggregate"): one topic per aggregate keyed by its id, with `eventType` in a header, so that per-aggregate ordering holds for the loan origination and repayment sagas (ADR-003). The alternative, one topic per event type with consumers reordering by `aggregateVersion`, was rejected because every saga consumer would have to buffer and reorder.

### 8. Migration from per-event topics

Nothing publishes to the per-event topics yet, so there is no dual-run. Each `evt.<ctx>.<aggregate>.<event>.v1` topic in the platform's topic list and in the AsyncAPI contracts is replaced by its aggregate topic `evt.<ctx>.<aggregate>.v1`; for example the seven `evt.ln.loan.*.v1` topics become `evt.ln.loan.v1`. The platform removes the per-event topics from its provisioning script (owned by the platform pillar), and each outbox relay writes the aggregate topic with the `eventType` header. Dead-letter, retry and legacy topics are unchanged. The AsyncAPI contracts stay at pre-release `1.0.0`, because none is on the catalog's `main`.

## Alternatives

- **Keep monolith topic names.** Rejected: not machine-parseable, no owner or version in the name.
- **Avro envelope with Confluent wire format.** Not chosen now: the schema-registry repository holds JSON Schemas (ADR-022); can be revisited (reversible before first production topic).

## Consequences

- Topic ACLs can be derived from the name (producer = owner of `evt.<ctx>.<aggregate>`).
- Consumers receive every event type of an aggregate and skip the ones they do not handle; the header makes that cheap. Per-aggregate ordering is guaranteed by the partition, so sagas need no reordering buffer.
- Every producer needs an envelope builder and every consumer an inbox keyed on `eventId`; the monolith `DomainEvent` must gain `eventId`, `eventType` and `producer` in the anti-corruption adapters.
- Topic creation becomes a platform change, not an application side effect.
- Topic names are effectively irreversible once consumers exist; renames go through the v2 dual-publish path.
- Related: ADR-003 (Saga), ADR-017 (Open Finance eventing), ADR-021, ADR-022, ADR-024. Aligned with the platform contract (platform contract, 2026-10-08, owned by the platform pillar), which fixes the same topic and DLQ patterns.
