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
    ignore_changes = [tags["owner"]]
  }
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.20.30.0/27"]
}

resource "azurerm_subnet" "db" {
  name                 = "db"
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = ["10.20.30.32/27"]
}