resource "azurerm_resource_group" "application" {
	name     = "drodrigues-app-rg"
	location = var.location

	tags = merge(var.tags, {
		type = "application"
	})

	lifecycle {
		ignore_changes = [tags]
	}
}

resource "azurerm_service_plan" "application" {
	name                = "${var.prefix}-app-plan"
	location            = azurerm_resource_group.application.location
	resource_group_name = azurerm_resource_group.application.name
	os_type             = "Linux"
	sku_name            = "B1"

	tags = var.tags

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
	virtual_network_subnet_id = var.subnet_id

	site_config {
		application_stack {
			dotnet_version = "8.0"
		}
	}

	tags = var.tags

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
	virtual_network_subnet_id = var.subnet_id

	site_config {
		application_stack {
			dotnet_version = "8.0"
		}
	}

	tags = var.tags

	lifecycle {
		ignore_changes = [tags]
	}
}
