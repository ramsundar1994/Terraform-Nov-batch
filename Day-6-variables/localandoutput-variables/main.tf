# inline local variables
locals {
  resource_group_name = "local-rg"
  location = "eastasia"
}

resource "azurerm_resource_group" "rg-name" {
  name = local.resource_group_name
  location = local.location
}

#Example 2: External local variables

resource "azurerm_resource_group" "external-rg" {
  name = local.new-rg
  location = local.location_new
}

#inline output variables
output "output-rg1" {
  value = azurerm_resource_group.rg-name.name
}