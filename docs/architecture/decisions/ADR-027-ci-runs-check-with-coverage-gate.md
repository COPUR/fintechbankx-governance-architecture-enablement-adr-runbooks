# ADR-027: CI Runs `check` So Quality Gates Are Enforced

## Status

Proposed

## Date

2026-10-08

## Context

The shared `required-gates.yml` runs `gradle test` in `ci/test`. The service builds define their quality gates (JaCoCo coverage verification at 85 percent, ArchUnit rules wired as verification tasks, static analysis) on the `check` lifecycle task, which `test` does not trigger. The required check can therefore be green while coverage is below the gate. Both the 2026-10-07 repo survey and the 2026-10-08 role-agent review flagged this.

## Decision

1. `ci/test` runs `./gradlew --no-daemon check` (the committed wrapper) in every Gradle repository. `check` depends on `test`, so no test coverage is lost.
2. The coverage threshold lives in each repository's build (`jacocoTestCoverageVerification`), not in the workflow, so it is visible and reviewed with the code. The programme default is 85 percent line coverage on domain and application modules; a repository that cannot meet it on day one sets a lower floor in its build with a dated note and raises it, never removes it.
3. A repository may not add markers or flags that make `check` non-blocking (the removed `.ci/allow-gradle-fail` is the precedent).
4. The reusable `java-service-ci` workflow in `fintechbankx-platform-delivery-iac-cicd-templates` runs `./gradlew check` (platform contract addendum, 2026-10-08). Its opt-out input that runs only `test` is not used by service repositories without an ADR. Each repository's `required-gates.yml` moves to that workflow or to `check` directly.

## Alternatives

- **Keep `test` and add a separate coverage job.** Rejected: two places to keep in sync, and the separate job tends not to be marked required.

## Consequences

- Some repositories will go red when this lands because their coverage is below the gate; that is the point. Each pillar fixes its own repos.
- CI takes slightly longer (report generation and verification).
- Related: ADR-002 (ArchUnit rules), the alignment matrix in the enterprise-architecture repo.
