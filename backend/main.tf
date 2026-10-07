locals {
  resource_group_name  = "${var.prefix}-terraform-state-rg"
  storage_account_name = "${var.prefix}tfstate"
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
}

resource "azurerm_storage_container" "sc" {
  name                  = "terraform"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}