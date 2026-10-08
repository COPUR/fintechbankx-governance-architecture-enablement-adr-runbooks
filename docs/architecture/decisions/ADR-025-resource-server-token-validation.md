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
4. **DPoP for open-finance clients.** Consent-auth and the `svc-of-*` services serve third-party providers under the FAPI 2.0 profile: their tokens are sender-constrained (DPoP, or mTLS-bound), and a token with a `cnf.jkt` claim must arrive with a valid `DPoP` proof header (RFC 9449): signature with the bound key, `htm` and `htu` matching the request, `iat` within the allowed window, `ath` matching the access token hash, and `jti` not replayed (replay cache shared across replicas). First-party web and mobile clients are not required to use DPoP for now (Proposed: enable for mobile later). Internal service-to-service calls follow ADR-020: client-credentials tokens over STRICT mTLS, no DPoP.
5. **Authorities.** Realm roles map to `ROLE_<ROLE>`; operation scopes are checked in addition to roles. Resource ownership (a customer may only act on their own customer and account ids) is enforced in the application layer, not inferred from the token alone.
6. **Tests.** Each service has tests that prove a token with the wrong audience and an expired token are rejected; open-finance services also prove a DPoP-bound token without a valid proof is rejected.

## Alternatives

- **Issuer-only validation plus mesh policy.** Rejected: the mesh proves which workload called, not which client the token was issued to, and does nothing at the external edge.
- **Validate audience only at the ingress gateway.** Rejected: internal callers bypass the gateway, and defence in depth requires the service itself to check.

## Consequences

- Loan, payments, customer, risk and compliance services need a resource-server change and tests before cut-over; the owning pillar threads carry it.
- Keycloak adds the audience with an Audience protocol mapper on every calling client (service clients, `fintechbankx-web`, `fintechbankx-mobile`, TPP clients) for each service id it may call, as set by the platform contract addendum of 2026-10-08.
- Reversible only by a later ADR, since loosening it weakens a security control.
- Related: ADR-004, ADR-006, ADR-020, ADR-023.
