# ADR-030: Homes for Unhomed Monolith Capabilities

## Status

Proposed

## Date

2026-10-17

## Context

Nine capabilities in `COPUR/enterprise-loan-management-system` (`master`) have no target repository. `fbx-domain-map` section 4 lists them:

- `amanahfi-platform`: Islamic finance (onboarding, accounts, payments, murabaha, compliance, risk, api-gateway, event-streaming) with its own shared kernel. About 306 Java files.
- `masrufi-framework`: financing models (murabaha, musharakah, ijarah, salam, istisna, qard hassan), written as an extension of the credit system. About 35 files.
- Accounts ledger: not a real module in the monolith. `bankwide/` and `bank-wide-services/` hold README placeholders, and the amanahfi accounts context is the only code. Payments parity runs with `ACCOUNTS_ADAPTER=in-memory`, and the mandates "accounts API owner" question is open.
- Analytics: dashboard and risk analytics, shared-infrastructure analytics, and open-finance consent analytics with masking. It has no aggregate of its own and reads other contexts' data.
- Open-finance extensions in `open-finance-context`: `corporatetreasury`, `dynamiconboarding`, `fxservices`, `insurancedata` and `insurancequotes`.

Without a home these capabilities have no owner, so they break the one-owner-per-data-set rule (ADR-018, ADR-022), have no manifest row, and cannot be covered by the regression parity (ADR-029). The accounts ledger is the most urgent: payments and mandates need it before their in-memory accounts adapter can be replaced.

## Decision

The user accepted this proposal on 2026-10-17 (K1: yes). Each capability goes to the home below. Four new repositories are created or proposed; the rest are reassignments or retirements.

### 1. Accounts ledger: new repository

- Repository `neo-fintechbankx-corebanking-accounts-ledger-service`, context `acc`, service id `svc-acc-accounts-ledger`, app id `app.acc.accounts-ledger`.
- Event namespace `evt.acc.account`, first version `.v1`. Database `db_acc_accounts_ledger_<env>`, schema `sc_acc_accounts_ledger`.
- Aggregates `Account` and `LedgerPosting`. Every posting is double-entry.
- Payments and mandates reach it through an HTTP port that replaces the in-memory accounts adapter. Wave 3, with payments, its first consumer.

### 2. AmanahFi: split between new and existing repositories

- Financing core (murabaha) goes to the new repository `neo-fintechbankx-islamicfinance-financing-service`: context `isf`, service id `svc-isf-financing`, app id `app.isf.financing`, namespace `evt.isf.financing` (`.v1`), database `db_isf_financing_<env>`. Wave 5, after payments and the ledger.
- Onboarding goes to `fintechbankx-customer-profile-kyc-service`.
- Accounts goes to the accounts ledger.
- Payments go to `fintechbankx-payments-initiation-settlement-service`.
- Risk goes to `fintechbankx-risk-decisioning-service`; Sharia compliance rules are a rule set in `fintechbankx-compliance-evidence-service`.
- The api-gateway, event-streaming and the amanahfi shared kernel are retired. The platform provides the mesh and Kafka, and a shared kernel is code only (the ownership matrix rules).

### 3. MasruFi: product types of the Islamic finance service

MasruFi has no repository of its own. Its financing models (musharakah, ijarah, salam, istisna, qard hassan) become product types of `neo-fintechbankx-islamicfinance-financing-service`. The extension of the credit system is retired.

### 4. Analytics: retired as a module

The monolith dashboard code is not moved.

- Risk analytics becomes a read model in `fintechbankx-risk-decisioning-service`.
- Consent analytics and masking become a read model in `fintechbankx-openfinance-consent-authorization-service`.
- A business-intelligence need is a new ADR for a data platform fed by events. It is not decided here.

### 5. Open-finance extensions

- `corporatetreasury` goes to `fintechbankx-openfinance-business-financial-data-service`. Before any code moves, the existing service is diffed against this module, and missing endpoints are added there.
- `dynamiconboarding` goes to the accounts ledger, which opens the account. KYC is a call to the customer service, and consent is checked against the consent authorization service.
- `insurancedata` and `insurancequotes` go to one new repository, `neo-fintechbankx-openfinance-insurance-data-quotes`: context `open_finance`, service id `svc-of-insurance-data-quotes`, app id `app.of.insurance-data-quotes`, namespace `evt.of.insurance`, database `db_of_insurance_data_quotes_<env>`, package root `com.enterprise.openfinance.insurance`. Wave 2.
- `fxservices` goes to a new repository, `neo-fintechbankx-openfinance-fx-quotes-service`: service id `svc-of-fx-quotes`, app id `app.of.fx-quotes`, namespace `evt.of.fx`, database `db_of_fx_quotes_<env>`. Wave 5, deferred until the accounts ledger is live, because a settled FX deal posts to an account.

### Naming and ownership

The four repositories are named `neo-fintechbankx-<domain>-<capability>-service`, with the `neo-` prefix, which the user chose for the renames on 2026-10-17. The insurance repository has no `-service` suffix (`neo-fintechbankx-openfinance-insurance-data-quotes`): it was created that way, and this ADR does not rename it. The governance docs use these names. Each repository gets one owning squad. The proposed squads (the strategy document requires approval before a repository is created) are:

| Repository | Tribe | Proposed squad |
|---|---|---|
| accounts ledger | Lending and Money Movement | Payment Orchestration Squad |
| Islamic finance financing | Lending and Money Movement | Loan Lifecycle Squad |
| open-finance insurance data and quotes | Open Finance | Retail Financial Data Squad |
| open-finance FX quotes | Open Finance | Corporate Financial Data Squad |

A new core-banking squad is the alternative if the Architecture Board wants one for the ledger. That is a change to the tribe and squad strategy and is not made here.

All repositories stay under `COPUR`; the user decided this on 2026-10-17. The four new repositories carry a `neo-` prefix. Repository creation and renames stay with the user. A thread creates or renames a repository only after the user's written approval for it.

## Alternatives

- **Accounts ledger inside payments.** Rejected. Payments would own the book of record for accounts, and mandates would still depend on it.
- **Analytics as its own repository.** Rejected. A repository with no aggregate that reads other contexts' data breaks the rule that cross-context data moves only by API or event.
- **MasruFi as its own repository.** Rejected. It has the same financing aggregates as murabaha, and two services for one model would split its rules.
- **Keeping the monolith as the home.** Rejected. It blocks the cut-over and the regression parity for these capabilities.

## Consequences

- Four new repositories, each needing a CODEOWNERS file, a README ownership block, a manifest row and a squad approval. Each private one takes `CI_RUNNER=fbx-ci` and joins the runner script's repository list.
- Wave 5 is new. Islamic finance and FX come after payments and the ledger, so they start last.
- Payments and mandates replace the in-memory accounts adapter with a port to the ledger. This ADR answers the open "accounts API owner" question for mandates.
- Monolith data for these capabilities moves by backfill under ADR-026, not by shared tables.
- The capabilities need parity rows against the monolith (ADR-029) before the cut-over. This ADR does not add them.
- The EA domain map, the ownership matrix and the bootstrap manifest carry the same rows as this ADR, and `check-adr-numbers.sh` passes with this ADR in place.

## Related

- ADR-018 (repository taxonomy), ADR-019 (events), ADR-022 (contract catalogs), ADR-026 (backfill before cut-over), ADR-029 (test-first and regression parity).
