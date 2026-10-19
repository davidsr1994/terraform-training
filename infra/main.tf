data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "key_vault" {
  name = "drodrigues-terraform-state-rg"
}

import {
  to = azurerm_key_vault.kv
  id = "/subscriptions/49175c01-02a7-44bb-b379-2c06f4aae5b4/resourceGroups/drodrigues-terraform-state-rg/providers/Microsoft.KeyVault/vaults/drodrigues-kv"
}

moved {
  from = azurerm_resource_group.network
  to   = module.network.azurerm_resource_group.network
}

moved {
  from = azurerm_virtual_network.network
  to   = module.network.azurerm_virtual_network.network
}

moved {
  from = azurerm_subnet.app
  to   = module.network.azurerm_subnet.app
}

moved {
  from = azurerm_subnet.db
  to   = module.network.azurerm_subnet.db
}

moved {
  from = azurerm_resource_group.application
  to   = module.app_service.azurerm_resource_group.application
}

moved {
  from = azurerm_service_plan.application
  to   = module.app_service.azurerm_service_plan.application
}

moved {
  from = azurerm_linux_web_app.front
  to   = module.app_service.azurerm_linux_web_app.front
}

moved {
  from = azurerm_linux_web_app.api
  to   = module.app_service.azurerm_linux_web_app.api
}

moved {
  from = azurerm_resource_group.database
  to   = module.psql.azurerm_resource_group.database
}

moved {
  from = azurerm_postgresql_flexible_server.database
  to   = module.psql.azurerm_postgresql_flexible_server.database
}

resource "azurerm_key_vault" "kv" {
  name                       = "${var.prefix}-kv"
  location                   = "spaincentral"
  resource_group_name        = data.azurerm_resource_group.key_vault.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  rbac_authorization_enabled = true

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_key_vault_secret" "kv_secret" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_officer]
}

module "network" {
  source   = "./modules/network"
  prefix   = var.prefix
  location = var.location
  tags     = local.common_tags
}

module "app_service" {
  source    = "./modules/app_service"
  prefix    = var.prefix
  location  = var.location
  subnet_id = module.network.app_subnet_id
  tags      = local.common_tags
}

module "psql" {
  source      = "./modules/psql"
  prefix      = var.prefix
  location    = var.location
  db_password = var.db_password
  tags        = local.common_tags
}

resource "azurerm_role_assignment" "kv_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

