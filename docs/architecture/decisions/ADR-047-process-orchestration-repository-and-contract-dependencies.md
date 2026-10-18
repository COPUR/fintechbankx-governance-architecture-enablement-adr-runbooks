# ADR-047: Process Orchestration Repository and Contract-Only Dependencies

## Status

Proposed

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the Camunda project design (design document 07, not in a repository, unverified where it says so). The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting the recommended options, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- ADR-040 places the Camunda client and every job worker in a `bpo` service. The design needs a repository for that service, its models, its deployment values and its programme evidence.
- Repository-to-repository code sharing is forbidden by the guardrails. Services depend only on published contracts.
- Camunda process models repeat the same steps (screening review, ledger posting, waiting on external status, four-eyes approval, batch fan-out, customer contact). Shared subprocesses reduce that repetition.

## Decision

1. One repository, `neo-fintechbankx-bpo-process-orchestration`, owned by the Process Platform squad (D7-K1, option a). It holds Camunda deployment values, BPMN and DMN models, the `bpo` services, simulators, tests and the programme folders (POT, POC, POV).
2. Dependencies are contracts only. `bpo` depends on the OpenAPI and AsyncAPI files published in the catalog repositories. Domain services depend on `bpo`'s published process contract: `bpo-process-api` and `evt.bpo.process.v1`.
3. Contracts are pinned in `contracts/pins/catalog-pins.lock`, with the catalog commit and each file's sha256. Vendored copies are read-only (D7-K7, option a). A pin older than 30 days produces a warning.
4. `bpo` lists the operation identifiers and fields it uses in `expectations/<provider>.yaml`, published in the catalog. A provider change that touches a listed field is reported as a consumer break.
5. Six library subprocesses live in `models/bpmn/_lib` and are called through call activities bound by `versionTag`: screening review, ledger posting, waiting on external status, four-eyes approval, batch fan-out and customer contact. A lint rule enforces the binding. Four-eyes user tasks are assigned to a candidate group or a pseudonymous reference, never to a staff username. Camunda writes assignee and candidate-user fields to OpenSearch (ADR-038), so they carry no personal identifiers.
6. The Camunda deployment values live in `deploy/camunda-platform` in this repository, pinned by chart version and sha256 (D7-K2, option a). This moves the values out of the platform's wrapper repository, as ADR-038 notes. The values name secrets only by reference: each secret is created by an ExternalSecret from `<env>/<slug>/...`, and no secret value appears inline.
7. BPMN compensation events are not used (ADR-041), enforced by lint.
8. The Keycloak realm is kept in the identity repository (realm-as-code). This repository keeps a request file that lists the clients and audiences it needs.
9. Required gates: model and DMN lint, contract pin check, contract publication checks for `bpo`'s own APIs, chart render checks, ArchUnit (services do not import each other's packages; workers use only vendored clients), and the security gate.

## Alternatives

- **Two repositories, one for the models and one for the platform values** (D7-K1, option b). Deferred until production operations start. It would need a second pin for the engine version.
- **A repository named after the design's earlier proposal** (D7-K1, option c). Not chosen: it does not follow the `neo-fintechbankx-<context>-<capability>` form.
- **Pin by submodule or fetch at build time** (D7-K7, options b and c). Rejected: builds would depend on the network and on moving refs.

## Consequences

- Upgrading Camunda within 8.10 changes only this repository. Domain repositories are not affected.
- A new domain command follows the release order: domain change, catalog, identity audience if needed, `bpo` pin and worker, then the flag.
- Domain repositories change only for their own contract, and only through their own pull requests.

## Related

ADR-002, ADR-019, ADR-022, ADR-028, ADR-038, ADR-040, ADR-041.
