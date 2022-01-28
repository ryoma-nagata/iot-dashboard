targetScope = 'resourceGroup'

param location string
param iotName string
param tags object
param storageAccountFileSystemId string 
var storageAccountFileSystemName = length(split(storageAccountFileSystemId, '/')) >= 13 ? last(split(storageAccountFileSystemId, '/')) : 'incorrectSegmentLength'
var storageAccountName = length(split(storageAccountFileSystemId, '/')) >= 13 ? split(storageAccountFileSystemId, '/')[8] : 'incorrectSegmentLength'


resource iothub 'Microsoft.Devices/IotHubs@2021-07-02'={
  location:location
  name:iotName
  sku:{
    name: 'B1'
    capacity:10
  }
  identity:{
    type:'SystemAssigned'
  }  
  tags:tags
  properties:{
    routing:{
      endpoints:{
        storageContainers:[
          {
            name: 'datalakeLanding'
            containerName: storageAccountFileSystemName
            encoding:'JSON'
            authenticationType:'identityBased'
            fileNameFormat: '{iothub}/{partition}/{YYYY}/{MM}/{DD}/{HH}/{mm}.JSON'
            batchFrequencyInSeconds:100
            maxChunkSizeInBytes:104857600
            endpointUri:'https://${storageAccountName}.blob.${environment().suffixes.storage}/' 
            subscriptionId:subscription().subscriptionId
            resourceGroup:resourceGroup().name
            
          }
        ]
      }
      routes:[
        {
          name: 'datalake'
          endpointNames: [
            'datalakeLanding'
          ]
          isEnabled: true
          source: 'DeviceMessages'
        }
        {
          name: 'events'
          endpointNames: [
            'events'
          ]
          isEnabled: true
          source: 'DeviceMessages'
        }
      ]
    }
  }
}
