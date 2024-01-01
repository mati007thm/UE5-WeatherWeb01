#!/bin/bash

# set subscription
subscription=c42c6aa8-3c10-40e5-a3ff-ba5843e3dda5
# set name for ResourceGroup
resourceGroup=CLARCD_1Theuerman
# set name for AppServicePlan
appServicePlan=$resourceGroup-myAppServicePlan
# set name for WebApp
webApp=UE5-WeatherWeb01
# set name for DeploymentUser
deploymentUser=$resourceGroup-myUser
# set DeploymentPassword
deploymentPassword=Pa55w.rd
# set DeploymentLocalGitUrl
deploymentLocalGitUrl=https://$deploymentUser@$webApp.scm.azurewebsites.net/$webApp.git

inside_git_repo="$(git rev-parse --is-inside-work-tree 2>/dev/null)"

if [ "$inside_git_repo" ]; then
  echo "inside git repo"
else
  echo git not initialized
  git init
fi

dotnet restore
#dotnet run

az login
az account set --subscription $subscription

az webapp deployment user set --user-name $deploymentUser --password $deploymentPassword
# Uncomment the next line if the resource group needs to be created
# az group create --name $resourceGroup --location "West Europe"
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku FREE
az webapp create --resource-group $resourceGroup --plan $appServicePlan --name $webApp --deployment-local-git
az webapp config appsettings set --name $webApp --resource-group $resourceGroup --settings DEPLOYMENT_BRANCH='main'
git remote add azure $deploymentLocalGitUrl
git branch -m main
git add .
git commit -m "azure commit"
git push azure main