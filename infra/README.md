# Infrastructure: Azure App Service for SupplyChain Backend (Demo Prep)

This folder contains Bicep IaC for task **002-infrastructure-bicep-appservice**. The scope is
**strictly limited to exactly two Azure resources**:

1. **App Service Plan (Linux)** — `modules/app-service-plan.bicep`
2. **Web App (App Service, Linux, Java 21 runtime)** — `modules/web-app.bicep`, referencing the
   App Service Plan above.

No other Azure resources (MySQL, RabbitMQ, networking/VNet, Key Vault, Application Insights/monitoring,
etc.) are defined anywhere in this template, by design.

## Files

```
infra/
├── main.bicep              # Orchestrates the two modules below
├── modules/
│   ├── app-service-plan.bicep   # Single resource: Microsoft.Web/serverfarms (Linux)
│   └── web-app.bicep            # Single resource: Microsoft.Web/sites (Linux, Java 21)
├── parameters.json          # Default parameter values (region: japaneast)
├── deploy.sh                # az deployment group create (Linux/macOS) — NOT executed by this task
├── deploy.ps1               # az deployment group create (Windows) — NOT executed by this task
├── README.md                # This file
└── compliance.md            # Notes on scope/compliance decisions
```

> **This task does not provision anything.** `deploy.sh` / `deploy.ps1` are provided for a human
> operator to run manually in the future, after `az login`. They were **not** executed as part of
> generating these files, and no `az deployment` command has been run.

## Resources

| Resource | Bicep Type | Name (default) | SKU | Notes |
|---|---|---|---|---|
| App Service Plan | `Microsoft.Web/serverfarms` | `asp-supplychain-backend-demo` | `B1` / `Basic` | Linux (`kind: linux`, `reserved: true`). Sized for a demo/review workload, not production. |
| Web App | `Microsoft.Web/sites` | `app-supplychain-backend-demo` | N/A (runs on plan above) | Linux, `linuxFxVersion: JAVA|21-java21` (Java SE 21 runtime). `httpsOnly: true`, TLS 1.2 minimum. |

## Parameters

| Parameter | Default | Description |
|---|---|---|
| `location` | `japaneast` | Azure region for both resources (Japan East, per requirement). |
| `baseName` | `supplychain-backend-demo` | Base name used to derive the Plan/Web App names. |
| `appServicePlanSkuName` | `B1` | App Service Plan SKU name — Basic tier, appropriate for a demo/review workload. |
| `appServicePlanSkuTier` | `Basic` | App Service Plan SKU tier. |
| `javaVersion` | `21` | Java version for the Linux Web App runtime stack. |
| `javaServer` | `JAVA` | Java server type (Java SE, no app server/Tomcat). |
| `javaServerVersion` | `SE` | Documentation/tag value identifying the Java SE variant. |
| `tags` | `{ environment: demo, workload: supplychain-backend, provisionedBy: bicep }` | Tags applied to both resources. |

## External Dependencies (NOT Provisioned Here)

This application (per `application.yml`) depends on:

- **MySQL** — a database, currently referenced via a Docker Compose-style hostname (`mysql`).
- **RabbitMQ** — a message broker, currently referenced via a Docker Compose-style hostname (`rabbitmq`).

**Neither MySQL nor RabbitMQ is provisioned by this Bicep template.** They must be hosted/managed
externally (e.g., existing self-hosted instances, or separately provisioned Azure services in a future,
separate plan), and connection details must be supplied to the Web App out-of-band (e.g., via App
Service **Application Settings**) before deployment.

### ⚠️ Known Startup Risk

The Docker Compose-style hostnames (`mysql`, `rabbitmq`) used in `application.yml` **will not resolve**
on Azure App Service. Spring Boot's default MySQL/JPA and RabbitMQ auto-configuration typically fails the
application context (fail-fast) if the database or broker is unreachable at startup. As a result:

> **The Web App may fail to start, or crash-loop / fail continuous health checks, if MySQL and
> RabbitMQ are not reachable and correctly configured (e.g., via Application Settings pointing at
> real, resolvable endpoints) at runtime.**

No changes have been made to `application.yml` or any application code/dependency versions as part of
this task — this is a documentation note only, so operators are aware of the risk before deploying.

## Explicitly Out of Scope

The following are **intentionally not included** anywhere in this template:

- Azure Database for MySQL (or any MySQL hosting)
- Azure Service Bus / any RabbitMQ hosting
- Networking (VNet, subnets, Private Endpoint, NSGs)
- Key Vault
- Application Insights / Log Analytics / any monitoring resource
- Any other Azure resource type not listed in the "Resources" table above

## Deploying Later (Manual, Out of Band)

These scripts are **not run as part of this task**. To deploy manually later:

```bash
# Linux/macOS
az login
./deploy.sh
```

```powershell
# Windows
az login
./deploy.ps1
```

Both scripts default to resource group `rg-supplychain-backend-demo` in `japaneast` and use
`az deployment group create` (Azure CLI), not `azd`.
