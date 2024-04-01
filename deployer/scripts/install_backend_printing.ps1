#!/bin/bash

$WORKLOAD_ENV_NAME = $Env:WORKLOAD_ENV_NAME
$ARM_TENANT_ID = $Env:ARM_TENANT_ID
$ARM_SUBSCRIPTION_ID = $Env:ARM_SUBSCRIPTION_ID
$CONTROL_PLANE_SERVICE_PRINCIPAL_NAME = $Env:CONTROL_PLANE_SERVICE_PRINCIPAL_NAME
$CONTROL_PLANE_RESOURCE_GROUP_NAME = $Env:CONTROL_PLANE_ENVIRONMENT_CODE + "-RG"
$STORAGE_ACCOUNT_NAME = $Env:CONTROL_PLANE_ENVIRONMENT_CODE.ToLower() + "tstatebgprinting"
$CONTAINER_NAME = "tfstate"
$ACR_NAME = "sapprintacr"
$ENABLE_LOGGING_ON_FUNCTION_APP = $Env:ENABLE_LOGGING_ON_FUNCTION_APP

$variables = @("WORKLOAD_ENV_NAME",
  "ARM_TENANT_ID",
  "ARM_SUBSCRIPTION_ID",
  "CONTROL_PLANE_SERVICE_PRINCIPAL_NAME",
  "CONTROL_PLANE_RESOURCE_GROUP_NAME",
  "STORAGE_ACCOUNT_NAME",
  "CONTAINER_NAME",
  "ACR_NAME",
  "ENABLE_LOGGING_ON_FUNCTION_APP")

foreach ($var in $variables) {
  if ([string]::IsNullOrEmpty((Get-Variable -Name $var).Value)) {
    Write-Host "$var is null or empty!" -ForegroundColor Red
  }
}

if ($ARM_TENANT_ID.Length -eq 0) {
  az login --output none --only-show-errors
}
else {
  az login --output none --tenant $ARM_TENANT_ID --only-show-errors
}

az config set extension.use_dynamic_install=yes_without_prompt --only-show-errors

if ($ARM_SUBSCRIPTION_ID.Length -eq 0) {
  Write-Host "$ARM_SUBSCRIPTION_ID is not set!" -ForegroundColor Red
  $ARM_SUBSCRIPTION_ID = Read-Host "Please enter a subscription ID"
}

az account set --subscription $ARM_SUBSCRIPTION_ID

$app_registration = (az ad sp list --all --filter "startswith(displayName,'$CONTROL_PLANE_SERVICE_PRINCIPAL_NAME')" --query "[?displayName=='$CONTROL_PLANE_SERVICE_PRINCIPAL_NAME'].displayName | [0]" --only-show-errors)

$scopes = "/subscriptions/$ARM_SUBSCRIPTION_ID"

if ($app_registration.Length -gt 0) {
  Write-Host "Found an existing Service Principal:" $CONTROL_PLANE_SERVICE_PRINCIPAL_NAME
  $ExistingData = (az ad sp list --all --filter "startswith(displayName,'$CONTROL_PLANE_SERVICE_PRINCIPAL_NAME')" --query  "[?displayName=='$CONTROL_PLANE_SERVICE_PRINCIPAL_NAME']| [0]" --only-show-errors) | ConvertFrom-Json

  $ARM_CLIENT_ID = $ExistingData.appId
  $ARM_OBJECT_ID = $ExistingData.Id
  $ARM_TENANT_ID = $ExistingData.appOwnerOrganizationId

  $confirmation = Read-Host "Reset the Service Principal password y/n?"
  if ($confirmation -eq 'y') {

    $ARM_CLIENT_SECRET = (az ad sp credential reset --id $ARM_CLIENT_ID --append --query "password" --out tsv --only-show-errors).Replace("""", "")
  }
  else {
    $ARM_CLIENT_SECRET = Read-Host "Please enter the Service Principal password"
  }

}
else {
  Write-Host "Creating the Service Principal" $CONTROL_PLANE_SERVICE_PRINCIPAL_NAME -ForegroundColor Green
  $SPN_DATA = (az ad sp create-for-rbac --role "Contributor" --scopes $scopes --name $CONTROL_PLANE_SERVICE_PRINCIPAL_NAME --only-show-errors) | ConvertFrom-Json

  $ARM_CLIENT_SECRET = $SPN_DATA.password
  $ExistingData = (az ad sp list --all --filter "startswith(displayName,'$CONTROL_PLANE_SERVICE_PRINCIPAL_NAME')" --query  "[?displayName=='$CONTROL_PLANE_SERVICE_PRINCIPAL_NAME'] | [0]" --only-show-errors) | ConvertFrom-Json
  $ARM_CLIENT_ID = $ExistingData.appId
  $ARM_TENANT_ID = $ExistingData.appOwnerOrganizationId
  $ARM_OBJECT_ID = $ExistingData.Id
}
Write-Host "Service Principal Name:" $CONTROL_PLANE_SERVICE_PRINCIPAL_NAME

# Assign the Service Principal to the User Access Administrator role
az role assignment create --assignee $ARM_CLIENT_ID --role "Contributor" --subscription $ARM_SUBSCRIPTION_ID --scope /subscriptions/$ARM_SUBSCRIPTION_ID --output none
az role assignment create --assignee $ARM_CLIENT_ID --role "User Access Administrator" --subscription $ARM_SUBSCRIPTION_ID --scope /subscriptions/$ARM_SUBSCRIPTION_ID --output none

Set-Location -Path $ENV:SAPPRINT_PATH

# check if the repository exists, if it does, remove it
if (Test-Path "universal-print-for-sap-starter-pack") {
  Remove-Item "./universal-print-for-sap-starter-pack" -Recurse -Force
}

# Clone the git repository
Write-Host "######## Cloning the code repo ########" -ForegroundColor Green
git clone https://github.com/Azure/universal-print-for-sap-starter-pack.git
Set-Location -Path "./universal-print-for-sap-starter-pack"
git checkout main

# Create resource group
az group create --name $CONTROL_PLANE_RESOURCE_GROUP_NAME --location eastus --only-show-errors

# Create the Azure container registry and build the docker image
Write-Host "######## Build the docker image and push it to the ACR registry ########" -ForegroundColor Green
az acr create --resource-group $CONTROL_PLANE_RESOURCE_GROUP_NAME --name $ACR_NAME --sku Basic --only-show-errors
az acr show --name $ACR_NAME --only-show-errors
az acr login --name $ACR_NAME --expose-token --only-show-errors
az acr build --registry $ACR_NAME --image bgprinting:latest --file ./backend-printing/Dockerfile ./backend-printing --only-show-errors

Write-Host "######## Creating storage account to store the terraform state ########" -ForegroundColor Green
# Create storage account
az storage account create --resource-group $CONTROL_PLANE_RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob --only-show-errors
az storage account update --resource-group $CONTROL_PLANE_RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --https-only true --allow-blob-public-access false --only-show-errors
az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --only-show-errors

$Env:TF_VAR_tenant_id = $ARM_TENANT_ID
$Env:TF_VAR_subscription_id = $ARM_SUBSCRIPTION_ID
$Env:TF_VAR_client_id = $ARM_CLIENT_ID
$Env:TF_VAR_client_secret = $ARM_CLIENT_SECRET
$Env:TF_VAR_object_id = $ARM_OBJECT_ID
$Env:TF_VAR_location = $Env:LOCATION
$Env:TF_VAR_environment = $Env:WORKLOAD_ENV_NAME
$Env:TF_VAR_virtual_network_id = $Env:SAP_VIRTUAL_NETWORK_ID
$Env:TF_VAR_subnet_address_prefixes = $Env:BGPRINT_SUBNET_ADDRESS_PREFIX
$Env:TF_VAR_container_registry_url = $ACR_NAME + ".azurecr.io"
$Env:TF_VAR_container_image_name = "bgprinting"
$Env:TF_VAR_control_plane_rg = $CONTROL_PLANE_RESOURCE_GROUP_NAME
$ENV:TF_VAR_enable_logging_on_function_app = $ENABLE_LOGGING_ON_FUNCTION_APP

$terraform_key = $WORKLOAD_ENV_NAME + ".terraform.tfstate"
$terraform_directory = "./deployer/terraform"

# Initialize the terraform
Write-Host "######## Initializing Terraform ########" -ForegroundColor Green
terraform -chdir="$terraform_directory" init -reconfigure -upgrade -backend-config="key=$terraform_key" -backend-config="storage_account_name=$STORAGE_ACCOUNT_NAME"  -backend-config="resource_group_name=$CONTROL_PLANE_RESOURCE_GROUP_NAME"  -backend-config="container_name=$CONTAINER_NAME"  -backend-config="tenant_id=$ARM_TENANT_ID" -backend-config="client_id=$ARM_CLIENT_ID" -backend-config="client_secret=$ARM_CLIENT_SECRET" -backend-config="subscription_id=$ARM_SUBSCRIPTION_ID"

# Refresh the terraform
Write-Host "######## Refreshing Terraform ########" -ForegroundColor Green
terraform -chdir="$terraform_directory"  refresh

# Plan the terraform
Write-Host "######## Planning the Terraform ########" -ForegroundColor Green
terraform -chdir="$terraform_directory" plan -compact-warnings -json -no-color -parallelism=5 -out=tfplan.tfstate 

# Apply the terraform
Write-Host "######## Applying the Terraform ########" -ForegroundColor Green
terraform -chdir="$terraform_directory" apply -auto-approve -compact-warnings -json -no-color -parallelism=5