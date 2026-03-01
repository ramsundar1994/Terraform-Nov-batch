# config data block
data "azurerm_client_config" "current" {
  #tenant ID
  #client ID
  #object ID
  #subscription id
}
#Resource group
resource "azurerm_resource_group" "rg-01" {
  name     = var.resource_group
  location = var.location
}
#vNet Creation
resource "azurerm_virtual_network" "vNet" {
  name                = var.vnet
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  address_space       = [var.address_space]
}
#subnet creation
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg-01.name
  virtual_network_name = azurerm_virtual_network.vNet.name
  address_prefixes     = [var.subnet]
}
#public IP 
resource "azurerm_public_ip" "public-ip" {
  name                = "vm-pip"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
#NIC Card for VM
resource "azurerm_network_interface" "vm-nic" {
  depends_on          = [azurerm_virtual_network.vNet]
  name                = "${var.vm_name}-nic"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.5"
    public_ip_address_id          = azurerm_public_ip.public-ip.id
    subnet_id = azurerm_subnet.subnet.id
  }
}
# Password string creations
resource "random_password" "psd" {
  length           = 20
  special          = true
  override_special = "!@#$%"
}
#Key vault creation   #RBAC 
resource "azurerm_key_vault" "kv" {
  name                      = var.keyvault-name
  resource_group_name       = azurerm_resource_group.rg-01.name
  location                  = azurerm_resource_group.rg-01.location
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
}
#keyvault secret creation
resource "azurerm_key_vault_secret" "kv-secret" {
  name         = "${var.vm_name}-secret"
  value        = random_password.psd.result
  key_vault_id = azurerm_key_vault.kv.id
}
# keyvault role assignment 
resource "azurerm_role_assignment" "rbac-role" {
  scope                = azurerm_key_vault.kv.id
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets User"
}
resource "azurerm_windows_virtual_machine" "windows-vm" {
  depends_on          = [azurerm_network_interface.vm-nic]
  name                = var.vm_name
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  size                = "Standard_D2s_v3"
  network_interface_ids = [
    azurerm_network_interface.vm-nic.id
  ]
  os_disk {
    name                 = "${var.vm_name}-osdisk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  admin_username = var.admin_username
  admin_password = azurerm_key_vault_secret.kv-secret.value
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
  # Local Provisioner for export Public IP
  provisioner "local-exec" {
    command = "echo VM Created with public IP ${azurerm_public_ip.public-ip.ip_address} >> vm-info.txt" 
  }
}
#NSG
resource "azurerm_network_security_group" "nsg" {
  name = "${var.vm_name}-nsg"
  resource_group_name = azurerm_resource_group.rg-01.name
  location = azurerm_resource_group.rg-01.location
}
resource "azurerm_network_security_rule" "nsg-rule" {
 name = "Allow-RDP"
  priority = 110
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3389"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg-01.name
  network_security_group_name = azurerm_network_security_group.nsg.name

}
resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}