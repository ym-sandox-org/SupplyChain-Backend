// Module: Web App (Linux, Java 21)
// Hosts the SupplyChain Backend JAR on Azure App Service.
//
// IMPORTANT — External runtime dependencies (NOT provisioned by this template):
//   - MySQL 8.0 database (accessed via JDBC/JPA, see `mysql-connector-java`)
//   - RabbitMQ broker (accessed via `spring-boot-starter-amqp`)
// This module does NOT create Azure Database for MySQL, Azure Service Bus, or any
// other managed resource for these dependencies. The app settings below are
// placeholders only — they must be populated with a reachable MySQL and RabbitMQ
// endpoint (self-hosted, on another Azure resource, or on-prem via VPN/ExpressRoute)
// before/at deploy time.
//
// WARNING: Spring Boot's datasource and AMQP auto-configuration fail fast at startup
// if MySQL or RabbitMQ are unreachable. If these placeholder values are left unset or
// point to an unreachable endpoint, the Web App is expected to crash-loop and/or fail
// App Service health checks (HTTP ping on the configured health path).

@description('Name of the Web App')
param webAppName string

@description('Azure region for the Web App')
param location string

@description('Resource ID of the App Service Plan hosting this Web App')
param appServicePlanId string

@description('Tags to apply to the resource')
param tags object = {}

@description('Linux FX version for the Java runtime (Java SE 21 on this App Service Linux image)')
param linuxFxVersion string = 'JAVA|21-java21'

@description('MySQL JDBC connection string. EXTERNAL DEPENDENCY — not provisioned by this template. Must point to a reachable MySQL 8.0 instance or the app will fail to start / fail health checks.')
@secure()
param mysqlConnectionString string = ''

@description('MySQL datasource username. EXTERNAL DEPENDENCY — not provisioned by this template.')
param mysqlUsername string = ''

@description('MySQL datasource password. EXTERNAL DEPENDENCY — not provisioned by this template.')
@secure()
param mysqlPassword string = ''

@description('RabbitMQ host. EXTERNAL DEPENDENCY — not provisioned by this template. Must be a reachable RabbitMQ broker or the app will fail to start / fail health checks.')
param rabbitMqHost string = ''

@description('RabbitMQ port')
param rabbitMqPort string = '5672'

@description('RabbitMQ username. EXTERNAL DEPENDENCY — not provisioned by this template.')
param rabbitMqUsername string = ''

@description('RabbitMQ password. EXTERNAL DEPENDENCY — not provisioned by this template.')
@secure()
param rabbitMqPassword string = ''

resource webApp 'Microsoft.Web/sites@2023-12-01' = {
  name: webAppName
  location: location
  tags: tags
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      healthCheckPath: '/actuator/health'
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '8080'
        }
        {
          // EXTERNAL DEPENDENCY (MySQL) — placeholder, see module header comment.
          name: 'SPRING_DATASOURCE_URL'
          value: mysqlConnectionString
        }
        {
          // EXTERNAL DEPENDENCY (MySQL) — placeholder, see module header comment.
          name: 'SPRING_DATASOURCE_USERNAME'
          value: mysqlUsername
        }
        {
          // EXTERNAL DEPENDENCY (MySQL) — placeholder, see module header comment.
          name: 'SPRING_DATASOURCE_PASSWORD'
          value: mysqlPassword
        }
        {
          // EXTERNAL DEPENDENCY (RabbitMQ) — placeholder, see module header comment.
          name: 'SPRING_RABBITMQ_HOST'
          value: rabbitMqHost
        }
        {
          // EXTERNAL DEPENDENCY (RabbitMQ) — placeholder, see module header comment.
          name: 'SPRING_RABBITMQ_PORT'
          value: rabbitMqPort
        }
        {
          // EXTERNAL DEPENDENCY (RabbitMQ) — placeholder, see module header comment.
          name: 'SPRING_RABBITMQ_USERNAME'
          value: rabbitMqUsername
        }
        {
          // EXTERNAL DEPENDENCY (RabbitMQ) — placeholder, see module header comment.
          name: 'SPRING_RABBITMQ_PASSWORD'
          value: rabbitMqPassword
        }
      ]
    }
  }
}

output id string = webApp.id
output name string = webApp.name
output defaultHostName string = webApp.properties.defaultHostName
