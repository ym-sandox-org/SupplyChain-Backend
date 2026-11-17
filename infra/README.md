# SupplyChain Backend — Azure Infrastructure (Bicep, Review Only)

> **Status: REVIEW ONLY.** These Bicep files were generated for task
> `001-infrastructure-bicep-appservice` for manual review. **No Azure resources have
> been provisioned, no deployment has been run, and no changes have been pushed to
> Git.** Do not run `deploy.sh` / `deploy.ps1` until this has been reviewed and the
> external dependency parameters (MySQL, RabbitMQ) are ready.

## Scope

This template provisions **only**:

| Resource | Bicep Resource Type | Purpose |
|---|---|---|
| App Service Plan (Linux) | `Microsoft.Web/serverfarms` | Compute plan hosting the Web App |
| Web App (Java 21, Linux) | `Microsoft.Web/sites` | Hosts the SupplyChain Backend Spring Boot application |

**Out of scope / not created by this template:**

- Azure Database for MySQL (or any other MySQL resource)
- Azure Service Bus (or any other RabbitMQ/messaging resource)
- Any networking, monitoring, identity, or other supporting resources not listed above

## External Runtime Dependencies (documented, not provisioned)

The SupplyChain Backend application depends on the following at runtime. They are
**not** created by this template — they must already exist and be reachable from the
Web App (e.g. self-hosted, on another Azure subscription/VNet, or on-prem):

| Dependency | Used via | How it's supplied to the Web App |
|---|---|---|
| MySQL 8.0 | `mysql-connector-java`, Spring Data JPA | App settings `SPRING_DATASOURCE_URL`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD` (placeholders in `modules/web-app.bicep`) |
| RabbitMQ | `spring-boot-starter-amqp` | App settings `SPRING_RABBITMQ_HOST`, `SPRING_RABBITMQ_PORT`, `SPRING_RABBITMQ_USERNAME`, `SPRING_RABBITMQ_PASSWORD` (placeholders in `modules/web-app.bicep`) |

> **⚠ Warning:** Spring Boot's datasource and AMQP auto-configuration fail fast at
> startup if MySQL or RabbitMQ are unreachable. If the app settings above are left
> empty or point to unreachable endpoints, the Web App may fail to start or function.
> This is a known, documented risk from the modernization plan and is **not**
> addressed by this template — it is out of scope. No App Service health check path
> is configured; add one only after verifying an endpoint.

The site and SCM endpoints both default to denying access. The template does not
configure allow rules; later application package deployment requires a separate,
limited SCM access allow rule.

## Files

```
infra/
├── main.bicep                   # Orchestrates App Service Plan + Web App modules
├── modules/
│   ├── app-service-plan.bicep     # Linux App Service Plan
│   └── web-app.bicep             # Linux Web App, Java 21 runtime, external-dependency app settings
├── parameters.json               # Default parameter values (Japan East, empty external-dependency secrets)
├── deploy.sh                     # Deployment script (Azure CLI, bash) — NOT executed by this task
├── deploy.ps1                    # Deployment script (Azure CLI, PowerShell) — NOT executed by this task
├── README.md                     # This file
└── compliance.md                 # Rules/compliance notes for this template
```

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `location` | `japaneast` | Azure region for all resources |
| `appName` | `supplychain-backend` | Base name used to build resource names |
| `environmentName` | `dev` | Environment suffix (e.g. dev/test/prod) |
| `appServicePlanSku` | `B1` | App Service Plan SKU/tier — confirm before deploying |
| `appServicePlanCapacity` | `1` | Number of worker instances |
| `mysqlConnectionString` | `""` (secure) | EXTERNAL DEPENDENCY — JDBC URL for a reachable MySQL 8.0 instance |
| `mysqlUsername` | `""` | EXTERNAL DEPENDENCY — MySQL username |
| `mysqlPassword` | `""` (secure) | EXTERNAL DEPENDENCY — MySQL password |
| `rabbitMqHost` | `""` | EXTERNAL DEPENDENCY — RabbitMQ host |
| `rabbitMqPort` | `"5672"` | RabbitMQ port |
| `rabbitMqUsername` | `""` | EXTERNAL DEPENDENCY — RabbitMQ username |
| `rabbitMqPassword` | `""` (secure) | EXTERNAL DEPENDENCY — RabbitMQ password |

## Naming

- App Service Plan: `asp-${appName}-${environmentName}` → default `asp-supplychain-backend-dev`
- Web App: `app-${appName}-${environmentName}` → default `app-supplychain-backend-dev`

## Region

All resources default to **Japan East (`japaneast`)** per the task requirements.

## Validation performed during generation

- `az bicep build --file main.bicep` completed with no errors or warnings (other than
  the Azure CLI's generic "new Bicep release available" notice, which is unrelated to
  this template).

## Next steps (manual, not performed by this task)

1. Review `main.bicep`, `modules/app-service-plan.bicep`, and `modules/web-app.bicep`.
2. Confirm that the default `B1` App Service Plan SKU meets the demo requirements.
3. Supply real MySQL and RabbitMQ connection values in a parameters file (or via a
   secrets mechanism such as Key Vault references) before any deployment.
4. If approved, run `deploy.sh` / `deploy.ps1` manually against a target resource
   group — this task does **not** execute them.
