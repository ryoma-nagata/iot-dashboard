// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

// The module contains a template to create a role assignment of the Synase MSI to a file system.
targetScope = 'resourceGroup'

// Parameters
param storageAccountFileSystemId string
param synapseId string
param iotId string

// Variables
var storageAccountName = length(split(storageAccountFileSystemId, '/')) >= 13 ? split(storageAccountFileSystemId, '/')[8] : 'incorrectSegmentLength'
var synapseName = last(split(synapseId, '/'))
var iotName =  last(split(iotId, '/'))


// Resources
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = {
  name: storageAccountName
}

resource synapse 'Microsoft.Synapse/workspaces@2021-03-01' existing = {
  name: synapseName

}
resource iot 'Microsoft.Devices/IotHubs@2021-07-02' existing = {
  name: iotName

}

resource synapseRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uniqueString(storageAccount.id, synapse.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'))
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: synapse.identity.principalId
    principalType: 'ServicePrincipal'
  }
}
resource iotRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(uniqueString(storageAccount.id, iot.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'))
  scope: storageAccount
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
    principalId: iot.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
