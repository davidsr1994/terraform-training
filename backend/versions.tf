terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "david-terraform-state-rg"
    storage_account_name = "davidtfstate"
    container_name       = "terraform"
    key                  = "david.tfstate"
    use_azuread_auth     = true # authenticate to the state with Azure AD, not an access key
  }
}

provider "azurerm" {
  subscription_id = "c0fc8d1b-6806-4cbc-9a57-8f36f1e6331d"
  features {}
}