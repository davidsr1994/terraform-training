resource "azurerm_resource_group" "database" {
	name     = "drodrigues-db-rg"
	location = var.location

	tags = merge(var.tags, {
		type = "database"
	})

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

	tags = var.tags

	lifecycle {
		ignore_changes = [tags]
	}
}
