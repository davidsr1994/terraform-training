data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "key_vault" {
  name = "drodrigues-terraform-state-rg"
}

import {
  to = azurerm_key_vault.kv
  id = "/subscriptions/49175c01-02a7-44bb-b379-2c06f4aae5b4/resourceGroups/drodrigues-terraform-state-rg/providers/Microsoft.KeyVault/vaults/drodrigues-kv"
}

resource "azurerm_key_vault" "kv" {
  name                      = "${var.prefix}-kv"
  location                  = "spaincentral"
  resource_group_name       = data.azurerm_resource_group.key_vault.name
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  sku_name                  = "standard"
  rbac_authorization_enabled = true
}

resource "azurerm_key_vault_secret" "kv_secret" {
  name         = "db-password"
  value        = var.db_password
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_officer]
}

resource "azurerm_role_assignment" "kv_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_resource_group" "network" {
  name     = "drodrigues-net-rg"
  location = var.location

  tags = merge(local.common_tags, {
    type = "network"
  })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_resource_group" "application" {
  name     = "drodrigues-app-rg"
  location = var.location

  tags = merge(local.common_tags, {
    type = "application"
  })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_resource_group" "database" {
  name     = "drodrigues-db-rg"
  location = var.location

  tags = merge(local.common_tags, {
    type = "database"
  })

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = ["10.20.30.0/24"]

  tags = {
    for key, value in local.common_tags : key => value
    if key != "owner"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.20.30.0/27"]

  delegation {
    name = "app-service"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "db" {
  name                 = "db"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.20.30.32/27"]
}

resource "azurerm_service_plan" "application" {
  name                = "${var.prefix}-app-plan"
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name
  os_type             = "Linux"
  sku_name            = "B1"

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_linux_web_app" "front" {
  name                = "${var.prefix}-front-app"
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name
  service_plan_id     = azurerm_service_plan.application.id

  https_only                = true
  virtual_network_subnet_id = azurerm_subnet.app.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_linux_web_app" "api" {
  name                = "${var.prefix}-api-app"
  location            = azurerm_resource_group.application.location
  resource_group_name = azurerm_resource_group.application.name
  service_plan_id     = azurerm_service_plan.application.id

  https_only                = true
  virtual_network_subnet_id = azurerm_subnet.app.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_postgresql_flexible_server" "database" {
  name                = "${var.prefix}-psql"
  resource_group_name = azurerm_resource_group.database.name
  location            = azurerm_resource_group.database.location

  administrator_login    = "pgadmin"
  administrator_password = var.db_password
  sku_name               = "B_Standard_B1ms"
  version                = "16"
  storage_mb             = 32768
  zone                   = "1"

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}