// Module: App Service Plan (Linux)
// Hosts the SupplyChain Backend Web App. No database or messaging resources
// are created here — MySQL and RabbitMQ are external dependencies (see README.md).

@description('Name of the App Service Plan')
param appServicePlanName string

@description('Azure region for the App Service Plan')
param location string

@description('App Service Plan SKU (e.g. P1v3, B1, S1)')
param skuName string = 'P1v3'

@description('Number of worker instances')
param capacity int = 1

@description('Tags to apply to the resource')
param tags object = {}

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: 'linux'
  sku: {
    name: skuName
    capacity: capacity
  }
  properties: {
    reserved: true // required for Linux plans
  }
}

output id string = appServicePlan.id
output name string = appServicePlan.name
