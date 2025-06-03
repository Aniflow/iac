param dbName string
param location string = resourceGroup().location

@secure()
param mysqlAdminUsername string

@secure()
param mysqlAdminPassword string

resource mysql 'Microsoft.DBforMySQL/flexibleServers@2023-12-30' = {
  name: dbName
  location: location
  sku: {
    name: 'Basic_B1s'
    tier: 'Basic'
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
}
