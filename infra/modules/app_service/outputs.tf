output "front_default_hostname" {
	value = azurerm_linux_web_app.front.default_hostname
}

output "api_default_hostname" {
	value = azurerm_linux_web_app.api.default_hostname
}
