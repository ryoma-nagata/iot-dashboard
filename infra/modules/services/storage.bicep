// This template is used to create a datalake.
targetScope = 'resourceGroup'

// Parameters
param location string
param tags object

param storageName string
param fileSystemNames array


// Variables
var storageNameCleaned = replace(storageName, '-', '')
var resourceAccessRules =  [
  {
    tenantId: subscription().tenantId
    resourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/*/providers/Microsoft.Synapse/workspaces/*'
  }
] 

// Resources
resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageNameCleaned
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: true
    isNfsV3Enabled: false
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'Metrics'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
      resourceAccessRules: resourceAccessRules
    }
    // routingPreference: {  // Not supported for thsi account
    //   routingChoice: 'MicrosoftRouting'
    //   publishInternetEndpoints: false
    //   publishMicrosoftEndpoints: false
    // }
    supportsHttpsTrafficOnly: true
  }
}

resource storageManagementPolicies 'Microsoft.Storage/storageAccounts/managementPolicies@2021-02-01' = {
  parent: storage
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          enabled: true
          name: 'default'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                // enableAutoTierToHotFromCool: true  // Not available for HNS storage yet
                tierToCool: {
                  // daysAfterLastAccessTimeGreaterThan: 90  // Not available for HNS storage yet
                  daysAfterModificationGreaterThan: 90
                }
                // tierToArchive: {  // Not available for HNS storage yet
                //   // daysAfterLastAccessTimeGreaterThan: 365  // Not available for HNS storage yet
                //   daysAfterModificationGreaterThan: 365
                // }
                // delete: {  // Uncomment, if you also want to delete assets after a certain timeframe
                //   // daysAfterLastAccessTimeGreaterThan: 730  // Not available for HNS storage yet
                //   daysAfterModificationGreaterThan: 730
                // }
              }
              snapshot: {
                tierToCool: {
                  daysAfterCreationGreaterThan: 90
                }
                // tierToArchive: {  // Not available for HNS storage yet
                //   daysAfterCreationGreaterThan: 365
                // }
                // delete: {  // Uncomment, if you also want to delete assets after a certain timeframe
                //   daysAfterCreationGreaterThan: 730
                // }
              }
              version: {
                tierToCool: {
                  daysAfterCreationGreaterThan: 90
                }
                // tierToArchive: {  // Not available for HNS storage yet
                //   daysAfterCreationGreaterThan: 365
                // }
                // delete: {  // Uncomment, if you also want to delete assets after a certain timeframe
                //   daysAfterCreationGreaterThan: 730
                // }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
              prefixMatch: []
            }
          }
        }
      ]
    }
  }
}

resource storageBlobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-02-01' = {
  parent: storage
  name: 'default'
  properties: {
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    cors: {
      corsRules: []
    }
    // automaticSnapshotPolicyEnabled: true  // Not available for HNS storage yet
    // changeFeed: {
    //   enabled: true
    //   retentionInDays: 7
    // }
    // defaultServiceVersion: ''
    // deleteRetentionPolicy: {
    //   enabled: true
    //   days: 7
    // }
    // isVersioningEnabled: true
    // lastAccessTimeTrackingPolicy: {
    //   name: 'AccessTimeTracking'
    //   enable: true
    //   blobType: [
    //     'blockBlob'
    //   ]
    //   trackingGranularityInDays: 1
    // }
    // restorePolicy: {
    //   enabled: true
    //   days: 7
    // }
  }
}

resource storageFileSystems 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = [for fileSystemName in fileSystemNames: {
  parent: storageBlobServices
  name: fileSystemName
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}]

// Outputs
output storageId string = storage.id
output storageFileSystemIds array = [for fileSystemName in fileSystemNames: {
  storageFileSystemId: resourceId('Microsoft.Storage/storageAccounts/blobServices/containers', storageNameCleaned, 'default', fileSystemName)
}]
