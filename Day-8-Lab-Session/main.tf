resource "azurerm_resource_group" "vm-rg" {
  name     = var.resource_group.resource_group_name
  location = var.resource_group.location
  tags = var.tags
}
resource "azurerm_virtual_network" "vNet-name" {
  name                = var.vnet.name
  resource_group_name = azurerm_resource_group.vm-rg.name
  location            = azurerm_resource_group.vm-rg.location
  address_space       = [var.vnet.address_space[0]]
  tags = var.tags
}
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet.name
  resource_group_name  = azurerm_resource_group.vm-rg.name
  virtual_network_name = azurerm_virtual_network.vNet-name.name
  address_prefixes     = [var.subnet.address_prefixes[0]]
}
resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.nic)
  name                = each.value
  resource_group_name = azurerm_resource_group.vm-rg.name
  location            = azurerm_resource_group.vm-rg.location
  ip_configuration {
    name                          = "ipconfig-${each.value}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
  }
  tags = var.tags
}
resource "azurerm_windows_virtual_machine" "windows-vm" {
  name                  = var.vm.name
  resource_group_name   = azurerm_resource_group.vm-rg.name
  location              = azurerm_resource_group.vm-rg.location
  size                  = var.vm.size
  admin_username        = var.vm.admin_username
  admin_password        = var.vm.admin_password
  network_interface_ids = [for nic in azurerm_network_interface.nic : nic.id]
  os_disk {
    storage_account_type = var.osdisk
    caching              = "ReadWrite"
  }
  source_image_reference {
    sku       = var.source_image.sku
    offer     = var.source_image.offer
    version   = var.source_image.version
    publisher = var.source_image.publisher
  }
  tags = var.tags
}