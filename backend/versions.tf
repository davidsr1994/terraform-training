terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "drodrigues-terraform-state-rg"
    storage_account_name = "drodriguestfstate"
    container_name       = "terraform"
    key                  = "drodrigues.tfstate"
  }
}

provider "azurerm" {
  subscription_id = "49175c01-02a7-44bb-b379-2c06f4aae5b4"
  features {}
}