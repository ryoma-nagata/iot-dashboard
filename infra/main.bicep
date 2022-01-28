
targetScope = 'subscription'

// general params
param location string ='japaneast' 

param project string = 'iot'
@allowed([
  'demo'
  'poc'
  'dev'
  'test'
  'prod'
])
param env string ='demo'
param deployment_id string ='001'
param userId string 

var uniqueName = '${project}-pi${deployment_id}'
var rg_name = '${uniqueName}-rg-iot-lambda-${env}'
var tags = {
  Environment : env
  Project : project
}

// resources 
resource rg_iot 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location:location
  name:rg_name
  tags:tags
}

module lambda 'modules/lambda.bicep' ={
  scope:rg_iot
  name:'lambdaServiceDeployment'
  params:{
    tags:tags
    userId:userId
    uniqueName:uniqueName 
    env:env
    location:location
  }
}
