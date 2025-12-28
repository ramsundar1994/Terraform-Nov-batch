#RG Details
resource_group = {
  resource_group_name = "testing-rg"
  location            = "eastasia"
}
#vnet details
vnet = {
  name          = "vnet-testing-01"
  address_space = ["10.0.0.0/24", "10.0.1.0/24"]
}
subnet = {
  name             = "subnet-A"
  address_prefixes = ["10.0.0.0/24", "10.0.1.0/24"]
}
nic = ["vm-nic1", "vm-nic2"]
vm = {
  name           = "azure-vm-01"
  size           = "Standard_D2s_v3"
  admin_username = "vmadmin"
  admin_password = "Welcome@12345"
}
osdisk = "Premium_LRS"
source_image = {
  offer     = "WindowsServer"
  sku       = "2022-datacenter"
  version   = "latest"
  publisher = "MicrosoftWindowsServer"
}
