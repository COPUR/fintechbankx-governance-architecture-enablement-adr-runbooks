# ADR-041: Camunda Holds No Money, Rules or Personal Data

## Status

Proposed

## Date

2026-10-18. Source: the Camunda architecture design of 2026-10-18 (not in a repository, unverified; sections 5 and 6.3 of that design). Approval: user message cmsg_01TVU6MCNctBZbo8MPkX9s1oPVTRfJijv7CMLm3kNpkaiz (2026-10-18 02:31:54Z), which approves the recommended options. No decision cards were posted.

## Context

- Camunda would otherwise become one process brain for every flow. Without a boundary, its models would absorb limits, fees, risk rules and personal data. The design names this the largest risk to the orchestration choice.
- Money state stays in the ledger (ADR-036, ADR-037). Risk and compliance decisions stay in their services (ADR-031, ADR-032). Personal data stays in the customer and compliance services.

## Decision

1. Camunda owns process instance state and history, timers, human tasks and the order of compensation steps.
2. Camunda never owns balances, holds, journals, limits, fees, interest, FX, instalment allocation, risk or compliance decisions, or personal data.
3. Process variables are limited to business keys (`paymentId`, `applicationId`, `bulkId`, `caseId`, `consentId`, end-to-end id), status and reason enums, DMN outputs, retry counters, deadlines, trace ids and the four-eyes result as a count (`approvalsRecorded`), which `bpo-process-api` sets after it checks that the approver and the maker differ. Staff identities stay out of the process; the owning service's audit trail records who approved. An amount may appear only as a band that the domain service sets.
4. No personal data, card numbers (PAN), document content, ISO 20022 message bodies or screening-list detail appear in variables. The target is 8 KB per instance, with a hard limit of 64 KB.
5. Zeebe DMN decides routing and human-workflow questions only. Domain DMN tables stay in the owning service, versioned.
6. Compensation is an explicit compensating command in the process. BPMN compensation events are banned by the model lint.
7. Each evidence event records the DMN version that was used.

## Alternatives

- **Camunda as the owner of rules and data.** Rejected. This is the "god orchestrator" risk.

## Consequences

- Model review checks variable names against a dictionary. CI tests the variable size limit.
- A change to a domain rule is a service change, not a BPMN change.
- Compensation paths are visible in the model and need runbooks.

## Related

ADR-031, ADR-032, ADR-036, ADR-037, ADR-038, ADR-040.
