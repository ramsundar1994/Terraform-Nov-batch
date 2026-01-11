#Terraform function lowercase string ( )
resource "azurerm_resource_group" "rg-test" {
  name = lower(var.rg-name)
  location = "westus"
}
# terraform function format function
resource "azurerm_resource_group" "rg-fmt" {
 name = format("finapp-%s-%s", var.rg2,"rg")
 location = "West US"
}
#terraform replace() function 
#replace(string, substring, replacement)
resource "azurerm_resource_group" "rg-rpl" {
  name = lower(replace(var.rg-rpl," ","-"))
  location = "westus"
}
#Example 2 : 
resource "azurerm_storage_account" "stg" {
  name =  replace(lower(var.stg),"storage","stg")
  resource_group_name = azurerm_resource_group.rg-rpl.name
  location =  azurerm_resource_group.rg-rpl.location
  account_replication_type =  "LRS"
  account_tier = "Standard"
}