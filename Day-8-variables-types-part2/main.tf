# Example 1: Resource group creation ( Object variable)
resource "azurerm_resource_group" "object-rg" {
  name     = var.resource_group.name
  location = var.resource_group.location
}
# Example 2: Resource group creation  ( Map (object)) ---> Nested Objects
resource "azurerm_resource_group" "prod-rg" {
  name     = var.resource_group_common["prod"].name
  location = var.resource_group_common["prod"].location
}
resource "azurerm_resource_group" "nonprod-rg" {
  name     = var.resource_group_common["nonprod"].name
  location = var.resource_group_common["nonprod"].location
}
# Example 3 : Storage account creation using (Nested Objects)
resource "azurerm_storage_account" "stg-account" {
  for_each                 = var.storage_account
  name                     = each.value.storage_account_name
  location                 = each.value.location
  resource_group_name      = each.value.resource_group_name
  account_replication_type = each.value.account_replication_type
  account_tier             = each.value.account_tier
}