# ADR-025: Resource-Server Token Validation (Issuer, Audience, DPoP)

## Status

Proposed

## Date

2026-10-08

## Context

The role-agent review of the five service-extraction PRs (2026-10-08) found that the extracted services validate an incoming JWT against the issuer only. A token issued by the `fintechbankx` realm for any client is then accepted by every service, so a token meant for one API can be replayed against another. On external endpoints, a DPoP-bound token is accepted without checking the proof, which drops the sender constraint that ADR-004 and the FAPI 2.0 profile rely on. ADR-020 already says the callee rejects tokens whose `aud` does not contain its own id; this ADR makes the full validation rule explicit for every resource server.

## Decision

Every fintechbankx service that exposes an API validates each bearer token as follows, and fails closed:

1. **Signature and issuer.** Signature against the realm JWKS (`<issuer>/protocol/openid-connect/certs`), `iss` equal to `https://<identity-host>/realms/fintechbankx`.
2. **Audience.** `aud` must contain the service's own service id (for example `svc-ln-loan-lifecycle`). Tokens without it are rejected with 401.
3. **Lifetime.** `exp` and `nbf` checked with at most 60 seconds of clock skew.
4. **DPoP by caller, not by namespace.** Every endpoint that a third-party provider (TPP) calls requires a DPoP-bound token under the FAPI 2.0 profile (TPP clients are DPoP-only and authenticate with `private_key_jwt`; mTLS-bound tokens are not offered), whichever service or namespace serves it. That covers consent-auth and the `svc-of-*` services, and also the TPP-facing payment endpoints:
   - payment initiation
   - bulk orchestration (`/open-finance/v1/file-payments`)
   - recurring mandates (`/open-finance/v1/vrp`)
   - request-to-pay when a TPP calls it

   On these paths:
   - The request carries `Authorization: DPoP <token>` and a valid `DPoP` proof (RFC 9449): signed with the bound key, `htm` and `htu` matching the request, `iat` within the allowed window, `ath` matching the access token hash, and `jti` not replayed (replay cache shared across replicas).
   - `cnf.jkt` equals the proof key's thumbprint.
   - A plain Bearer token is rejected with 401 and `WWW-Authenticate: DPoP`.

   Not covered:
   - Internal service-to-service calls with client-credentials tokens follow ADR-020: Bearer over STRICT mTLS, no DPoP. An example is bulk orchestration calling consent-auth.
   - First-party calls from the customer web and mobile clients and from the staff web client (`fintechbankx-staff-web`) stay Bearer for now (Proposed: enable for mobile later). Web and mobile are customer-only clients; offline tokens are issued to mobile only.

   A service with both kinds of caller keeps them on separate path prefixes and enforces DPoP per prefix: TPP-facing under `/open-finance/v1/...`, first-party and internal under `/api/v1/...` (platform contract, "DPoP applies by caller, not by namespace", 2026-10-08).
5. **Authorities.** Realm roles map to `ROLE_<ROLE>`; operation scopes are checked in addition to roles. Resource ownership (a customer may only act on their own customer and account ids) is enforced in the application layer, not inferred from the token alone. On TPP-facing paths a resource id that does not exist and one that belongs to another TPP get the same answer, `404` with one fixed message per resource type, so a TPP cannot probe for other TPPs' ids; `403` is kept for a TPP's own resource that its token's scope does not cover.
6. **Tests.** Each service has tests that prove a token with the wrong audience and an expired token are rejected; every TPP-facing path (open finance and payments) also proves that a Bearer token, and a DPoP-bound token without a valid proof, are rejected.

## Alternatives

- **Issuer-only validation plus mesh policy.** Rejected: the mesh proves which workload called, not which client the token was issued to, and does nothing at the external edge.
- **Validate audience only at the ingress gateway.** Rejected: internal callers bypass the gateway, and defence in depth requires the service itself to check.

## Consequences

- Loan, payments, customer, risk and compliance services need a resource-server change and tests before cut-over; the owning pillar threads carry it. Payment initiation, bulk, mandates and request-to-pay also split TPP-facing paths under `/open-finance/v1` and enforce DPoP there.
- The mesh treats the TPP-facing payment prefixes like open finance: gateway ALLOW by path, with the token checked by the service.
- Keycloak adds the audience with an Audience protocol mapper on every calling client (service clients, `fintechbankx-web`, `fintechbankx-mobile`, TPP clients) for each service id it may call, as set by the platform contract addendum of 2026-10-08.
- Reversible only by a later ADR, since loosening it weakens a security control.
- Related: ADR-004, ADR-006, ADR-020, ADR-023.
