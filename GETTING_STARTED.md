# 🖨️ SAP Universal Backend Printing: A Cloud-Driven Revolution
Welcome to the future of printing in SAP landscapes, where the fusion of cloud technology and printing solutions opens up a new realm of possibilities. From the bustling floors of production to the quiet hum of office printers, our open-source solution seamlessly integrates with your SAP system, propelling your printing capabilities into the cloud era with Microsoft’s Universal Print.

## 🌐 Frontend vs. Backend: A Tale of Two Printings
In the SAP universe, we encounter two distinct printing scenarios: frontend and backend. Frontend printing is designed for end-users who operate directly from SAPGUI, web browsers, and SAP’s web-based applications. It’s the go-to method for those immediate, on-demand printing tasks. For a comprehensive guide on setting up frontend printing with SAP, take a look at this Microsoft Learn page.

On the flip side, we have backend printing — the powerhouse behind large-scale, automated print jobs that are triggered by applications, not people. This is where the SAP Backend Print comes into play. It’s an open-source marvel that intercepts spool requests from the SAP system and dispatches them to Universal Print devices. You can effortlessly deploy this solution within your Azure subscription and tailor it to your SAP system using Terraform. And the best part? The backend print worker is a serverless solution, thriving on Azure Function App, ensuring a smooth and efficient printing process.

[Terraform](https://www.terraform.io/) from Hashicorp is an open-source tool for provisioning and managing cloud infrastructure.

## 🛠️ Crafting the Infrastructure: Azure & SAP Pre-requisites
### Azure Pre-requisites
- **Azure AD Tenant**: Ensure it’s empowered with Universal Print capabilities, setting the stage for a seamless printing experience.
- **Azure Subscription**: Your gateway to Microsoft’s cloud services.
- **Microsoft Universal Print License**: Included with Microsoft 365 E3 or higher, this license is your ticket to hassle-free cloud printing. [Learn More About Licensing](https://learn.microsoft.com/en-us/universal-print/fundamentals/universal-print-license)
- **Registered Printers**: Your faithful print companions must be enlisted in Universal Print to accept their cloud-based print duties. [Printer Registration Guide](https://learn.microsoft.com/en-us/universal-print/fundamentals/universal-print-printer-registration)

### SAP Pre-requisites
- **SAP NetWeaver**: Version 7.57 or above, laying the groundwork for advanced printing capabilities..
- **Print Queue Management**: Activate this feature in SAP by implementing the updates provided in [SAP Note](https://me.sap.com/notes/3348799) by applying the corrections in the note.
- **Cloud Print Manager**: Set this up in SAP by adhering to the instructions detailed in the attached PDF of [SAP Note](https://me.sap.com/notes/3420465). Once activated, establish the print queues within SAP and align your applications accordingly.
- **Authorized SAP User**: An individual empowered with the rights to generate and oversee spool requests and print queues, ensuring a smooth and secure printing process.

## 🏰 Architecture:
The architecture is designed with simplicity and efficiency in mind, consisting of:
- **SAP NetWeaver System**: Equipped with Cloud Print Manager and Print Queues, ready to handle your printing needs.
- **Azure AD Tenant**: Enhanced with Universal Print, it’s the backbone that supports your printing infrastructure.
- **Backend Print Solution**: The solution that takes care of reading print jobs from SAP and delivering them to the right printers.
- **Universal Print Devices**: These are your printers, all set up and registered in Azure, waiting to receive and print your documents.
  
![Drawing](https://github.com/devanshjainms/universal-print-for-sap-starter-pack/assets/86314060/087ad957-0531-4a38-b837-877c1bfd7112)

## 🎨 Configure backend printing solution:
The backend printing solution operates like a well-oiled machine, with two main components working in harmony:
**1. Deployment Infrastructure (Control Plane)**: Think of this as the conductor of an orchestra, overseeing the setup and ensuring that all parts of the printing process are perfectly tuned and ready for action.
**2. Backend Print Worker (Workload Plane)**: This is the musician of the group, diligently reading the music (spool requests) and playing the notes (sending print jobs) to the Universal Print devices with precision and care.
Together, these components form a seamless solution that transforms the complex task of SAP printing into a smooth and effortless performance. The dependency between the two components is illustrated in the diagram below:

### Control Plane
The control plane is primarily responsible for managing the infrastructure state of the backend print worker and the Azure resources. The control plane is deployed using setup scripts and consists of the following components:
- **Persistent Storage**: A safe place for all Terraform state files, keeping track of your infrastructure’s blueprint.
- **Container Registry**: A digital library where the backend print worker’s image is stored, ready to be deployed.

### Workload Plane
The workload plane is where the action happens. It’s all about processing those print jobs, and it’s set up using Terraform. Here’s what it includes:
- **App Service Plan & Function App**: The stage where the backend print worker performs.
- **Application Insights**: An optional but keen observer for monitoring the backend print worker’s performance.
- **Key Vault**: A secure vault for all your secrets and sensitive information.
- **Storage Account**: The warehouse for managing print jobs.
- **Logic App & Custom Connector**: The messengers that ensure print jobs are delivered to Universal Print devices.
- **API Connection**: The bridge that connects the Logic App to the Universal Print API.
Managed Identity: The backstage pass for the Function App, granting access to the Key Vault and Storage Account.

### Deploy the backend print solution
1. **Start Your Engines**: Head over to the Azure portal and fire up the Azure Cloud Shell (Powershell).
2. **Script Time**: Create a new file in the Cloud Shell editor. Copy and paste the below script (setup.ps1) into it. Make sure to tweak the parameters so they fit your SAP environment like a glove. This script is the magic wand that sets up your control plane and gets the backend print worker up and running. Once the script does its thing, you’ll have both the control plane and the backend print worker neatly deployed in your Azure subscription.

```powershell
$Env:CONTROL_PLANE_ENVIRONMENT_CODE="CTRL"
$Env:WORKLOAD_ENV_NAME="PROD"
$Env:LOCATION="eastus"
$Env:ARM_TENANT_ID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$Env:ARM_SUBSCRIPTION_ID = "yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"
$Env:SAP_VIRTUAL_NETWORK_ID = "/subscriptions/yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy/resourceGroups/SAP/providers/Microsoft.Network/virtualNetworks/SAP-VNET"
$Env:BGPRINT_SUBNET_ADDRESS_PREFIX = "0.0.0.0/24"
$Env:ENABLE_LOGGING_ON_FUNCTION_APP = "false"
$Env:HOMEDRIVE = "/home/azureuser"

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
```

3. **Connect the Dots**: Jump to the workload plane resource group in the Azure portal. Find the API connection resource and hit the “Edit API connection” button. Then, give the green light by clicking “Authorize” to link up with the Universal Print API.

4. **Function App**: Now, take a stroll to the Function App and find the validator function on the overview screen. Click on “Code + Test”. Ready to connect the SAP? Hit the “Test/Run” button. In the body section, drop in the JSON payload provided below and press “Run”. If you see a happy “200 OK” response code, you’re all set! If not, the error message will give you clues to fix any hiccups.
   
```json
{
    "sap_environment" : "PROD",
    "sap_sid": "SID",
    "sap_hostname": "http://10.186.102.6:8001",
    "sap_user": "sapuser",
    "sap_password": "sappassword",
    "sap_print_queues": [
        {
            "queue_name":"ZQ1",
            "print_share_id": "12345678-1234-1234-1234-123456789012"
        },
        {
            "queue_name":"ZQ2",
            "print_share_id": "12345678-1234-1234-1234-123456789012"
        }
    ]
}
```

5. **Test Drive**: It’s time to put the backend print worker to the test. Create a spool request in SAP and direct it to the print queue you’ve set up in the Cloud Print Manager. The backend print worker will grab the spool request and whisk it away to the Universal Print device.

Repeat step 4 and 5 for each SAP environment you want to connect to the backend print worker.


## 🚀 Ready, Set, Print!
With everything in place, you’re ready to start printing from SAP to Azure’s Universal Print. It’s a game-changer for large-scale printing needs!

### Naming convention followed for the resources deployed:
Control Plane:
- Resource Group Name: $CONTROL_PLANE_ENVIRONMENT_CODE-RG
- Storage Account Name: $CONTROL_PLANE_ENVIRONMENT_CODEtstatebgprinting
- Container Registry: sapprintacr

Workload Plane:
- Resource Group Name: $WORKLOAD_ENV_NAME-$LOCATION-RG
- App Server Plan: $WORKLOAD_ENV_NAME-$LOCATION-APPSERVICEPLAN
- Function App: $WORKLOAD_ENV_NAME-$LOCATION-FUNCTIONAPP
- Storage Account: $WORKLOAD_ENV_NAME$LOCATION$GUID
- Key Vault: $WORKLOAD_ENV_NAME$LOCATIONKV
- Logic App: $WORKLOAD_ENV_NAME$LOCATIONMSI
- Logic App Custom Connector: $WORKLOAD_ENV_NAME$LOCATION-$GUID
- API Connection: UPGRAPH-CONNECTION$GUID

