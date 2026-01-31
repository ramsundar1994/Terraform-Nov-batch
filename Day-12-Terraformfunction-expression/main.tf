#Example 1:
locals {
  storage_type = var.environment == "prod" ? "LRS" : "GRS"
}
output "storage_type" {
  value = local.storage_type
}
#Example 2 

resource "azurerm_resource_group" "rg-01" {
  count = var.environment == "dev" ? 1 : 0
  name = "dev-rg"
  location = "westus"
}
resource "azurerm_resource_group" "rg-02" {
  count = var.environment == "prod" ? 1 : 0
  name = "prod-rg"
  location = "westus"
}