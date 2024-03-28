terraform {
    required_version = ">=0.12"

    required_providers {
        azurerm = {
            source  = "hashicorp/azurerm"
            version = "<3.96"
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

provider "azurerm" {
    features {}
}
