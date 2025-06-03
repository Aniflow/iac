param acrName string
param aksName string

resource aks 'Microsoft.ContainerService/managedClusters@2023-01-01' existing = {
  name: aksName
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(aks.name, acr.id, 'acrpull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalId: aks.identity.principalId
  }
}
