// =============================================================================
// modules/web-app.bicep
// Single resource: Web App (App Service), Linux, Java 21 (Java SE) runtime
//
// NOTE: MySQL and RabbitMQ connection settings are NOT configured here.
// This app will rely on whatever App Settings / connection details are
// supplied out-of-band against externally hosted MySQL and RabbitMQ
// instances. If those are not reachable/configured at runtime, the Web App
// may fail to start or crash-loop (see README.md "Known Startup Risks").
// =============================================================================

@description('Name of the Web App.')
param name string

@description('Azure region.')
param location string

@description('Resource ID of the App Service Plan this Web App runs on.')
param appServicePlanId string

@description('Java version, e.g. 21. Used only to build the linuxFxVersion runtime stack string.')
param javaVersion string

@description('Java server type, e.g. JAVA for Java SE. Used only to build the linuxFxVersion runtime stack string.')
param javaServer string

@description('Java server version, e.g. SE. Not directly used in linuxFxVersion (Java SE format is JAVA|{version}-java{version}); retained for documentation/traceability of the requested runtime.')
param javaServerVersion string

@description('Tags to apply.')
param tags object = {}

// Linux Java SE runtime stack string, e.g. "JAVA|21-java21" for Java 21 (Java SE, no app server).
var linuxFxVersion = '${javaServer}|${javaVersion}-java${javaVersion}'

resource webApp 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  tags: union(tags, {
    javaServerVariant: javaServerVersion
  })
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
    }
  }
}

@description('Resource ID of the Web App.')
output id string = webApp.id

@description('Name of the Web App.')
output name string = webApp.name

@description('Default hostname of the Web App.')
output defaultHostName string = webApp.properties.defaultHostName
