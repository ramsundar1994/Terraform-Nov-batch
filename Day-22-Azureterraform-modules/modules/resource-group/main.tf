resource "azurerm_resource_group" "rg-01" {
  name = var.rg
  location =  var.location
}