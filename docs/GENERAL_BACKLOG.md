# General Backlog (Architecture, Security, Platform, and Delivery)

## Backlog Purpose

This backlog consolidates enterprise-level work required to move from current-state architecture to target-state platform operations, aligned with:

- Centralized AAA (Keycloak + LDAP + DPoP)
- Service mesh security runtime
- Clean coding and repository hygiene
- Capability maturity uplift

## Execution Artifacts

- Consolidated categorized backlog (single planning view):
  `<repo-root>/docs/CONSOLIDATED_BACKLOG_BY_CATEGORY_2026-03-10.md`
- Architecture scorecard baseline:
  `<repo-root>/docs/enterprisearchitecture/implementation-development/transformation/outputs/architecture-scorecard-latest.md`
- Architecture remediation plan:
  `<repo-root>/docs/enterprisearchitecture/implementation-development/transformation/outputs/architecture-scorecard-remediation-plan.md`
- First PR-ready backlog split by team:
  `<repo-root>/docs/enterprisearchitecture/implementation-development/transformation/outputs/pr-ready-backlog-by-team.md`
- GitHub milestone map:
  `<repo-root>/docs/enterprisearchitecture/implementation-development/transformation/outputs/github-milestone-map.md`
- GitHub issue drafts and creation guide:
  `<repo-root>/docs/enterprisearchitecture/implementation-development/transformation/outputs/github-issue-drafts/`
  `<repo-root>/docs/enterprisearchitecture/implementation-development/transformation/outputs/github-issue-creation-guide.md`
- Verified critique-to-backlog conversion (2026-03-10):
  `<repo-root>/docs/REPORT_VERIFIED_BACKLOG_2026-03-10.md`
- API/platform technical debt remediation backlog (Q042-Q050, DB) (2026-03-10):
  `<repo-root>/docs/architecture/API_TECH_DEBT_REMEDIATION_BACKLOG_2026-03-10.md`
- Extended remediation set added (Q036/Q063/Q064/Q065/Q066/Q067/Q068/Q070):
  `<repo-root>/docs/architecture/API_TECH_DEBT_REMEDIATION_BACKLOG_2026-03-10.md`
- Additional matrix intake added (Q048/Q049/Q069/ADR-011/ADR-012/DB Code):
  `<repo-root>/docs/architecture/API_TECH_DEBT_REMEDIATION_BACKLOG_2026-03-10.md`
- Proven execution log (2026-03-10):
  `<repo-root>/docs/operations/PROVEN_ACTION_LOG_2026-03-10.md`

## Prioritization Model

- `P0` Critical security/compliance or production stability blockers
- `P1` High-value platform and delivery enablers
- `P2` Optimization and developer-experience improvements
- `P3` Deferred or exploratory enhancements

## Epic Backlog

| ID | Priority | Epic | Description | Estimate (SP) | Owner |
| --- | --- | --- | --- | --- | --- |
| EP-001 | P0 | Central AAA Platform | Keycloak HA, LDAP federation, token policies, operational runbooks | 34 | Identity Platform Team |
| EP-002 | P0 | DPoP Enforcement | Gateway DPoP verifier, replay cache, conformance tests | 21 | API Security Team |
| EP-003 | P0 | Mesh Zero-Trust Baseline | Strict mTLS, authz policies, egress controls | 34 | Mesh Platform Team |
| EP-004 | P1 | Distributed AuthZ Agents | OPA/ext_authz policy lifecycle and integration | 21 | Security Platform Team |
| EP-005 | P1 | Observability Baseline | OTel, SIEM integration, SLO dashboards, alert standards | 21 | SRE/Observability Team |
| EP-006 | P1 | CI/CD Security Gates | SAST/SCA/coverage/policy gates and drift detection | 21 | DevSecOps Team |
| EP-007 | P1 | Repository Hygiene | Folder rationalization, naming alignment, deprecation cleanup | 21 | Architecture + Platform |
| EP-008 | P2 | Contract and Test Modernization | OpenAPI/contract tests, integration test stabilization | 13 | Domain Teams |
| EP-009 | P2 | Capability Maturity Program | Quarterly capability scoring and roadmap governance | 8 | Architecture Board |
| EP-010 | P3 | Advanced Resilience | Multi-region failover and chaos automation expansion | 13 | SRE Team |
| EP-011 | P1 | IaC and GitOps Standardization | Terraform module governance, drift automation, and GitOps reconciliation | 21 | Platform Engineering + DevOps |
| EP-012 | P1 | API Runtime Governance | API catalog integrity, contract compatibility, and standards conformance enforcement | 21 | API Governance + DevEx |
| EP-013 | P0 | Compliance and Data Contract Hardening | Tiered compliance execution and contract-aligned schema enforcement | 21 | Compliance Platform + Data Platform |

## Story-Level Backlog (Initial Cut)

| ID | Epic | Priority | Story | Estimate (SP) | Dependency |
| --- | --- | --- | --- | --- | --- |
| ST-001 | EP-001 | P0 | Deploy Keycloak HA in non-prod with PostgreSQL HA | 8 | None |
| ST-002 | EP-001 | P0 | Configure LDAP federation and group-to-role mappers | 5 | ST-001 |
| ST-003 | EP-001 | P0 | Implement realm/client config-as-code with drift checks | 8 | ST-001 |
| ST-004 | EP-002 | P0 | Implement DPoP proof verifier at gateway | 8 | ST-003 |
| ST-005 | EP-002 | P0 | Implement replay cache and replay rejection semantics | 5 | ST-004 |
| ST-006 | EP-002 | P0 | Build DPoP conformance test suite in CI | 8 | ST-004 |
| ST-007 | EP-003 | P0 | Enable sidecar injection and permissive mTLS in staging | 5 | ST-001 |
| ST-008 | EP-003 | P0 | Move selected namespaces to strict mTLS | 8 | ST-007 |
| ST-009 | EP-003 | P0 | Add deny-by-default AuthorizationPolicy baseline | 8 | ST-008 |
| ST-010 | EP-004 | P1 | Integrate ext_authz service with gateway/mesh | 8 | ST-009 |
| ST-011 | EP-004 | P1 | Publish initial ABAC/RBAC policy packs per domain | 8 | ST-010 |
| ST-012 | EP-005 | P1 | Standardize OpenTelemetry and trace propagation | 5 | ST-007 |
| ST-013 | EP-005 | P1 | Build security/latency/error SLO dashboards | 5 | ST-012 |
| ST-014 | EP-006 | P1 | Add policy lint and IaC validation gates | 5 | ST-009 |
| ST-015 | EP-006 | P1 | Enforce coverage >=85% and security blockers | 5 | None |
| ST-016 | EP-007 | P1 | Publish repo structure policy and naming standards | 3 | None |
| ST-017 | EP-007 | P1 | Resolve duplicate/legacy folder ownership mapping | 5 | ST-016 |
| ST-018 | EP-008 | P2 | Add contract tests for high-risk APIs (consent/payment) | 8 | ST-015 |
| ST-019 | EP-009 | P2 | Establish quarterly capability review cadence | 3 | None |
| ST-020 | EP-010 | P3 | Run mesh + identity chaos drills and automate recovery checks | 8 | ST-008 |
| ST-021 | EP-003 | P0 | Add runtime strict-mTLS attestation gate and sidecar-bypass deny validation | 5 | ST-009 |
| ST-022 | EP-006 | P1 | Enforce SBOM generation + cosign signing + provenance verification in release pipelines | 8 | ST-015 |
| ST-023 | EP-010 | P1 | Implement Argo Rollouts/Flagger canary strategy with automated rollback policies | 8 | ST-008 |
| ST-024 | EP-010 | P1 | Publish centralized blue-green/canary runbooks and execute rollback drills with evidence logs | 5 | ST-023 |
| ST-025 | EP-010 | P1 | Integrate k6/Gatling load gates and tune HPA/VPA per workload class | 8 | ST-012 |
| ST-026 | EP-011 | P1 | Extract and version Terraform modules for EKS/network/security baseline | 8 | None |
| ST-027 | EP-011 | P1 | Add tfsec/checkov policy gates and module-consumption enforcement in PR checks | 5 | ST-026 |
| ST-028 | EP-011 | P1 | Implement scheduled Terraform drift detection with GitOps reconciliation alerts | 8 | ST-026 |
| ST-029 | EP-012 | P1 | Tie API catalog generation to deployment artifacts and block undocumented shadow routes | 5 | ST-011 |
| ST-030 | EP-012 | P1 | Enforce SemVer + OAS breaking-change gate and mandate `X-FAPI-Interaction-ID` in contract suites | 5 | ST-029 |
| ST-031 | EP-012 | P1 | Roll out shared RFC 7807 (`ProblemDetail`) error starter and pagination conformance tests | 8 | ST-030 |
| ST-032 | EP-010 | P0 | Implement gateway degraded-mode fallback and retry-storm protection for Redis/cache outage | 8 | ST-023 |
| ST-033 | EP-010 | P1 | Formalize dependency resilience matrix (Keycloak-first timeouts/retries/circuit policies) | 5 | ST-023 |
| ST-034 | EP-005 | P1 | Stream secret rotation events to SIEM with structured JSON and correlation IDs | 5 | ST-012 |
| ST-035 | EP-013 | P0 | Implement tiered event-driven compliance strategy with async offload for non-critical checks | 8 | ST-010 |
| ST-036 | EP-013 | P0 | Add Flyway+Testcontainers sample-data schema gate and complete typed-contract enforcement | 8 | ST-001 |

## Sprint Proposal (First 3 Sprints)

## Sprint 1

- ST-001, ST-002, ST-003, ST-015, ST-016

## Sprint 2

- ST-004, ST-005, ST-007, ST-012, ST-014

## Sprint 3

- ST-006, ST-008, ST-009, ST-010, ST-013

## Sprint 4

- ST-021, ST-022, ST-026, ST-027

## Sprint 5

- ST-023, ST-024, ST-025, ST-028

## Sprint 6

- ST-029, ST-030, ST-033, ST-034

## Sprint 7

- ST-031, ST-032, ST-035, ST-036

## Definition of Ready

1. Clear acceptance criteria and security impact.
2. Test strategy defined (unit/integration/security).
3. Dependencies identified and owned.
4. Rollback strategy documented.

## Definition of Done

1. Code + policy + docs updated.
2. Required tests and quality gates pass.
3. Observability and runbook updates included.
4. Backlog status and architecture traceability updated.

## Wave A Execution Status (Kickoff)

| Item | Status | Evidence |
| --- | --- | --- |
| Repository structure policy published | Done | `docs/architecture/REPOSITORY_STRUCTURE_POLICY.md` |
| Module ownership map published | Done | `docs/architecture/MODULE_OWNERSHIP_MAP.md` |
| PR governance checklist expanded | Done | `.github/pull_request_template.md` |
| CODEOWNERS hardened for governance and shared foundation paths | Done | `.github/CODEOWNERS` |
| CI governance gate added | Done | `.github/workflows/ci.yml`, `tools/validation/validate-repo-governance.sh` |
| Legacy path freeze enforcement | Done | CI blocking in place and policy markers added: `archive/README.md`, `temp-src/README.md`, `simple-test/README.md` |

## Wave B Execution Status (Kickoff)

| Item | Status | Evidence |
| --- | --- | --- |
| Duplicate legacy roots marked deprecated | Done | `bankwide/README.md`, `bank-wide-services/README.md`, `loan-service/README.md`, `payment-service/README.md` |
| Deprecated-root CI enforcement added | Done | `tools/validation/validate-repo-governance.sh` |
| Governance validator implemented with TDD and coverage gate | Done | `tools/validation-node/src/bin/repo-governance-validator.mjs`, `tools/validation-node/test/repo-governance-validator.test.mjs`, CI coverage gate via `c8` (>=90 lines/functions) |
| Local pre-commit governance gate added | Done | `.githooks/pre-commit`, `tools/validation/install-git-hooks.sh` |
| OpenAPI protected-operation DPoP parity governance gate added | Done | `tools/validation-node/src/bin/repo-governance-validator.mjs` validates `api/openapi/*.yaml` security operations include required `DPoP` header |
| Rationalization plan documented | Done | `docs/architecture/WAVE_B_LEGACY_ROOT_RATIONALIZATION_PLAN.md` |
| Dependency/reference inventory for deprecated roots | Done | Build include dependency check enforced; references categorized (runtime service naming vs folder dependency) |
| Residual tracked file cleanup in deprecated roots | Done | `bankwide/build.gradle` removed and deletion path allowed by governance validator |
| Strict deprecated-root cleanliness in CI | Done | `STRICT_DEPRECATED_ROOTS=true` enabled in `.github/workflows/ci.yml` governance gate |
| Jenkins and GitLab templates hardened with governance + coverage gates | Done | `ci/templates/microservice/Jenkinsfile`, `ci/templates/microservice/gitlab-ci.yml`, `ci/templates/bounded-context/gitlab-ci.yml` |
| Open Finance service Jenkinsfiles aligned to hardened baseline | Done | All `services/openfinance-*/Jenkinsfile` include governance stage and strict security tooling checks |
| Full relocation/archive of deprecated roots | Planned | Archive/remove deprecated roots after two release cycles and migration sign-off |

## Wave C Execution Status (2026-02-25)

| Item | Status | Evidence |
| --- | --- | --- |
| `risk-context` implemented with hexagonal module split | Done | `risk-context/risk-domain`, `risk-context/risk-application`, `risk-context/risk-infrastructure` |
| `compliance-context` implemented with hexagonal module split | Done | `compliance-context/compliance-domain`, `compliance-context/compliance-application`, `compliance-context/compliance-infrastructure` |
| Risk and compliance OpenAPI contracts moved from stub to executable contract tests | Done | `api/openapi/risk-context.yaml`, `api/openapi/compliance-context.yaml`, `*OpenApiContractTest` classes |
| Coverage gate script extended for risk and compliance groups | Done | `tools/validation/validate-coverage-gates.sh`, `.github/workflows/ci.yml` |
| Risk context gate at >=85% line coverage | Done | `build/reports/coverage-gates/risk-context.txt` |
| Compliance context gate at >=85% line coverage | Done | `build/reports/coverage-gates/compliance-context.txt` |
| All grouped coverage gates executed without failures for active contexts | Done | `build/reports/coverage-gates/all.txt` |
| Incubating framework modules isolated into explicit non-wave gate group | Done | `tools/validation/validate-coverage-gates.sh --group incubating` |
| Shared foundation and Masrufi coverage baseline uplift | Planned | `build/reports/coverage-gates/incubating.txt` (currently failing by design until tests are added) |
| Runtime credential policy enforced (no real `.env` secrets) | Done | `services/openfinance-consent-authorization-service/README.md`, `docs/architecture/DATA_AT_REST_POLICY.md` |
| Internal runtime secret API implemented | Done | `POST/GET /internal/v1/system/secrets*` in consent authorization service |
| Data-at-rest handling for runtime secrets (masked + hash in DB) | Done | `InternalSystemSecret*` domain/application/persistence implementation |
| Strict mTLS roadmap baseline completed and CI-enforced | Done | `security/service-architecture/service-mesh-config.yaml`, `tools/validation/validate-strict-mtls-baseline.sh`, `tools/validation-node/src/bin/repo-governance-validator.mjs`, `.github/workflows/ci.yml`, `docs/architecture/STRICT_MTLS_ROADMAP_COMPLETION.md` |
| ST-036 schema contract slice expanded (loan/customer/payment/risk/compliance) | In Progress | `*SchemaContractIntegrationTest` + module-scoped Flyway migrations in loan/customer/payment/risk/compliance infrastructure modules; Flyway PostgreSQL support dependency added (`flyway-database-postgresql`) so schema suites execute against PostgreSQL 16 in Docker-enabled runs; CI gate: `.github/workflows/ci.yml` (`schema-contract-data-model`); local sweep command `tools/validation/validate-schema-contract-data-model.sh` auto-detects Colima/Testcontainers settings and executes all contract suites. |
| ST-029 API catalog artifact coupling + shadow-route blocking implemented and CI-enforced | Done | `tools/validation-node/src/bin/generate-api-catalog.mjs`, `tools/validation-node/src/bin/runtime-route-contract-validator.mjs`, `api/contracts/runtime-route-contracts.yaml`, `.github/workflows/ci.yml` (`api-catalog-governance`), delivery artifact `build/reports/api-catalog/API_CATALOGUE.generated.md` |
| ST-030 semver/backward-compat gate hardened (expanded FAPI interaction-header enforcement + provider/consumer contract coverage) | In Progress | `tools/validation-node/src/bin/openapi-semver-compat-validator.mjs`, `tools/validation-node/test/openapi-semver-compat-validator.test.mjs`, `api/contracts/consumer-provider-core.yaml`, `tools/validation-node/src/bin/provider-consumer-contract-validator.mjs`, `.github/workflows/ci.yml` (`openapi-semver-compat`, `provider-consumer-contract`) |
| TD-005 provider/consumer compatibility gate started (core contracts + CI) | In Progress | `api/contracts/consumer-provider-core.yaml`, `tools/validation-node/src/bin/provider-consumer-contract-validator.mjs`, `tools/validation-node/test/provider-consumer-contract-validator.test.mjs`, `.github/workflows/ci.yml` (`provider-consumer-contract`) |
| ST-031 error/pagination standardization expanded (risk/compliance/personal/business/metadata/consent/public APIs) | In Progress | Shared `ErrorResponse` and pagination requirements extended in `api/openapi/risk-context.yaml`, `api/openapi/compliance-context.yaml`, `api/openapi/personal-financial-data-service.yaml`, `api/openapi/business-financial-data-service.yaml`, `api/openapi/banking-metadata-service.yaml`, `api/openapi/consent-authorization-service.yaml`, `api/openapi/atm-directory-service.yaml`, and `api/openapi/open-products-service.yaml`; validator enforcement added in `tools/validation-node/src/bin/openapi-semver-compat-validator.mjs` and service-level contract tests cover consent/CoP/personal/business/atm/open-products |
| ST-031 runtime standardization slice added (error-envelope correlation fallback + pagination meta assertions) | In Progress | Runtime handlers now guarantee non-null `interactionId` (header or generated UUID) in `services/openfinance-personal-financial-data-service/src/main/java/com/enterprise/openfinance/personalfinancialdata/infrastructure/rest/AccountInformationExceptionHandler.java`, `services/openfinance-business-financial-data-service/src/main/java/com/enterprise/openfinance/businessfinancialdata/infrastructure/rest/CorporateTreasuryExceptionHandler.java`, `services/openfinance-banking-metadata-service/src/main/java/com/enterprise/openfinance/bankingmetadata/infrastructure/rest/MetadataExceptionHandler.java`, `services/openfinance-consent-authorization-service/src/main/java/com/enterprise/openfinance/consentauthorization/infrastructure/rest/ConsentExceptionHandler.java`; pagination runtime assertions expanded in controller unit tests for personal/business/metadata services |
| Service-level OpenAPI contract gate wired in CI (including metadata contract-only lane) | Done | `.github/workflows/ci.yml` (`openapi-runtime-contract-services`) executes consent/CoP/personal/business/atm/open-products contract tests + metadata `contractTest`; metadata lane configured in `services/openfinance-banking-metadata-service/build.gradle` |
| ST-033 dependency resilience matrix (Keycloak-first) formalized and CI-enforced | Done | `docs/architecture/DEPENDENCY_RESILIENCE_MATRIX.md`, `security/service-architecture/dependency-resilience-policies.yaml`, `tools/validation-node/src/bin/dependency-resilience-validator.mjs`, `tools/validation-node/test/dependency-resilience-validator.test.mjs`, `.github/workflows/ci.yml` (`dependency-resilience-baseline`) |
| ST-034 secret rotation SIEM logging baseline (structured JSON + correlation ID) | Done | Consent internal secrets runtime API emits standardized `INTERNAL_SECRET_UPSERT` audit events via `InternalSecretAuditPublisher`/`StructuredInternalSecretAuditPublisher` with `sourceService`, `retentionClass`, and `X-FAPI-Interaction-ID` correlation; contract enforced by `api/contracts/security-event-contracts.yaml`, `tools/validation-node/src/bin/security-event-contract-validator.mjs`, and CI job `security-event-contract` |
| ST-022 supply-chain hard gate wired (SBOM + signing + provenance in CI/release) | Done | `tools/validation/validate-supply-chain-baseline.sh` (Cosign v3 compatible flags), `tools/validation-node/src/bin/supply-chain-baseline-validator.mjs`, `tools/validation-node/test/supply-chain-baseline-validator.test.mjs`, `.github/workflows/ci.yml` (`supply-chain-baseline`), `.github/workflows/release.yml`; local evidence generated under `build/reports/supply-chain/` via `bash tools/validation/validate-supply-chain-baseline.sh amanahfi-platform/api-gateway/build/libs/api-gateway-1.0.0-SNAPSHOT.jar` |
| ST-032 gateway degraded-mode fallback expanded (policy-as-code + CI gate + runtime filter/probe) | In Progress | Baseline policy + gate: `security/service-architecture/cache-degraded-mode-policies.yaml`, `tools/validation-node/src/bin/cache-degraded-mode-validator.mjs`, `tools/validation-node/test/cache-degraded-mode-validator.test.mjs`, `tools/validation/validate-cache-degraded-mode-baseline.sh`, `.github/workflows/ci.yml` (`cache-degraded-mode-baseline`); runtime slice: `amanahfi-platform/api-gateway/src/main/java/com/amanahfi/gateway/security/CacheDegradedModeFilter.java`, `amanahfi-platform/api-gateway/src/main/java/com/amanahfi/gateway/security/CacheHealthProbe.java`, `amanahfi-platform/api-gateway/src/main/java/com/amanahfi/gateway/security/PropertyBackedCacheHealthProbe.java`, `amanahfi-platform/api-gateway/src/main/java/com/amanahfi/gateway/security/Fapi2SecurityConfig.java`, `amanahfi-platform/api-gateway/src/main/resources/application.yml`, tests: `amanahfi-platform/api-gateway/src/test/java/com/amanahfi/gateway/security/CacheDegradedModeFilterTest.java`, `amanahfi-platform/api-gateway/src/test/java/com/amanahfi/gateway/security/PropertyBackedCacheHealthProbeTest.java` |
| ST-021 strict mTLS runtime attestation tooling added (cluster evidence generator + tests) | Done | `tools/validation-node/src/bin/strict-mtls-runtime-attestation.mjs`, `tools/validation/validate-strict-mtls-runtime-attestation.sh` (preflight + `STRICT_MTLS_EXCLUDE_NAMESPACES` override), `tools/validation-node/test/strict-mtls-runtime-attestation.test.mjs`, `docs/architecture/STRICT_MTLS_ROADMAP_COMPLETION.md`; live local-cluster execution evidence generated at `build/reports/security/strict-mtls-runtime-attestation.md` |
| Validation stack migration to Node.js expanded (security/runtime + API governance + repository governance + reporting generators + CI lane cutover) | Done | `docs/architecture/NODEJS_VALIDATION_MIGRATION_PLAN.md`, `tools/validation-node/package.json`, `tools/validation-node/src/bin/{repo-governance-validator.mjs,cache-degraded-mode-validator.mjs,dependency-resilience-validator.mjs,strict-mtls-runtime-attestation.mjs,supply-chain-baseline-validator.mjs,openapi-semver-compat-validator.mjs,provider-consumer-contract-validator.mjs,runtime-route-contract-validator.mjs,generate-api-catalog.mjs,security-event-contract-validator.mjs,generate-test-telemetry-summary.mjs,generate-architecture-scorecard.mjs}`, `tools/validation-node/test/*.test.mjs`, `tools/validation/validate-repo-governance.sh`, `build.gradle` (`governanceCheck`), `ci/templates/microservice/Jenkinsfile`, `ci/templates/microservice/gitlab-ci.yml`, `ci/templates/bounded-context/gitlab-ci.yml`, `.github/workflows/ci.yml` (`repository-governance`, `validation-node-tests`, `openapi-semver-compat`, `provider-consumer-contract`, `api-catalog-governance`, `security-event-contract`, node-based telemetry summary in `build-and-test`, node-based `architecture-scorecard`) |
| Architecture scorecard refreshed after Wave C pass | Done | `docs/enterprisearchitecture/implementation-development/transformation/outputs/architecture-scorecard-latest.md` |
