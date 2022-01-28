// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// This template is used to create a Synapse workspace.
targetScope = 'resourceGroup'

// Parameters
param location string
param tags object

param synapseName string
param administratorUsername string = 'SqlServerMainUser'
@secure()
param administratorPassword string

param synapseDefaultStorageAccountFileSystemId string

@allowed([
  'true'
  'false'
])
param AllowAll string = 'true'


// Variables
var synapseDefaultStorageAccountFileSystemName = length(split(synapseDefaultStorageAccountFileSystemId, '/')) >= 13 ? last(split(synapseDefaultStorageAccountFileSystemId, '/')) : 'incorrectSegmentLength'
var synapseDefaultStorageAccountName = length(split(synapseDefaultStorageAccountFileSystemId, '/')) >= 13 ? split(synapseDefaultStorageAccountFileSystemId, '/')[8] : 'incorrectSegmentLength'


// Resources
resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' = {
  name: synapseName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: 'https://${synapseDefaultStorageAccountName}.dfs.${environment().suffixes.storage}' 
      filesystem: synapseDefaultStorageAccountFileSystemName
    }

    publicNetworkAccess: 'Enabled'

    sqlAdministratorLogin: administratorUsername
    sqlAdministratorLoginPassword: administratorPassword

  }
}
resource synapseWorkspace_allowAll 'Microsoft.Synapse/workspaces/firewallRules@2021-06-01' = if (AllowAll == 'true') {
  parent: synapse
  name: 'allowAll'

  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource synapseManagedIdentitySqlControlSettings 'Microsoft.Synapse/workspaces/managedIdentitySqlControlSettings@2021-03-01' = {
  parent: synapse
  name: 'default'
  properties: {
    grantSqlControlToManagedIdentity: {
      desiredState: 'Enabled'
    }
  }
}


// Outputs
output synapseId string = synapse.id
