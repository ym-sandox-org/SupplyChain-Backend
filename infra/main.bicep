// Main orchestration template: App Service Plan + Web App for SupplyChain Backend.
//
// SCOPE: This template provisions ONLY an Azure App Service Plan (Linux) and a
// Web App configured for the Java 21 runtime.
//
// OUT OF SCOPE (by design, see plan.md / README.md):
//   - Azure Database for MySQL (or any MySQL resource)
//   - Azure Service Bus (or any RabbitMQ/messaging resource)
// MySQL and RabbitMQ are external runtime dependencies of the application. They
// are documented, not provisioned. See the webApp module header for the
// app-setting placeholders and the health-check failure warning.

targetScope = 'resourceGroup'

@description('Azure region for all resources')
param location string = 'japaneast'

@description('Short environment/application name used to build resource names')
param appName string = 'supplychain-backend'

@description('Deployment environment suffix (e.g. dev, test, prod)')
param environmentName string = 'dev'

@description('App Service Plan SKU')
param appServicePlanSku string = 'P1v3'

@description('App Service Plan instance count')
param appServicePlanCapacity int = 1

@description('MySQL JDBC connection string. EXTERNAL DEPENDENCY — not provisioned by this template.')
@secure()
param mysqlConnectionString string = ''

@description('MySQL datasource username. EXTERNAL DEPENDENCY — not provisioned by this template.')
param mysqlUsername string = ''

@description('MySQL datasource password. EXTERNAL DEPENDENCY — not provisioned by this template.')
@secure()
param mysqlPassword string = ''

@description('RabbitMQ host. EXTERNAL DEPENDENCY — not provisioned by this template.')
param rabbitMqHost string = ''

@description('RabbitMQ port')
param rabbitMqPort string = '5672'

@description('RabbitMQ username. EXTERNAL DEPENDENCY — not provisioned by this template.')
param rabbitMqUsername string = ''

@description('RabbitMQ password. EXTERNAL DEPENDENCY — not provisioned by this template.')
@secure()
param rabbitMqPassword string = ''

var tags = {
  application: appName
  environment: environmentName
  'managed-by': 'bicep'
}

var appServicePlanName = 'asp-${appName}-${environmentName}'
var webAppName = 'app-${appName}-${environmentName}'

module appServicePlan 'modules/app-service-plan.bicep' = {
  name: 'appServicePlanDeploy'
  params: {
    appServicePlanName: appServicePlanName
    location: location
    skuName: appServicePlanSku
    capacity: appServicePlanCapacity
    tags: tags
  }
}

module webApp 'modules/web-app.bicep' = {
  name: 'webAppDeploy'
  params: {
    webAppName: webAppName
    location: location
    appServicePlanId: appServicePlan.outputs.id
    tags: tags
    mysqlConnectionString: mysqlConnectionString
    mysqlUsername: mysqlUsername
    mysqlPassword: mysqlPassword
    rabbitMqHost: rabbitMqHost
    rabbitMqPort: rabbitMqPort
    rabbitMqUsername: rabbitMqUsername
    rabbitMqPassword: rabbitMqPassword
  }
}

output appServicePlanName string = appServicePlan.outputs.name
output webAppName string = webApp.outputs.name
output webAppDefaultHostName string = webApp.outputs.defaultHostName
