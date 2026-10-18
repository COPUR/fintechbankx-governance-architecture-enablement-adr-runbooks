# ADR-031: Credit Score on Events and Loan Eligibility Ownership

## Status

Proposed

## Date

2026-10-18. Answers recorded 2026-10-18 01:45Z to two 2026-10-08 cards: "credit score on events" (cmsg_01TVU6MCNctBZbo8MPkX9s1oJqsHhminpzXMawHdC2PoLL, posted 2026-10-08 12:22:27Z) and "loan eligibility" (cmsg_01TVU6MCNctBZbo8MPkX9s1oFiACC4KebegaojDjn9LodQ, posted 2026-10-08 12:22:34Z). Both were answered with the recommended option.

## Context

Two cards asked which service owns credit data and loan eligibility.

- The monolith's score event carries the score (`newCreditScore`). The monolith's `CustomerCreditProjection` subscribes to that event and reads the score, so the monolith is a consumer of the field. The split customer service's AsyncAPI spec for the event is not merged.
- The monolith checks a minimum score of 600 for loan eligibility, with no inbound adapter. The split customer service keeps an `isEligibleForLoan` method that nothing calls over the API.

Both answers move a field or a rule to a single owner, so they follow one-owner-per-data-set (ADR-018, ADR-022).

## Decision

1. **Score events carry no score in the split services.** The event is `Customer.Customer.CreditScoreUpdated.v1`. It carries `customerId` and an updated marker. It is v1 because the contract is pre-release (ADR-019, section 5). A consumer that needs the score reads `GET /api/v1/customers/{id}/credit` in the customer service, under the caller allow-list (ADR-020). The credit-limit event keeps its old and new amounts. No `.v2` topic is created.
2. **Risk decides eligibility, after parity.** When the regression parity rows for loan eligibility pass (ADR-029), the risk decisioning service owns the 600 minimum and the limits derived from the score. The customer service keeps the credit profile: score, limit and amount used. The loan service orchestrates the check and enforces risk's decision.
   - Planned, not on main yet: `POST /api/v1/risk/loan-eligibility` (`customerId`, `requestedAmount`, `currency`), which answers ELIGIBLE or INELIGIBLE with a reason and answers 503 when the customer service is unavailable. Source: customer-risk-compliance squad plan, 2026-10-18, not in a repository (unverified).
3. **Moving the rule is its own change.** The customer service's `isEligibleForLoan` is deleted in a follow-up change. The loan service calls risk's eligibility endpoint only after the parity rows exist.

## Alternatives

- **The event carries the score (monolith shape).** Not chosen. Every consumer then keeps a copy of a risk-derived value that changes outside its own data.
- **Loan decides eligibility.** Not chosen. The loan service would own a risk rule and its inputs, which breaks one owner per data set.
- **Risk publishes the score and the customer service keeps a read-only copy.** Not chosen. The copy is a second source for a value the customer service does not own.

## Consequences

- In the split services, `CreditScoreUpdated` has no score field. Consumers that need the score add a read dependency on the customer service, and each consumer is listed in the caller allow-list.
- The monolith's `CustomerCreditProjection` still reads the score from its own event. This ADR does not change the monolith; parity covers its behaviour until cut-over.
- Matrix rows LP-01, CR-01 and CR-04 carry a Proposed note pointing here (`monolith-to-repo-alignment.csv`).

## Related

ADR-018, ADR-019, ADR-020, ADR-022, ADR-029.
