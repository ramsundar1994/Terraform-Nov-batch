resource "azurerm_resource_group" "rg-1" {
  name     = "provisioner-rg"
  location = "eastus"
}
resource "azurerm_virtual_network" "vnet-01" {
  name                = "vm-vnet"
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location
  address_space       = ["10.0.0.0/24"]
}
resource "azurerm_subnet" "subnet-01" {
  name                 = "subnet-A"
  resource_group_name  = azurerm_resource_group.rg-1.name
  virtual_network_name = azurerm_virtual_network.vnet-01.name
  address_prefixes     = ["10.0.0.0/28"]
}
resource "azurerm_public_ip" "pip" {
  name                = "pip-vm-01"
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location
  allocation_method   = "Static"
  lifecycle {
    prevent_destroy = false
  }
  
}
resource "azurerm_network_security_group" "nsg" {
  name = "nsg-01"
  resource_group_name = azurerm_resource_group.rg-1.name
  location = azurerm_resource_group.rg-1.location
}
resource "azurerm_network_security_rule" "nsg-rule1" {
  name = "Allow-RDP"
  priority = 110
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "3389"
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg-1.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_security_rule" "nsg-rule2" {
  name = "Allow-winrm"
  priority = 100
  direction = "Inbound"
  access = "Allow"
  protocol = "Tcp"
  source_port_range = "*"
  destination_port_range = "5985"  #http #https:5986
  source_address_prefix = "*"
  destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.rg-1.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_interface_security_group_association" "nsg-association" {
  network_security_group_id = azurerm_network_security_group.nsg.id
  network_interface_id = azurerm_network_interface.nic.id
}
resource "azurerm_network_interface" "nic" {
  name                = "nic-vm-01"
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet-01.id
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_windows_virtual_machine" "windows-vm" {
  name                  = "windows-01"
  location              = azurerm_resource_group.rg-1.location
  resource_group_name   = azurerm_resource_group.rg-1.name
  size                  = "Standard_DS1_v2"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "vmadmin"
  admin_password        = "Welcome@12345"
  #custom_data = base64encode(file("enable-winrm.ps1"))
  os_disk {
    name                 = "vm-os-disk-01"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }
  #local Provisioner
  provisioner "local-exec" {
    command = "echo VM Created with public IP ${azurerm_public_ip.pip.ip_address} >> vm-info.txt"
  }
  # provisioner "file" {
  #   source = "install.ps1"
  #   destination = "C:/install.ps1"
  #   connection {
  #     type     = "winrm"
  #     host     = azurerm_windows_virtual_machine.windows-vm.public_ip_address
  #     user     = "vmadmin"
  #     password = "Welcome@12345"
  #     port     = 5985
  #     https    = false
  #     insecure = true  
  #   }
  # }
  # # provisioner "remote-exec" {
    
  # }
}
resource "azurerm_virtual_machine_extension" "winrm" {
  name                 = "enable-winrm"
  virtual_machine_id   = azurerm_windows_virtual_machine.windows-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

settings = <<SETTINGS
{
  "commandToExecute": "powershell.exe -ExecutionPolicy Unrestricted -Command \"Enable-PSRemoting -Force; winrm quickconfig -force; Set-Item -Path WSMan:\\localhost\\Service\\AllowUnencrypted -Value true; Set-Item -Path WSMan:\\localhost\\Service\\Auth\\Basic -Value true; netsh advfirewall firewall add rule name=\\\"WinRM-HTTP\\\" dir=in action=allow protocol=TCP localport=5985; Restart-Service WinRM\""
}
SETTINGS

}
resource "null_resource" "copy_script" { # 1 new resource deployment
  depends_on = [ azurerm_windows_virtual_machine.windows-vm ]
  provisioner "file" {
    source = "install.ps1"
    destination = "C:/install.ps1"
    connection {
      type     = "winrm"
      host     = azurerm_windows_virtual_machine.windows-vm.public_ip_address
      user     = "vmadmin"
      password = "Welcome@12345"
      port     = 5985
      https    = false
      insecure = true  
    }
  }
  provisioner "remote-exec" {
    inline = ["powershell.exe -ExecutionPolicy Bypass -File C:/install.ps1",
      "powershell.exe echo 'Hello from Terraform Provisioner!' >> C:/terraform-output.txt"
    ]
    connection {
      type     = "winrm"
      host     = azurerm_windows_virtual_machine.windows-vm.public_ip_address
      user     = "vmadmin"
      password = "Welcome@12345"
      port     = 5985
      https    = false
      insecure = true  
    }
  }
}

