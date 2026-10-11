# ADR-020: Service-to-Service Token Policy

## Status

Proposed

## Date

2026-10-08

## Context

Once loan, payments, customer, risk and compliance run as separate services, calls that were in-process method calls in the monolith become network calls (for example loan origination asking risk for a decision, or payments asking consent whether a payment is authorised). The easy path is to forward the end user's bearer token from service to service. That spreads a high-value, DPoP-bound customer token across internal hops, gives every downstream service the user's full scope, breaks when the token is sender-constrained to the client, and makes the audit trail unable to say which service acted. ADR-004 (OAuth 2.1) and ADR-006 (Zero Trust) set the direction; this ADR fixes the internal rule.

## Decision

Aligned with the platform contract (platform contract, 2026-10-08, owned by the platform pillar).

1. **Realm.** All service and user identities live in the Keycloak realm `fintechbankx`. Issuer `https://<identity-host>/realms/fintechbankx`; JWKS at `<issuer>/protocol/openid-connect/certs`.
2. **One client per service, client credentials only.** Each service has exactly one confidential Keycloak client whose client id is its service id (for example `svc-ln-loan-lifecycle`). The client has only the client-credentials grant enabled (no standard flow, no direct access grants). A service calling another service obtains its own access token with that grant.
3. **`service` realm role.** The client's service account carries the realm role `service` (lowercase in Keycloak; Spring Security maps it to `ROLE_SERVICE`). Internal endpoints require `ROLE_SERVICE` plus a fine-grained scope for the operation (for example `risk.decision.request`). End-user tokens never carry `service`.
4. **Realm roles.** The realm defines exactly these roles: `customer`, `banker`, `loan_officer`, `admin`, `service`, `auditor`, `compliance_officer`. Staff users are federated from LDAP and receive `banker`, `loan_officer`, `admin`, `auditor` or `compliance_officer` through LDAP group mapping. Adding a realm role needs an ADR.
5. **No user-token forwarding.** A service never forwards the end user's access token to another service. When the callee needs the user context, the caller passes it as data (customer id, consent id, `correlationId`) and the callee re-authorises against its own rules.
6. **Audience restriction.** Each service token is restricted to the callee's audience (its service id), and the callee rejects tokens whose `aud` does not contain its own id. Keycloak attaches audiences with an Audience protocol mapper on each calling client, one per service id it may call (platform contract addendum, 2026-10-08). Full resource-server validation is in ADR-025.
7. **mTLS in the mesh.** Service-to-service traffic runs over mesh-wide Istio STRICT mTLS (ADR-005) with a default-deny AuthorizationPolicy per namespace that allow-lists caller SPIFFE principals `cluster.local/ns/<ns>/sa/<sa>` (ADR-023). RequestAuthentication validates tokens against the realm JWKS at the ingress gateway and in every service namespace. The token proves the calling service at the application layer; mTLS proves the workload at the transport layer. Both are required.
8. **DPoP and FAPI at the edge only.** DPoP-bound tokens, PAR and the FAPI 2.0 profile apply to external clients at the API edge. Internally, client-credentials tokens are short-lived and bound to the mesh identity rather than DPoP.
9. **Secret delivery.** Each client secret is stored in AWS Secrets Manager at `<env>/<service-slug>/oidc-client` and delivered to the pod by the External Secrets Operator through the `ClusterSecretStore` named `aws-secrets-manager`. Secrets are never committed, baked into images or set as literal values in manifests.

## Alternatives

- **Forward the user token (token relay).** Rejected for the reasons in Context.
- **OAuth2 token exchange (RFC 8693) for on-behalf-of calls.** Not adopted now; can be added later for flows that must carry a delegated user identity (reversible).
- **mTLS identity only, no tokens.** Rejected: no per-operation scope and no application-level audit of the calling service.

## Consequences

- Keycloak realm configuration (`fintechbankx-platform-identity-iam-keycloak-ldap`) needs one client per service id and the `service` role; mesh authorization policies (`fintechbankx-platform-mesh-security-service-mesh`) need per-caller rules; each service needs an ExternalSecret for `<env>/<service-slug>/oidc-client`.
- Each service needs a token client with caching and refresh, and resource-server checks for `aud`, role and scope on internal endpoints.
- Audit records name the acting service and the business correlation id, not a borrowed user identity.
- Reversible: the policy can be relaxed per endpoint by a later ADR, though doing so weakens a security control and needs Board approval.
- Related: ADR-004, ADR-005, ADR-006, ADR-023.
