param aksName string
param logAnalyticsWorkspaceId string
param location string = resourceGroup().location

resource aks 'Microsoft.ContainerService/managedClusters@2023-01-01' = {
  name: aksName
  location: location
  sku: {
    name: 'Basic'
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
        vmSize: 'Standard_DS2_v2'
        osType: 'Linux'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
      }
    ]

    addonProfiles: {
      ingressApplicationGateway: {
        enabled: false
      }
      ingress: {
        enabled: true
        config: {}
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
