# Infrastructure Plan: Azure App Service Bicep for SupplyChain Backend (Demo Prep)

## User Requirements

- Create Bicep IaC to host this Java 21 Spring Boot backend on **Azure App Service**.
- Scope is limited to **App Service Plan** and **Web App** resources only — no other Azure resources.
- **MySQL** and **RabbitMQ** are external dependencies and must NOT be provisioned by this plan; document that the app may fail to start (crash-loop / failed health checks) if these dependencies are unreachable at runtime.
- Do **not** change application code or upgrade/downgrade any dependency versions.
- Security issues must be **reported only** — no automatic remediation of CVEs or dependency versions.
- Do **not** create/provision Azure resources, do not deploy, and do not push anything to Git. All outputs are files for review only.

**Plan Configuration**:

| Parameter | Value | Description |
|-----------|-------|-------------|
| IaC Tool | Bicep | Infrastructure as Code tool |
| Provision | **false** | Files are generated for review only; no `az deployment` / resource creation will be run |
| Subscription | Not provided | No subscription targeting or provisioning occurs under this plan |

---

## Proposed Architecture

```
                    ┌──────────────────────────────┐
                    │        Azure App Service      │
                    │  ┌──────────────────────────┐ │
   HTTPS  ────────► │  │  Web App (Linux, Java 21) │ │
                    │  │  supplychain-backend      │ │
                    │  └────────────┬─────────────┘ │
                    │               │                │
                    │   App Service Plan (Linux)      │
                    └───────────────┼────────────────┘
                                    │
                     (outbound network calls — NOT provisioned here)
                         ┌──────────┴───────────┐
                         ▼                       ▼
                ┌─────────────────┐     ┌──────────────────┐
                │  MySQL (ext.)   │     │  RabbitMQ (ext.)  │
                │  self-hosted /  │     │  self-hosted /    │
                │  external svc   │     │  external svc     │
                └─────────────────┘     └──────────────────┘
```

MySQL and RabbitMQ remain **external dependencies** — connectivity details (hostnames `mysql`/`rabbitmq` in
`application.yml`) are not Azure-resolvable as-is and are out of scope for provisioning in this plan.

---

## Azure Resource List

| Resource Type | Resource Name (example) | SKU | Est. Monthly Cost* | Purpose |
|---------------|--------------------------|-----|---------------------|---------|
| App Service Plan (Linux) | `asp-supplychain-backend-demo` | B1 (Basic, 1 core/1.75GB) | ~$13 USD/mo | Compute tier hosting the Web App; Basic tier chosen for demo/review scope |
| Web App (App Service) | `app-supplychain-backend-demo` | N/A (runs on the Plan above) | Included in Plan cost | Hosts the Java 21 / Spring Boot JAR via the App Service Java SE (Linux) runtime |

\* Rough estimate based on general Azure retail pricing for the East US region; actual pricing varies by
region, currency, and any applicable discounts/reservations. No resources will be provisioned, so no
charges will be incurred by running this plan.

**Explicitly out of scope** (external dependencies only, not provisioned):
- Azure Database for MySQL (or any MySQL hosting)
- Azure Service Bus / any RabbitMQ hosting
- Networking resources (VNet, Private Endpoint), Key Vault, Application Insights, etc.

---

## Known Startup Risks (External Dependencies)

- `application.yml` currently points at Docker Compose-style hostnames `mysql` and `rabbitmq`, which will
  **not resolve** on Azure App Service. Unless these are overridden with reachable endpoints via App
  Settings, the Web App **may fail to start** or crash-loop while trying to connect to the database/broker
  at boot.
- Spring Boot's default MySQL/JPA and RabbitMQ auto-configuration can fail the application context
  (fail-fast) if the database or broker is unreachable, which will surface as failed App Service health
  checks / continuous restarts.
- This plan does **not** change `application.yml`, add externalized configuration, or modify any code —
  it only documents the risk so operators can supply working connection settings (e.g., via App Service
  Application Settings) to an externally hosted MySQL and RabbitMQ before the Web App is actually deployed.

---

## Security Reporting (No Auto-Remediation)

- A CVE/dependency scan will be run across the project's Maven dependencies.
- Findings will be documented in a report (vulnerable package, installed version, CVE id/severity, and the
  minimum patched version available) **without modifying `pom.xml` or any source code**.
- No dependency upgrades, downgrades, or code fixes will be applied as part of this plan.

---

## Tasks Overview

| # | Task | Type | Output | Notes |
|---|------|------|--------|-------|
| 1 | Security/CVE scan (report-only) | security | CVE report file | No code/dependency changes applied |
| 2 | Generate Bicep for App Service Plan + Web App | infrastructure | `.bicep` files under `infra/` | `provision: false`; MySQL/RabbitMQ documented as external, not provisioned |

See `./.metadata/tasks.json` for full task definitions.

---

## Open Questions & Questionnaire

- [ ] Target Azure region and resource naming convention for the generated Bicep files (defaulted to
      East US / `*-demo` naming in this draft; adjust before any future provisioning).
- [ ] Whether MySQL/RabbitMQ should be migrated to managed Azure services (Azure Database for MySQL,
      Azure Service Bus) in a future, separate plan — explicitly out of scope here.
- [ ] How the externally hosted MySQL/RabbitMQ connection details will be supplied to the Web App (e.g.,
      App Service Application Settings, Key Vault references) once this app is actually deployed.
