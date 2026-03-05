#resource group
resource "azurerm_resource_group" "rg-01" {
  name     = "load-balancer-rg"
  location = "eastus"
}
#vNet creations
resource "azurerm_virtual_network" "vnet1" {
  name                = "lb-vnet-001"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  address_space       = ["10.0.0.0/24"]
}
#subnet creation
resource "azurerm_subnet" "subnet" {
  name                 = "lb-subnet"
  resource_group_name  = azurerm_resource_group.rg-01.name
  address_prefixes     = ["10.0.0.0/28"]
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

# Load Balancer creation
#step 1 : ( public IP for LB)
resource "azurerm_public_ip" "lb-pip" {
  name                = "lb-pip-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  sku                 = "Standard"
  allocation_method   = "Static"
}
#step 2: 
resource "azurerm_lb" "lb1" {
  name                = "public-load-balancer"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name                 = "frontend-pip"
    public_ip_address_id = azurerm_public_ip.lb-pip.id
  }
}
#step 3: backend pool
resource "azurerm_lb_backend_address_pool" "backend" {
  name            = "backend-pool-001"
  loadbalancer_id = azurerm_lb.lb1.id
}
#step 4: Health Probe
resource "azurerm_lb_probe" "health-probe" {
  name            = "health-probe-01"
  loadbalancer_id = azurerm_lb.lb1.id
  port            = 80
  protocol        = "Http"
  request_path = "/"
}
#step 5: load balancer rule
resource "azurerm_lb_rule" "lb-rule" {
  name                           = "lb-rule-01"
  frontend_ip_configuration_name = "frontend-pip"
  loadbalancer_id                = azurerm_lb.lb1.id
  frontend_port                  = 80
  backend_port                   = 80
  protocol                       = "Tcp"
  probe_id                       = azurerm_lb_probe.health-probe.id
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend.id]
}
#step 6: Create VM NIC to add backendpool
resource "azurerm_network_interface" "vm-nic" {
  name                = "vm-nic"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
  }
}
#step 7 : Associate NIC to Backendpool
resource "azurerm_network_interface_backend_address_pool_association" "nic-lb-associate" {
  network_interface_id    = azurerm_network_interface.vm-nic.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.backend.id
  ip_configuration_name   = "ipconfig1"
}
#step 8: Network Security Group for VM to Allow http rule
resource "azurerm_network_security_group" "nsg" {
  name                = "vm-nsg-01"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
}
resource "azurerm_network_security_rule" "nsg-rule" {
  name                        = "Allow-http"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg-01.name
}
resource "azurerm_network_security_rule" "nsg-rule-rdp" {
  name                        = "Allow-rdp"
  priority                    = 112
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg-01.name
}
#step 9 : associate NSG to Subnet or NIC
resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  network_interface_id      = azurerm_network_interface.vm-nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
#Step 10 : Create windows virtual machine and enable IIS 
resource "azurerm_windows_virtual_machine" "iis-vm" {
  name                = "webserver-vm"
  resource_group_name = azurerm_resource_group.rg-01.name
  location            = azurerm_resource_group.rg-01.location
  size                = "Standard_D2s_v3"
  os_disk {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
  }
  admin_username        = "vmadmin"
  admin_password        = "Welcome@12345"
  network_interface_ids = [azurerm_network_interface.vm-nic.id]
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter"
    version   = "latest"
  }
}
#step 11 : VM Extension for IIS (internet information services)
resource "azurerm_virtual_machine_extension" "vm-ext" {
  depends_on = [ azurerm_windows_virtual_machine.iis-vm ]
  name                 = "install-iis"
  virtual_machine_id   = azurerm_windows_virtual_machine.iis-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  settings             = <<SETTINGS
{
  "commandToExecute": "powershell Install-WindowsFeature -name Web-Server -IncludeManagementTools"
}
SETTINGS
}
#step 12:  allow RDP for vm by creating NAT Rule in LB
resource "azurerm_lb_nat_rule" "nat-rule" {
  name = "nat-rdp-rule"
  resource_group_name = azurerm_resource_group.rg-01.name
  loadbalancer_id = azurerm_lb.lb1.id
  protocol = "Tcp"
  frontend_port = 3389
  backend_port = 3389
  frontend_ip_configuration_name = "frontend-pip"
}
#step 13: NAT Rule associate with NIC
resource "azurerm_network_interface_nat_rule_association" "nat-rule-asso" {
  network_interface_id = azurerm_network_interface.vm-nic.id
  nat_rule_id = azurerm_lb_nat_rule.nat-rule.id
  ip_configuration_name = "ipconfig1"
}