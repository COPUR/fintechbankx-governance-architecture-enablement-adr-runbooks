# Spotify Squad Plan and To-Be Repository Design

## Purpose

Define a **planning-only** transformation model for splitting the current monorepo into separate repositories aligned to:

1. Spotify model (tribes, squads, chapters, guilds)
2. DDD bounded contexts
3. Event-driven integration
4. High cohesion / low coupling execution

## Planning Constraint

- This artifact **does not modify runtime code**.
- Existing repository remains source-of-truth until extraction waves are approved.

## Guiding Architecture Rules

1. One bounded context has one primary owning squad.
2. Each service owns its data store and schema.
3. No cross-service direct DB access.
4. API-first and event-contract-first before implementation.
5. Shared code is limited to primitives and contract tooling, not domain logic.

## To-Be Spotify Topology

## Tribes and Mission

| Tribe | Mission | Scope |
| --- | --- | --- |
| Open Finance Tribe | External ecosystem-facing capabilities | Consent, AIS, CoP, metadata, open data |
| Lending and Money Movement Tribe | Core lending and payment execution | Loan lifecycle, payment initiation, recurring/bulk/RtP |
| Platform and Reliability Tribe | Shared runtime and delivery platform | Identity, mesh, eventing, CI/CD, observability, IaC |

## Squad Allocation (Primary Ownership)

| Squad | Tribe | Primary Services / Products | Primary Upstream Dependencies |
| --- | --- | --- | --- |
| Consent and Authorization Squad | Open Finance | Consent lifecycle and authorization APIs | Identity Platform, Event Platform |
| Retail Financial Data Squad | Open Finance | Personal financial data service | Consent APIs, Customer profile API |
| Corporate Financial Data Squad | Open Finance | Business financial data service | Consent APIs, Corporate treasury data |
| Payee and Metadata Squad | Open Finance | Confirmation of payee and metadata enrichment | Customer profile API, Event Platform |
| Open Data Squad | Open Finance | Product catalog and ATM directory | Platform security baseline only |
| Loan Lifecycle Squad | Lending and Money Movement | Loan origination, servicing, schedules | Customer, Risk, Compliance |
| Payment Orchestration Squad | Lending and Money Movement | Payment initiation and settlement | Risk, Compliance, Identity |
| Recurring and Bulk Payments Squad | Lending and Money Movement | VRP, mandates, file/bulk orchestration, RtP | Payment orchestration, Compliance |
| Customer and KYC Squad | Lending and Money Movement | Customer profile, KYC, onboarding | Identity, Compliance |
| Risk and Compliance Decisioning Squad | Lending and Money Movement | Risk decisions and compliance evidence | Event Platform, Customer/Loan/Payment events |
| Identity Platform Squad | Platform and Reliability | Keycloak, LDAP federation, DPoP and token policies | None |
| Mesh Security Squad | Platform and Reliability | Istio strict mTLS, authz baseline, network policies | Identity Platform |
| Event Platform Squad | Platform and Reliability | Kafka, schema registry, AsyncAPI governance | None |
| DevSecOps Enablement Squad | Platform and Reliability | Jenkins/GitLab templates, quality/security gates | None |
| Observability and SRE Squad | Platform and Reliability | OTel baseline, SLOs, incident runbooks | Mesh and Event Platform |
| Infrastructure and Data Platform Squad | Platform and Reliability | Terraform modules, DB/cache standards, GitOps drift control | DevSecOps Enablement |

## Chapters

- Java 23 Chapter
- Security Engineering Chapter
- Test Engineering Chapter
- Data Engineering Chapter
- SRE Chapter

## Guilds

- DDD Guild
- Event-Driven Architecture Guild
- FAPI and DPoP Guild
- API Governance Guild
- Platform Engineering Guild

## To-Be Repository Naming Standard

- Prefix by business platform and capability.
- Use lowercase kebab-case.
- Avoid use-case numeric naming.
- Keep one deployable service per repo for runtime services.

Pattern:

- Runtime service repos: `<capability>-service`
- Platform repos: `platform-<capability>`
- Contract repos: `contracts-<capability>`
- Governance repos: `governance-<capability>`

## Proposed To-Be Repository Inventory

## Open Finance runtime repositories

1. `fintechbankx-openfinance-consent-authorization-service`
2. `fintechbankx-openfinance-personal-financial-data-service`
3. `fintechbankx-openfinance-business-financial-data-service`
4. `fintechbankx-openfinance-payee-verification-service`
5. `fintechbankx-openfinance-banking-metadata-service`
6. `fintechbankx-openfinance-open-products-catalog-service`
7. `fintechbankx-openfinance-atm-directory-service`

## Core domain runtime repositories

1. `fintechbankx-lending-loan-lifecycle-service`
2. `fintechbankx-payments-initiation-settlement-service`
3. `fintechbankx-payments-recurring-mandates-service`
4. `fintechbankx-payments-bulk-orchestration-service`
5. `fintechbankx-payments-request-to-pay-service`
6. `fintechbankx-customer-profile-kyc-service`
7. `fintechbankx-risk-decisioning-service`
8. `fintechbankx-compliance-evidence-service`

## Platform repositories

1. `fintechbankx-platform-identity-keycloak-ldap`
2. `fintechbankx-platform-service-mesh-security`
3. `fintechbankx-platform-event-streaming`
4. `fintechbankx-platform-observability-sre`
5. `fintechbankx-platform-delivery-templates`
6. `fintechbankx-platform-terraform-modules`

## Contract and governance repositories

1. `fintechbankx-contracts-openapi-catalog`
2. `fintechbankx-contracts-asyncapi-catalog`
3. `fintechbankx-contracts-schema-registry`
4. `fintechbankx-governance-architecture-adr-runbooks`

## DDD and Event-Driven Interaction Contract

## Bounded Context Ownership

| Bounded Context | Owning Squad | Primary Aggregates | Publish Events | Consume Events |
| --- | --- | --- | --- | --- |
| Consent | Consent and Authorization Squad | Consent, AuthorizationGrant | `consent.created`, `consent.authorized`, `consent.revoked` | Customer lifecycle events |
| Personal Financial Data | Retail Financial Data Squad | AccountReadModel, TransactionReadModel | `account.snapshot.updated` | Consent events |
| Business Financial Data | Corporate Financial Data Squad | CorporateAccountReadModel, LiquiditySnapshot | `corporate.snapshot.updated` | Consent events |
| Payee Verification | Payee and Metadata Squad | PayeeDirectoryEntry, MatchDecision | `payee.verified` | Customer update events |
| Loan | Loan Lifecycle Squad | LoanApplication, LoanAccount, PaymentSchedule | `loan.created`, `loan.approved`, `loan.disbursed` | Risk/Compliance decision events |
| Payment | Payment Orchestration Squad | PaymentInstruction, PaymentExecution | `payment.initiated`, `payment.settled`, `payment.failed` | Risk/Compliance decision events |
| Risk | Risk and Compliance Decisioning Squad | RiskAssessment, RiskDecision | `risk.assessed` | Payment and loan request events |
| Compliance | Risk and Compliance Decisioning Squad | ComplianceDecision, AuditEvidence | `compliance.checked`, `audit.recorded` | Payment and loan request events |
| Customer | Customer and KYC Squad | CustomerProfile, KycState | `customer.created`, `customer.kyc.verified` | Identity events |

## Approved Integration Pattern

1. Command/query API calls for immediate decision points.
2. Event propagation for state synchronization and reporting.
3. Outbox pattern for all event-producing services.
4. Schema compatibility validation for all event evolution.

## Wave-Based Parallel Extraction Plan

## Wave 0: Platform Baseline

Owners: Platform and Reliability Tribe

Deliverables:

1. Identity baseline (Keycloak/LDAP/DPoP policies)
2. Mesh security baseline (STRICT mTLS + authz policy pack)
3. Event platform baseline (Kafka + schema registry + AsyncAPI policy)
4. Delivery templates baseline (Jenkins/GitLab quality gates)
5. Terraform module baseline (network, compute, secrets, observability)

## Wave 1: Low-risk Open Finance Services

Owners: Open Finance Tribe

Deliverables:

1. Payee verification service repo creation and contract freeze
2. Open products catalog service repo creation
3. ATM directory service repo creation

## Wave 2: Consent and AIS Services

Owners: Open Finance Tribe

Deliverables:

1. Consent and authorization service repo creation
2. Personal financial data service repo creation
3. Business financial data service repo creation
4. Metadata service repo creation

## Wave 3: Core lending and payment

Owners: Lending and Money Movement Tribe

Deliverables:

1. Loan lifecycle repo creation
2. Payment initiation and settlement repo creation
3. Recurring, bulk, and request-to-pay repo creation

## Wave 4: Cross-cutting completion

Owners: All tribes

Deliverables:

1. Customer, risk, compliance runtime split completion
2. Contract catalog centralization
3. Governance and runbook repos fully operational

## Quality Gates Required Before Any Repo Cutover

1. Contract tests green (OpenAPI/AsyncAPI).
2. Architecture rules green (domain layer purity).
3. Coverage threshold met (>=85% minimum).
4. Security gates green (SAST/SCA/secrets/SBOM/signing).
5. Observability baseline present (trace id, metrics, structured logs).
6. Rollback playbook and migration runbook approved.

## Decision Summary

This plan keeps current repository stable while enabling independent, parallelized execution through a squad-aligned repo strategy with explicit ownership and integration contracts.
