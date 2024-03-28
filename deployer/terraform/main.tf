
terraform {
    backend "azurerm" {}
}

module "sap_bgprint" {
    source = "./sap_bgprint"

    client_id                      = var.client_id
    client_secret                  = var.client_secret
    subscription_id                = var.subscription_id
    tenant_id                      = var.tenant_id
    resource_group_name            = var.resource_group_name
    location                       = var.location
    virtual_network_id             = var.virtual_network_id
    subnet_address_prefixes        = var.subnet_address_prefixes
    environment                    = var.environment
    object_id                      = var.object_id
    resource_group_tags            = var.resource_group_tags
    container_registry_url         = var.container_registry_url
    container_image_name           = var.container_image_name
    control_plane_rg               = var.control_plane_rg
    enable_logging_on_function_app = var.enable_logging_on_function_app
}
