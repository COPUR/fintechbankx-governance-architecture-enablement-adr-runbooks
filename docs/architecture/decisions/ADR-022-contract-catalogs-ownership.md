# ADR-022: Contract Catalogs Ownership

## Status

Proposed

## Date

2026-10-08

## Context

Three governance repositories hold contracts: `fintechbankx-governance-api-contracts-openapi-catalog` (seeded with copies of every monolith `api/openapi/*.yaml`), `fintechbankx-governance-api-contracts-asyncapi-catalog` (naming and guardrail docs, no specs yet) and `fintechbankx-governance-api-contracts-schema-registry` (seeded with `database/*.sql`, no event schemas yet). Service repositories also carry OpenAPI specs that their own `ci/test` lints. With copies in two places and no rule for which is authoritative, specs drift and breaking changes slip through whichever copy is not checked.

## Decision

1. **Providers author.** The provider service is the author and owner of its OpenAPI and AsyncAPI specifications. They live in the provider repository (`openapi/` or `api/openapi/`, `asyncapi/`) and are gated there by Redocly lint, oasdiff breaking-change checks and AsyncAPI validation.
2. **Catalogs mirror in a separate PR.** After a provider change merges, the provider squad opens a separate PR to mirror the spec into the catalog repository. The catalog copy is never edited first.
3. **Catalogs own the cross-cutting view.** The catalog repositories own the index (which service exposes which API or topic, version, owner, consumers), estate-wide lint rules and breaking-change CI against the previous catalog version. A breaking change detected by the catalog blocks the mirror PR until the provider follows the versioning rules (new API major version, or new major topic per ADR-019), unless it is covered by an accepted waiver:
   - **Waiver file.** The provider lists the exact findings in `<spec>.accepted-breaking.txt` next to its spec, first line `# Accepted <date> <decision>: <reason>`. The catalog mirror PR copies the file unchanged; the catalog gates (oasdiff `--err-ignore` in the OpenAPI catalog, the accepted list in the AsyncAPI catalog and the schema registry) apply it only when it is new in that PR and the spec changes with it.
   - **Who approves.** The provider squad proposes the waiver in its PR. Every consumer of the changed operation or topic signs off in that PR: consumers are the services listed for it in the catalog index (`consumes` in the AsyncAPI index) or, for synchronous APIs, the callers recorded in the provider's README and in the platform caller allow-lists. The API Governance Guild approves. Proposed default, pending the user's decision on accepted differences: the owning squad proposes and the Architecture Board approves, as for parity differences (ADR-029).
   - **Expiry.** A waiver covers one change. After the mirror merges it is stale, is never applied again, and is deleted by the next PR that touches the spec.
   - **When a waiver is not allowed.** A change that breaks a consumer who has not signed off needs a new major version instead.
4. **Schema registry holds event payload schemas.** `fintechbankx-governance-api-contracts-schema-registry` holds the JSON Schema of each event's `data` payload (and the shared envelope schema from ADR-019), one file per `eventType` and major version, with CI that checks backward compatibility against the previous version. The `database/*.sql` seed files are not contracts and move out of the registry (to the owning services) in a later change.
5. **Consumers depend on the catalog.** Consumers generate clients and consumer tests from the catalog version, not from a provider's branch.
6. **Topic catalog vs AsyncAPI catalog.** The topic catalog (topic names, partitions, retention, producer and consumer identities used for provisioning and MSK access) lives in `fintechbankx-platform-event-streaming-kafka`, per the platform contract (platform contract, 2026-10-08, owned by the platform pillar). The AsyncAPI catalog holds the message contracts for those topics. A topic appears in both, and the two must agree; the API Governance Guild and the Event Platform Squad check this in review until a CI cross-check exists.

## Alternatives

- **Catalog-first authoring.** Rejected: separates the spec from the code and tests that implement it.
- **No catalogs, providers only.** Rejected: no estate-wide index, lint or consumer view.

## Consequences

- Two PRs per contract change (provider, then catalog). The catalog lag is visible and should be short; the API Governance Guild reviews mirror PRs.
- Breaking changes are caught twice: in the provider against its own `main`, and in the catalog against the published version.
- The schema-registry repository needs a compatibility checker and a layout convention before the first event contract is mirrored.
- Reversible: authoring location can be moved later without changing the specs themselves.
- Related: ADR-016, ADR-018, ADR-019, ADR-024.
