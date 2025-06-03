targetScope = 'subscription'

param environmentName string
param location string
param dtap string

@secure()
param mysqlAdminUsername string

@secure()
param mysqlAdminPassword string

var dtapInitial = string(first(toLower(dtap)))
var abbrs = loadJsonContent('abbreviations.json')

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}-${dtapInitial}'
  location: location
}

module containerRegistry 'acr/container-registry.bicep' = {
  name: 'ContainerRegistryDeployment'
  scope: resourceGroup
  params: {
    acrName: '${abbrs.containerRegistryRegistries}-${environmentName}-${dtapInitial}'
  }
}

module assignPullRole 'security/roles.bicep' = {
  name: 'AssignAcrPullRole'
  scope: resourceGroup
  params: {
    acrName: containerRegistry.name
    aksName: kubernetesService.name
  }
}

module animeMysql 'mysql/mysql-database.bicep' = {
  name: 'animeDbDeployment'
  scope: resourceGroup
  params: {
    dbName: '${abbrs.sqlServersDatabases}-${environmentName}-animedb-${dtapInitial}'
    mysqlAdminUsername: mysqlAdminUsername
    mysqlAdminPassword: mysqlAdminPassword 
  }
}

module userMysql 'mysql/mysql-database.bicep' = {
  name: 'userDbDeployment'
  scope: resourceGroup
  params: {
    dbName: '${abbrs.sqlServersDatabases}-${environmentName}-userdb-${dtapInitial}'
    mysqlAdminUsername: mysqlAdminUsername 
    mysqlAdminPassword: mysqlAdminPassword
  }
}

module logAnalytics 'monitoring/log-analytics.bicep' = {
  name: 'LogAnalyticsDeployment'
  scope: resourceGroup
  params: {
    logAnalyticsName: '${abbrs.logAnalyticsWorkspace}${environmentName}-${dtapInitial}'
  }
}

module appInsights 'monitoring/app-insights.bicep' = {
  name: 'appInsightsDeployment'
  scope: resourceGroup
  params: {
    appInsightsName: '${abbrs.operationalInsightsWorkspaces}${environmentName}-${dtapInitial}'
    LogAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsId
  }
}

module kubernetesService 'aks/azure-k8s.bicep' = {
  name: 'AKSDeployment'
  scope: resourceGroup
  params: {
    aksName: '${abbrs.containerServiceManagedClusters}${environmentName}-${dtapInitial}'
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsId 
  }
  dependsOn: [
    containerRegistry
    animeMysql
    userMysql
  ]
}
