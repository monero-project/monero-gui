# Palantir Foundry/AIP integration

This repository defines the governed XUNIA XMR ontology contract in `ontology/xuniaxmr.ontology.json`. Palantir Foundry remains the authoritative runtime: create and publish the matching object types, links, and actions in Ontology Manager, then generate a backend-service OSDK package in Developer Console.

## Security boundary

Never send wallet seeds, private/spend/view keys, mnemonics, access tokens, client secrets, or raw transactions to Foundry, AIP, GitHub Actions, logs, artifacts, or GPT-Doug-LLM. The contract intentionally stores redacted operational metadata only. Release promotion and agent recommendation acceptance require human approval.

## GitHub configuration

Create a GitHub environment named `foundry-production` with required reviewers. Add:

- Secret `FOUNDRY_CLIENT_ID`
- Secret `FOUNDRY_CLIENT_SECRET`
- Variable `FOUNDRY_STACK_URL`, for example `https://example.palantirfoundry.com`
- Variable `FOUNDRY_ONTOLOGY`, the Ontology API name or RID
- Optional variable `FOUNDRY_TOKEN_URL` when your enrollment uses a non-default OAuth token endpoint

The Developer Console application must be a backend service with a service user and the `api:ontologies-read` operation scope. Grant only the object/action types required by this application.

## Provisioning sequence

1. Validate the local contract with `python3 scripts/validate_ontology.py`.
2. In Ontology Manager, map governed Foundry datasets to the eight object types.
3. Add the five link types and action types from the contract.
4. Make `promoteRelease`, `acceptAgentRecommendation`, and finding closure human-approved.
5. Publish the Ontology changes.
6. Create the restricted backend application and OSDK package in Developer Console.
7. Configure the GitHub environment and run **Foundry Ontology Gate**.
8. Connect AIP Logic or an Agent to the published Ontology. Permit recommendations; keep consequential actions behind approvals.

The workflow performs a real OAuth client-credentials exchange and calls Foundry Ontologies v2 to verify that every required object API name is active. It does not print tokens or secrets.
