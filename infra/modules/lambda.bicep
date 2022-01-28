targetScope = 'resourceGroup'

param location string ='japaneast' 
param env string ='demo'
param uniqueName string
param tags object
param userId string 

var iothubName = '${uniqueName}-iot-${env}'
var datalakeName = replace(replace(toLower('${uniqueName}-dls-cold-${env}'), '-', ''), '_', '')
var FileSytemNames = [
  'raw'
  'enrich'
  'curated'
  'workspace'
  'landing'
]
var synapseName = '${uniqueName}-syn-${env}'


module iothub 'services/iothub.bicep' ={
  name:'iotHubDeployment'
  params:{
    location: location
    tags: tags
    iotName: iothubName
  }
}

module storage 'services/storage.bicep' ={
  name:'storageDeployment'
  params:{
    location: location
    tags: tags
    storageName: datalakeName
    fileSystemNames: FileSytemNames
  }
}

module synapse 'services/synapse.bicep' ={
  name:'synapseDeployment'
  params:{
    location: location
    tags: tags
    synapseDefaultStorageAccountFileSystemId: storage.outputs.storageFileSystemIds[3].storageFileSystemId
    administratorPassword: ''
    synapseName: synapseName
  }
}
module rbac_synapse_storage 'auxiliary/synapseRoleAssignmentStorage.bicep'={
  name:'synapseRBACStorage'
  params:{
    iotId:iothub.outputs.iotId
    storageAccountFileSystemId: storage.outputs.storageFileSystemIds[3].storageFileSystemId
    synapseId: synapse.outputs.synapseId
  }
}

module user_rbac_Storage 'auxiliary/userRBACStorage.bicep' ={
  name:'userRBAC'
  params:{
    storageAccountFileSystemId: storage.outputs.storageFileSystemIds[3].storageFileSystemId
    userId: userId
  }
}

module iothubRouting 'auxiliary/iothubRouting.bicep' ={
  name:'IotHubRouting'
  dependsOn:[
    rbac_synapse_storage
  ]
  params:{
    iotName:iothubName
    location:location
    storageAccountFileSystemId:storage.outputs.storageFileSystemIds[4].storageFileSystemId
    tags:tags
  }


}
