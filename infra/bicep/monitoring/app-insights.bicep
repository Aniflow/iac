param appInsightsName string
param LogAnalyticsWorkspaceId string
param location string = resourceGroup().location

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: LogAnalyticsWorkspaceId 
  }
}
