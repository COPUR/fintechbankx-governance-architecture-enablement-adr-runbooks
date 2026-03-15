# Repository Creation Backlog by Squad (Planning-Only)

## Purpose

Provide a PR-ready backlog to create **new repositories only** (no code migration in this phase), aligned with the approved Spotify model and DDD/event-driven boundaries.

## Backlog Categories

1. Governance and standards
2. Platform foundations
3. Domain repository bootstrap
4. Contract and event governance
5. Readiness and cutover controls

## Epic Backlog

| Epic ID | Category | Priority | Epic | Owner Squad | Estimate (SP) |
| --- | --- | --- | --- | --- | ---: |
| REP-EP-001 | Governance and standards | P0 | Define repo charter, ownership, and contribution controls | DevSecOps Enablement Squad | 8 |
| REP-EP-002 | Platform foundations | P0 | Bootstrap shared pipeline and security templates for all new repos | DevSecOps Enablement Squad | 13 |
| REP-EP-003 | Platform foundations | P0 | Bootstrap platform repos (identity, mesh, eventing, observability, terraform) | Platform and Reliability Tribe | 21 |
| REP-EP-004 | Domain bootstrap | P1 | Bootstrap Open Finance runtime repos with standard skeleton | Open Finance Tribe | 21 |
| REP-EP-005 | Domain bootstrap | P1 | Bootstrap lending and payment runtime repos with standard skeleton | Lending and Money Movement Tribe | 21 |
| REP-EP-006 | Contract governance | P1 | Bootstrap OpenAPI and AsyncAPI contract catalog repos | API Governance Guild | 13 |
| REP-EP-007 | Readiness and cutover | P1 | Define migration runbooks and non-invasive readiness checks | Architecture Board + SRE | 8 |

## Story Backlog

| Story ID | Epic | Priority | Story | Owner Squad | Dependency | Estimate (SP) | Exit Criteria |
| --- | --- | --- | --- | --- | --- | ---: | --- |
| REP-ST-001 | REP-EP-001 | P0 | Publish repo naming and ownership policy | DevSecOps Enablement Squad | None | 3 | Policy approved and linked from governance docs |
| REP-ST-002 | REP-EP-001 | P0 | Standardize CODEOWNERS and branch protection baseline template | DevSecOps Enablement Squad | REP-ST-001 | 5 | Template includes required approvers and mandatory checks |
| REP-ST-003 | REP-EP-002 | P0 | Create Jenkins template for Java 23 + security + coverage gates | DevSecOps Enablement Squad | REP-ST-002 | 5 | Template runs in a sandbox repo and blocks on gate failures |
| REP-ST-004 | REP-EP-002 | P0 | Create GitLab template with equivalent blocking gates | DevSecOps Enablement Squad | REP-ST-003 | 5 | Gate parity documented against Jenkins |
| REP-ST-005 | REP-EP-002 | P0 | Create standard repo skeleton (DDD + hexagonal + test folders) | Architecture Enablement + DevSecOps | REP-ST-001 | 3 | Template published and reusable by scripts |
| REP-ST-006 | REP-EP-003 | P0 | Create `fintechbankx-platform-identity-keycloak-ldap` repo | Identity Platform Squad | REP-ST-005 | 3 | Repo initialized with README, ADR, CI template, IaC stub |
| REP-ST-007 | REP-EP-003 | P0 | Create `fintechbankx-platform-service-mesh-security` repo | Mesh Security Squad | REP-ST-005 | 3 | Repo initialized and policy baseline documented |
| REP-ST-008 | REP-EP-003 | P0 | Create `fintechbankx-platform-event-streaming` repo | Event Platform Squad | REP-ST-005 | 3 | Repo initialized with AsyncAPI and schema conventions |
| REP-ST-009 | REP-EP-003 | P1 | Create `fintechbankx-platform-observability-sre` and `fintechbankx-platform-terraform-modules` repos | Observability and Data Platform Squads | REP-ST-005 | 5 | Both repos initialized with baseline standards |
| REP-ST-010 | REP-EP-004 | P1 | Create open finance consent and AIS repos | Open Finance Tribe | REP-ST-003, REP-ST-004, REP-ST-005 | 8 | 4 repos created with standard skeleton and pipeline wiring |
| REP-ST-011 | REP-EP-004 | P1 | Create open finance payee, metadata, products, ATM repos | Open Finance Tribe | REP-ST-010 | 8 | 4 repos created with standard skeleton and pipeline wiring |
| REP-ST-012 | REP-EP-005 | P1 | Create loan and payment orchestration repos | Lending and Money Movement Tribe | REP-ST-003, REP-ST-004, REP-ST-005 | 8 | 5 repos created with standard skeleton and pipeline wiring |
| REP-ST-013 | REP-EP-005 | P1 | Create customer, risk, compliance repos | Lending and Money Movement Tribe | REP-ST-012 | 8 | 3 repos created with standard skeleton and pipeline wiring |
| REP-ST-014 | REP-EP-006 | P1 | Create `fintechbankx-contracts-openapi-catalog` repo and publication workflow | API Governance Guild | REP-ST-003, REP-ST-004 | 5 | Contracts lint and compatibility gate are active |
| REP-ST-015 | REP-EP-006 | P1 | Create `fintechbankx-contracts-asyncapi-catalog` and `fintechbankx-contracts-schema-registry` repos | API Governance Guild | REP-ST-014 | 5 | Async contracts validated and version policy published |
| REP-ST-016 | REP-EP-007 | P1 | Create migration runbook template for non-disruptive code extraction | Architecture Board + SRE | REP-ST-010, REP-ST-012 | 3 | Runbook includes rollback, observability, and acceptance checklist |
| REP-ST-017 | REP-EP-007 | P1 | Create cutover-readiness checklist and scorecard for each new repo | Architecture Board + SRE | REP-ST-016 | 3 | Checklist published and linked to release governance |

## Execution Status Snapshot (2026-03-13)

| Story ID | Status | Notes |
| --- | --- | --- |
| REP-ST-001 | Complete | Naming and ownership policy published with `fintechbankx-` repo convention. |
| REP-ST-002 | Complete | Branch protection baseline executed across `main`, `dev`, `staging`. |
| REP-ST-003 | Complete | Jenkins template/skeleton propagated through bootstrap seed structure. |
| REP-ST-004 | In Progress | GitLab parity script generated, but execution blocked (`glab` missing in runtime). |
| REP-ST-005 | Complete | Standard DDD/hexagonal skeleton seeded to all target repositories. |
| REP-ST-006 | Complete | Repo created and bootstrapped. |
| REP-ST-007 | Complete | Repo created and bootstrapped. |
| REP-ST-008 | Complete | Repo created and bootstrapped. |
| REP-ST-009 | Complete | Repos created and bootstrapped. |
| REP-ST-010 | Complete | Open Finance consent + AIS repos created and bootstrapped. |
| REP-ST-011 | Complete | Open Finance payee/metadata/products/ATM repos created and bootstrapped. |
| REP-ST-012 | Complete | Loan + payment orchestration repos created and bootstrapped. |
| REP-ST-013 | Complete | Customer, risk, compliance repos created and bootstrapped. |
| REP-ST-014 | Complete | OpenAPI contracts repo created with bootstrap branch and PR. |
| REP-ST-015 | Complete | AsyncAPI and schema repos created with bootstrap branch and PRs. |
| REP-ST-016 | Complete | Migration runbook template published in `migration-runbook-template.md`. |
| REP-ST-017 | Complete | Cutover scorecard published in `cutover-readiness-scorecard.md`. |

## Suggested Milestones

| Milestone | Scope | Included Stories |
| --- | --- | --- |
| `MS-REPO-FOUNDATION` | Governance and templates | REP-ST-001 to REP-ST-005 |
| `MS-REPO-PLATFORM` | Platform repository bootstrap | REP-ST-006 to REP-ST-009 |
| `MS-REPO-OPENFINANCE` | Open Finance repository bootstrap | REP-ST-010, REP-ST-011 |
| `MS-REPO-CORE-DOMAINS` | Core lending/payment/customer/risk/compliance bootstrap | REP-ST-012, REP-ST-013 |
| `MS-REPO-CONTRACTS-CUTOVER` | Contract repos and migration readiness | REP-ST-014 to REP-ST-017 |

## Non-Goals for This Backlog

1. No runtime code migration in current repository.
2. No production cutover in this phase.
3. No data migration execution in this phase.

## Acceptance Gate for Planning Completion

1. Repo list approved by architecture board.
2. Squad ownership approved by tribe leads.
3. Platform and contract repos accepted by governance guilds.
4. Migration runbook template and cutover scorecard approved.
