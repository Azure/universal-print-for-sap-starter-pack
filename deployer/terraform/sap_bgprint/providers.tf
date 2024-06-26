terraform {
    required_version = ">=0.12"

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "~>3.0"
        }
        azapi = {
            source  = "Azure/azapi"
        }

        azuread = {
            source  = "hashicorp/azuread"
            version = "2.47.0"
        }
    }
}