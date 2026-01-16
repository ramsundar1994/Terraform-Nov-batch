#Example 1 for Collection Function using (List+length+count)

resource "azurerm_resource_group" "rg-test" {
  count    = length(var.resource_group) # ["0", "1" ,"2"]
  name     = var.resource_group[count.index]
  location = "westus"
}
resource "azurerm_virtual_network" "vnet-dev" {
  name = "vnet-${var.environment}"
  resource_group_name = azurerm_resource_group.rg-test[0].name
  location = azurerm_resource_group.rg-test[0].location
  address_space = [ "10.0.0.0/24" ]
}
resource "azurerm_subnet" "subnet" {
  name = "subnet-${var.environment}"
  resource_group_name = azurerm_resource_group.rg-test[0].name
  virtual_network_name = azurerm_virtual_network.vnet-dev.name
  address_prefixes = [ "10.0.0.0/28" ]
}
resource "azurerm_network_interface" "nic" {
  name = "vm-nic-${var.environment}"
  resource_group_name = azurerm_resource_group.rg-test[0].name
  location = azurerm_resource_group.rg-test[0].location
  ip_configuration {
    name = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet.id
  }
}
#Example 2 : Collection Function using  (Map+lookup) function
resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                  = "vm-linux-${var.environment}"
  resource_group_name   = azurerm_resource_group.rg-test[0].name
  location              = azurerm_resource_group.rg-test[0].location
  size                  = lookup(var.vm_size, var.environment, "Standard_B2s")
  admin_password        = "Welcome@12345"
  admin_username        = "vmadmin"
  disable_password_authentication = false 
  network_interface_ids = [ azurerm_network_interface.nic.id]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"

  }
}