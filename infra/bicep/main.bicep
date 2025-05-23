@description('Name of the AKS cluster')
param aksClusterName string = 'myAksCluster'

@description('AKS Node VM size')
param nodeVmSize string = 'Standard_DS2_v2'

@description('Number of nodes in AKS node pool')
param nodeCount int = 1

@description('Name of the ACR instance')
param acrName string = 'myAcrRegistry'

@description('MySQL server admin username')
param mysqlAdminUsername string = 'mysqladmin'

@description('MySQL admin password (secure string)')
@secure()
param mysqlAdminPassword string

@description('Location for all resources')
param location string = resourceGroup().location


resource aks 'Microsoft.ContainerService/managedClusters@2023-03-01' = {
  name: aksClusterName
  location: location
  properties: {
    kubernetesVersion: ''
    dnsPrefix: '${aksClusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: nodeVmSize
        maxPods: 110
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
      }
    ]
    linuxProfile: {
      adminUsername: 'azureuser'
      ssh: {
        publicKeys: [
          {
            keyData: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCy...'
          }
        ]
      }
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
  }
}


resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
}


resource mysqlUserService 'Microsoft.DBforMySQL/flexibleServers@2023-03-01' = {
  name: '${aksClusterName}-mysql-user'
  location: location
  sku: {
    name: 'Basic_B1s'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    version: '8.0'
    administratorLogin: mysqlAdminUsername
    administratorLoginPassword: mysqlAdminPassword
    storage: {
      storageSizeGB: 32
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
  dependsOn: [
    aks
  ]
}

resource mysqlAnimeService 'Microsoft.DBforMySQL/flexibleServers@2023-03-01' = {
  name: '${aksClusterName}-mysql-anime'
  location: location
  sku: {
    name: 'Basic_B1s'
    tier: 'Basic'
    capacity: 1
  }
  properties: {
    version: '8.0'
    administratorLogin: mysqlAdminUsername
    administratorLoginPassword: mysqlAdminPassword
    storage: {
      storageSizeGB: 32
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
  dependsOn: [
    aks
  ]
}


output aksClusterName string = aks.name
output acrLoginServer string = acr.properties.loginServer
