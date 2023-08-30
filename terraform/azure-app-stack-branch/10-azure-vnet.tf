resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-network"
  address_space       = ["10.125.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet_a" {
  name                 = "subnet_a"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.125.10.0/24"]
}

output "azure_vnet_name" {
  description = "azure vnet name"
  value = azurerm_virtual_network.vnet.name
}

output "subnet_a_name" {
  description = "subnet_a name"
  value       = azurerm_subnet.subnet_a.name
}
