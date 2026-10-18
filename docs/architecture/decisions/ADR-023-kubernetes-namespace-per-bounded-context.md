# ADR-023: Kubernetes Namespace per Bounded Context with Mesh Default-Deny and IRSA

## Status

Proposed

## Date

2026-10-08

## Context

ADR-008 (Kubernetes production deployment) and ADR-005 (Istio) do not say how the extracted services are laid out in the cluster. Without a rule, services from different contexts share namespaces, mesh authorization policies end up broad, and AWS IAM roles for service accounts (IRSA) are trusted too widely. The platform pillar has published the layout the six `fintechbankx-platform-*` repositories provide (platform contract, 2026-10-08, owned by the platform pillar). This ADR records it as the programme decision so service repositories can rely on it.

## Decision

### 1. Namespaces

One namespace per bounded context, plus platform namespaces:

| Namespace | Workloads (service id, service account) |
|---|---|
| `lending` | `svc-ln-loan-lifecycle` (SA `loan-lifecycle-service`) |
| `payments` | `svc-pay-initiation-settlement` (SA `payment-initiation-settlement-service`), `svc-pay-recurring-mandates`, `svc-pay-bulk-orchestration`, `svc-pay-request-to-pay` |
| `customer` | `svc-cus-profile-kyc` (SA `customer-profile-kyc-service`) |
| `risk` | `svc-rsk-decisioning` (SA `risk-decisioning-service`) |
| `compliance` | `svc-cmp-evidence` (SA `compliance-evidence-service`) |
| `open-finance` | `svc-of-*` services |
| `identity` | Keycloak, OpenLDAP |
| `kafka` | Strimzi, for local and non-AWS clusters only (AWS uses Amazon MSK, ADR-024) |
| `observability` | OTel collector, Prometheus, Grafana, Tempo, Loki, Alertmanager |
| `istio-system`, `istio-ingress`, `external-secrets` | Platform |

Service-account names not listed above are set by the owning squad as `<capability>-service` and recorded in the repository README and the alignment matrix (ADR-018). Mesh-injected namespaces (label `istio-injection=enabled`) are `lending`, `payments`, `customer`, `risk`, `compliance`, `open-finance`, `identity` and `observability`; `istio-system`, `kube-system`, `external-secrets` and `kafka` (Strimzi manages its own TLS) are not injected (platform contract addendum, 2026-10-08). Every context namespace carries `fintechbankx.io/context=<ctx>`. In-cluster service DNS is `<sa>.<ns>.svc.cluster.local:8080`.

### 2. Workload conventions

- Ports: `8080` for the API, `8081` for management (`/actuator/health/liveness`, `/actuator/health/readiness`, `/actuator/prometheus`). Only `8080` is exposed to other workloads.
- A service chart installs into its context namespace with service account name = the SA above.
- Pod labels: `app.kubernetes.io/name=<sa>`, `app=<sa>`, `version=<semver or sha>`, `app.kubernetes.io/part-of=fintechbankx-<ctx>`, `fintechbankx.io/service-id=<service id>`, and annotation/label `sidecar.istio.io/inject: "true"`.
- Service ports are named `http` (8080) and `http-management` (8081) so Istio detects the protocol. `traffic.sidecar.istio.io/excludeInboundPorts` is not allowed; probes go through Istio's probe rewrite.
- Secrets come only from the External Secrets Operator `ClusterSecretStore` named `aws-secrets-manager` (namespace `external-secrets`, IRSA role from the terraform-modules `external-secrets-irsa` module, readable scope `<env>/*` secrets and KMS keys tagged `fintechbankx.io/secrets=true`; manifest in the mesh repo) for service secrets at `<env>/<service account>/...`, and `aws-secrets-manager-platform` for platform and identity secrets; the store follows the secret's name. Any other store name, such as `platform-secrets`, is invalid. The tag goes only on a secrets-only key that encrypts Secrets Manager secrets (for example the `db-app` and `db-migration` secrets); database storage, snapshots and Performance Insights use a separate untagged key, so the External Secrets role can never decrypt them.
- Traces go over OTLP to `otel-collector.observability.svc.cluster.local` (`4317` gRPC, `4318` HTTP).

### 3. Mesh: default deny, allow-list by SPIFFE principal

- Mesh-wide `PeerAuthentication` named `default` in `istio-system`, mode STRICT. No service ships a `PeerAuthentication` or `DestinationRule` that weakens it.
- Each namespace has a default-deny `AuthorizationPolicy`. Each service adds an ALLOW policy listing exactly the caller principals it accepts, in the form `cluster.local/ns/<ns>/sa/<sa>` (for example payments allowing `cluster.local/ns/lending/sa/loan-lifecycle-service` for disbursement). Principal wildcards across namespaces are not allowed.
- `RequestAuthentication` against the Keycloak `fintechbankx` realm JWKS at the ingress gateway and in every service namespace (ADR-020).
- An allow-list entry is part of the consumer change: the consumer squad asks, the provider squad approves in its own repository.

### 4. IRSA keyed on namespace and service account

Each service has its own IAM role. The role trust policy is restricted to exactly `system:serviceaccount:<ns>:<sa>` for that service, never a namespace wildcard. The role grants only what the service needs (its Secrets Manager entries, its MSK topics per ADR-024, its own buckets or keys).

## Alternatives

- **One namespace per service.** Rejected for now: more namespaces with no extra isolation over per-SA principals and IRSA; can be revisited per context (reversible).
- **One namespace per pillar or one shared namespace.** Rejected: blurs the context boundary in RBAC, quotas and network policy.
- **Namespace-wide mesh allow rules.** Rejected: any compromised workload in a namespace could call every service.

## Consequences

- Cross-context calls must be declared twice (caller token scope, ADR-020; provider allow-list here), which makes coupling visible in review.
- Renaming a namespace or service account breaks SPIFFE allow-lists and IRSA trust at the same time; treat both names as part of the service contract (renames are costly, though reversible).
- Platform repositories own the namespace, labels and default-deny baseline; service repositories own their ALLOW policies and service accounts.
- Related: ADR-005, ADR-006, ADR-008, ADR-018, ADR-020, ADR-024.
