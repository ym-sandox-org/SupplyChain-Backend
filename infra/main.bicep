// =============================================================================
// main.bicep
// Scope: EXACTLY two Azure resources:
//   1. App Service Plan (Linux) - demo/review sized
//   2. Web App (App Service) - Linux, Java 21 runtime
//
// Explicitly OUT OF SCOPE (do not add here): MySQL, RabbitMQ, networking,
// Key Vault, monitoring/Application Insights, or any other Azure resource.
//
// MySQL and RabbitMQ are external dependencies that are NOT provisioned by
// this template. See README.md for details and startup-risk notes.
// =============================================================================

targetScope = 'resourceGroup'

@description('Azure region for all resources. Defaults to Japan East per requirement.')
param location string = 'japaneast'

@description('Base name used to derive resource names (plan and web app).')
param baseName string = 'supplychain-backend-demo'

@description('App Service Plan SKU name. B1 is sized for demo/review workloads.')
param appServicePlanSkuName string = 'B1'

@description('App Service Plan SKU tier.')
param appServicePlanSkuTier string = 'Basic'

@description('Java runtime version for the Linux Web App.')
param javaVersion string = '21'

@description('Java server type for the Linux Web App runtime stack.')
param javaServer string = 'JAVA'

@description('Java server/runtime variant. JAVA (SE) is used since no app server (Tomcat) is required.')
param javaServerVersion string = 'SE'

@description('Tags applied to all resources in this template.')
param tags object = {
  environment: 'demo'
  workload: 'supplychain-backend'
  provisionedBy: 'bicep'
}

var appServicePlanName = 'asp-${baseName}'
var webAppName = 'app-${baseName}'

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'deploy-app-service-plan'
  params: {
    name: appServicePlanName
    location: location
    skuName: appServicePlanSkuName
    skuTier: appServicePlanSkuTier
    tags: tags
  }
}

module webApp 'modules/web-app.bicep' = {
  name: 'deploy-web-app'
  params: {
    name: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    javaVersion: javaVersion
    javaServer: javaServer
    javaServerVersion: javaServerVersion
    tags: tags
  }
}

@description('Resource ID of the App Service Plan.')
output appServicePlanId string = appServicePlan.outputs.id

@description('Name of the App Service Plan.')
output appServicePlanName string = appServicePlan.outputs.name

@description('Resource ID of the Web App.')
output webAppId string = webApp.outputs.id

@description('Name of the Web App.')
output webAppName string = webApp.outputs.name

@description('Default hostname of the Web App.')
output webAppDefaultHostName string = webApp.outputs.defaultHostName
