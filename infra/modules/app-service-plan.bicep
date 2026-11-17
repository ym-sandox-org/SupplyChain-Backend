// =============================================================================
// modules/app-service-plan.bicep
// Single resource: App Service Plan (Linux)
// =============================================================================

@description('Name of the App Service Plan.')
param name string

@description('Azure region.')
param location string

@description('SKU name, e.g. B1 for a demo/review workload.')
param skuName string

@description('SKU tier, e.g. Basic.')
param skuTier string

@description('Tags to apply.')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: 'linux'
  properties: {
    reserved: true // required for Linux plans
  }
}

@description('Resource ID of the App Service Plan.')
output id string = appServicePlan.id

@description('Name of the App Service Plan.')
output name string = appServicePlan.name
