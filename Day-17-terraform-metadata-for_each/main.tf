#common or shared resources
resource "azurerm_resource_group" "rg-01" {
  name = "Testing-RG"
  location = "eastus"
}
resource "azurerm_virtual_network" "vnet" {
  name = "vnet-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location = azurerm_resource_group.rg-01.location
  address_space = [ "10.0.0.0/24" ]
}
resource "azurerm_subnet" "subnet" {
  name = "subnet-01"
  address_prefixes = [ "10.0.0.0/28" ]
  resource_group_name = azurerm_resource_group.rg-01.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}
# Metadata map for VM details
locals {
  vm_metadata = {
    "app1" = {
      size = "Standard_D2s_v3"
      username = "azureadmin"
    }
    "app2" = {
      size = "Standard_B1ms"
      username = "azureadmin"
    }
  }
}
#mutiple Nics
resource "azurerm_network_interface" "nic" {
  for_each = local.vm_metadata
  name = "NIC-${each.key}"
  resource_group_name = azurerm_resource_group.rg-01.name
  location = azurerm_resource_group.rg-01.location
  ip_configuration {
    name = "Ipconfig-${each.key}"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "lvm" {
  for_each = local.vm_metadata
  name = "Linux-${each.key}"
  location = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  size = each.value.size
  admin_username = each.value.username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]
  os_disk {
    name = "os-disk-windows-${each.key}"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  disable_password_authentication = false
  admin_password = "Welcome@123"
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

}