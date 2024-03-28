$Env:CONTROL_PLANE_ENVIRONMENT_CODE="SAPPRINT-CTRL"
$Env:WORKLOAD_ENV_NAME="TEST"
$Env:LOCATION=""
$Env:ARM_TENANT_ID = ""
$Env:ARM_SUBSCRIPTION_ID = ""
$Env:SAP_VIRTUAL_NETWORK_ID = ""
$Env:BGPRINT_SUBNET_ADDRESS_PREFIX = ""
$Env:ENABLE_LOGGING_ON_FUNCTION_APP = "false"
$Env:HOMEDRIVE = ""

$UniqueIdentifier = Read-Host "Please provide an identifier that makes the service principal names unique, for exaple (MGMT/CTRL)"

$confirmation = Read-Host "Do you want to create a new Application registration for Control Plane (needed for the Web Application) y/n?"
if ($confirmation -eq 'y') {
    $Env:CONTROL_PLANE_SERVICE_PRINCIPAL_NAME = $UniqueIdentifier + "-SAP-PRINT-APP"
}
else {
    $Env:CONTROL_PLANE_SERVICE_PRINCIPAL_NAME = Read-Host "Please provide the Application registration name"
}

$ENV:SAPPRINT_PATH = Join-Path -Path $Env:HOMEDRIVE -ChildPath "SAP-PRINT"
if (-not (Test-Path -Path $ENV:SAPPRINT_PATH)) {
    New-Item -Path $ENV:SAPPRINT_PATH -Type Directory | Out-Null
}

Set-Location -Path $ENV:SAPPRINT_PATH

Get-ChildItem -Path $ENV:SAPPRINT_PATH -Recurse | Remove-Item -Force -Recurse

$scriptUrl = "https://raw.githubusercontent.com/Azure/universal-print-for-sap-starter-pack/main/deployer/scripts/install_backend_printing.ps1"
$scriptPath = Join-Path -Path $ENV:SAPPRINT_PATH -ChildPath "install_backend_printing.ps1"

Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath

Invoke-Expression -Command $scriptPath
