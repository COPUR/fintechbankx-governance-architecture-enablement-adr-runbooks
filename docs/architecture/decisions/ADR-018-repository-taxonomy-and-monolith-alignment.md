# ADR-018: Repository Taxonomy and Monolith Alignment

## Status

Proposed. Needs Architecture Board approval; the new repositories in section 6 additionally need Board approval of their context codes before anyone creates them.

## Date

2026-10-08

## Context

The `enterprise-loan-management-system` monolith is being decomposed into 26 `COPUR/fintechbankx-*` repositories. Three naming schemes are in circulation for the same repositories:

1. the **actual** GitHub names, which carry a pillar prefix (for example `fintechbankx-lendingpayments-loan-lifecycle-core`);
2. the **canonical** names used by the bootstrap manifest, the tribe/squad strategy and each repository's `MIGRATION_GRANULARITY.md` (for example `fintechbankx-lending-loan-lifecycle-service`);
3. the naming standard's repository pattern `<domain-or-platform>-<capability>-service` (enterprise-architecture repo, `NAMING_CONVENTION_DDD_EDA_BUSINESS_CONTEXT.md`).

Nothing records which name is authoritative where, which pillar a repository belongs to, or which monolith paths each repository is meant to own. Several monolith modules have no target repository at all (core-banking placeholders under `bank-wide-services`, `amanahfi-platform/*`, `masrufi-framework`, and five Open Finance capability packages under `open-finance-context/open-finance-infrastructure/src/main/java/com/enterprise/openfinance/`). Without one recorded taxonomy, ownership questions get re-decided per pull request and extractions drift.

## Decision

### 1. Pillars

The 26 repositories are grouped into five pillars. The pillar is the second segment of the actual repository name.

| Pillar (name segment) | Tribe | Repositories |
|---|---|---|
| Governance (`governance`) | Governance and Contract Control | 5 |
| Platform (`platform`) | Platform and Reliability Tribe | 6 |
| Lending and payments (`lendingpayments`) | Lending and Money Movement Tribe | 5 |
| Customer, risk and compliance (`customer`, `riskcompliance`) | Lending and Money Movement Tribe | 3 |
| Open finance (`openfinance`) | Open Finance Tribe | 7 |

### 2. Repository register (actual vs canonical)

The **actual** name is used for git, GitHub and CI. The **canonical** name is the key in the bootstrap manifest and the governance documents. Both refer to the same repository; neither is renamed by this ADR.

| Pillar | Actual repository (`COPUR/...`) | Canonical name | Service id | Owning squad | Wave | Seeded from (monolith) |
|---|---|---|---|---|---|---|
| Governance | `fintechbankx-governance-architecture-enablement-enterprise-architecture` | `fintechbankx-enterprise-architecture` | n/a | Architecture Board | n/a | architecture docs, strategy, PlantUML |
| Governance | `fintechbankx-governance-architecture-enablement-adr-runbooks` | `fintechbankx-governance-architecture-adr-runbooks` | `svc-gov-architecture-runbooks` | Architecture Board | 4 | ADRs, runbooks, compliance mappings |
| Governance | `fintechbankx-governance-api-contracts-openapi-catalog` | `fintechbankx-contracts-openapi-catalog` | `svc-ctr-openapi-catalog` | API Governance Guild | 4 | `api/openapi/*.yaml` copies |
| Governance | `fintechbankx-governance-api-contracts-asyncapi-catalog` | `fintechbankx-contracts-asyncapi-catalog` | `svc-ctr-asyncapi-catalog` | API Governance Guild | 4 | naming and guardrail docs |
| Governance | `fintechbankx-governance-api-contracts-schema-registry` | `fintechbankx-contracts-schema-registry` | `svc-ctr-schema-registry` | API Governance Guild | 4 | `database/*.sql` |
| Platform | `fintechbankx-platform-identity-iam-keycloak-ldap` | `fintechbankx-platform-identity-keycloak-ldap` | `svc-idn-keycloak-ldap` | Identity Platform Squad | 0 | Keycloak, Envoy, Vault assets |
| Platform | `fintechbankx-platform-mesh-security-service-mesh` | `fintechbankx-platform-service-mesh-security` | `svc-msh-security` | Mesh Security Squad | 0 | Istio mTLS, RBAC, network policy |
| Platform | `fintechbankx-platform-event-streaming-kafka` | `fintechbankx-platform-event-streaming` | `svc-evt-streaming` | Event Platform Squad | 0 | Kafka config, publishers, topic scripts |
| Platform | `fintechbankx-platform-observability-sre-operations` | `fintechbankx-platform-observability-sre` | `svc-obs-sre` | Observability and SRE Squad | 0 | Prometheus, Grafana, alert rules |
| Platform | `fintechbankx-platform-delivery-iac-cicd-templates` | `fintechbankx-platform-delivery-templates` | `svc-dly-templates` | DevSecOps Enablement Squad | 0 | CI templates, microservice skeleton |
| Platform | `fintechbankx-platform-delivery-iac-terraform-modules` | `fintechbankx-platform-terraform-modules` | `svc-iac-modules` | Infrastructure and Data Platform Squad | 0 | `modules/microservice-base`, `services/<slug>` |
| Lending and payments | `fintechbankx-lendingpayments-loan-lifecycle-core` | `fintechbankx-lending-loan-lifecycle-service` | `svc-ln-loan-lifecycle` | Loan Lifecycle Squad | 3 | `loan-context`, `loan-service` |
| Lending and payments | `fintechbankx-lendingpayments-payment-orchestration-initiation-settlement` | `fintechbankx-payments-initiation-settlement-service` | `svc-pay-initiation-settlement` | Payment Orchestration Squad | 3 | `payment-context`, `payment-service` |
| Lending and payments | `fintechbankx-lendingpayments-payment-orchestration-recurring-mandates` | `fintechbankx-payments-recurring-mandates-service` | `svc-pay-recurring-mandates` | Recurring and Bulk Payments Squad | 3 | `recurringpayments` in `open-finance-context` |
| Lending and payments | `fintechbankx-lendingpayments-payment-orchestration-bulk-orchestration` | `fintechbankx-payments-bulk-orchestration-service` | `svc-pay-bulk-orchestration` | Recurring and Bulk Payments Squad | 3 | `bulkpayments` in `open-finance-context` |
| Lending and payments | `fintechbankx-lendingpayments-payment-orchestration-request-to-pay` | `fintechbankx-payments-request-to-pay-service` | `svc-pay-request-to-pay` | Recurring and Bulk Payments Squad | 3 | `requesttopay` in `open-finance-context` |
| Customer, risk and compliance | `fintechbankx-customer-profile-kyc-core` | `fintechbankx-customer-profile-kyc-service` | `svc-cus-profile-kyc` | Customer and KYC Squad | 4 | `customer-context` |
| Customer, risk and compliance | `fintechbankx-riskcompliance-risk-decisioning-core` | `fintechbankx-risk-decisioning-service` | `svc-rsk-decisioning` | Risk and Compliance Decisioning Squad | 4 | `risk-context` |
| Customer, risk and compliance | `fintechbankx-riskcompliance-compliance-evidence-core` | `fintechbankx-compliance-evidence-service` | `svc-cmp-evidence` | Risk and Compliance Decisioning Squad | 4 | `compliance-context` |
| Open finance | `fintechbankx-openfinance-consent-auth-service` | `fintechbankx-openfinance-consent-authorization-service` | `svc-of-consent-authorization` | Consent and Authorization Squad | 2 | `services/openfinance-consent-authorization-service` |
| Open finance | `fintechbankx-openfinance-retail-data-personal-financial` | `fintechbankx-openfinance-personal-financial-data-service` | `svc-of-personal-financial-data` | Retail Financial Data Squad | 2 | `services/openfinance-personal-financial-data-service` |
| Open finance | `fintechbankx-openfinance-corporate-data-business-financial` | `fintechbankx-openfinance-business-financial-data-service` | `svc-of-business-financial-data` | Corporate Financial Data Squad | 2 | `services/openfinance-business-financial-data-service` |
| Open finance | `fintechbankx-openfinance-payee-metadata-payee-verification` | `fintechbankx-openfinance-payee-verification-service` | `svc-of-payee-verification` | Payee and Metadata Squad | 1 | `services/openfinance-confirmation-of-payee-service` |
| Open finance | `fintechbankx-openfinance-payee-metadata-banking-metadata` | `fintechbankx-openfinance-banking-metadata-service` | `svc-of-banking-metadata` | Payee and Metadata Squad | 2 | `services/openfinance-banking-metadata-service` |
| Open finance | `fintechbankx-openfinance-open-data-products-catalog` | `fintechbankx-openfinance-open-products-catalog-service` | `svc-of-open-products-catalog` | Open Data Squad | 1 | `services/openfinance-open-products-service` |
| Open finance | `fintechbankx-openfinance-open-data-atm-directory` | `fintechbankx-openfinance-atm-directory-service` | `svc-of-atm-directory` | Open Data Squad | 1 | `services/openfinance-atm-directory-service` |

Sources: `repository-bootstrap-manifest.csv` and the `fbx-domain-map` skill in the enterprise-architecture repository. The enterprise-architecture repository has no manifest row (it is not a runtime service).

### 3. Naming rule for new repositories

New repositories are named `fintechbankx-<pillar>-<domain>-<capability>` (lowercase kebab-case), matching the actual names above. Each new repository also gets a canonical name per the naming standard (`fintechbankx-<domain>-<capability>-service`, or `platform-` / `contracts-` / `governance-` prefixes for non-runtime repositories), recorded in the manifest. A new pillar or a new context code needs Architecture Board approval.

### 4. One owning squad per repository

Every repository has exactly one owning squad, recorded in its `README.md` ownership block, in `CODEOWNERS` and in the manifest. A squad may own several repositories; a repository never has two owning squads.

### 5. Alignment matrix as source of truth

`docs/alignment/MONOLITH_TO_REPO_ALIGNMENT_MATRIX.md` in `fintechbankx-governance-architecture-enablement-enterprise-architecture` is the single source of truth for which monolith path maps to which repository, what has been extracted, and what remains. Each repository's `MIGRATION_GRANULARITY.md` must agree with it; where they disagree, the matrix wins and the repository file is corrected. It is introduced by enterprise-architecture PR #15 (draft, 2026-10-08) together with a CI check that fails when a monolith folder, Gradle module or root migration has no row.

### 6. Proposed new repositories for unhomed capabilities

These monolith capabilities have no target repository. Each is a **proposal**: it needs Board approval of the context code, an owning squad, a manifest row and its own ADR before any repository is created. Names and codes are suggestions.

| Monolith source | Proposed actual name | Proposed context code | Notes |
|---|---|---|---|
| `bank-wide-services`, `bankwide` (core-banking accounts and ledger, today README placeholders) | `fintechbankx-corebanking-accounts-ledger-core` | `cbk` (new) | New pillar `corebanking`. Ledger is the system of record for balances; loan and payments post to it by API or event. |
| `amanahfi-platform/*` (onboarding, accounts, payments, murabaha, compliance, risk, gateway, event-streaming; own shared kernel) | `fintechbankx-islamicfinance-amanahfi-core` | `isf` (new) | New pillar `islamicfinance`. Whether amanahfi becomes one repository or one per sub-context is an open question. |
| `masrufi-framework` (Islamic finance extension: murabaha, musharakah, ijarah) | `fintechbankx-islamicfinance-masrufi-extension` | `isf` | Overlaps amanahfi `murabaha-context`; the Board must decide whether to merge it into the amanahfi repository first. |
| `open-finance-context` package `corporatetreasury` | `fintechbankx-openfinance-corporate-data-corporate-treasury` | `of` | Same tribe as corporate financial data. |
| `open-finance-context` package `fxservices` | `fintechbankx-openfinance-fx-remittance-fx-services` | `of` | |
| `open-finance-context` packages `insurancedata`, `insurancequotes` | `fintechbankx-openfinance-insurance-data-quotes` | `of` | |
| `open-finance-context` package `dynamiconboarding` | `fintechbankx-openfinance-onboarding-dynamic-onboarding` | `of` | PII stays with the customer context; this service holds onboarding session state only. |

`common/*`, `shared-infrastructure` and `integration-context/kafka-connect-open-finance-smt` are not new runtime repositories: shared code is vendored per service or published as a library; the SMT belongs with `fintechbankx-platform-event-streaming-kafka` (to be confirmed by the Event Platform Squad).

## Alternatives

- **Rename all repositories to their canonical names.** Rejected for now: renames break clone URLs, branch protections and CI links across 26 repositories for no functional gain. Can be revisited (reversible).
- **Drop the canonical names.** Rejected: the manifest, naming lint and service ids key on them.
- **One repository per pillar.** Rejected: re-creates the shared release train the decomposition is meant to remove.

## Consequences

- Placing a change, a new aggregate or a new endpoint becomes a lookup in one register plus the alignment matrix.
- Governance documents must use canonical names; git and CI use actual names. Tooling that crosses the two must use the mapping in section 2.
- The alignment matrix becomes a maintained artefact; extraction PRs update it in the same change set.
- Proposed repositories stay proposals until the Board approves them; capabilities in section 6 remain in the monolith meanwhile.
- Each runtime repository deploys into the Kubernetes namespace of its bounded context (`lending`, `payments`, `customer`, `risk`, `compliance`, `open-finance`), not one namespace per pillar (ADR-023). The pillar is an ownership grouping, not a runtime boundary.
- Supersedes nothing. Related: ADR-001 (DDD), ADR-002 (Hexagonal), ADR-015 (Open Finance source of truth), ADR-019 to ADR-024.
