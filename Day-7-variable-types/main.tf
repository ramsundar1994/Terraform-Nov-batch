resource "azurerm_resource_group" "rg-string" {
  name = var.rg-name
  location = var.location
}
#Example1 of List string 
resource "azurerm_resource_group" "rg-list" {
  for_each = toset(var.rg-names)
  name = each.value
  location = var.location
}
# Example 2 list string
resource "azurerm_resource_group" "location-list" {
  count = length(var.location-list)
  name = "${var.location-list[count.index]}-RG"
  location = var.location-list[count.index]
}
# Variable type (map)
#Example 1:
resource "azurerm_resource_group" "rg-map" {
  for_each = var.resource-groups
  name = each.key
  location = each.value
}