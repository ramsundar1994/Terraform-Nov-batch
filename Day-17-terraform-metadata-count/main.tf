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
#Unique resources
# Looping we Count Meta Data
resource "azurerm_network_interface" "Nic" {
  count = 2  # 0,1 
  name = "vm-nic${count.index}"
  resource_group_name = azurerm_resource_group.rg-01.name
  location = azurerm_resource_group.rg-01.location
  ip_configuration {
    name = "internal"
    subnet_id = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip[count.index].id
  }

}
resource "azurerm_public_ip" "pip" {
  count = 2
  name =  "PIP${count.index}"
  location = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  allocation_method = "Dynamic"
}
resource "azurerm_windows_virtual_machine" "vms" {
  count = 2
  name = "azurevm-vm-${count.index}"    #count VM=0 = NIC =0 
  location = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  size = "Standard_D2s_v3"
  network_interface_ids = [
    azurerm_network_interface.Nic[count.index].id
  ]  #count = 0, 1
  admin_username = "vmadmin"
  admin_password = "Welcome@12345"
  os_disk {
    name = "OS-DISK-${count.index}"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
}
resource "null_resource" "IP" {
  count = 2
  provisioner "local-exec" {
    command = "echo VM Created with public IP ${azurerm_public_ip.pip[count.index].ip_address} >> vm-info.txt"
  }
}