targetScope = 'resourceGroup'

param location string
param iotName string
param tags object


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
}

output iotId string = iothub.id
