param aksName string
param logAnalyticsWorkspaceId string
param location string = resourceGroup().location

resource aks 'Microsoft.ContainerService/managedClusters@2025-03-01' = {
  name: aksName
  location: location
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${aksName}-dns'
    enableRBAC: true

    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 1
        minCount: 1
        maxCount: 3
        enableAutoScaling: true
        vmSize: 'Standard_D2s_v3'
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]

    addonProfiles: {
      ingressApplicationGateway: {
        enabled: false
      }
      omsAgent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }

    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
    }
  }
}

output aksId string = aks.id
