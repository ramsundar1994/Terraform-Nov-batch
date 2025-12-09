#Resource group
resource "azurerm_resource_group" "rg-name2" {
  name = "terraform-rg2"
  location = "eastus"
  tags = {
    "environment" = "prod"
    "owner" = "xyz"
  }
}
resource "azurerm_resource_group" "rg-name3" {
  name = "terraform-rg3"
  location = "eastus"
  tags = {
    "environment" = "prod"
    "owner" = "xyz"
  }
}
resource "azurerm_resource_group" "rg-name" {
  name = "terraform-rg"
  location = "eastus"
  tags = {
    "env" ="prod"
    "owner" ="xyz"
  }
}