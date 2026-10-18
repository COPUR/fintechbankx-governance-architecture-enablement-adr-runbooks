# ADR-048: Engagement Rewards Context (`rwd`) and Deterministic Rewards Only

## Status

Proposed

## Date

2026-10-18. Source: the design thread's reply of 2026-10-18 05:13Z, which points to the Camunda project design (design document 07, not in a repository). Its legal notes on lotteries and promotions are design research and are not verified. The coordinator reads the user's reply "Tamam" (cmsg_01TVU6MCNctBZbo8MPkX9s1o7UaLWMLBShE3fWn56DhwRH, 2026-10-18 05:24:09Z) to the decisions post (cmsg_01TVU6MCNctBZbo8MPkX9s1oSotWDTqnMJjyvFJXuRob4F, 05:13:49Z) as accepting the recommended options, as design direction. This ADR stays Proposed until the set is approved in the governance thread.

## Context

- The Camunda project's marketing scenarios need reward budgets, per-customer ceilings and eligibility rules. Those are money and rules, which ADR-041 keeps out of Camunda.
- Random rewards (lotteries, scratch cards) need a permit in Türkiye and in Dubai, and cash prizes are restricted in Dubai (design research, not verified).
- The proof-of-value phase needs a real reward context. The proof-of-concept phase can use a stub.

## Decision

1. A new bounded context `rwd` (engagement rewards), repository `neo-fintechbankx-engagement-rewards-service`, owned by an Engagement squad. The service id `svc-rwd-engagement-rewards` is proposed here for confirmation. The context code is added to the naming standard.
2. Rewards are deterministic. A reward is granted only for an announced milestone, for example "the third Karekod payment this week". No lottery, scratch card or random reward (D7-K5, option a). Whether any chance-based form is allowed is a legal question and is not opened by this ADR.
3. Money stays out of Camunda. The reward amount, the campaign budget and the per-customer ceiling are in `rwd`. A grant is a ledger journal from the marketing expense account, and the campaign budget is a ledger hold (ADR-037). Camunda sees only a reward reference and an outcome.
4. During the proof-of-concept phase, the `rwd` contract is a stub in the `bpo` simulators. Before the proof of value, a real `rwd` is required (D7-K3, option a).
5. Marketing consent stays with the customer context, and message delivery with the notification context. Camunda sees only an enum for the consent state (design D7-K9, option a).
6. Campaign measurement joins process metrics and `rwd` figures on `campaignId`.

## Alternatives

- **Rewards inside `pay`** (D7-K3, option b). Rejected: payments would own marketing money.
- **An external marketing platform** (D7-K3, option c). Rejected: it puts customer data outside the bank's residency controls.
- **Lottery rewards with a permit** (D7-K5, option b). Not chosen for now. It needs a permit and a legal opinion.

## Consequences

- A new context, repository and squad. The naming row is added in this batch; the repository is opened by the user after the owner approves.
- The proof of value waits for the real `rwd`.

## Related

ADR-037, ADR-041, ADR-047.
