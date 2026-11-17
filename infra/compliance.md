# Compliance / Scope Notes — 002-infrastructure-bicep-appservice

## Scope compliance

- [x] Exactly two Azure resources defined: App Service Plan (Linux) + Web App (Linux, Java 21).
- [x] No MySQL, RabbitMQ, networking, Key Vault, monitoring, or any other resource type is present in
      `main.bicep` or any module under `modules/`.
- [x] MySQL and RabbitMQ documented as external dependencies in `README.md`, including the startup-risk
      note (possible crash-loop / failed health checks if unreachable at runtime).
- [x] No application source code or dependency versions were modified as part of this task.
- [x] No `az deployment` (or any provisioning command) was run as part of generating these files.
- [x] No Git push was performed as part of generating these files (commit only, per task instructions
      from the calling workflow, if applicable).
- [x] Region fixed to **japaneast** (Japan East) in `parameters.json` and as the default for the
      `location` parameter in `main.bicep`, per the explicit requirement for this task.

## Validation performed

- `az bicep build --file main.bicep` completed successfully with **no errors and no warnings**
  (verified locally; compiled output was discarded after validation — it is not part of the
  deliverable, only `.bicep` source files are).

## Design decisions

- **SKU**: `B1` / `Basic` chosen for the App Service Plan as an appropriately sized, low-cost tier for a
  demo/review workload (not intended for production scale/availability).
- **Runtime stack**: `linuxFxVersion = JAVA|21-java21`, matching Azure App Service's Linux Java SE 21
  runtime (no embedded app server/Tomcat, since the project is a self-contained Spring Boot JAR).
- **HTTPS/TLS**: `httpsOnly: true` and `minTlsVersion: '1.2'` set on the Web App as a baseline security
  default; this does not introduce any additional resource (e.g., no Key Vault, no custom domain/cert
  resources).
- **Modules**: Each resource (`app-service-plan.bicep`, `web-app.bicep`) is isolated into its own module
  file for clarity and reuse, orchestrated from `main.bicep`. This does not add resources beyond the two
  in scope — it is purely an organizational choice.

## Out of scope — explicitly not provisioned or referenced as Azure resources

| Dependency | Status | Notes |
|---|---|---|
| MySQL | External, not provisioned | Referenced only in documentation (`README.md`), not in any `.bicep` file. |
| RabbitMQ | External, not provisioned | Referenced only in documentation (`README.md`), not in any `.bicep` file. |
| Networking (VNet/Private Endpoint) | Not included | No VNet integration or private networking configured. |
| Key Vault | Not included | No secret/connection string management configured. |
| Monitoring (Application Insights, Log Analytics) | Not included | No monitoring/diagnostics resources configured. |
