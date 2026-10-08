# ADR-021: Database per Service and Data Migration

## Status

Proposed

## Date

2026-10-08

## Context

The monolith keeps customer, loan and payment tables in one database, with Flyway migrations in `src/main/resources/db/migration/` and cross-context foreign keys: `payments.loan_id` references `loans(id)` and `payment_installments.installment_id` references `loan_installments(id)` (`V4__Create_payments_table.sql`). The Service Data Ownership Matrix in the enterprise-architecture repo already forbids shared databases between services, and the naming standard defines `db_<context-code>_<capability>_<env>` and `sc_<context-code>_<capability>`. What is missing is the rule for how each service owns its schema and how data leaves the monolith without loss.

## Decision

1. **One schema per service.** Each service owns exactly one Postgres schema `sc_<ctx>_<capability>` (for example `sc_ln_loan_lifecycle`) in its own logical database `db_<ctx>_<capability>_<env>` (for example `db_ln_loan_lifecycle_prod`).
2. **Flyway owned by the service.** Migrations live in the service repository and run from the service's own pipeline with the service's migration role. No other repository migrates that schema.
3. **No cross-service reads.** No service, report or the monolith reads another service's schema. Data crosses contexts by API or event only. Cross-context foreign keys become plain identifier columns (for example `loan_id` in payments) validated through the owning service's API or events.
4. **Transactional outbox, single relay.** A state change and its outgoing events are written in one local transaction to the service's own `outbox` table. One relay per service (Debezium connector or a single poller, per ADR-017) publishes outbox rows to Kafka (ADR-019). Consumers record processed `eventId`s in an inbox table. Relay failures are classified:
   - **Payload errors** that can never succeed for that row (`RecordTooLargeException`, `SerializationException`, `InvalidTopicException`): the relay parks the row (status and error recorded, alert raised) and continues with the next one.
   - **Everything else**, including authorization errors (`TopicAuthorizationException`, SASL/IAM failures), `UnknownTopicOrPartitionException` (the topic is missing or not yet visible: a provisioning fault, not a property of the row) and any unclassified exception: the relay stops the batch without marking the row or anything after it, retries with backoff and alerts. It never skips or parks a row for such an error, however long it lasts (there is no time ceiling), so per-aggregate ordering and the complete event history are kept. The relay exports the age of the oldest pending row, a failure counter tagged by exception class, a parked-event counter that counts every park once, operator parks included, and a gauge of currently parked rows (metric names in the Kafka client guide of `fintechbankx-platform-event-streaming-kafka`); an alert on the oldest pending age pages the owning squad, and the platform's parked-events alert warns it on any new park. Services ship no alert rules of their own; observability owns them. Only an operator may park such a row, by hand, with the reason recorded. Client timeouts follow the Kafka client conventions linked from ADR-019.
5. **Backfill, then verify, then cut over.** Moving existing data from the monolith uses versioned backfill scripts in the target repository, followed by a verification job that compares row counts and per-column checksums (and, for money, balance totals per account and per currency) between source and target. Cut-over happens only after the verification report is clean and attached to the runbook (see `docs/runbooks/RUNBOOK-EXTRACT-service-cutover.md`).
6. **Backfill ordering follows references.** A context is backfilled after the contexts it references: customer before loan, loan (including installments) before payments, payments before compliance evidence. Payments rows referencing loans or installments that are not yet in the loan service fail verification.
7. **DBA bootstrap step.** Databases, schemas and roles (owner, migration, application read-write, read-only for support) are created by a DBA bootstrap step per environment, from the Terraform modules repository or a reviewed SQL script, before the service's first deployment. Services do not create their own database or roles.
8. **Monolith tables are dropped last.** Monolith tables are dropped only after the new service has run through a full business cycle (month-end for loans and payments) with the monolith no longer writing them.

## Alternatives

- **Shared database with schema-per-service and cross-schema views.** Rejected: keeps runtime coupling and blocks independent scaling and migration. Any temporary exception needs its own ADR with an end date.
- **Dual write from the application to old and new stores.** Rejected: no atomicity; use outbox or backfill with verification.
- **Change data capture from the monolith as the long-term integration.** Allowed only as a temporary migration aid behind an anti-corruption layer, not as a permanent contract.

## Known deviations

- The open-finance personal-financial-data, business-financial-data and banking-metadata services keep DocumentDB plus Redis read models instead of an Aurora PostgreSQL schema. Each records that choice in an ADR in its own repository. The ownership rules above still apply: one owner per data set, no reads of another service's store, data in by API or event.

## Consequences

- Reporting and joins across contexts move to event-fed read models or an analytics platform.
- Each extraction needs a backfill script, a verification job and a reconciliation report; this is the slowest part of each slice and must be planned.
- Dropping monolith tables is irreversible; everything before it is reversible by switching the cut-over flag off.
- DBA capacity is needed per environment for bootstrap; until roles exist, services cannot deploy.
- Related: ADR-001, ADR-017, ADR-019.
