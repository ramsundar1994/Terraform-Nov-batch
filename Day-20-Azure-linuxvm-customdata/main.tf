#Step 1 :
resource "azurerm_resource_group" "rg-01" {
  name     = "linux-rg"
  location = "eastus"
}
#Step 2 : vnet creation
resource "azurerm_virtual_network" "vnet-01" {
  name                = "vnet-01"
  location            = azurerm_resource_group.rg-01.location
  resource_group_name = azurerm_resource_group.rg-01.name
  address_space       = ["10.0.0.0/24"]
}
#Step 3: Subnet Creation
resource "azurerm_subnet" "subnets" {
  name                 = "subnet-A"
  resource_group_name  = azurerm_resource_group.rg-01.name
  virtual_network_name = azurerm_virtual_network.vnet-01.name
  address_prefixes     = ["10.0.0.0/28"]
}
#Step 4 : Public IP
resource "azurerm_public_ip" "pip" {
  name                = "vm-pip-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  sku                 = "Standard"
  allocation_method   = "Static"
}
# Step 5: NIC for Linux VM
resource "azurerm_network_interface" "vm-nic" {
  name                = "VM-nic-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}
#step 6: NSG creation for SSH of Linux machine
resource "azurerm_network_security_group" "nsg-01" {
  name                = "vm-nsg"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
}
resource "azurerm_network_security_rule" "nsg-rule" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg-01.name
  resource_group_name         = azurerm_resource_group.rg-01.name
}
resource "azurerm_network_security_rule" "rule2" {
  name                        = "AllowHTTP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg-01.name
  network_security_group_name = azurerm_network_security_group.nsg-01.name
}
# Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg-associate" {
  network_interface_id      = azurerm_network_interface.vm-nic.id
  network_security_group_id = azurerm_network_security_group.nsg-01.id
}
#step 7 : Azure Linux VM Creation
resource "azurerm_linux_virtual_machine" "linux-vm" {
  name                = "Linux-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  size                = "Standard_D2s_v3"
  admin_username      = "vmadmin"
  admin_password      = "Welcome@12345"
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id
  ]
  disable_password_authentication = false
  os_disk {
    name                 = "linux-vm-os-disk"
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "Canonical"
    sku       = "22_04-lts"
    version   = "latest"
  }
  # Passing Custom data to enable nginx services for web
  custom_data = base64encode(file("cloud-init.yml"))
}
output "vm-pip" {
  value = azurerm_public_ip.pip.ip_address
}