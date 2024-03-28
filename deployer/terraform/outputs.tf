# Define the output values for the project

output "resource_group_id" {
    description = "The id of the resource group"
    value       = module.sap_bgprint.resource_group_id
}

output "key_vault_id" {
    description = "The id of the key vault"
    value       = module.sap_bgprint.key_vault_id
}

output "custom_connector" {
    description = "The id of the custom connector"
    value       = module.sap_bgprint.custom_connector
    sensitive   = true
}