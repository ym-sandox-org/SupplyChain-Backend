# Task 002-infrastructure-bicep-appservice: Bicep IaC for App Service (Plan + Web App only)

## Status: Files generated for review only. Provision = false (no resources created, no deployment run).

## What was generated

Under `./infra/` at the repository root:

- `main.bicep` — orchestrates exactly two resources via modules.
- `modules/app-service-plan.bicep` — App Service Plan (Linux), SKU `B1`/`Basic`.
- `modules/web-app.bicep` — Web App (App Service), Linux, Java 21 (Java SE) runtime, referencing the
  App Service Plan.
- `parameters.json` — default parameters, region fixed to `japaneast` (Japan East).
- `deploy.sh` / `deploy.ps1` — Azure CLI (`az deployment group create`) deployment scripts for later,
  manual, out-of-band use. **Not executed as part of this task.**
- `README.md` — documents resources, parameters, and external dependencies (MySQL, RabbitMQ) with the
  startup-risk warning.
- `compliance.md` — scope/compliance checklist confirming no resources beyond the two in scope were
  defined, and that validation (`az bicep build`) passed cleanly.

## Resources in scope (exactly two)

1. App Service Plan (Linux) — `asp-supplychain-backend-demo`
2. Web App (App Service, Linux, Java 21) — `app-supplychain-backend-demo`, references the Plan above.

## Explicitly excluded

MySQL, RabbitMQ, networking, Key Vault, monitoring, and any other Azure resource type. MySQL and
RabbitMQ are documented in `infra/README.md` as external dependencies not provisioned here, with a note
that the Web App may fail to start or crash-loop if those dependencies are not reachable/configured at
runtime.

## Region

Japan East (`japaneast`) — used for all generated Bicep parameters/defaults.

## What was NOT done (per task constraints)

- No `az deployment` (or any other provisioning command) was executed.
- No Azure resources were created/provisioned.
- No application source code or dependency versions were modified.
- No changes were pushed to Git as part of generating these files.

## Validation

- `az bicep build --file infra/main.bicep` completed with **no errors and no warnings**.

## Follow-up / Open Items

- A resource group (e.g., `rg-supplychain-backend-demo`) must exist (or be created) before `deploy.sh` /
  `deploy.ps1` can be run manually in the future.
- Connection details for externally hosted MySQL and RabbitMQ must be supplied via App Service
  Application Settings (or similar) before any real deployment of this Web App, to avoid the documented
  startup risk.
