#RG for VM
resource "azurerm_resource_group" "vm-rg" {
  name     = "Windows-VM-RG"
  location = "eastasia"
}
#datablock for fetching vnet and subnet details 
data "azurerm_resource_group" "rg-name" {
  name = "vNet-RG"
}
data "azurerm_virtual_network" "vNet" {
  name                = "vNet-test-01"
  resource_group_name = data.azurerm_resource_group.rg-name.name
}
data "azurerm_subnet" "subnet" {
  name                 = "subnet-A"
  resource_group_name  = data.azurerm_resource_group.rg-name.name
  virtual_network_name = data.azurerm_virtual_network.vNet.name
}
#Public IP
resource "azurerm_public_ip" "public-ip" {
  name = "windows-pip"
  resource_group_name = azurerm_resource_group.vm-rg.name
  location = azurerm_resource_group.vm-rg.location
  allocation_method = "Static"
  sku = "Standard"
}
# NIC Card for VM
resource "azurerm_network_interface" "vm-nic" {
  name                = "Windows-VM-NIC-01"
  resource_group_name = azurerm_resource_group.vm-rg.name
  location            = azurerm_resource_group.vm-rg.location
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}
# Network Security Group 
resource "azurerm_network_security_group" "nsg" {
  name = "VM-NSG"
  resource_group_name = azurerm_resource_group.vm-rg.name
  location = azurerm_resource_group.vm-rg.location
}
resource "azurerm_network_security_rule" "nsg-rule" {
  name = "Allow-RDP"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3389"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.vm-rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
#VM Code block
resource "azurerm_windows_virtual_machine" "Windows-vm" {
  name                  = "Windows-VM"
  resource_group_name   = azurerm_resource_group.vm-rg.name
  location              = azurerm_resource_group.vm-rg.location
  network_interface_ids = [azurerm_network_interface.vm-nic.id]
  admin_username        = "vmadmin"
  admin_password        = "Welcome@12345"
  size                  = "Standard_D2s_v3"
  os_disk {
    name                 = "Windows-VM-OSDisk-01"
    storage_account_type = "Premium_LRS"
    caching              = "None"
  }
  source_image_reference {
    offer     = "WindowsServer"
    publisher = "MicrosoftWindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}
# Associate NSG with NIC card
resource "azurerm_network_interface_security_group_association" "nsg-associate" {
  network_interface_id = azurerm_network_interface.vm-nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}