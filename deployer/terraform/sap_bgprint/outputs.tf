output "resource_group_id" {
    description = "The id of the resource group"
    value       = azurerm_resource_group.rg.id
}

output "key_vault_id" {
    description = "The id of the key vault"
    value       = azurerm_key_vault.kv.id
}

output "custom_connector" {
    description = "The id of the custom connector"
    value       = azapi_resource.custom_connector
    sensitive   = true
}