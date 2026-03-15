  # NIC Creations
  resource "azurerm_network_interface" "vm-nic" {
    count = var.nic_count
    name = "${var.vmname}-nic-${count.index}"  #windows-vm-nic-0 windowsvm-nic-1
    resource_group_name = var.resource_group_name
    location = var.location
    ip_configuration {
      name = "ipconfig"
      subnet_id = var.subnet_id
      private_ip_address_allocation = "Dynamic"
    }
  }
  # Windows virtual Machine Creation
  resource "azurerm_windows_virtual_machine" "windows-01" {
    name = var.vmname
    resource_group_name = var.resource_group_name
    location = var.location
    size = var.vmsize
    admin_username = var.admin_username
    admin_password = var.admin_password
    os_disk {
      caching = "ReadOnly"
      storage_account_type = "Standard_LRS"
    }
    network_interface_ids = azurerm_network_interface.vm-nic[*].id
    source_image_reference {
      publisher = "MicrosoftWindowsServer"
      offer     = "WindowsServer"
      sku       = var.image-sku
      version   = "latest"
    }
  }