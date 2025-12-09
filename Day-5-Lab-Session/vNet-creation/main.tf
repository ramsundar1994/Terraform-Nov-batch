resource "azurerm_resource_group" "rg-name" {
  name     = "vNet-RG"
  location = "eastasia"
}
resource "azurerm_virtual_network" "vnet-name" {
  name                = "vNet-test-01"
  resource_group_name = azurerm_resource_group.rg-name.name
  location            = azurerm_resource_group.rg-name.location
  address_space       = ["10.0.0.0/24"]
}
resource "azurerm_subnet" "subnet-name" {
  name                 = "subnet-A"
  resource_group_name  = azurerm_resource_group.rg-name.name
  virtual_network_name = azurerm_virtual_network.vnet-name.name
  address_prefixes     = ["10.0.0.0/26"]
}