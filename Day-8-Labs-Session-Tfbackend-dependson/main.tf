terraform {
  backend "azurerm" {
    resource_group_name = "RG-01"
    storage_account_name = "stg297937"
    container_name = "backend-container"
    key = "day-8-lab-session.tfstate"
  }
}
resource "azurerm_storage_account" "stg-01" {
  name                     = "stg297937"
  location                 = "centralus"
  resource_group_name      = "RG-01"
  account_replication_type = "LRS"
  account_tier             = "Standard"
}
resource "azurerm_storage_container" "name" {
  depends_on            = [azurerm_storage_account.stg-01] ##Explicit dependency 
  name                  = "backend-container"
  storage_account_name  = azurerm_storage_account.stg-01.name
  container_access_type = "private"
}
resource "azurerm_resource_group" "rg-test" {
  name = "testing-rg"
  location = "eastasia"
}