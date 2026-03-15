resourcegroup = "module-rg"
location = "eastus"
# vNet Inputs
vnet-name = "vnet-test-01"
address_space = "10.0.0.0/24"
#subnet details
subnet_name = "snet-testing-01"
address_prefixes = "10.0.0.0/24"
#vm config details
vm_config = {
  "windows-vm" = {
    vmsize = "Standard_D2s_v3"
    admin_username = "vmadmin"
    admin_password = "Welcome@12345"
    nic_count = 2
    image-sku = "2022-datacenter"
  }
  "windows-vm2" = {
    vmsize = "Standard_D2s_v3"
    admin_username = "azureadmin"
    admin_password = "Welcome@12345"
    nic_count = 2
    image-sku = "2019-datacenter"
  }
}