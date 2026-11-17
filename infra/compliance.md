# Compliance Report — SupplyChain Backend Infrastructure (Bicep)

**Task**: 001-infrastructure-bicep-appservice
**Status**: Review only — not deployed

## Note on rule sources

This generation pass did not have access to the `appmod-get-available-region-sku`,
`appmod-get-iac-rules`, or `appmod-get-waf-rules` tooling in this session. The
template below was authored against general Azure Well-Architected Framework (WAF)
and App Service best practices instead. **Re-run these rule checks when the
tooling is available, before any deployment.**

## Scope compliance

| Requirement | Status | Notes |
|---|---|---|
| Only App Service Plan + Web App generated | ✅ | `modules/app-service-plan.bicep`, `modules/web-app.bicep` |
| No MySQL resource created | ✅ | Documented as external dependency only |
| No Service Bus / RabbitMQ resource created | ✅ | Documented as external dependency only |
| Web App configured for Java 21 | ✅ | `linuxFxVersion: 'JAVA|21-java21'` |
| App Service Plan is Linux | ✅ | `kind: 'linux'`, `reserved: true` |
| Region = Japan East | ✅ | `location` parameter defaults to `japaneast` |
| No application source code changes | ✅ | No files under `src/` touched |
| No dependency/library version changes | ✅ | `pom.xml` not touched |
| No provisioning / deployment executed | ✅ | No `az deployment` command run |
| No git commit/push performed | ✅ | No git commands run as part of this task |
| Failure-mode documented for missing MySQL/RabbitMQ | ✅ | See `web-app.bicep` header comments, README.md, and inline app-setting comments |

## WAF / security considerations applied

- `httpsOnly: true` on the Web App.
- `minTlsVersion: '1.2'`.
- `ftpsState: 'Disabled'`.
- Secrets (`mysqlConnectionString`, `mysqlPassword`, `rabbitMqPassword`) are declared
  with `@secure()` to avoid exposure in deployment logs/outputs.
- `healthCheckPath` configured (`/actuator/health`) — note this will fail if MySQL/
  RabbitMQ are unreachable, which is an intentional, documented risk (not a defect in
  this template — the dependencies are out of scope).
- Resources tagged with `application`, `environment`, and `managed-by` for
  traceability.

## Follow-ups recommended before deployment

1. Re-validate region/SKU availability with `appmod-get-available-region-sku` (or the
   `az vm list-skus` / `az appservice list-locations` equivalents) once tooling is
   available.
2. Re-validate against `appmod-get-iac-rules` (azcli deployment tool) and
   `appmod-get-waf-rules` for landing-zone compliance.
3. Consider Key Vault references for the MySQL/RabbitMQ secrets instead of plain app
   settings.
4. Confirm `P1v3` SKU sizing/cost is appropriate (see plan.md cost estimate).
