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

var animeDbName = string('${abbrs.sqlServersDatabases}${environmentName}-animedb-${dtapInitial}')
var userDbName = string('${abbrs.sqlServersDatabases}${environmentName}-userdb-${dtapInitial}')
var logAnalyticsName = string('${abbrs.logAnalyticsWorkspace}${environmentName}-${dtapInitial}')
var appInsightsName = string('${abbrs.operationalInsightsWorkspaces}${environmentName}-${dtapInitial}')
var aksClusterName = string('${abbrs.containerServiceManagedClusters}${environmentName}-${dtapInitial}')

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: '${abbrs.resourcesResourceGroups}${environmentName}-${dtapInitial}'
  location: location
}

module animeMysql 'mysql/mysql-database.bicep' = {
  name: 'animeDbDeployment'
  scope: resourceGroup
  params: {
    dbName: animeDbName 
    mysqlAdminUsername: mysqlAdminUsername
    mysqlAdminPassword: mysqlAdminPassword 
  }
}

module userMysql 'mysql/mysql-database.bicep' = {
  name: 'userDbDeployment'
  scope: resourceGroup
  params: {
    dbName: userDbName 
    mysqlAdminUsername: mysqlAdminUsername 
    mysqlAdminPassword: mysqlAdminPassword
  }
}

module logAnalytics 'monitoring/log-analytics.bicep' = {
  name: 'LogAnalyticsDeployment'
  scope: resourceGroup
  params: {
    logAnalyticsName: logAnalyticsName
  }
}

module appInsights 'monitoring/app-insights.bicep' = {
  name: 'appInsightsDeployment'
  scope: resourceGroup
  params: {
    appInsightsName: appInsightsName 
    LogAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsId
  }
}

module kubernetesService 'aks/azure-k8s.bicep' = {
  name: 'AKSDeployment'
  scope: resourceGroup
  params: {
    aksName: aksClusterName 
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsId 
  }
}
