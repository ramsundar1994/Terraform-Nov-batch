#Multiple NSG Rules Example 1
resource "azurerm_resource_group" "rg-name" {
  name = "dynamic-rg"
  location = "westus"
}

resource "azurerm_network_security_group" "nsg-group" {
  name = "nsg-01"
  resource_group_name = azurerm_resource_group.rg-name.name
  location = azurerm_resource_group.rg-name.location
  dynamic "security_rule" {
    for_each = var.nsg-rule
    content {
      name = security_rule.value.name
      priority = security_rule.value.priority
      direction = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }    
}

#Create Multiple subnets in vNet 
resource "azurerm_virtual_network" "vNet-01" {
  name = "vNet-01"
  resource_group_name = azurerm_resource_group.rg-name.name
  location = azurerm_resource_group.rg-name.location
  address_space = [ "10.0.0.0/22" ] #1024IP's
  dynamic "subnet" {
    for_each = var.subnets
    content {
      name = subnet.value.name
      address_prefix = subnet.value.address_prefix
    }
  }
}
#Create Multiple NIC's
resource "azurerm_network_interface" "nics" {
  for_each =  {
    for s in azurerm_virtual_network.vNet-01.subnet : s.name => s
  }
  name = "${each.key}-nic-01"
  location = azurerm_resource_group.rg-name.location
  resource_group_name = azurerm_resource_group.rg-name.name
  ip_configuration {
    name = "${each.key}-ipconfig"
    subnet_id = each.value.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  for_each = azurerm_network_interface.nics
  network_interface_id = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg-group.id
}
resource "azurerm_windows_virtual_machine" "vm" {
  name = "windows-01"
  resource_group_name = azurerm_resource_group.rg-name.name
  location = azurerm_resource_group.rg-name.location
  size = "Standard_Ds1_v2"
  admin_username = "vmadmin"
  admin_password = "Welcome@12345"
  network_interface_ids = [ for nic in azurerm_network_interface.nics : nic.id ]
  os_disk {
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