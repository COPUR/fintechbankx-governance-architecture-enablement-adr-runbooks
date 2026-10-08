# ADR-029: Test-First Delivery and Regression Parity with the Monolith as Fitness Functions

## Status

Proposed

## Date

2026-10-08

## Context

The user asked for the 26 domains to be built as hexagonal Spring services with a TDD approach, and for a regression test at the end that compares their behaviour with the monolith (`COPUR/enterprise-loan-management-system`, branch `master`). Some of this is already covered:
- ADR-027 makes CI run `check` with a coverage gate.
- ADR-028 adds ArchUnit layer rules.
- ADR-026 covers data backfill until cut-over.

Nothing yet states the following, and coverage alone does not prove them:
- Tests are written before the behaviour they cover.
- An extracted capability behaves like the monolith code it replaces.

## Decision

### 1. Test-first (TDD) fitness functions

1. **Red before green.** A pull request that changes behaviour in `src/main` adds or changes a test that fails on the base branch and passes on the head. The PR description names that test and shows the failing run on the base. Reviewers, the `quality-engineer` role agent included, reject behaviour changes without it.
2. **Tests travel with code.** A pull request that changes `src/main/` without changing `src/test/` fails. Label `no-behaviour-change` opts out; reviewers check that the label is true for refactors, renames and generated code. The shared workflow `.github/workflows/tdd-gate.yml` in `fintechbankx-platform-delivery-iac-cicd-templates` implements this (logic and tests in `scripts/ci/tdd-gate.mjs`). Every service repository calls it on `pull_request` with the `labeled` and `unlabeled` events.
3. **Test layers** are ordered as in the `fbx-hexagonal-service` skill: domain unit tests first, then application tests with in-memory ports, then adapter tests (web slice, Testcontainers), then contract tests against the catalogued OpenAPI and AsyncAPI contracts.
4. **Gates on `check`:**
   - coverage (ADR-027)
   - ArchUnit (ADR-028; the repository's own tests plus the shared gate in `java-service-ci.yml`)
   - contract and breaking-change checks (ADR-022)

### 2. Regression parity with the monolith

1. **Scenario catalog keyed by the alignment matrix.** Each regression scenario names the matrix row id it covers (`LP-01`, `CR-03`, ...). The matrix in the enterprise-architecture repository (`docs/alignment/monolith-to-repo-alignment.csv`) is the stable reference: ids are never renumbered or reused.
2. **Same input, two systems.**
   - Each scenario runs against the monolith at a pinned `master` commit and against the extracted service, with the same seed data.
   - It calls the same business operation through each system's API. Where a path changed, the scenario holds an explicit path mapping.
3. **What is compared:**
   - Response status and body after normalisation. Generated ids, timestamps and trace headers are ignored. Money is compared exactly, amount, scale and currency.
   - The resulting state, read back through the API.
   - The domain events emitted, mapped from the monolith's topics to `evt.*` topics (ADR-019).
4. **Accepted differences are listed, not hidden.**
   - An intended change is recorded with the scenario id, the difference and the decision that allows it. Examples: customer `email` optional, an explicit currency where the monolith defaulted to USD.
   - Any other difference fails the run.
5. **Cut-over gate.** A matrix row moves to `filled` (merged with green gates) as before. A capability is not cut over from the monolith until its scenarios pass parity or every difference is accepted (ADR-026, `RUNBOOK-EXTRACT-service-cutover.md`).
6. **Ownership:**
   - The "Regression tests against the monolith" workstream owns the harness and the scenario catalog, and chooses where they live.
   - Service pillars own the scenarios for their rows and fix parity failures in their repositories.

## Alternatives

- **Coverage threshold only.** Rejected: coverage says code ran, not that it was specified first or that it matches the monolith.
- **Compare databases instead of behaviour.** Rejected: schemas differ on purpose (ADR-021). The contract between the systems is behaviour through their APIs and events.

## Consequences

- Every behaviour-changing PR carries red-before-green evidence, which slows the first PRs slightly and removes "tests added later".
- The matrix row ids become a public key that other repositories depend on; renumbering is forbidden.
- Parity runs need the monolith running with seed data; the regression workstream provides that environment.
- Related: ADR-019, ADR-021, ADR-022, ADR-026, ADR-027, ADR-028.
