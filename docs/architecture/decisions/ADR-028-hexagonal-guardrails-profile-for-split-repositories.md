# ADR-028: Hexagonal Guardrails Profile for the Split Repositories

## Status

Proposed

## Date

2026-10-08

## Context

The monolith's `docs/HEXAGONAL_ARCHITECTURE_GUARDRAILS.md` (ADR-001 DDD, ADR-002 hexagonal) prescribes a package layout under the root `com.bank.loanmanagement.<bounded-context>`, with `domain/port/in|out` and `infrastructure/adapter/in|out`. None of the split fintechbankx repositories uses that root. The cores use `com.bank.<context>` and the open-finance and payment-capability services use `com.enterprise.openfinance.<capability>`. Four service pillars are about to make layout passes, and each needs the same answer: is one root required, and which parts of the layout are mandatory?

A scan of each service repository's newest branch on 2026-10-08 also found breaks that the layout question does not cover:
- Loan and payment initiation-settlement services have no use-case interfaces (customer added them in its PR #13).
- Three payment-capability repos carry a domain class that imports Spring.
- The consent service's application layer imports infrastructure, and it holds consents in memory.
- Eight repositories have no ArchUnit tests.

## Decision

1. **Package root is free per repository; one root per repository.** Existing roots stay. New repositories use `com.fintechbankx.<context>.<capability>`. A repository never imports another repository's root.
2. **Layer layout is mandatory** under the root:
   - `domain` (with `domain.port.in` for use-case interfaces and `domain.port.out` for repository and external-service interfaces)
   - `application` (use-case implementations, sagas, DTOs, mappers)
   - `infrastructure.<technology>` (web|rest, persistence, outbox, messaging, external, security, config)

   The monolith's `infrastructure.adapter.in|out` nesting is not required.
3. **Four ArchUnit rules run on `check`** in every service repository. Once `fintechbankx-platform-delivery-iac-cicd-templates` PR #11 merges, they are also enforced centrally by the shared `java-service-ci.yml` workflow in `fintechbankx-platform-delivery-iac-cicd-templates` (its ArchUnit gate, `tools/archunit-gate`). That gate runs the four rules on the compiled classes, whatever the repository's own tests say:
   - The domain depends on no application, infrastructure, Spring, JPA, Kafka or Mongo packages.
   - The application layer depends on no infrastructure package.
   - Inbound adapters depend on `domain.port.in`, not on application implementations.
   - `domain.port.out` implementations live in infrastructure.

   One root per repository (decision 1) is review-only today: the shared gate treats every package prefix with a `.domain` sub-package as a root, so a second root passes the four rules. Platform is asked to pin the root per repository in the gate; until then reviewers check it, and no class may sit in another context's aggregate package.
4. **Data:**
   - The store engine is chosen per service and stays private to it (ADR-021).
   - A system-of-record store has versioned migrations (Flyway, or a versioned change log such as Mongock for MongoDB) and backups.
   - A read model can be rebuilt from events or the owning API.
   - In-memory stores are for tests and local profiles only.
5. **Tests:**
   - Persistence tests use Testcontainers with the real engine, not H2.
   - Coverage follows ADR-027 (85 percent line gate). The monolith's 95 percent domain target is reported and becomes a repository's gate once it is met; a gate is never lowered.
   - Test-first and regression parity are in ADR-029.
6. The profile, the comparison with the monolith guardrails and the per-repository conformance table live in the enterprise-architecture repository, `docs/architecture/guardrails/FINTECHBANKX_SERVICE_GUARDRAILS.md`. Each pillar fixes its own rows during its layout pass.

## Alternatives

- **One root for all repositories (`com.fintechbankx...` everywhere, or the monolith's `com.bank.loanmanagement`).** Rejected:
  - Renaming every package in 15 repositories during extraction changes no dependency.
  - It breaks the diff to the monolith source that backfill and regression work rely on.
  - It collides with open pull requests.
- **Layout advisory only.** Rejected: without ArchUnit the layer rules erode, as the Spring import in three payment-capability domains shows.

## Consequences

- Each service pillar's layout pass makes these changes:
  - It adds `domain.port.in` use-case interfaces where they are missing (loan, payment initiation-settlement).
  - It removes the Spring-annotated `DistributedConsentService` from the recurring-mandates, bulk and request-to-pay domains.
  - It moves the consent service's PKCE settings and OAuth error type out of infrastructure.
  - It gives consent a persistent store.
  - It adds the four ArchUnit rules where they are missing.
- Repositories whose CI still runs `test` go red on coverage when they move to `check` (ADR-027).
- Every repository without `domain.port.in` use cases fails the shared ArchUnit gate (rule 3) as soon as it adopts `java-service-ci.yml`. A repository's own ArchUnit test is not proof of conformance when its rule is looser than the shared one. The gate's `archunit-report-only` input is a temporary, visible escape hatch, removed in the same layout pass.
- Related: ADR-001, ADR-002, ADR-021, ADR-027, ADR-029.
