resource "azurerm_virtual_network" "vNe-01" {
  name =  var.vnet-name
  resource_group_name = var.resource_group_name
  location = var.location
  address_space = [var.address_space]
}