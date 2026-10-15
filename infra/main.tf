data "azurerm_client_config" "current" {}

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