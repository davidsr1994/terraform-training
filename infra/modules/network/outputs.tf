output "app_subnet_id" {
  value = azurerm_subnet.app.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}

output "net_rg_name" {
  value = azurerm_resource_group.network.name
}
