#Example 1:
# Inline variables
variable "rg" {
  type = string
  default = "Terraform-RG" # very least way to pass variable value
  description = "This variable for RG Creation"
}
variable "location" {
  type = string
  default = "eastasia"
  description = "This variable for RG Location"
}
#resource group using inline variable
resource "azurerm_resource_group" "rg-name" {
  name = var.rg
  location = var.location
}
#Example 2 : External variables 
resource "azurerm_resource_group" "rg-external" {
  name = var.resource-group
  location = var.location-external
}
#Example 3 : External variables using tfvars file 
resource "azurerm_resource_group" "rg-tf" {
  name = var.RG-01
  location = var.location-tf
}