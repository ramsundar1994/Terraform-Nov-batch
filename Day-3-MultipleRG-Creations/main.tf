resource "azurerm_resource_group" "rg-01" {
  name     = "Terraform-RG-test"
  location = "westus"
}
resource "azurerm_resource_group" "rg-02" {
  name     = "Terraform-RG-test2"
  location = "eastasia"
}

resource "azurerm_resource_group" "rg-03" {
  name     = "terraform-rg-test3"
  location = "southeastasia"
}