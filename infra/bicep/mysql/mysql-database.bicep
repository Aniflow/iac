param dbName string
param location string = resourceGroup().location

@secure()
param mysqlAdminUsername string

@secure()
param mysqlAdminPassword string

resource mysql 'Microsoft.DBforMySQL/flexibleServers@2023-06-30' = {
  name: dbName
  location: location
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
  }
  properties: {
    administratorLogin: mysqlAdminUsername
    administratorLoginPassword: mysqlAdminPassword
    storage: {
      storageSizeGB: 32
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}
