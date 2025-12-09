#data block fetching existing RG details from Azure portal
data "azurerm_resource_group" "rg-name" {
  name = "RG-01"
}
resource "azurerm_managed_disk" "data-disk" {
  name = "data-disk-01"
  resource_group_name = data.azurerm_resource_group.rg-name.name
  location = data.azurerm_resource_group.rg-name.location
  storage_account_type = "Premium_LRS"
  create_option = "Empty"
  disk_size_gb = "4"
}