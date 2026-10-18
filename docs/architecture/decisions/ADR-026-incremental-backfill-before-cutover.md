# ADR-026: Incremental (Upsert) Backfill Until Cut-Over

## Status

Proposed

## Date

2026-10-08

## Context

ADR-021 requires each extracted service to backfill its own schema from the monolith and verify it before cut-over. The role-agent review of the extraction PRs (2026-10-08) found that most backfill scripts insert only rows that have not been copied yet and skip rows already present. The monolith keeps changing those rows until cut-over (loan status, installment payments, customer contact details, credit limits), so a second run leaves the service's copy stale and the verification step can pass on outdated data. The compliance backfill already upserts for this reason.

## Decision

1. Every backfill is re-runnable and **upserts**: rows that exist in the target are updated when the monolith row changed since the previous run; new rows are inserted. Deletions in the monolith are recorded as tombstones or reconciled explicitly, never ignored silently.
2. Change detection uses the monolith's `updated_at` (or equivalent version column) with a high-water mark stored in the target's backfill state table. Where the monolith table has no such column, the run compares a row hash.
3. Rows the new service has already changed itself (after it starts taking writes in shadow or dual-run) are not overwritten by the backfill; such conflicts are logged and fail the verification step.
4. The verification job compares counts and per-row checksums of the business columns after every run, and the final run before the traffic switch must report zero differences.
5. Ordering from ADR-021 still holds (loan before payments).

## Alternatives

- **Single bulk copy at cut-over with a write freeze.** Possible for small tables, but forces downtime proportional to data volume; kept as a fallback for a context whose tables have no change marker.
- **Change data capture (Debezium) from the monolith.** Stronger, but adds Kafka Connect infrastructure that is not in place yet (alignment matrix row PL-07); can replace scripted backfill later.

## Consequences

- Loan, payments, customer and risk backfills need an upsert change and a test that runs the backfill twice with a monolith change in between.
- Monolith tables without `updated_at` need hash comparison, which is slower on large tables.
- Related: ADR-021, the generic cut-over runbook in `docs/runbooks/RUNBOOK-EXTRACT-service-cutover.md`.
