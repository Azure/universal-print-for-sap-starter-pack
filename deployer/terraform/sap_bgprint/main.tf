# Import the existing resource group
resource "azurerm_resource_group" "rg" {
    name                        = format("%s-%s-RG", upper(var.environment), upper(var.location))
    location                    = var.location
    tags                        = var.resource_group_tags
}

# create msi for the function app to access the key vault and storage account
resource "azurerm_user_assigned_identity" "msi" {
    name                        = format("%s%s%s", lower(var.environment), lower(var.location), lower("msi"))
    location                    = azurerm_resource_group.rg.location 
    resource_group_name         = azurerm_resource_group.rg.name
}

#assign roles to the msi to access the key vault and storage account
resource "azurerm_role_assignment" "keyvault" {
    scope                   = azurerm_key_vault.kv.id
    principal_id            = azurerm_user_assigned_identity.msi.principal_id
    role_definition_name    = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "queue" {
    scope                   = azurerm_storage_account.storage_account.id
    principal_id            = azurerm_user_assigned_identity.msi.principal_id
    role_definition_name    = "Storage Queue Data Contributor"
}

resource "azurerm_role_assignment" "blob" {
    scope                   = azurerm_storage_account.storage_account.id
    principal_id            = azurerm_user_assigned_identity.msi.principal_id
    role_definition_name    = "Storage Blob Data Contributor"
}

resource "azurerm_role_assignment" "table" {
    scope                   = azurerm_storage_account.storage_account.id
    principal_id            = azurerm_user_assigned_identity.msi.principal_id
    role_definition_name    = "Storage Table Data Contributor"
}

resource "azurerm_role_assignment" "acr" {
    scope                   = "/subscriptions/${var.subscription_id}/resourceGroups/${var.control_plane_rg}"
    principal_id            = azurerm_user_assigned_identity.msi.principal_id
    role_definition_name    = "AcrPull"
}

#create a subnet in the virtual network
resource "azurerm_subnet" "subnet" {
    name                        = format("bgprint-subnet")
    resource_group_name         = split("/", var.virtual_network_id)[4]
    virtual_network_name        = split("/", var.virtual_network_id)[8]
    delegation {
        name                    = "delegation"
        service_delegation {
            name                = "Microsoft.Web/serverFarms"
        }
    }
    address_prefixes            = [var.subnet_address_prefixes]
    service_endpoints           = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Web"] 
}

# Import the existing key vault
resource "azurerm_key_vault" "kv" {
    name                        = format("%s%s%s", lower(var.environment), lower(var.location), lower("kv"))
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = azurerm_resource_group.rg.location
    enabled_for_disk_encryption = true
    purge_protection_enabled    = false
    tenant_id                   = azurerm_user_assigned_identity.msi.tenant_id
    sku_name                    = "standard"
    access_policy {
        tenant_id               = azurerm_user_assigned_identity.msi.tenant_id
        object_id               = azurerm_user_assigned_identity.msi.principal_id
        secret_permissions      = [
            "Get",
            "List",
            "Set",
            "Delete",
            "Purge"
        ]
    }
    public_network_access_enabled = true
}

# Azure AD Application Registration for the custom connector
resource "azuread_application_registration" "app" {
    display_name                = format("%s%s%s", upper(var.environment), "-BGPRINT-APP-", upper(random_string.random.result))
}

resource "azuread_application_api_access" "app_access" {
    application_id              = azuread_application_registration.app.id
    api_client_id               = "00000003-0000-0000-c000-000000000000"
    scope_ids                   = [
        "ed11134d-2f3f-440d-a2e1-411efada2502",
        "5fa075e9-b951-4165-947b-c63396ff0a37",
        "21f0d9c0-9f13-48b3-94e0-b6b231c7d320"
    ]
}

resource "azuread_application_redirect_uris" "redirect_uri" {
    application_id = azuread_application_registration.app.id
    type = "Web"
    redirect_uris = [
        jsondecode(azapi_resource.custom_connector.output).properties.connectionParameters.token.oAuthSettings.redirectUrl,
        "https://global.consent.azure-apim.net/redirect"
    ]
}

resource "azuread_application_password" "password" {
    application_id = azuread_application_registration.app.id
}
